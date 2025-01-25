package main

import "base:runtime"
import "core:fmt"
import "core:mem"
import "core:time"
import "core:c"
import "core:strings"
import "core:dynlib"
import "core:c/libc"
import "core:os"
import "core:path/filepath"
import rl "vendor:raylib"
import fe "odin-fe"

import ansi "ansi_code"

fe_ctx : ^fe.Context
fe_gc : c.int

dude_fe_open :: proc(ptr: rawptr, size: c.int) {
	fe_ctx = fe.open(ptr, size)
	fe_ctx.handlers.error = _fe_error_handler
	fe_gc = fe.savegc(fe_ctx)
}
dude_fe_close :: proc() {
	fe.close(fe_ctx)
}

dude_fe_bind_cfunc :: proc(symname: cstring, cfunc: fe.CFunc) {
	fe.set(fe_ctx, fe.symbol(fe_ctx, symname), fe.cfunc(fe_ctx, cfunc))
}

dude_fe_eval_all :: proc(src: string) -> ^fe.Object {
	reader :StringReader= { src, 0 }
	obj := fe.read(fe_ctx, _fe_string_reader, &reader)
	ret : ^fe.Object
	for ; obj!=nil; obj = fe.read(fe_ctx, _fe_string_reader, &reader) {
		ret = fe.eval(fe_ctx, obj)
	}
	fe.restoregc(fe_ctx, fe_gc)
	return ret
}

dude_fe_eval :: proc(src: string) -> ^fe.Object {
	obj := dude_fe_read(src)
	ret := fe.eval(fe_ctx, obj)
	fe.restoregc(fe_ctx, fe_gc)
	return ret
}

dude_fe_read :: proc(src: string) -> ^fe.Object {
	reader :StringReader= { src, 0 }
	return fe.read(fe_ctx, _fe_string_reader, &reader)
}

fe_tostring :: proc(ctx:^fe.Context, obj: ^fe.Object, allocator:= context.temp_allocator) -> string {
	context.allocator = allocator
	@static _buff : [4096]u8
	str := cast(string)_buff[:fe.tostring(ctx, obj, &_buff[0], len(_buff))]
	return strings.clone(str)
}
fe_tocstring :: proc(ctx:^fe.Context, obj: ^fe.Object, allocator:= context.temp_allocator) -> cstring {
	context.allocator = allocator
	@static _buff : [4096]u8
	str := cast(string)_buff[:fe.tostring(ctx, obj, &_buff[0], len(_buff))]
	return strings.clone_to_cstring(str)
}

@(private="file")
_fe_error_handler :: proc "c" (ctx:^fe.Context, err:cstring, cl:^fe.Object) {
	context = runtime.default_context()
	// fmt.eprintf("ERROR:\n{}\n", err)
	@static buf : [512]u8
	objmsg := buf[:fe.tostring(fe_ctx, fe.car(fe_ctx, cl), raw_data(buf[:]), len(buf))]
	ansi.color_ansi(.Red)
	fmt.printf("ERROR")
	fmt.printf(" {}\n", err)
	fmt.printf("!> {}\n", cast(string)objmsg)
	ansi.color_ansi(.Default)
	_error_recover()
}

@(private="file")
_error_recover :: proc() {
	fe.hack_finish_error_handle()
}

@(private="file")
_fe_string_reader :: proc "c" (ctx:^fe.Context, udata:rawptr) -> c.char {
	context = runtime.default_context()
	reader := cast(^StringReader)udata
	if reader.ptr<len(reader.text) {
		ptr := reader.ptr
		reader.ptr += 1
		return reader.text[ptr];
	} else {
		return 0
	}
}
StringReader :: struct {
	text : string,
	ptr : int,
}
