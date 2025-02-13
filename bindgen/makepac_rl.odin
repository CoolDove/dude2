package bindgen

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"
import "core:strconv"
import "core:math/linalg"
import rl "vendor:raylib"


makepac_rl :: proc() -> PacDefine {
	pac_raylib := pac_make("rl") 
	{
		func : ^FuncDefine
		type : ^TypeDefine

		type = append_type(&pac_raylib, "tex2d", "rl.Texture2D", {"w", "arg0.width", s7v_real}, {"h", "arg0.height", s7v_real})
		type.gcfree = "tex:= cast(^rl.Texture2D)ptr; rl.UnloadTexture(tex^); free(tex)"

		func = append_function(&pac_raylib, "get-mouse-pos", "")
		func.execute = "ret := rl.GetMousePosition()"
		func.return_value = s7v_retvec2

		func = append_function(&pac_raylib, "get-mousebtn-down", "", arg_cstr)
		func.execute = `btn := arg0
	ret := false
	if btn == "L" || btn == "left" || btn == "Left" || btn == "LEFT" {
		ret = rl.IsMouseButtonDown(.LEFT)
	} else if btn == "R" || btn == "right" || btn == "Right" || btn == "RIGHT" {
		ret = rl.IsMouseButtonDown(.RIGHT)
	} else if btn == "M" || btn == "middle" || btn == "Middle" || btn == "MIDDLE" {
		ret = rl.IsMouseButtonDown(.MIDDLE)
	}`
		func.return_value = S7Value_SimpleMake.boolean

		func = append_function(&pac_raylib, "get-keyboard-down", "", arg_cstr)
		func.execute = "ret := rl.IsKeyDown(parse_key(arg0))"
		func.return_value = S7Value_SimpleMake.boolean

		func = append_function(&pac_raylib, "get-keyboard-up", "", arg_cstr)
		func.execute = "ret := rl.IsKeyUp(parse_key(arg0))"
		func.return_value = S7Value_SimpleMake.boolean

		func = append_function(&pac_raylib, "get-keyboard-pressed", "", arg_cstr)
		func.execute = "ret := rl.IsKeyPressed(parse_key(arg0))"
		func.return_value = S7Value_SimpleMake.boolean

		func = append_function(&pac_raylib, "get-keyboard-released", "", arg_cstr)
		func.execute = "ret := rl.IsKeyReleased(parse_key(arg0))"
		func.return_value = S7Value_SimpleMake.boolean

		append_function(&pac_raylib, "draw-rectangle", "", 
			arg_rectangle, arg_color
		).execute = "rl.DrawRectangleV({arg0.x, arg0.y}, {arg0.width, arg0.height}, arg1)"

		append_function(&pac_raylib, "draw-texture", "",
			arg_texture, arg_rectangle, arg_rectangle, arg_vec2, arg_float, arg_color
		).execute = "rl.DrawTexturePro(arg0^, arg1, arg2, arg3, arg4, arg5)"

		append_function(&pac_raylib, "draw-triangle", "",
			arg_vec2, arg_vec2, arg_vec2, arg_color
		).execute = "rl.DrawTriangle(arg0, arg1, arg2, arg3)"

		append_function(&pac_raylib, "draw-text", "",
			arg_cstr, arg_vec2, arg_float, arg_float, arg_color
		).execute = "rl.DrawTextEx(dude_font, arg0, arg1, arg2, arg3, arg4)"

		func = append_function(&pac_raylib, "measure-text", "", 
			arg_cstr, arg_float, arg_float
		)
		func.execute = "ret := rl.MeasureTextEx(dude_font, arg0, arg1, arg2)"
		func.return_value = s7v_retvec2

		func = append_function(&pac_raylib, "load-texture", "",
			arg_cstr
		)
		func.execute = "ret := new(rl.Texture2D)\n\tret^ = rl.LoadTexture(arg0)\n"
		func.return_value = cast(S7Value_CObj)"tex2d"

		// ** Window
		func = append_function(&pac_raylib, "get-screen-size", "")
		func.execute = "ret :rl.Vector2= {auto_cast rl.GetScreenWidth(), auto_cast rl.GetScreenHeight()}"
		func.return_value = s7v_retvec2

		// ** GUI
		func = append_function(&pac_raylib, "gui-button", "",
			arg_cstr, arg_rectangle
		)
		func.execute = "ret := rl.GuiButton(arg1, arg0)"
		func.return_value = S7Value_SimpleMake.boolean

		func = append_function(&pac_raylib, "gui-lbbutton", "",
			arg_cstr, arg_rectangle
		)
		func.execute = "ret := rl.GuiLabelButton(arg1, arg0)"
		func.return_value = S7Value_SimpleMake.boolean
	}
	pac_raylib.extra_code = _extra_code
	return pac_raylib
}

@(private="file")
_extra_code :cstring= `
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
`
