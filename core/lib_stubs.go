//go:build cgo && !android

package main

/*
#include <stdlib.h>
*/
import "C"
import "unsafe"

// Stub implementations for non-Android CGO builds (desktop).
// On desktop, the socket server path (server.go) is used instead,
// so these are never called at runtime.

func protect(_ unsafe.Pointer, _ int) {}

func resolveProcess(_ unsafe.Pointer, _ int, _, _ string, _ int) string {
	return ""
}

func invokeResult(callback unsafe.Pointer, data string) {
	s := C.CString(data)
	defer C.free(unsafe.Pointer(s))
	// Desktop CGO builds use the socket server path; this stub is a no-op.
	_ = s
}

func releaseObject(_ unsafe.Pointer) {}

func takeCString(s *C.char) string {
	gs := C.GoString(s)
	C.free(unsafe.Pointer(s))
	return gs
}
