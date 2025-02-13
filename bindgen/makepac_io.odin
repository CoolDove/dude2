package bindgen

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"
import "core:math/linalg"
import rl "vendor:raylib"

makepac_io :: proc() -> PacDefine {
	pac_io := pac_make("io")
	{
		func : ^FuncDefine
		func = append_function(&pac_io, "read-string-file", "", 
			arg_cstr
		)
		func.execute = `
	str, ok := os.read_entire_file(auto_cast arg0, context.temp_allocator)
	ret :cstring
	if ok do ret = strings.clone_to_cstring(transmute(string)str, context.temp_allocator)
	else do ret = ""`
		func.return_value = S7Value_SimpleMake.string
	}
	return pac_io
}
