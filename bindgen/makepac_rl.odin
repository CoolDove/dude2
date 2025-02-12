package bindgen

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"
import "core:math/linalg"
import rl "vendor:raylib"


makepac_rl :: proc() -> PacDefine {
	pac_raylib := pac_make("rl") 
	{
		append_type(&pac_raylib, "tex2d", "rl.Texture2D", {"w", "arg0.width", s7v_real}, {"h", "arg0.height", s7v_real})

		func : ^FuncDefine
		func = append_function(&pac_raylib, "get-mouse-pos", "")
		func.execute = "ret := rl.GetMousePosition()"
		func.return_value = s7v_retvec2

		func = append_function(&pac_raylib, "get-mousebtn-down", "", arg_cstr)
		rl.IsMouseButtonDown(.LEFT)
		func.execute = `btn := arg0
	ret := false
	if btn == "L" || btn == "left" || btn == "Left" || btn == "LEFT" {
		ret = rl.IsMouseButtonDown(.LEFT)
	} else if btn == "R" || btn == "right" || btn == "Right" || btn == "RIGHT" {
		ret = rl.IsMouseButtonDown(.RIGHT)
	} else if btn == "M" || btn == "middle" || btn == "Middle" || btn == "MIDDLE" {
		ret = rl.IsMouseButtonDown(.MIDDLE)
	}
`
		func.return_value = S7Value_SimpleMake.boolean

		append_function(&pac_raylib, "draw-rectangle", "", 
			arg_rectangle, arg_color
		).execute = "rl.DrawRectangleV({arg0.x, arg0.y}, {arg0.width, arg0.height}, arg1)"

		append_function(&pac_raylib, "draw-texture", "",
			arg_texture, arg_rectangle, arg_rectangle, arg_vec2, arg_float, arg_color
		).execute = "rl.DrawTexturePro(arg0^, arg1, arg2, arg3, arg4, arg5)"

		append_function(&pac_raylib, "draw-text", "",
			arg_cstr, arg_vec2, arg_float, arg_float, arg_color
		).execute = "rl.DrawTextEx(rl.GetFontDefault(), arg0, arg1, arg2, arg3, arg4)"

		func = append_function(&pac_raylib, "load-texture", "",
			arg_cstr
		)
		func.execute = "ret := new(rl.Texture2D)\n\tret^ = rl.LoadTexture(arg0)\n"
		func.return_value = cast(S7Value_CObj)"tex2d"
	}
	return pac_raylib
}
