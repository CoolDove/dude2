package main

import "core:io"
import "core:fmt"
import "core:os"
import "core:path/filepath"

@(private="file")
pipe_file : os.Handle

open_pipe :: proc(name: string) -> os.Handle {
	close_pipe()
	pipe_path := _get_pipepath(name)
	pipe_err : os.Error
	if !os.exists(pipe_path) {
		os.make_directory(filepath.dir(pipe_path, context.temp_allocator))
		pipe_file, pipe_err = os.open(pipe_path, os.O_RDWR|os.O_CREATE)
		fmt.printf("pip file created\n")
	} else {
		pipe_file, pipe_err = os.open(pipe_path, os.O_RDWR)
		fmt.printf("pip file opened\n")
	}
	fmt.printf("listening: {}\n", name)
	os.ftruncate(pipe_file, 0)
	os.seek(pipe_file, 0, 0)
	return pipe_file
}
close_pipe :: proc() {
	if pipe_file != 0 do os.close(pipe_file)
	pipe_file = 0
}
read_pipe :: proc() -> string {
	if pipe_file == 0 do return {}
	if str := _read_string_from_pipe(); str != {} {
		// fmt.printf("read: {}\n", str)
		return str
	}
	return {}
}
write_pipe :: proc(name, content: string) {
	path := _get_pipepath(name)
	os.write_entire_file(path, transmute([]u8)content)
	// fmt.printf("write to pipe: {}\n", content)
}

@(private="file")
_get_pipepath :: proc(name: string, allocator:=context.temp_allocator) -> string {
	context.allocator = allocator
	app_path := os.get_env("LOCALAPPDATA")
	filename := fmt.tprintf("{}.pipefile", name)
	return filepath.join({app_path, "dude", filename})
}
@(private="file")
_read_string_from_pipe :: proc() -> string {
	@static _buffer : [2048]u8
	n, err := os.read(pipe_file, _buffer[:])
	if err == nil || n != 0 {
		os.seek(pipe_file, 0, 0)
		os.ftruncate(pipe_file, 0)
		return string(_buffer[:n])
	}
	return {}
}

