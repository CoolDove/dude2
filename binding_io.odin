package main
// GENERATED FILE, DONT MODIFY
import "base:runtime"
import "core:c"
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:strconv"
import "core:os"
import "core:math/linalg"
import rl "vendor:raylib"
import "s7"
TypeDefines_io :: struct {
}
iotypes : TypeDefines_io



s7bind_io :: proc() {
	s7.define_function(scm, "io/read-string-file", __api_read_string_file, 1, 0, false, "")

}



@(private="file")
__api_read_string_file :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "io/read-string-file")
	arg0 := reader->cstr()
	if reader._err != nil do return reader._err.?

	
	str, ok := os.read_entire_file(auto_cast arg0, context.temp_allocator)
	ret :cstring
	if ok do ret = strings.clone_to_cstring(transmute(string)str, context.temp_allocator)
	else do ret = ""
	return s7.make_string(scm, auto_cast ret)
}

