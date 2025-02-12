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
}
S7Value_CObj :: cstring // typename
S7Value_SimpleMake :: distinct cstring // typename

pac_make :: proc(name: cstring, allocator:=context.allocator) -> PacDefine {
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

s7v_real := cast(S7Value_SimpleMake)"real"


main :: proc() {
	root : string
	if len(os.args) > 1 do root = os.args[1]
	else do root = ""

	pac_raylib := pac_make("rl") 
	{
		append_type(&pac_raylib, "tex2d", "rl.Texture2D", {"w", "arg0.width", s7v_real}, {"h", "arg0.height", s7v_real})

		func : ^FuncDefine
		append_function(&pac_raylib, "draw-rectangle", "", 
			arg_rectangle, arg_color
		).execute = "rl.DrawRectangleV({arg0.x, arg0.y}, {arg0.width, arg0.height}, arg1)"

		append_function(&pac_raylib, "draw-texture", "",
			arg_texture, arg_rectangle, arg_rectangle, arg_vec2, arg_float, arg_color
		).execute = "rl.DrawTexturePro(arg0^, arg1, arg2, arg3, arg4, arg5)"

		func = append_function(&pac_raylib, "load-texture", "",
			arg_cstr
		)
		func.execute = `
	ret := new(rl.Texture2D)
	ret^ = rl.LoadTexture(arg0)`
		func.return_value = cast(S7Value_CObj)"tex2d"

	}

	raylib_path := filepath.join({root, "binding_raylib.odin"}, context.temp_allocator)
	raylib_path, _ = filepath.abs(raylib_path)
	generate(&pac_raylib, raylib_path)
}

generate :: proc(pac: ^PacDefine, path: string) {
	fmt.printf("gen to: {}\n", path)
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
import "core:slice"
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

generate_function :: proc(sbreg, sbbot: ^strings.Builder, func: FuncDefine, pac: ^PacDefine) {
	using strings
	func_def_name, _ := strings.replace_all(cast(string)func.name, "-", "_", context.temp_allocator)
	func_def_name, _ = strings.replace_all(func_def_name, ".", "_get_", context.temp_allocator)
	func_def_name = strings.concatenate({ "__api_", func_def_name })
	s7_func_name := fmt.tprintf("{}/{}", pac.name, func.name)
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

		switch r in func.return_value {
		case S7Value_CObj :
			write_string(sbbot, fmt.tprintf("\treturn s7.make_c_object(scm, {}types.{}.id, ret)", pac.name, r))
		case S7Value_SimpleMake :
			write_string(sbbot, fmt.tprintf("\treturn s7.make_{}(scm, auto_cast ret)", r))
		case:
			write_string(sbbot, "\treturn s7.make_boolean(scm, true)")
		}

		write_string(sbbot, "\n}\n\n")
	}
}

