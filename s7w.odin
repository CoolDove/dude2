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
	numbers : proc(using reader: ^SsArgReader, data: []f64),
	numberf32 : proc(using reader: ^SsArgReader) -> f32,
	numbersf32 : proc(using reader: ^SsArgReader, data: []f32),

	integer : proc(using reader: ^SsArgReader) -> int,
	integers : proc(using reader: ^SsArgReader, data: []int),
	integeri32 : proc(using reader: ^SsArgReader) -> i32,
	integersi32 : proc(using reader: ^SsArgReader, data: []i32),
	integeru8 : proc(using reader: ^SsArgReader) -> u8,
	integersu8 : proc(using reader: ^SsArgReader, data: []u8),

	vectoru8 : proc(using reader: ^SsArgReader, data: []u8),

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
		if x := ss.car(_arg); !ss.is_integer(x) {
			_err = ss.wrong_type_arg_error(_scm, _name, auto_cast _idx, ss.car(_arg), "an integer")
			return 0
		} else {
			_arg = ss.cdr(_arg)
			_idx += 1
			return cast(int)ss.number_to_integer(scm, x)
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


	vectoru8 = proc(using reader: ^SsArgReader, data: []u8) {
		if _err != nil do return // the reader is broken, keep the _err
		if x := ss.car(_arg); !ss.is_byte_vector(x) {
			_err = ss.wrong_type_arg_error(_scm, _name, auto_cast _idx, ss.car(_arg), "a byte vector")
			return
		} else {
			length := ss.vector_length(x)
			if length != cast(i64)len(data) {
				_err = ss.wrong_type_arg_error(_scm, _name, auto_cast _idx, ss.car(_arg), fmt.ctprintf("a byte vector lengths {}", len(data)))
				return
			}
			for i in 0..<length {
				data[i] = ss.byte_vector_ref(x, i)
			}
			_arg = ss.cdr(_arg)
			_idx += 1
		}
	},

}
