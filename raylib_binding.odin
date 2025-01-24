package main

import "base:runtime"
import "core:c"
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
	arg := arg
	posx := cast(c.int)fe.tonumber(ctx, fe.nextarg(ctx, &arg))
	posy := cast(c.int)fe.tonumber(ctx, fe.nextarg(ctx, &arg))
	width := cast(c.int)fe.tonumber(ctx, fe.nextarg(ctx, &arg))
	height := cast(c.int)fe.tonumber(ctx, fe.nextarg(ctx, &arg))

	r := cast(u8)fe.tonumber(ctx, fe.nextarg(ctx, &arg))
	g := cast(u8)fe.tonumber(ctx, fe.nextarg(ctx, &arg))
	b := cast(u8)fe.tonumber(ctx, fe.nextarg(ctx, &arg))
	a := cast(u8)fe.tonumber(ctx, fe.nextarg(ctx, &arg))

	color :rl.Color= {r,g,b,a}
	rl.DrawRectangle(posx, posy, width, height, color)
	return fe.bool(ctx, 1)
}

_api_draw_line :: proc "c" (ctx:^fe.Context, arg: ^fe.Object) -> ^fe.Object {
	arg := arg
	ax := cast(c.float)fe.tonumber(ctx, fe.nextarg(ctx, &arg))
	ay := cast(c.float)fe.tonumber(ctx, fe.nextarg(ctx, &arg))
	bx := cast(c.float)fe.tonumber(ctx, fe.nextarg(ctx, &arg))
	by := cast(c.float)fe.tonumber(ctx, fe.nextarg(ctx, &arg))

	r := cast(u8)fe.tonumber(ctx, fe.nextarg(ctx, &arg))
	g := cast(u8)fe.tonumber(ctx, fe.nextarg(ctx, &arg))
	b := cast(u8)fe.tonumber(ctx, fe.nextarg(ctx, &arg))
	a := cast(u8)fe.tonumber(ctx, fe.nextarg(ctx, &arg))

	color :rl.Color= {r,g,b,a}
	rl.DrawLineV({ax,ay}, {bx,by}, color)
	return fe.bool(ctx, 1)
}

