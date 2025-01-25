package main

import "base:runtime"
import "core:fmt"
import "core:mem"
import "core:time"
import "core:c"
import "core:c/libc"
import "core:strings"
import "core:os"
import "core:path/filepath"
import fe "odin-fe"


_string_buff : [4096]u8

_str_substring :: proc "c" (ctx:^fe.Context, arg: ^fe.Object) -> ^fe.Object {
	context = runtime.default_context()
	arg := arg
	length := fe.tostring(ctx, fe.nextarg(ctx, &arg), raw_data(_string_buff[:]), len(_string_buff))
	str := cast(string)_string_buff[:length]
	start := cast(int)fe.tonumber(ctx, fe.nextarg(ctx, &arg))
	end := cast(int)fe.tonumber(ctx, fe.nextarg(ctx, &arg))

	sub := cast(cstring)&_string_buff[start]
	_string_buff[end+1] = 0 // manually set a terminator
	fmt.printf("cstring: {}\n", sub)

	return fe.string(ctx, sub)
}
