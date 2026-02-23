package main

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"fmt"
	"sort"
	"strings"
	"sync"
	"time"
)

const (
	sessionTTL      = 2 * time.Minute
	maxSessionSize  = 10 * 1024 * 1024 // 10 MB
	cleanupInterval = 30 * time.Second
)

type configChunk struct {
	index int
	data  []byte
}

type configSession struct {
	id        string
	chunks    []configChunk
	createdAt time.Time
	totalSize int
}

type committedConfig struct {
	data      []byte
	createdAt time.Time
}

var (
	sessionsMu       sync.Mutex
	activeSessions   = make(map[string]*configSession)
	committedConfigs = make(map[string]*committedConfig)
	cleanupOnce      sync.Once
)

func zeroBytes(bytes []byte) {
	for i := range bytes {
		bytes[i] = 0
	}
}

func clearSessionData(session *configSession) {
	for i := range session.chunks {
		zeroBytes(session.chunks[i].data)
		session.chunks[i].data = nil
	}
	session.chunks = nil
	session.totalSize = 0
}

func generateSessionId() (string, error) {
	b := make([]byte, 16)
	_, err := rand.Read(b)
	if err != nil {
		return "", err
	}
	return hex.EncodeToString(b), nil
}

func startSessionCleanup() {
	cleanupOnce.Do(func() {
		go func() {
			ticker := time.NewTicker(cleanupInterval)
			defer ticker.Stop()
			for range ticker.C {
				cleanExpiredSessions()
			}
		}()
	})
}

func cleanExpiredSessions() {
	sessionsMu.Lock()
	defer sessionsMu.Unlock()
	now := time.Now()
	for id, s := range activeSessions {
		if now.Sub(s.createdAt) > sessionTTL {
			clearSessionData(s)
			delete(activeSessions, id)
		}
	}
	for id, c := range committedConfigs {
		if now.Sub(c.createdAt) > sessionTTL {
			zeroBytes(c.data)
			c.data = nil
			delete(committedConfigs, id)
		}
	}
}

func beginConfigSession() (string, error) {
	startSessionCleanup()
	sessionsMu.Lock()
	defer sessionsMu.Unlock()

	id, err := generateSessionId()
	if err != nil {
		return "", fmt.Errorf("failed to generate session id: %w", err)
	}
	activeSessions[id] = &configSession{
		id:        id,
		chunks:    make([]configChunk, 0),
		createdAt: time.Now(),
	}
	return id, nil
}

func appendConfigChunk(sessionId string, chunkBase64 string, index int) error {
	if sessionId == "" {
		return errors.New("session id is required")
	}
	if index < 0 {
		return errors.New("chunk index must be >= 0")
	}
	decoded, err := base64.StdEncoding.DecodeString(chunkBase64)
	if err != nil {
		return fmt.Errorf("base64 decode error: %w", err)
	}

	sessionsMu.Lock()
	defer sessionsMu.Unlock()

	session, ok := activeSessions[sessionId]
	if !ok {
		zeroBytes(decoded)
		return errors.New("session not found or expired")
	}
	if time.Since(session.createdAt) > sessionTTL {
		clearSessionData(session)
		delete(activeSessions, sessionId)
		zeroBytes(decoded)
		return errors.New("session expired")
	}
	if session.totalSize+len(decoded) > maxSessionSize {
		clearSessionData(session)
		delete(activeSessions, sessionId)
		zeroBytes(decoded)
		return fmt.Errorf("config exceeds max size %d bytes", maxSessionSize)
	}

	for _, existing := range session.chunks {
		if existing.index == index {
			zeroBytes(decoded)
			return fmt.Errorf("duplicate chunk index %d", index)
		}
	}

	session.chunks = append(session.chunks, configChunk{index: index, data: decoded})
	session.totalSize += len(decoded)
	return nil
}

func commitConfigSession(sessionId string, expectedSha256 string) error {
	if sessionId == "" {
		return errors.New("session id is required")
	}
	if expectedSha256 == "" {
		return errors.New("sha256 is required")
	}

	// Extract session under lock, release before CPU-intensive work
	sessionsMu.Lock()
	session, ok := activeSessions[sessionId]
	if !ok {
		sessionsMu.Unlock()
		return errors.New("session not found or expired")
	}
	delete(activeSessions, sessionId)
	expired := time.Since(session.createdAt) > sessionTTL
	sessionsMu.Unlock()

	if expired {
		clearSessionData(session)
		return errors.New("session expired")
	}

	// Sort chunks by index and assemble (no lock needed)
	chunks := make([]configChunk, len(session.chunks))
	copy(chunks, session.chunks)
	sort.Slice(chunks, func(i, j int) bool {
		return chunks[i].index < chunks[j].index
	})
	assembled := make([]byte, 0, session.totalSize)
	for _, chunk := range chunks {
		assembled = append(assembled, chunk.data...)
	}

	// Verify SHA-256 (no lock needed)
	hash := sha256.Sum256(assembled)
	actualHash := hex.EncodeToString(hash[:])
	if !strings.EqualFold(actualHash, expectedSha256) {
		zeroBytes(assembled)
		clearSessionData(session)
		return fmt.Errorf("sha256 mismatch: expected %s, got %s", expectedSha256, actualHash)
	}

	// Store committed config under lock
	sessionsMu.Lock()
	committedConfigs[sessionId] = &committedConfig{
		data:      assembled,
		createdAt: time.Now(),
	}
	sessionsMu.Unlock()
	clearSessionData(session)
	return nil
}

func consumeCommittedConfig(sessionId string) ([]byte, error) {
	sessionsMu.Lock()
	defer sessionsMu.Unlock()

	config, ok := committedConfigs[sessionId]
	if !ok {
		return nil, errors.New("committed config not found or expired")
	}
	delete(committedConfigs, sessionId)
	return config.data, nil
}
