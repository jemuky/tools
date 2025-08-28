package main

import "core:testing"

@(test)
test_handle :: proc(_: ^testing.T) {
	sixiangs := [6]SiXiang{.少阳, .少阳, .少阴, .少阳, .老阳, .老阳}
	handle_from_sixiang(&sixiangs)
}
