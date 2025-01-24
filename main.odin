package main

import "base:runtime"
import "core:fmt"
import "core:mem"
import "core:time"
import "core:c"
import "core:strings"
import "core:os"
import "core:path/filepath"
import rl "vendor:raylib"
import fe "odin-fe"

fe_ctx : ^fe.Context
fe_gc : c.int

main :: proc() {
	fmt.printf("{}\n", os.args)
	if len(os.args) > 1 && os.args[1] == "eval" {
		name := os.args[2]
		expr := os.args[3]
		write_pipe(name, expr)
		return
	} else {
		// fmt.printf("Unrecognized args. `dude eval {{name}} {{expr}}`\n")
	}
	main_dude()
}

main_dude :: proc() {
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
	fe.set(fe_ctx, fe.symbol(fe_ctx, "api-draw-line"), fe.cfunc(fe_ctx, _api_draw_line))
	fe.set(fe_ctx, fe.symbol(fe_ctx, "api-is-key-down"), fe.cfunc(fe_ctx, _api_is_key_down))
	fe.set(fe_ctx, fe.symbol(fe_ctx, "api-load-texture"), fe.cfunc(fe_ctx, _api_load_texture))
	fe.set(fe_ctx, fe.symbol(fe_ctx, "api-draw-texture"), fe.cfunc(fe_ctx, _api_draw_texture))
	fe.set(fe_ctx, fe.symbol(fe_ctx, "api-draw-texture-pro"), fe.cfunc(fe_ctx, _api_draw_texture_pro))

	dude_fe_eval_all(#load("builtin-base.fe"))

	//* initialize pipe
	defer close_pipe()

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
		path := os.args[1]
		file_handle, load_err = os.open(path)
		filename := filepath.short_stem(path)
		if load_err == nil {
			if src, ok := os.read_entire_file(file_handle); ok {
				rl.SetWindowTitle(strings.clone_to_cstring(filename, context.temp_allocator))
				open_pipe(filename)

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

	hotreload := false
	cmdl_on := true
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({0,0,0,0})

		if rl.IsKeyPressed(.F1) {
			cmdl_on = !cmdl_on
		}
		if piped_str := read_pipe(); piped_str != {} {
			dude_fe_eval_all(piped_str)
		}

		if hotreload {
			if info, stat_err := os.fstat(file_handle, context.temp_allocator); stat_err == nil {
				new_last_update := info.modification_time
				if new_last_update._nsec != file_last_update._nsec {
					os.seek(file_handle, 0, 0)
					if src, read_err := os.read_entire_file_or_err(file_handle); read_err == nil {
						fmt.printf("hotreload!\n")
						dude_fe_eval_all(cast(string)src)
						delete(src)
					} else {
						fmt.printf("failed to load file! {}\n", read_err)
					}
					file_last_update = new_last_update
				}
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

main_eval :: proc() {
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
