package main

import "base:runtime"
import "core:c"
import "core:fmt"
import rl "vendor:raylib"
import ss "s7"

SsArgReader :: struct {
	using _vtable : ^_SsArgReader_VTable,
	_scm: ^ss.Scheme,
	_idx : int,
	_name : cstring,
	_arg : ss.Pointer,
	_err : Maybe(ss.Pointer),
}

@(private="file")
_SsArgReader_VTable :: struct {
	number : proc(using reader: ^SsArgReader) -> f64,
	numberf32 : proc(using reader: ^SsArgReader) -> f32,
}

ss_arg_reader_make :: proc(scm: ^ss.Scheme, arg: ss.Pointer, name: cstring) -> SsArgReader {
	return {&_vtable, scm, 0, name, arg, {}}
}

@(private="file")
_vtable :_SsArgReader_VTable= {
	number = proc(using reader: ^SsArgReader) -> f64 {
		if _err != nil do return 0 // the reader is broken, keep the _err
		if x := ss.car(_arg); !ss.is_number(x) {
			_err = ss.wrong_type_arg_error(_scm, _name, auto_cast _idx, ss.car(_arg), "a number")
			return 0
		} else {
			_arg = ss.cdr(_arg)
			_idx += 1
			return ss.number_to_real(scm, x)
		}
	},
	numberf32 = proc(using reader: ^SsArgReader) -> f32 {
		return cast(f32)reader->number()
	}
}
