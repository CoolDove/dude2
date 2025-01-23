package main

import "base:runtime"
import "core:fmt"
import "core:mem"
import "core:c"
import rl "vendor:raylib"
import fe "odin-fe"

fe_ctx : ^fe.Context

main :: proc() {
	fe_buffer_size := 32*1024*1024
	fe_buffer, err := mem.alloc_bytes(fe_buffer_size)
	if err != nil {
		fmt.printf("Failed to allocate memory for fe interpreter. {}\n", err)
		return
	}
	fe_ctx = fe.open(raw_data(fe_buffer), auto_cast fe_buffer_size)
	fe_gc := fe.savegc(fe_ctx)

	src := "(print \"hello, world\")"
	obj := dude_read_fe(src)
	fe.eval(fe_ctx, obj)

	fe.restoregc(fe_ctx, fe_gc)
	fe.close(fe_ctx)
	mem.free_bytes(fe_buffer)
}

dude_read_fe :: proc(src: string) -> ^fe.Object {
	reader :StringReader= { src, 0 }
	return fe.read(fe_ctx, _fe_string_reader, &reader)
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
