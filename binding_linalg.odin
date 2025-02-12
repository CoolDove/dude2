package main
// GENERATED FILE, DONT MODIFY
import "base:runtime"
import "core:c"
import "core:fmt"
import "core:slice"
import "core:math/linalg"
import rl "vendor:raylib"
import "s7"
TypeDefines_linalg :: struct {
}
linalgtypes : TypeDefines_linalg



s7bind_linalg :: proc() {
	s7.define_function(scm, "linalg/vec2-length", __api_vec2_length, 1, 0, false, "")

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

