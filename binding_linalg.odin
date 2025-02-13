package main
// GENERATED FILE, DONT MODIFY
import "base:runtime"
import "core:c"
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:os"
import "core:math/linalg"
import rl "vendor:raylib"
import "s7"
TypeDefines_linalg :: struct {
}
linalgtypes : TypeDefines_linalg



s7bind_linalg :: proc() {
	s7.define_function(scm, "linalg/vec2-length", __api_vec2_length, 1, 0, false, "")
	s7.define_function(scm, "linalg/vec2-distance", __api_vec2_distance, 2, 0, false, "")
	s7.define_function(scm, "linalg/vec2-add", __api_vec2_add, 2, 0, false, "")
	s7.define_function(scm, "linalg/vec2-subtract", __api_vec2_subtract, 2, 0, false, "")
	s7.define_function(scm, "linalg/vec2-scale", __api_vec2_scale, 2, 0, false, "")

}



@(private="file")
__api_vec2_length :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "linalg/vec2-length")
	arg0 : rl.Vector2; reader->vectorf32(arg0[:])
	if reader._err != nil do return reader._err.?

	ret := linalg.length(arg0)
	return s7.make_real(scm, auto_cast ret)
}

@(private="file")
__api_vec2_distance :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "linalg/vec2-distance")
	arg0 : rl.Vector2; reader->vectorf32(arg0[:])
	arg1 : rl.Vector2; reader->vectorf32(arg1[:])
	if reader._err != nil do return reader._err.?

	ret := linalg.distance(arg0, arg1)
	return s7.make_real(scm, auto_cast ret)
}

@(private="file")
__api_vec2_add :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "linalg/vec2-add")
	arg0 : rl.Vector2; reader->vectorf32(arg0[:])
	arg1 : rl.Vector2; reader->vectorf32(arg1[:])
	if reader._err != nil do return reader._err.?

	ret := arg0 + arg1
	return make_s7vector_f(scm, auto_cast ret.x, auto_cast ret.y, )
}

@(private="file")
__api_vec2_subtract :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "linalg/vec2-subtract")
	arg0 : rl.Vector2; reader->vectorf32(arg0[:])
	arg1 : rl.Vector2; reader->vectorf32(arg1[:])
	if reader._err != nil do return reader._err.?

	ret := arg0 - arg1
	return make_s7vector_f(scm, auto_cast ret.x, auto_cast ret.y, )
}

@(private="file")
__api_vec2_scale :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "linalg/vec2-scale")
	arg0 : rl.Vector2; reader->vectorf32(arg0[:])
	arg1 := reader->numberf32()
	if reader._err != nil do return reader._err.?

	ret := arg1 * arg0
	return make_s7vector_f(scm, auto_cast ret.x, auto_cast ret.y, )
}

