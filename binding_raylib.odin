package main
// GENERATED FILE, DONT MODIFY
import "base:runtime"
import "core:c"
import "core:fmt"
import "core:slice"
import "core:math/linalg"
import rl "vendor:raylib"
import "s7"
TypeDefines_rl :: struct {
	tex2d : TypeDefine,
}
rltypes : TypeDefines_rl



s7bind_rl :: proc() {
	rltypes.tex2d = { s7.make_c_type(scm, "tex2d"), "tex2d" }
	s7.define_function(scm, "rl/draw-rectangle", __api_draw_rectangle, 2, 0, false, "")
	s7.define_function(scm, "rl/draw-texture", __api_draw_texture, 6, 0, false, "")
	s7.define_function(scm, "rl/load-texture", __api_load_texture, 1, 0, false, "")
	s7.define_function(scm, "rl/tex2d.w", __api_tex2d_get_w, 1, 0, false, "")
	s7.define_function(scm, "rl/tex2d.h", __api_tex2d_get_h, 1, 0, false, "")

}



@(private="file")
__api_draw_rectangle :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "rl/draw-rectangle")
	arg0 : rl.Rectangle; reader->vectorf32(slice.from_ptr(cast(^f32)&arg0, 4))
	arg1 : rl.Color; reader->vectoru8(arg1[:])
	if reader._err != nil do return reader._err.?

	rl.DrawRectangleV({arg0.x, arg0.y}, {arg0.width, arg0.height}, arg1)
	return s7.make_boolean(scm, true)
}

@(private="file")
__api_draw_texture :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "rl/draw-texture")
	arg0 := cast(^rl.Texture2D)reader->cobj(rltypes.tex2d)
	arg1 : rl.Rectangle; reader->vectorf32(slice.from_ptr(cast(^f32)&arg1, 4))
	arg2 : rl.Rectangle; reader->vectorf32(slice.from_ptr(cast(^f32)&arg2, 4))
	arg3 : rl.Vector2; reader->vectorf32(arg3[:])
	arg4 := reader->numberf32()
	arg5 : rl.Color; reader->vectoru8(arg5[:])
	if reader._err != nil do return reader._err.?

	rl.DrawTexturePro(arg0^, arg1, arg2, arg3, arg4, arg5)
	return s7.make_boolean(scm, true)
}

@(private="file")
__api_load_texture :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "rl/load-texture")
	arg0 := reader->cstr()
	if reader._err != nil do return reader._err.?

	
	ret := new(rl.Texture2D)
	ret^ = rl.LoadTexture(arg0)
	return s7.make_c_object(scm, rltypes.tex2d.id, ret)
}

@(private="file")
__api_tex2d_get_w :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "rl/tex2d.w")
	arg0 := cast(^rl.Texture2D)reader->cobj(rltypes.tex2d)
	if reader._err != nil do return reader._err.?

	ret := arg0.width
	return s7.make_real(scm, auto_cast ret)
}

@(private="file")
__api_tex2d_get_h :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "rl/tex2d.h")
	arg0 := cast(^rl.Texture2D)reader->cobj(rltypes.tex2d)
	if reader._err != nil do return reader._err.?

	ret := arg0.height
	return s7.make_real(scm, auto_cast ret)
}

