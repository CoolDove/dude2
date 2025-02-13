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
TypeDefines_rl :: struct {
	tex2d : TypeDefine,
}
rltypes : TypeDefines_rl



s7bind_rl :: proc() {
	rltypes.tex2d = { s7.make_c_type(scm, "tex2d"), "tex2d" }
	s7.c_type_set_gc_free(scm, rltypes.tex2d.id, __api_gcfree_rltex2d)

	s7.define_function(scm, "rl/get-mouse-pos", __api_get_mouse_pos, 0, 0, false, "")
	s7.define_function(scm, "rl/get-mousebtn-down", __api_get_mousebtn_down, 1, 0, false, "")
	s7.define_function(scm, "rl/get-keyboard-down", __api_get_keyboard_down, 1, 0, false, "")
	s7.define_function(scm, "rl/get-keyboard-up", __api_get_keyboard_up, 1, 0, false, "")
	s7.define_function(scm, "rl/get-keyboard-pressed", __api_get_keyboard_pressed, 1, 0, false, "")
	s7.define_function(scm, "rl/get-keyboard-released", __api_get_keyboard_released, 1, 0, false, "")
	s7.define_function(scm, "rl/draw-rectangle", __api_draw_rectangle, 2, 0, false, "")
	s7.define_function(scm, "rl/draw-texture", __api_draw_texture, 6, 0, false, "")
	s7.define_function(scm, "rl/draw-triangle", __api_draw_triangle, 4, 0, false, "")
	s7.define_function(scm, "rl/draw-text", __api_draw_text, 5, 0, false, "")
	s7.define_function(scm, "rl/measure-text", __api_measure_text, 3, 0, false, "")
	s7.define_function(scm, "rl/load-texture", __api_load_texture, 1, 0, false, "")
	s7.define_function(scm, "rl/get-screen-size", __api_get_screen_size, 0, 0, false, "")
	s7.define_function(scm, "rl/gui-button", __api_gui_button, 2, 0, false, "")
	s7.define_function(scm, "rl/gui-lbbutton", __api_gui_lbbutton, 2, 0, false, "")
	s7.define_function(scm, "rl/tex2d.w", __api_tex2d_get_w, 1, 0, false, "")
	s7.define_function(scm, "rl/tex2d.h", __api_tex2d_get_h, 1, 0, false, "")

}



@(private="file")
__api_get_mouse_pos :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "rl/get-mouse-pos")
	if reader._err != nil do return reader._err.?

	ret := rl.GetMousePosition()
	return make_s7vector_f(scm, auto_cast ret.x, auto_cast ret.y, )
}

@(private="file")
__api_get_mousebtn_down :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "rl/get-mousebtn-down")
	arg0 := reader->cstr()
	if reader._err != nil do return reader._err.?

	btn := arg0
	ret := false
	if btn == "L" || btn == "left" || btn == "Left" || btn == "LEFT" {
		ret = rl.IsMouseButtonDown(.LEFT)
	} else if btn == "R" || btn == "right" || btn == "Right" || btn == "RIGHT" {
		ret = rl.IsMouseButtonDown(.RIGHT)
	} else if btn == "M" || btn == "middle" || btn == "Middle" || btn == "MIDDLE" {
		ret = rl.IsMouseButtonDown(.MIDDLE)
	}
	return s7.make_boolean(scm, auto_cast ret)
}

@(private="file")
__api_get_keyboard_down :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "rl/get-keyboard-down")
	arg0 := reader->cstr()
	if reader._err != nil do return reader._err.?

	ret := rl.IsKeyDown(parse_key(arg0))
	return s7.make_boolean(scm, auto_cast ret)
}

@(private="file")
__api_get_keyboard_up :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "rl/get-keyboard-up")
	arg0 := reader->cstr()
	if reader._err != nil do return reader._err.?

	ret := rl.IsKeyUp(parse_key(arg0))
	return s7.make_boolean(scm, auto_cast ret)
}

@(private="file")
__api_get_keyboard_pressed :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "rl/get-keyboard-pressed")
	arg0 := reader->cstr()
	if reader._err != nil do return reader._err.?

	ret := rl.IsKeyPressed(parse_key(arg0))
	return s7.make_boolean(scm, auto_cast ret)
}

@(private="file")
__api_get_keyboard_released :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "rl/get-keyboard-released")
	arg0 := reader->cstr()
	if reader._err != nil do return reader._err.?

	ret := rl.IsKeyReleased(parse_key(arg0))
	return s7.make_boolean(scm, auto_cast ret)
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
__api_draw_triangle :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "rl/draw-triangle")
	arg0 : rl.Vector2; reader->vectorf32(arg0[:])
	arg1 : rl.Vector2; reader->vectorf32(arg1[:])
	arg2 : rl.Vector2; reader->vectorf32(arg2[:])
	arg3 : rl.Color; reader->vectoru8(arg3[:])
	if reader._err != nil do return reader._err.?

	rl.DrawTriangle(arg0, arg1, arg2, arg3)
	return s7.make_boolean(scm, true)
}

@(private="file")
__api_draw_text :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "rl/draw-text")
	arg0 := reader->cstr()
	arg1 : rl.Vector2; reader->vectorf32(arg1[:])
	arg2 := reader->numberf32()
	arg3 := reader->numberf32()
	arg4 : rl.Color; reader->vectoru8(arg4[:])
	if reader._err != nil do return reader._err.?

	rl.DrawTextEx(dude_font, arg0, arg1, arg2, arg3, arg4)
	return s7.make_boolean(scm, true)
}

@(private="file")
__api_measure_text :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "rl/measure-text")
	arg0 := reader->cstr()
	arg1 := reader->numberf32()
	arg2 := reader->numberf32()
	if reader._err != nil do return reader._err.?

	ret := rl.MeasureTextEx(dude_font, arg0, arg1, arg2)
	return make_s7vector_f(scm, auto_cast ret.x, auto_cast ret.y, )
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
__api_get_screen_size :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "rl/get-screen-size")
	if reader._err != nil do return reader._err.?

	ret :rl.Vector2= {auto_cast rl.GetScreenWidth(), auto_cast rl.GetScreenHeight()}
	return make_s7vector_f(scm, auto_cast ret.x, auto_cast ret.y, )
}

@(private="file")
__api_gui_button :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "rl/gui-button")
	arg0 := reader->cstr()
	arg1 : rl.Rectangle; reader->vectorf32(slice.from_ptr(cast(^f32)&arg1, 4))
	if reader._err != nil do return reader._err.?

	ret := rl.GuiButton(arg1, arg0)
	return s7.make_boolean(scm, auto_cast ret)
}

@(private="file")
__api_gui_lbbutton :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "rl/gui-lbbutton")
	arg0 := reader->cstr()
	arg1 : rl.Rectangle; reader->vectorf32(slice.from_ptr(cast(^f32)&arg1, 4))
	if reader._err != nil do return reader._err.?

	ret := rl.GuiLabelButton(arg1, arg0)
	return s7.make_boolean(scm, auto_cast ret)
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

@(private="file")
__api_gcfree_rltex2d :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	ptr := s7.c_object_value(ptr)
	tex:= cast(^rl.Texture2D)ptr; rl.UnloadTexture(tex^); free(tex)
	return {}
}


@(private="file")
parse_key :: proc (key: cstring) -> (k: rl.KeyboardKey, ok: bool) #optional_ok {
	key := cast(string)key
	if len(key) == 0 do return {}, false
	if len(key) == 1 && key[0] > 64 && key[0] < 91 {
		return auto_cast key[0], true
	} else if len(key) > 1 && (key[0] == 'F' || key[0] == 'f') {
		l : int
		if fkey, ok := strconv.parse_int(key[1:], 0, &l); ok && (l == len(key)-1) {
			return auto_cast (290 + (fkey-1)), true
		}
	}
	return {}, false
}
