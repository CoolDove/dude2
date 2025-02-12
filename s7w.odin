package main

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:mem"
import rl "vendor:raylib"
import "s7"

SsArgReader :: struct {
	using _vtable : ^_SsArgReader_VTable,
	_scm: ^s7.Scheme,
	_idx : int,
	_name : cstring,
	_arg : s7.Pointer,
	_err : Maybe(s7.Pointer),
}

@(private="file")
_SsArgReader_VTable :: struct {
	number : proc(using reader: ^SsArgReader) -> f64,
	numbers : proc(using reader: ^SsArgReader, data: []f64),
	numberf32 : proc(using reader: ^SsArgReader) -> f32,
	numbersf32 : proc(using reader: ^SsArgReader, data: []f32),

	integer : proc(using reader: ^SsArgReader) -> int,
	integers : proc(using reader: ^SsArgReader, data: []int),
	integeri32 : proc(using reader: ^SsArgReader) -> i32,
	integersi32 : proc(using reader: ^SsArgReader, data: []i32),
	integeru8 : proc(using reader: ^SsArgReader) -> u8,
	integersu8 : proc(using reader: ^SsArgReader, data: []u8),

	vectorf64 : proc(using reader: ^SsArgReader, data: []f64),
	vectorf32 : proc(using reader: ^SsArgReader, data: []f32),
	vectoru8 : proc(using reader: ^SsArgReader, data: []u8),

	cstr : proc(using reader: ^SsArgReader) -> cstring,

	cobj : proc(using reader: ^SsArgReader, typedef: TypeDefine) -> rawptr,
}

ss_arg_reader_make :: proc(scm: ^s7.Scheme, arg: s7.Pointer, name: cstring) -> SsArgReader {
	return {&_vtable, scm, 0, name, arg, {}}
}

@(private="file")
_vtable :_SsArgReader_VTable= {
	number = proc(using reader: ^SsArgReader) -> f64 {
		if _err != nil do return 0 // the reader is broken, keep the _err
		if x := s7.car(_arg); !s7.is_number(x) {
			_err = s7.wrong_type_arg_error(_scm, _name, auto_cast _idx, s7.car(_arg), "a number")
			return 0
		} else {
			_arg = s7.cdr(_arg)
			_idx += 1
			return s7.number_to_real(scm, x)
		}
	},
	numbers = proc(using reader: ^SsArgReader, data: []f64) {
		for i in 0..<len(data) do data[i] = reader->number()
	},
	numberf32 = proc(using reader: ^SsArgReader) -> f32 {
		return cast(f32)reader->number()
	},
	numbersf32 = proc(using reader: ^SsArgReader, data: []f32) {
		for i in 0..<len(data) do data[i] = reader->numberf32()
	},
	integer = proc(using reader: ^SsArgReader) -> int {
		if _err != nil do return 0 // the reader is broken, keep the _err
		if x := s7.car(_arg); !s7.is_integer(x) {
			_err = s7.wrong_type_arg_error(_scm, _name, auto_cast _idx, s7.car(_arg), "an integer")
			return 0
		} else {
			_arg = s7.cdr(_arg)
			_idx += 1
			return cast(int)s7.number_to_integer(scm, x)
		}
	},
	integers = proc(using reader: ^SsArgReader, data: []int) {
		for i in 0..<len(data) do data[i] = reader->integer()
	},
	integeri32 = proc(using reader: ^SsArgReader) -> i32 {
		return cast(i32)reader->integer()
	},
	integersi32 = proc(using reader: ^SsArgReader, data: []i32) {
		for i in 0..<len(data) do data[i] = reader->integeri32()
	},
	integeru8 = proc(using reader: ^SsArgReader) -> u8 {
		return cast(u8)reader->integer()
	},
	integersu8 = proc(using reader: ^SsArgReader, data: []u8) {
		for i in 0..<len(data) do data[i] = reader->integeru8()
	},


	vectorf64 = proc(using reader: ^SsArgReader, data: []f64) {
		if _err != nil do return // the reader is broken, keep the _err
		if x := s7.car(_arg); !s7.is_float_vector(x) {
			_err = s7.wrong_type_arg_error(_scm, _name, auto_cast _idx, s7.car(_arg), "a float vector")
			return
		} else {
			length := s7.vector_length(x)
			if length != cast(i64)len(data) {
				_err = s7.wrong_type_arg_error(_scm, _name, auto_cast _idx, s7.car(_arg), fmt.ctprintf("a float vector lengths {}", len(data)))
				return
			}
			for i in 0..<length {
				data[i] = s7.float_vector_ref(x, i)
			}
			_arg = s7.cdr(_arg)
			_idx += 1
		}
	},
	vectorf32 = proc(using reader: ^SsArgReader, data: []f32) {
		tdata := make_slice([]f64, len(data)); delete(tdata)
		reader->vectorf64(tdata)
		for i in 0..<len(data) do data[i] = cast(f32)tdata[i]
	},
	vectoru8 = proc(using reader: ^SsArgReader, data: []u8) {
		if _err != nil do return // the reader is broken, keep the _err
		if x := s7.car(_arg); !s7.is_byte_vector(x) {
			_err = s7.wrong_type_arg_error(_scm, _name, auto_cast _idx, s7.car(_arg), "a byte vector")
			return
		} else {
			length := s7.vector_length(x)
			if length != cast(i64)len(data) {
				_err = s7.wrong_type_arg_error(_scm, _name, auto_cast _idx, s7.car(_arg), fmt.ctprintf("a byte vector lengths {}", len(data)))
				return
			}
			for i in 0..<length {
				data[i] = s7.byte_vector_ref(x, i)
			}
			_arg = s7.cdr(_arg)
			_idx += 1
		}
	},

	cstr = proc(using reader: ^SsArgReader) -> cstring {
		if _err != nil do return nil
		if x := s7.car(_arg); !s7.is_string(x) {
			_err = s7.wrong_type_arg_error(_scm, _name, auto_cast _idx, s7.car(_arg), "a string")
			return nil
		} else {
			cstr := s7.string(x)
			_arg = s7.cdr(_arg)
			_idx += 1
			return cstr
		}
	},

	cobj = proc(using reader: ^SsArgReader, typedef: TypeDefine) -> rawptr {
		if _err != nil do return nil
		if x := s7.car(_arg); !s7.is_c_object(x) || s7.c_object_type(x) != typedef.id {
			_err = s7.wrong_type_arg_error(_scm, _name, auto_cast _idx, s7.car(_arg), fmt.ctprintf("a cobject({})", typedef.name))
			return nil
		} else {
			type := s7.c_object_type(x)
			ptr := s7.c_object_value(x)
			_arg = s7.cdr(_arg)
			_idx += 1
			return ptr
		}
	},
}


test_define_type :: proc(scm: ^s7.Scheme) {
	rltex_type := s7.make_c_type(scm, "rltex")
	tex := new(rl.Texture2D)
	tex^ = rl.LoadTexture("hello.png")
	s7.make_c_object(scm, rltex_type, tex)
}
