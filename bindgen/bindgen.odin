package bindgen

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"
import "core:math/linalg"
import rl "vendor:raylib"

FuncDefine :: struct {
	pac : cstring,
	name : cstring,
	doc : cstring,
	argdefs: [dynamic]FuncArgDefine,
	execute : cstring,
	return_value : S7Value,
}
TypeDefine :: struct {
	pac : cstring, // rl
	name : cstring, // tex2d
	native_type : cstring, // Texture2D
	properties : [dynamic]TypePropertyDefine,
}

TypePropertyDefine :: struct {
	name : cstring,
	getter : cstring,
	s7value : S7Value,
}

PacDefine :: struct {
	name : cstring,
	functions : [dynamic]FuncDefine,
	types : [dynamic]TypeDefine,
}

S7Value :: union {
	S7Value_CObj,
	S7Value_SimpleMake,
	S7Value_Vecf,
}
S7Value_CObj :: cstring // typename //TODO: optimize this
S7Value_SimpleMake :: enum { // s7 typename (s7.make_xxx)
	real, integer, boolean, string
}
S7Value_Vecf :: distinct []cstring // variable names

pac_make :: proc(name: cstring) -> PacDefine {
	return {
		name,
		make_dynamic_array([dynamic]FuncDefine),
		make_dynamic_array([dynamic]TypeDefine),
	}
}
append_type :: proc(pac: ^PacDefine, name: cstring, native_type: cstring, props : ..TypePropertyDefine) -> ^TypeDefine {
	d := TypeDefine{pac.name, name, native_type, make([dynamic]TypePropertyDefine)}
	for p in props {
		append(&d.properties, p)
	}
	append(&pac.types, d)
	return &pac.types[len(pac.types)-1]
}
append_function :: proc(pac: ^PacDefine, name: cstring, doc:cstring="", argdefs: ..FuncArgDefine) -> ^FuncDefine {
	d := FuncDefine{ pac.name, name, doc, make([dynamic]FuncArgDefine), "", nil }
	for arg in argdefs {
		append(&d.argdefs, arg)
	}
	append(&pac.functions, d)
	return &pac.functions[len(pac.functions)-1]
}
type_make :: proc(name: cstring, allocator:=context.allocator) -> PacDefine{
	return {
		name,
		make_dynamic_array([dynamic]FuncDefine),
		make_dynamic_array([dynamic]TypeDefine),
	}
}

FuncArgDefine :: struct {
	fmtter : cstring,
}

arg_rectangle :FuncArgDefine= { "$ : rl.Rectangle; reader->vectorf32(slice.from_ptr(cast(^f32)&$, 4))" }
arg_color :FuncArgDefine= { "$ : rl.Color; reader->vectoru8($[:])" }
arg_float :FuncArgDefine= { "$ := reader->numberf32()" }
arg_vec2 :FuncArgDefine= { "$ : rl.Vector2; reader->vectorf32($[:])" }
arg_vec3 :FuncArgDefine= { "$ : rl.Vector3; reader->vectorf32($[:])" }
arg_vec4 :FuncArgDefine= { "$ : rl.Vector4; reader->vectorf32($[:])" }
arg_cstr :FuncArgDefine= { "$ := reader->cstr()" }

arg_texture :FuncArgDefine= { "$ := cast(^rl.Texture2D)reader->cobj(rltypes.tex2d)" }

s7v_real := S7Value_SimpleMake.real
s7v_retvec2 := S7Value_Vecf { "ret.x", "ret.y" }

root : string

main :: proc() {
	if len(os.args) > 1 do root = os.args[1]
	else do root = ""

	pac_raylib := makepac_rl()
	generate_pac(&pac_raylib, "binding_raylib.odin")

	pac_io := makepac_io()
	generate_pac(&pac_io, "binding_io.odin")

	pac_linalg := pac_make("linalg")
	{
		func : ^FuncDefine
		func = append_function(&pac_linalg, "vec2-length", "", arg_vec2)
		func.execute = "ret := linalg.length(arg0)"
		func.return_value = S7Value_SimpleMake.real

		func = append_function(&pac_linalg, "vec2-distance", "", arg_vec2, arg_vec2)
		func.execute = "ret := linalg.distance(arg0, arg1)"
		func.return_value = S7Value_SimpleMake.real

		func = append_function(&pac_linalg, "vec2-add", "", arg_vec2, arg_vec2)
		func.execute = "ret := arg0 + arg1"
		func.return_value = s7v_retvec2

		func = append_function(&pac_linalg, "vec2-subtract", "", arg_vec2, arg_vec2)
		func.execute = "ret := arg0 - arg1"
		func.return_value = s7v_retvec2

		func = append_function(&pac_linalg, "vec2-scale", "", arg_vec2, arg_float)
		func.execute = "ret := arg1 * arg0"
		func.return_value = s7v_retvec2
	}
	linalg_path := filepath.join({root, "binding_linalg.odin"}, context.temp_allocator)
	linalg_path, _ = filepath.abs(linalg_path)
	generate(&pac_linalg, linalg_path)

}

generate_pac :: proc(pac: ^PacDefine, filename: string) {
	path := filepath.join({root, filename}, context.temp_allocator)
	path, _ = filepath.abs(path)
	generate(pac, path)
}
generate :: proc(pac: ^PacDefine, path: string) {
	fmt.printf(" ** gen pac binding [{}] to: {}\n", pac.name, path)
	using strings
	sb, sbtop, sbreg, sbbot : Builder
	builder_init(&sb); defer builder_destroy(&sb)
	builder_init(&sbtop); defer builder_destroy(&sbtop)
	builder_init(&sbreg); defer builder_destroy(&sbreg)
	builder_init(&sbbot); defer builder_destroy(&sbbot)
	defer os.write_entire_file(path, transmute([]u8)to_string(sb))

	write_string(&sb, "package main\n")
	write_string(&sb, `// GENERATED FILE, DONT MODIFY
import "base:runtime"
import "core:c"
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:os"
import "core:math/linalg"
import rl "vendor:raylib"
import "s7"`)
	write_rune(&sb, '\n')

	write_string(&sbreg, fmt.tprintf("s7bind_{} :: proc() {{\n", pac.name))

	// generate types
	types_struct_name := fmt.tprintf("TypeDefines_{}", pac.name)
	write_string(&sbtop, fmt.tprintf("{} :: struct {{\n", types_struct_name))
	for type in pac.types {
		write_string(&sbtop, fmt.tprintf("\t{} : TypeDefine,\n", type.name))
		write_string(&sbreg, fmt.tprintf("\t{}types.{} = {{ s7.make_c_type(scm, \"{}\"), \"{}\" }}\n", pac.name, type.name, type.name, type.name))
		// generate properties
		for prop in type.properties {
			getfunc := append_function(pac, fmt.ctprintf("{}.{}", type.name, prop.name), "", arg_texture)
			getfunc.execute = fmt.caprintf("ret := {}", prop.getter)
			getfunc.return_value = prop.s7value
		}
	}
	write_string(&sbtop, "}\n")
	write_string(&sbtop, fmt.tprintf("{}types : {}\n", pac.name, types_struct_name))

	// generate functions
	for func in pac.functions {
		generate_function(&sbreg, &sbbot, func, pac)
	}
	write_string(&sbreg, "\n}\n")

	write_string(&sb, to_string(sbtop))
	write_string(&sb, "\n\n\n")
	write_string(&sb, to_string(sbreg))
	write_string(&sb, "\n\n\n")
	write_string(&sb, to_string(sbbot))

}

generate_make_s7value :: proc(s7value: S7Value, pac: ^PacDefine) -> cstring {
	switch r in s7value {
	case S7Value_CObj :
		return fmt.ctprintf("s7.make_c_object(scm, {}types.{}.id, ret)", pac.name, r)
	case S7Value_SimpleMake :
		return fmt.ctprintf("s7.make_{}(scm, auto_cast ret)", r)
	case S7Value_Vecf:
		using strings
		sb : Builder
		s :[]cstring= auto_cast s7value.(S7Value_Vecf)
		builder_init(&sb); defer builder_destroy(&sb)
		write_string(&sb, "make_s7vector_f(scm, ")
		for i in 0..<len(r) {
			write_string(&sb, fmt.tprintf("auto_cast {}, ", r[i]))
		}
		write_string(&sb, ")")
		result := to_cstring(&sb)
		return strings.clone_to_cstring(cast(string)result)
	case:
		return "s7.make_boolean(scm, true)"
	}
}

generate_function :: proc(sbreg, sbbot: ^strings.Builder, func: FuncDefine, pac: ^PacDefine) {
	using strings
	func_def_name, _ := strings.replace_all(cast(string)func.name, "-", "_", context.temp_allocator)
	func_def_name, _ = strings.replace_all(func_def_name, ".", "_get_", context.temp_allocator)
	func_def_name = strings.concatenate({ "__api_", func_def_name })
	s7_func_name := fmt.tprintf("{}/{}", pac.name, func.name)
	fmt.printf("generate function: {}\n", func_def_name)
	{// top
		write_string(sbreg, fmt.tprintf("\ts7.define_function(scm, \"{}\", {}, {}, {}, {}, \"{}\")", 
			s7_func_name, func_def_name, len(func.argdefs), 0, false, func.doc
		))
		write_rune(sbreg, '\n')
	}
	{// bottom
		write_string(sbbot, `@(private="file")`)
		write_rune(sbbot, '\n')
		write_string(sbbot, fmt.tprintf("{} :: proc \"c\" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {{", func_def_name))
		write_string(sbbot, "\n\tcontext = runtime.default_context()\n")
		write_string(sbbot, fmt.tprintf("\treader := ss_arg_reader_make(scm, ptr, \"{}\")\n", s7_func_name))

		for arg, idx in func.argdefs {
			argname := fmt.tprintf("arg{}", idx)
			text, _ := strings.replace_all(cast(string)arg.fmtter, "$", argname, context.temp_allocator)
			write_string(sbbot, fmt.tprintf("\t{}\n", text))
		}
		write_string(sbbot, "\tif reader._err != nil do return reader._err.?\n\n")

		write_string(sbbot, fmt.tprintf("\t{}\n", func.execute))

		return_str := generate_make_s7value(func.return_value, pac)
		fmt.printf("return str: {}\n", return_str)
		write_string(sbbot, fmt.tprintf("\treturn {}", return_str))

		write_string(sbbot, "\n}\n\n")
	}
}

