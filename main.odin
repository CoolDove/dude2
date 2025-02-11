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
import ss "s7"

scm : ^ss.Scheme
main :: proc() {
	//* initialize s7
	scm = ss.init()
	@static buffer : [4096]u8

	lib_write := #load("s7/scm/write.scm", cstring)

	ss.load(scm, "s7/scm/write.scm")
	ss.load(scm, "test.scm")

	ss.define_function(scm, "draw-rectangle", __api_draw_rectangle, 4, 0, false, "(draw-rectangle x y w h) : draw a rectangle")

	ss.eval_c_string(scm, "(define* (update) (draw-rectangle 20 20 300 60))")

	// for {
	// 	fmt.printf("\n@EVAL:\n")
	// 	length, err := os.read(os.stdin, buffer[:])
	// 	if err == nil {
	// 		if length < len(buffer) do buffer[length] = 0
	// 		src := cast(cstring)&buffer[0]
	// 		ss.eval_c_string(scm, src)
	// 	}
	// }

	// if len(os.args) > 1 && os.args[1] == "eval" {
	// 	name := os.args[2]
	// 	expr := os.args[3]
	// 	write_pipe(name, expr)
	// 	return
	// }
	main_dude()
}

__api_draw_rectangle :: proc "c" (scm: ^ss.Scheme, ptr: ss.Pointer) -> ss.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "draw-rectangle")
	rx := reader->numberf32()
	ry := reader->numberf32()
	rw := reader->numberf32()
	rh := reader->numberf32()
	if reader._err != nil do return reader._err.?

	rl.DrawRectangleV({rx, ry}, {rw, rh}, rl.WHITE)
	return ss.make_boolean(scm, true)
}

cmdl_on := false
hotreload := false
dude_font : rl.Font

main_dude :: proc() {
	//* initialize fe
	// fe_buffer_size := 32*1024*1024
	// fe_buffer, err := mem.alloc_bytes(fe_buffer_size)
	// if err != nil {
	// 	fmt.printf("Failed to allocate memory for fe interpreter. {}\n", err)
	// 	return
	// }
	// defer mem.free_bytes(fe_buffer)
	// dude_fe_open(raw_data(fe_buffer), cast(c.int)fe_buffer_size)
	// defer dude_fe_close()

	// dude_fe_bind_cfunc("printf", _sys_printf)

	// dude_fe_bind_cfunc("api-draw-rectangle", _api_draw_rectangle)
	// dude_fe_bind_cfunc("api-draw-line", _api_draw_line)
	// dude_fe_bind_cfunc("api-is-key-down", _api_is_key_down)
	// dude_fe_bind_cfunc("api-load-texture", _api_load_texture)
	// dude_fe_bind_cfunc("api-draw-texture", _api_draw_texture)
	// dude_fe_bind_cfunc("api-draw-text", _api_draw_text)
	// dude_fe_bind_cfunc("api-draw-texture-pro", _api_draw_texture_pro)
	// dude_fe_bind_cfunc("api-is-mouse-btn-down", _api_is_mouse_btn_down)

	// dude_fe_bind_cfunc("str-substring", _str_substring)

	// dude_fe_bind_cfunc("sys-toggle-hot-reload", _sys_toggle_hot_reload)

	// dude_fe_eval_all(#load("builtin-base.fe"))

	//* initialize pipe
	// defer close_pipe()

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
	// if len(os.args)>1 {
	// 	load_err : os.Error
	// 	path := os.args[1]
	// 	file_handle, load_err = os.open(path)
	// 	filename := filepath.short_stem(path)
	// 	if load_err == nil {
	// 		if src, ok := os.read_entire_file(file_handle); ok {
	// 			rl.SetWindowTitle(strings.clone_to_cstring(filename, context.temp_allocator))
	// 			open_pipe(filename)

	// 			file_loaded = load_err == nil
	// 			if info, stat_err := os.fstat(file_handle, context.temp_allocator); stat_err == nil {
	// 				file_last_update = info.modification_time
	// 			}
	// 			dude_fe_eval_all(cast(string)src)
	// 			delete(src)
	// 		}
	// 	}
	// }
	// defer if file_loaded do os.close(file_handle)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({0,0,0,0})

		if rl.IsKeyPressed(.F1) {
			cmdl_on = !cmdl_on
		}
		// if piped_str := read_pipe(); piped_str != {} {
		// 	dude_fe_eval_all(piped_str)
		// }

		ss.eval_c_string(scm, "(update)")
		// if hotreload {
		// 	if info, stat_err := os.fstat(file_handle, context.temp_allocator); stat_err == nil {
		// 		new_last_update := info.modification_time
		// 		if new_last_update._nsec != file_last_update._nsec {
		// 			os.seek(file_handle, 0, 0)
		// 			if src, read_err := os.read_entire_file_or_err(file_handle); read_err == nil {
		// 				fmt.printf("GAME RELOADED\n")
		// 				dude_fe_eval_all(cast(string)src)
		// 				delete(src)
		// 			} else {
		// 				fmt.printf("failed to load file! {}\n", read_err)
		// 			}
		// 			file_last_update = new_last_update
		// 		}
		// 	}
		// }

		// dude_fe_eval("(update)")
		cmdline()

		rl.EndDrawing()
		free_all(context.temp_allocator)
	}
	rl.CloseWindow()
}

cmdline :: proc() {
	@static buf : [4096]u8
	if cmdl_on && rl.GuiTextBox({60,100, 800-120, 40}, cast(cstring)raw_data(buf[:]), cast(i32)len(buf), true) {
		src := cast(cstring)&buf[0]
		if src != "" {
			// dude_fe_eval_all(src)
			ss.eval_c_string(scm, src)
			mem.set(&buf[0], 0, len(buf))
		}
	}
}

// @(private="file")
// _sys_toggle_hot_reload :: proc "c" (ctx:^fe.Context, arg: ^fe.Object) -> ^fe.Object {
// 	context = runtime.default_context()
// 	hotreload = !hotreload
// 	fmt.printf("HOT RELOAD: {}\n", "ON" if hotreload else "OFF")
// 	return fe.bool(ctx, 1)
// }
// 
// @(private="file")
// _sys_printf :: proc "c" (ctx:^fe.Context, arg: ^fe.Object) -> ^fe.Object {
// 	context = runtime.default_context()
// 	arg := arg
// 	fmtstr := __get_args_str_1string(ctx, &arg)
// 	fmtargs := make([dynamic]any); defer delete(fmtargs)
// 	if obj := fe.nextarg(ctx, &arg); obj != nil {
// 		append(&fmtargs, fe_tostring(ctx, obj))
// 	}
// 	fmted := fmt.ctprintf(fmtstr, ..fmtargs[:])
// 	fmt.printf("{}", fmted)
// 	return fe.string(ctx, fmted)
// }
