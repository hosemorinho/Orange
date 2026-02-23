package main

import (
	"bytes"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"testing"
)

func resetConfigSessionStateForTest() {
	sessionsMu.Lock()
	defer sessionsMu.Unlock()

	for id, session := range activeSessions {
		clearSessionData(session)
		delete(activeSessions, id)
	}
	for id, config := range committedConfigs {
		zeroBytes(config.data)
		delete(committedConfigs, id)
	}
}

func TestConfigSessionCommitAndConsume(t *testing.T) {
	resetConfigSessionStateForTest()

	content := []byte("port: 7890\nsocks-port: 7891\nmode: rule\n")
	hash := sha256.Sum256(content)
	expected := hex.EncodeToString(hash[:])

	sessionID, err := beginConfigSession()
	if err != nil {
		t.Fatalf("beginConfigSession failed: %v", err)
	}

	first := base64.StdEncoding.EncodeToString(content[:18])
	second := base64.StdEncoding.EncodeToString(content[18:])

	if err := appendConfigChunk(sessionID, first, 0); err != nil {
		t.Fatalf("append chunk 0 failed: %v", err)
	}
	if err := appendConfigChunk(sessionID, second, 1); err != nil {
		t.Fatalf("append chunk 1 failed: %v", err)
	}

	if err := commitConfigSession(sessionID, expected); err != nil {
		t.Fatalf("commitConfigSession failed: %v", err)
	}

	got, err := consumeCommittedConfig(sessionID)
	if err != nil {
		t.Fatalf("consumeCommittedConfig failed: %v", err)
	}
	defer zeroBytes(got)

	if !bytes.Equal(got, content) {
		t.Fatalf("consumed config mismatch")
	}
}

func TestConfigSessionRejectsBadSha(t *testing.T) {
	resetConfigSessionStateForTest()

	content := []byte("mixed-port: 7890\n")
	sessionID, err := beginConfigSession()
	if err != nil {
		t.Fatalf("beginConfigSession failed: %v", err)
	}

	chunk := base64.StdEncoding.EncodeToString(content)
	if err := appendConfigChunk(sessionID, chunk, 0); err != nil {
		t.Fatalf("appendConfigChunk failed: %v", err)
	}

	if err := commitConfigSession(sessionID, "deadbeef"); err == nil {
		t.Fatalf("expected sha mismatch error")
	}

	if _, err := consumeCommittedConfig(sessionID); err == nil {
		t.Fatalf("consumeCommittedConfig should fail after bad commit")
	}
}

func TestAppendConfigChunkRejectsNegativeIndex(t *testing.T) {
	resetConfigSessionStateForTest()

	sessionID, err := beginConfigSession()
	if err != nil {
		t.Fatalf("beginConfigSession failed: %v", err)
	}
	chunk := base64.StdEncoding.EncodeToString([]byte("a: 1\n"))

	if err := appendConfigChunk(sessionID, chunk, -1); err == nil {
		t.Fatalf("expected negative index error")
	}
}

func TestReadConfigBytesFromSessionSource(t *testing.T) {
	resetConfigSessionStateForTest()

	content := []byte("dns:\n  enable: true\n")
	hash := sha256.Sum256(content)
	expected := hex.EncodeToString(hash[:])

	sessionID, err := beginConfigSession()
	if err != nil {
		t.Fatalf("beginConfigSession failed: %v", err)
	}
	chunk := base64.StdEncoding.EncodeToString(content)
	if err := appendConfigChunk(sessionID, chunk, 0); err != nil {
		t.Fatalf("appendConfigChunk failed: %v", err)
	}
	if err := commitConfigSession(sessionID, expected); err != nil {
		t.Fatalf("commitConfigSession failed: %v", err)
	}

	got, err := readConfigBytes(sessionConfigPrefix + sessionID)
	if err != nil {
		t.Fatalf("readConfigBytes(session://) failed: %v", err)
	}
	defer zeroBytes(got)
	if !bytes.Equal(got, content) {
		t.Fatalf("session source content mismatch")
	}
}
