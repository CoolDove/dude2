package main

import "base:runtime"
import "core:fmt"
import "core:mem"
import "core:time"
import "core:c"
import "core:strings"
import "core:os"
import rl "vendor:raylib"
import fe "odin-fe"

fe_ctx : ^fe.Context
fe_gc : c.int

main :: proc() {
	//* initialize fe
	fe_buffer_size := 32*1024*1024
	fe_buffer, err := mem.alloc_bytes(fe_buffer_size)
	if err != nil {
		fmt.printf("Failed to allocate memory for fe interpreter. {}\n", err)
		return
	}
	fe_ctx = fe.open(raw_data(fe_buffer), auto_cast fe_buffer_size)
	fe_gc = fe.savegc(fe_ctx)

	fe.set(fe_ctx, fe.symbol(fe_ctx, "api-draw-rectangle"), fe.cfunc(fe_ctx, _api_draw_rectangle))
	fe.set(fe_ctx, fe.symbol(fe_ctx, "api-is-key-down"), fe.cfunc(fe_ctx, _api_is_key_down))
	fe.set(fe_ctx, fe.symbol(fe_ctx, "api-multiply"), fe.cfunc(fe_ctx, _api_multiply))
	dude_fe_eval_all(#load("builtin-base.fe"))

	//* initailize raylib
	input_buffer, _ := mem.alloc_bytes(1024*1024)
	defer mem.free_bytes(input_buffer)
	rl.SetTargetFPS(60)
	rl.InitWindow(800, 600, "dude2")
	rl.SetExitKey(auto_cast 0)
	dude_font := rl.LoadFont("./FiraCode-Medium.ttf"); defer rl.UnloadFont(dude_font)
	rl.GuiSetFont(dude_font)
	rl.GuiSetStyle(.DEFAULT, cast(i32)rl.GuiDefaultProperty.TEXT_SIZE, 32)

	file_handle : os.Handle
	file_loaded : bool
	file_last_update : time.Time
	if len(os.args)>1 {
		load_err : os.Error
		file_handle, load_err = os.open(os.args[1])
		if load_err == nil {
			if src, ok := os.read_entire_file(file_handle); ok {
				file_loaded = load_err == nil
				if info, stat_err := os.fstat(file_handle, context.temp_allocator); stat_err == nil {
					file_last_update = info.modification_time
				}
				dude_fe_eval_all(cast(string)src)
				delete(src)
			}
		}
	}
	defer if file_loaded do os.close(file_handle)

	cmdl_on := true
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({0,0,0,0})

		if rl.IsKeyPressed(.F1) {
			cmdl_on = !cmdl_on
		}

		if info, stat_err := os.fstat(file_handle, context.temp_allocator); stat_err == nil {
			new_last_update := info.modification_time
			if new_last_update._nsec != file_last_update._nsec {
				os.seek(file_handle, 0, 0)
				if src, read_err := os.read_entire_file_or_err(file_handle); read_err == nil {
					fmt.printf("game updated!\n")
					dude_fe_eval_all(cast(string)src)
					delete(src)
				} else {
					fmt.printf("failed to load file! {}\n", read_err)
				}
				file_last_update = new_last_update
			}
		}

		dude_fe_eval("(update)")

		if cmdl_on && rl.GuiTextBox({60,100, 800-120, 40}, cast(cstring)raw_data(input_buffer), cast(i32)len(input_buffer), true) {
			src := cast(string)(cast(cstring)raw_data(input_buffer))
			if src != "" {
				dude_fe_eval_all(src)
				mem.set(raw_data(input_buffer), 0, len(input_buffer))
			}
		}
		rl.EndDrawing()
	}
	rl.CloseWindow()
	fe.close(fe_ctx)
	mem.free_bytes(fe_buffer)
}

dude_fe_eval_all :: proc(src: string) -> ^fe.Object {
	reader :StringReader= { src, 0 }
	obj := fe.read(fe_ctx, _fe_string_reader, &reader)
	ret : ^fe.Object
	for ; obj!=nil; obj = fe.read(fe_ctx, _fe_string_reader, &reader) {
		ret = fe.eval(fe_ctx, obj)
		fe.restoregc(fe_ctx, fe_gc)
	}
	return ret
}
dude_fe_eval :: proc(src: string) -> ^fe.Object {
	obj := dude_fe_read(src)
	ret := fe.eval(fe_ctx, obj)
	fe.restoregc(fe_ctx, fe_gc)
	return ret
}

dude_fe_read :: proc(src: string) -> ^fe.Object {
	reader :StringReader= { src, 0 }
	return fe.read(fe_ctx, _fe_string_reader, &reader)
}

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

_api_multiply :: proc "c" (ctx:^fe.Context, arg: ^fe.Object) -> ^fe.Object {
	arg := arg
	l := cast(c.int)fe.tonumber(ctx, fe.nextarg(ctx, &arg))
	r := cast(c.int)fe.tonumber(ctx, fe.nextarg(ctx, &arg))
	return fe.number(ctx, auto_cast (l*r))
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
