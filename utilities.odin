package main

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:os"
import "core:math/linalg"
import rl "vendor:raylib"
import "core:encoding/csv"
import "s7"


s7bind_utilities :: proc() {
	s7.define_function(scm, "util/read-csv-string", __api_read_csv_string, 1, 0, false, "(util/read-csv-string csvstring) : parse a csv content into a 2d vector")
}

@(private="file")
__api_read_csv_string :: proc "c" (scm: ^s7.Scheme, ptr: s7.Pointer) -> s7.Pointer {
	context = runtime.default_context()
	reader := ss_arg_reader_make(scm, ptr, "util/read-csv-string")
	content := reader->cstr()

	csvr : csv.Reader
	csv.reader_init_with_string(&csvr, cast(string)content)
	records, err := csv.read_all(&csvr)
	if err != nil {
		fmt.printf("failed to read csv: {}\n", err)
		return s7.make_boolean(scm, false)
	}
	defer {
		for rec in records {
			delete(rec)
		}
		delete(records)
	}

	s7records := s7.make_vector(scm, cast(i64)len(records))
	for r, i in records {
		row := s7.make_vector(scm, cast(i64)len(r))
		for f, j in r {
			length : int
			if number, ok := strconv.parse_f64(f, &length); ok {
				s7.vector_set(scm, row, cast(i64)j, s7.make_real(scm, number))
			} else {
				cstr := strings.clone_to_cstring(f); defer delete(cstr)
				s7.vector_set(scm, row, cast(i64)j, s7.make_string(scm, cstr))
			}
		}
		s7.vector_set(scm, s7records, cast(i64)i, row)
	}
	return s7records
}
