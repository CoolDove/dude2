package main

import "base:runtime"
import "core:fmt"
import "core:mem"
import "core:time"
import "core:c"
import "core:c/libc"
import "core:strings"
import "core:os"
import "core:path/filepath"
import rl "vendor:raylib"
import fe "odin-fe"

main :: proc() {
	if len(os.args) > 1 && os.args[1] == "eval" {
		name := os.args[2]
		expr := os.args[3]
		write_pipe(name, expr)
		return
	}
	main_dude()
}

cmdl_on := false
hotreload := false
dude_font : rl.Font

main_dude :: proc() {
	//* initialize fe
	fe_buffer_size := 32*1024*1024
	fe_buffer, err := mem.alloc_bytes(fe_buffer_size)
	if err != nil {
		fmt.printf("Failed to allocate memory for fe interpreter. {}\n", err)
		return
	}
	defer mem.free_bytes(fe_buffer)
	dude_fe_open(raw_data(fe_buffer), cast(c.int)fe_buffer_size)
	defer dude_fe_close()

	dude_fe_bind_cfunc("printf", _sys_printf)

	dude_fe_bind_cfunc("api-draw-rectangle", _api_draw_rectangle)
	dude_fe_bind_cfunc("api-draw-line", _api_draw_line)
	dude_fe_bind_cfunc("api-is-key-down", _api_is_key_down)
	dude_fe_bind_cfunc("api-load-texture", _api_load_texture)
	dude_fe_bind_cfunc("api-draw-texture", _api_draw_texture)
	dude_fe_bind_cfunc("api-draw-text", _api_draw_text)
	dude_fe_bind_cfunc("api-draw-texture-pro", _api_draw_texture_pro)

	dude_fe_bind_cfunc("str-substring", _str_substring)

	dude_fe_bind_cfunc("sys-toggle-hot-reload", _sys_toggle_hot_reload)

	dude_fe_eval_all(#load("builtin-base.fe"))

	//* initialize pipe
	defer close_pipe()

	//* initailize raylib
	rl.SetTargetFPS(60)
	rl.InitWindow(800, 600, "dude2")
	rl.SetExitKey(auto_cast 0)
	dude_font = rl.LoadFont("./FiraCode-Medium.ttf"); defer rl.UnloadFont(dude_font)
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
						fmt.printf("GAME RELOADED\n")
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
		cmdline()

		rl.EndDrawing()
		free_all(context.temp_allocator)
	}
	rl.CloseWindow()
}

cmdline :: proc() {
	@static buf : [1024]u8
	if cmdl_on && rl.GuiTextBox({60,100, 800-120, 40}, cast(cstring)raw_data(buf[:]), cast(i32)len(buf), true) {
		src := cast(string)(cast(cstring)raw_data(buf[:]))
		if src != "" {
			dude_fe_eval_all(src)
			mem.set(raw_data(buf[:]), 0, len(buf))
		}
	}
}

@(private="file")
_sys_toggle_hot_reload :: proc "c" (ctx:^fe.Context, arg: ^fe.Object) -> ^fe.Object {
	context = runtime.default_context()
	hotreload = !hotreload
	fmt.printf("HOT RELOAD: {}\n", "ON" if hotreload else "OFF")
	return fe.bool(ctx, 1)
}

@(private="file")
_sys_printf :: proc "c" (ctx:^fe.Context, arg: ^fe.Object) -> ^fe.Object {
	context = runtime.default_context()
	arg := arg
	fmtstr := __get_args_str_1string(ctx, &arg)
	fmtargs := make([dynamic]any); defer delete(fmtargs)
	if obj := fe.nextarg(ctx, &arg); obj != nil {
		append(&fmtargs, fe_tostring(ctx, obj))
	}
	fmted := fmt.ctprintf(fmtstr, ..fmtargs[:])
	fmt.printf("{}", fmted)
	return fe.string(ctx, fmted)
}
