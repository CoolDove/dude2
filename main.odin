package main

import "base:runtime"
import "core:fmt"
import "core:mem"
import "core:slice"
import "core:time"
import "core:c"
import "core:c/libc"
import "core:strings"
import "core:os"
import "core:path/filepath"
import rl "vendor:raylib"
import "s7"
import ansi "ansi_code"

scm : ^s7.Scheme
main :: proc() {
	if len(os.args) > 1 {// client mode
		init_client()
		message : string
		if os.args[1] == "eval-file" && len(os.args) > 2 {
			if cmd, ok := os.read_entire_file(os.args[2]); ok {
				message = transmute(string)cmd
			} else {
				fmt.printf("failed to read file {}\n", os.args[2])
				return
			}
		} else {
			message = os.args[1]
		}
		client_send_message(strings.clone_to_cstring(message, context.temp_allocator))
		return
	}

	init_server()

	//* initialize s7
	scm = s7.init()
	@static buffer : [4096]u8

	lib_write := #load("s7/scm/write.scm", cstring)
	s7.load(scm, "s7/scm/r7rs.scm")

	s7bind_rl()
	s7bind_linalg()

	s7.load(scm, "builtin.scm")

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

	s7.load(scm, "test.scm")
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({0,0,0,0})

		if rl.IsKeyPressed(.F1) {
			cmdl_on = !cmdl_on
		}
		if message := server_check_message(); message != nil {
			ansi.color_ansi(.Yellow)
			fmt.printf("\nEVAL REMOTE\n")
			ansi.color_ansi(.Default)
			s7.eval_c_string(scm, message)
			fmt.print("\n")
		}
		s7.eval_c_string(scm, "(update)")

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
			s7.eval_c_string(scm, src)
			mem.set(&buf[0], 0, len(buf))
		}
	}
}
