package main

import "base:runtime"
import "core:c"
import "core:fmt"
import rl "vendor:raylib"
import fe "odin-fe"

_api_is_key_down :: proc "c" (ctx:^fe.Context, arg: ^fe.Object) -> ^fe.Object {
	context = runtime.default_context()
	arg := arg
	@static buff : [512]u8
	keyname_size := fe.tostring(ctx, fe.nextarg(ctx, &arg), raw_data(buff[:]), 512)
	keyname := cast(string)buff[:keyname_size]
	keycode := __get_key(keyname)
	result := rl.IsKeyDown(keycode)
	return fe.bool(ctx, cast(c.int)result)
}
__get_key :: proc(name: string) -> rl.KeyboardKey {
	switch name {
	case "a": fallthrough
	case "A":
		return .A;
	case "b": fallthrough
	case "B":
		return .B;
	case "c": fallthrough
	case "C":
		return .C;
	case "d": fallthrough
	case "D":
		return .D;
	case "e": fallthrough
	case "E":
		return .E;
	case "f": fallthrough
	case "F":
		return .F;
	case "g": fallthrough
	case "G":
		return .G;
	case "h": fallthrough
	case "H":
		return .H;
	case "i": fallthrough
	case "I":
		return .I;
	case "j": fallthrough
	case "J":
		return .J;
	case "k": fallthrough
	case "K":
		return .K;
	case "l": fallthrough
	case "L":
		return .L;
	case "m": fallthrough
	case "M":
		return .M;
	case "n": fallthrough
	case "N":
		return .N;
	case "o": fallthrough
	case "O":
		return .O;
	case "p": fallthrough
	case "P":
		return .P;
	case "q": fallthrough
	case "Q":
		return .Q;
	case "r": fallthrough
	case "R":
		return .R;
	case "s": fallthrough
	case "S":
		return .S;
	case "t": fallthrough
	case "T":
		return .T;
	case "u": fallthrough
	case "U":
		return .U;
	case "v": fallthrough
	case "V":
		return .V;
	case "w": fallthrough
	case "W":
		return .W;
	case "x": fallthrough
	case "X":
		return .X;
	case "y": fallthrough
	case "Y":
		return .Y;
	case "z": fallthrough
	case "Z":
		return .Z;
	}
	return auto_cast 0
}

_api_draw_rectangle :: proc "c" (ctx:^fe.Context, arg: ^fe.Object) -> ^fe.Object {
	context = runtime.default_context()
	arg := arg
	pos := __get_args_vec2_2num(ctx, &arg)
	size := __get_args_vec2_2num(ctx, &arg)
	color := __get_args_color_4num(ctx, &arg)

	rl.DrawRectangleV(pos, size, color)
	return fe.bool(ctx, 1)
}

_api_draw_line :: proc "c" (ctx:^fe.Context, arg: ^fe.Object) -> ^fe.Object {
	context = runtime.default_context()
	arg := arg
	posl := __get_args_vec2_2num(ctx, &arg)
	posr := __get_args_vec2_2num(ctx, &arg)
	color := __get_args_color_4num(ctx, &arg)
	rl.DrawLineV(posl, posr, color)
	return fe.bool(ctx, 1)
}

_api_draw_text :: proc "c" (ctx:^fe.Context, arg: ^fe.Object) -> ^fe.Object {
	context = runtime.default_context()
	arg := arg
	str := __get_args_cstr_1string(ctx, &arg)
	position := __get_args_vec2_2num(ctx, &arg)
	font_size := __get_args_float_1num(ctx, &arg)
	spacing := __get_args_float_1num(ctx, &arg)
	tint := __get_args_color_4num(ctx, &arg)
	rl.DrawTextEx(dude_font, str, position, font_size, spacing, tint)
	return fe.bool(ctx, 1)
}

_api_load_texture :: proc "c" (ctx:^fe.Context, arg: ^fe.Object) -> ^fe.Object {
	arg := arg
	@static _buffer : [512]u8
	filename := _buffer[:fe.tostring(ctx, fe.nextarg(ctx, &arg), raw_data(_buffer[:]), 512)]
	tex := rl.LoadTexture(cast(cstring)raw_data(_buffer[:]))
	texobj := [5]^fe.Object {
		fe.number(ctx, cast(f32)tex.id),
		fe.number(ctx, cast(f32)tex.width),
		fe.number(ctx, cast(f32)tex.height),
		fe.number(ctx, cast(f32)tex.mipmaps),
		fe.number(ctx, cast(f32)tex.format),
	}
	return fe.list(ctx, &texobj[0], 5)
}

_api_draw_texture :: proc "c" (ctx:^fe.Context, arg: ^fe.Object) -> ^fe.Object {
	context = runtime.default_context()
	arg := arg
	tex := __get_args_texture_1obj(ctx, &arg)
	pos := __get_args_vec2_2num(ctx, &arg)
	tint := __get_args_color_4num(ctx, &arg)

	rl.DrawTextureV(tex, pos, tint)
	return fe.bool(ctx, 1)
}

_api_draw_texture_pro :: proc "c" (ctx:^fe.Context, arg: ^fe.Object) -> ^fe.Object {
	context = runtime.default_context()
	arg := arg
	tex := __get_args_texture_1obj(ctx, &arg)
	src_rect := __get_args_rect_4num(ctx, &arg)
	dst_rect := __get_args_rect_4num(ctx, &arg)
	origin := __get_args_vec2_2num(ctx, &arg)
	rotation := __get_args_float_1num(ctx, &arg)
	tint := __get_args_color_4num(ctx, &arg)

	rl.DrawTexturePro(tex, src_rect, dst_rect, origin, rotation, tint)
	return fe.bool(ctx, 1)
}

__get_args_texture_1obj :: proc(ctx:^fe.Context, arg: ^^fe.Object) -> rl.Texture2D {
	texobj := fe.nextarg(ctx, arg)
	texprops := [5]^fe.Object {}
	for i in 0..<5 {
		texprops[i] = fe.car(ctx, texobj)
		texobj = fe.cdr(ctx, texobj)
	}
	tex := rl.Texture2D{
		id = cast(u32)fe.tonumber(ctx, texprops[0]),
		width = cast(i32)fe.tonumber(ctx, texprops[1]),
		height = cast(i32)fe.tonumber(ctx, texprops[2]),
		mipmaps = cast(i32)fe.tonumber(ctx, texprops[3]),
		format = cast(rl.PixelFormat)cast(c.int)fe.tonumber(ctx, texprops[4]),
	}
	return tex
}

__get_args_rect_4num :: proc(ctx:^fe.Context, arg: ^^fe.Object) -> rl.Rectangle {
	arg := arg
	return rl.Rectangle {
		cast(f32)fe.tonumber(ctx, fe.nextarg(ctx, arg)),
		cast(f32)fe.tonumber(ctx, fe.nextarg(ctx, arg)),
		cast(f32)fe.tonumber(ctx, fe.nextarg(ctx, arg)),
		cast(f32)fe.tonumber(ctx, fe.nextarg(ctx, arg)),
	}
}

__get_args_color_4num :: proc(ctx:^fe.Context, arg: ^^fe.Object) -> rl.Color {
	arg := arg
	return rl.Color {
		cast(u8)fe.tonumber(ctx, fe.nextarg(ctx, arg)),
		cast(u8)fe.tonumber(ctx, fe.nextarg(ctx, arg)),
		cast(u8)fe.tonumber(ctx, fe.nextarg(ctx, arg)),
		cast(u8)fe.tonumber(ctx, fe.nextarg(ctx, arg)),
	}
}

__get_args_vec2_2num :: proc(ctx:^fe.Context, arg: ^^fe.Object) -> rl.Vector2 {
	arg := arg
	return rl.Vector2 {
		cast(f32)fe.tonumber(ctx, fe.nextarg(ctx, arg)),
		cast(f32)fe.tonumber(ctx, fe.nextarg(ctx, arg)),
	}
}

__get_args_float_1num :: proc(ctx:^fe.Context, arg: ^^fe.Object) -> f32 {
	arg := arg
	return cast(f32)fe.tonumber(ctx, fe.nextarg(ctx, arg))
}

__get_args_str_1string :: proc(ctx:^fe.Context, arg: ^^fe.Object) -> string {
	arg := arg
	@static _buff : [4096]u8
	obj := fe.nextarg(ctx, arg)
	if fe.isnil(ctx, obj) != 0 do return ""
	str := fe_tostring(ctx, obj)
	return str
}
__get_args_cstr_1string :: proc(ctx:^fe.Context, arg: ^^fe.Object) -> cstring {
	arg := arg
	@static _buff : [4096]u8
	obj := fe.nextarg(ctx, arg)
	if fe.isnil(ctx, obj) != 0 do return ""
	str := fe_tocstring(ctx, obj)
	return str
}
