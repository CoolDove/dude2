package main

import "base:runtime"
import "core:fmt"
import win32 "core:sys/windows"
import "core:unicode/utf8"
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

	s7.set_current_output_port(scm, s7.open_output_function(scm, __dude_output_function))// unnecessary for Chinese output
	__dude_output_function :: proc "c" (sc: ^s7.Scheme, c: u8, port: s7.Pointer) {
		context = runtime.default_context()
		@static utfbuffer : [4]u8
		@static ptr : int
		utfbuffer[ptr] = c
		ptr += 1
		if utf8.full_rune(utfbuffer[:ptr]) {
			fmt.printf("{}", utf8.rune_at(transmute(string)utfbuffer[:ptr], 0))
			ptr = 0
		}
	}

	when ODIN_DEBUG {
		s7.eval_c_string(scm, "(define dude-debug #t)")
	} else {
		s7.eval_c_string(scm, "(define dude-debug #f)")
	}
	s7.load(scm, "builtin.scm")

	s7bind_utilities()
	s7bind_io()
	s7bind_rl()
	s7bind_linalg()

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
	rl.InitWindow(1270, 860, strings.clone_to_cstring(filepath.short_stem(os.args[0]), context.temp_allocator))
	rl.SetExitKey(auto_cast 0)
	{
		runes := utf8.string_to_runes(#load("./res/char_sheet.txt")); defer delete(runes)
		font_data := #load("res/fzytk.ttf")
		dude_font = rl.LoadFontFromMemory(".ttf", raw_data(font_data), auto_cast len(font_data), 64, raw_data(runes), auto_cast len(runes))
	} defer rl.UnloadFont(dude_font)
	rl.GuiSetFont(dude_font)
	rl.GuiSetStyle(.DEFAULT, cast(i32)rl.GuiDefaultProperty.TEXT_SIZE, 32)

	file_handle : os.Handle
	file_loaded : bool
	file_last_update : time.Time

	s7.eval_c_string(scm, "(define* (update) ( rl/draw-text \"There is no game, please check ./game.scm\" (fvec2-mk 20 40) 32 1 (colr-mk 0 255 0)))")

	if os.exists("./game.scm") {
		s7.load(scm, "./game.scm")
		fmt.printf("Game Loaded\n")
	}

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
	screen_size :rl.Vector2= {auto_cast rl.GetScreenWidth(), auto_cast rl.GetScreenHeight()}
	if cmdl_on && rl.GuiTextBox({60,100, screen_size.x-120, 40}, cast(cstring)raw_data(buf[:]), cast(i32)len(buf), true) {
		src := cast(cstring)&buf[0]
		if src != "" {
			s7.eval_c_string(scm, src)
			mem.set(&buf[0], 0, len(buf))
		}
	}
}
