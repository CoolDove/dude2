package s7

when ODIN_OS == .Linux {
	foreign import s7 "s7.o"
}
when ODIN_OS == .Windows {
	foreign import s7 "s7-windows-x64-msvc.lib"
}

Pointer :: distinct rawptr
Scheme  :: distinct rawptr

Function :: #type proc "c" (^Scheme, Pointer) -> Pointer
PFunc    :: #type proc "c" (^Scheme) -> Pointer

Read :: enum i32 {
	READ,
	READ_CHAR,
	READ_LINE,
	PEEK_CHAR,
	IS_CHAR_READY,
	NUM_READ_CHOICES,
}

Float_Function :: #type proc(sc: ^Scheme) -> f64
D_T            :: #type proc() -> f64
D_D_T          :: #type proc(x: f64) -> f64
D_DD_T         :: #type proc(x1: f64, x2: f64) -> f64
D_DDD_T        :: #type proc(x1: f64, x2: f64, x3: f64) -> f64
D_DDDD_T       :: #type proc(x1: f64, x2: f64, x3: f64, x4: f64) -> f64
D_V_T          :: #type proc(v: rawptr) -> f64
D_VD_T         :: #type proc(v: rawptr,  d: f64) -> f64
D_VDD_T        :: #type proc(v: rawptr, x1: f64, x2: f64) -> f64
D_VID_T        :: #type proc(v: rawptr,  i: i64,  d: f64) -> f64
D_P_T          :: #type proc(p: Pointer) -> f64
D_PD_T         :: #type proc(v: Pointer, x: f64) -> f64
D_7PI_T        :: #type proc(sc: ^Scheme, v: Pointer, i: i64) -> f64
D_7PID_T       :: #type proc(sc: ^Scheme, v: Pointer, i: i64, d: f64) -> f64
D_ID_T         :: #type proc(i: i64, d: f64) -> f64
D_IP_T         :: #type proc(i: i64, p: Pointer) -> f64
I_I_T          :: #type proc(x: i64) -> i64
I_7D_T         :: #type proc(sc: ^Scheme, x: f64) -> i64
I_II_T         :: #type proc(i1: i64, i2: i64) -> i64
I_7P_T         :: #type proc(sc: ^Scheme, p: Pointer) -> i64
B_P_T          :: #type proc(p: Pointer) -> b8
P_D_T          :: #type proc(sc: ^Scheme, x: f64) -> Pointer
P_P_T          :: #type proc(sc: ^Scheme, p: Pointer) -> Pointer
P_PP_T         :: #type proc(sc: ^Scheme, p1: Pointer, p2: Pointer) -> Pointer
P_PPP_T        :: #type proc(sc: ^Scheme, p1: Pointer, p2: Pointer, p3: Pointer) -> Pointer

@(link_prefix="s7_")
foreign s7 {
	init :: proc() -> ^Scheme ---
	free :: proc(^Scheme) ---

	f              :: proc(sc: ^Scheme) -> Pointer ---           // #f
	t              :: proc(sc: ^Scheme) -> Pointer ---           // #t
	nil            :: proc(sc: ^Scheme) -> Pointer ---           // ()
	undefined      :: proc(sc: ^Scheme) -> Pointer ---           // #<undefined>
	unspecified    :: proc(sc: ^Scheme) -> Pointer ---           // #<unspecified>
	is_unspecified :: proc(sc: ^Scheme, val: Pointer) -> b8 ---  // returns true if val is #<unspecified>
	eof_object     :: proc(sc: ^Scheme) -> Pointer ---           // #<eof>
	is_null        :: proc(sc: ^Scheme, p: Pointer) -> b8 ---    // null?
	// these are the Scheme constants; they do not change in value during a run,
	// so they can be safely assigned to C global variables if desired.

	is_valid                         :: proc(sc: ^Scheme, arg: Pointer) -> b8 --- // does 'arg' look like an s7 object?
	is_c_pointer                     :: proc(arg: Pointer) -> b8 --- // (c-pointer? arg)
	is_c_pointer_of_type             :: proc(arg: Pointer, type: Pointer) -> b8 ---
	c_pointer                        :: proc(p: Pointer) -> rawptr ---
	c_pointer_with_type              :: proc(sc: ^Scheme, p: Pointer, expected_type: Pointer, caller: cstring, argnum: i64) -> rawptr ---
	c_pointer_type                   :: proc(p: Pointer) -> Pointer ---
	make_c_pointer                   :: proc(sc: ^Scheme, ptr: rawptr) -> Pointer --- // these are for passing uninterpreted C pointers through Scheme
	make_c_pointer_with_type         :: proc(sc: ^Scheme, ptr: rawptr, type: Pointer, info: Pointer) -> Pointer ---
	make_c_pointer_wrapper_with_type :: proc(sc: ^Scheme, ptr: rawptr, type: Pointer, info: Pointer) -> Pointer ---

	eval_c_string                  :: proc(sc: ^Scheme, str: cstring) -> Pointer --- // (eval-string str)
	eval_c_string_with_environment :: proc(sc: ^Scheme, str: cstring, e: Pointer) -> Pointer ---
	object_to_string               :: proc(sc: ^Scheme, arg: Pointer, use_write: b8) -> Pointer --- // (object->string obj)
	object_to_c_string             :: proc(sc: ^Scheme, obj: Pointer) -> cstring --- // same as object->string but returns a C char* directly; the returned value should be freed by the caller


	load                           :: proc(sc: ^Scheme, file: cstring) -> Pointer --- // (load file)
	load_with_environment          :: proc(sc: ^Scheme, filename: cstring, e: Pointer) -> Pointer ---
	load_c_string                  :: proc(sc: ^Scheme, content: cstring, bytes: i64) -> Pointer ---
	load_c_string_with_environment :: proc(sc: ^Scheme, content: cstring, bytes: i64, e: Pointer) -> Pointer ---
	load_path                      :: proc(sc: ^Scheme) -> Pointer --- // *load-path*
	add_to_load_path               :: proc(sc: ^Scheme, dir: cstring) -> Pointer --- // (set! *load-path* (cons dir *load-path*))
	autoload                       :: proc(sc: ^Scheme, symbol: Pointer, file_or_function: Pointer) -> Pointer --- // (autoload symbol file-or-function)
	autoload_set_names             :: proc(sc: ^Scheme, names: [^]cstring, size: i64) ---
	// the load path is a list of directories to search if load can't find the file passed as its argument.
	// s7_load and s7_load_with_environment can load shared object files as well as scheme code.
	// The scheme (load "somelib.so" (inlet 'init_func 'somelib_init)) is equivalent to
	// s7_load_with_environment(s7, "somelib.so", s7_inlet(s7, s7_list(s7, 2, s7_make_symbol(s7, "init_func"), s7_make_symbol(s7, "somelib_init"))))
	// s7_load_with_environment returns NULL if it can't load the file.

	quit :: proc(sc: ^Scheme) --- // this tries to break out of the current evaluation, leaving everything else intact

	begin_hook     :: proc(sc: ^Scheme) -> proc "c" (sc: ^Scheme, val: ^b8) ---
	set_begin_hook :: proc(sc: ^Scheme, hook: proc "c" (sc: ^Scheme, val: ^b8)) ---
	// call "hook" at the start of any block; use NULL to cancel.
	// s7_begin_hook returns the current begin_hook function or NULL.


	eval               :: proc(sc: ^Scheme, code: Pointer, e: Pointer) -> Pointer --- // (eval code e) -- e is the optional environment
	eval_with_location :: proc(sc: ^Scheme, code: Pointer, e: Pointer, caller: cstring, file: cstring, line: i64) -> Pointer ---
	provide            :: proc(sc: ^Scheme, feature: cstring) --- // add feature (as a symbol) to the *features* list
	is_provided        :: proc(sc: ^Scheme, feature: cstring) -> b8 --- // (provided? feature)
	repl               :: proc(sc: ^Scheme) ---

	error                      :: proc(sc: ^Scheme, type: Pointer, info: Pointer) -> Pointer ---
	wrong_type_arg_error       :: proc(sc: ^Scheme, caller: cstring, arg_n: i64, arg: Pointer, descr: cstring) -> Pointer ---
	wrong_type_error           :: proc(sc: ^Scheme, caller: Pointer, arg_n: i64, arg: Pointer, descr: Pointer) -> Pointer ---
	// set arg_n to 0 to indicate that caller takes only one argument (so the argument number need not be reported
	out_of_range_error         :: proc(sc: ^Scheme, caller: cstring, arg_n: i64, arg: Pointer, descr: cstring) -> Pointer ---
	wrong_number_of_args_error :: proc(sc: ^Scheme, caller: cstring, args: Pointer) -> Pointer ---

	// these are equivalent to (error ...) in Scheme
	// the first argument to s7_error is a symbol that can be caught (via (catch tag ...))
	// the rest of the arguments are passed to the error handler (if in catch)
	// or printed out (in the default case).  If the first element of the list
	// of args ("info") is a string, the default error handler treats it as
	// a format control string, and passes it to format with the rest of the
	// info list as the format function arguments.
	// 
	// s7_wrong_type_arg_error is equivalent to s7_error with a type of 'wrong-type-arg
	// and similarly s7_out_of_range_error with type 'out-of-range.
	// 
	// catch in Scheme is taken from Guile:
	// 
	// (catch tag thunk handler)
	// 
	// evaluates 'thunk'.  If an error occurs, and the type matches 'tag' (or if 'tag' is #t),
	// the handler is called, passing it the arguments (including the type) passed to the
	// error function.  If no handler is found, the default error handler is called,
	// normally printing the error arguments to current-error-port.

	stacktrace          :: proc(sc: ^Scheme) -> Pointer ---
	history             :: proc(sc: ^Scheme) -> Pointer --- // the current (circular backwards) history buffer
	add_to_history      :: proc(sc: ^Scheme, entry: Pointer) -> Pointer --- // add entry to the history buffer
	history_enabled     :: proc(sc: ^Scheme) -> b8 ---
	set_history_enabled :: proc(sc: ^Scheme, enabled: b8) -> b8 ---

	gc_on :: proc(sc: ^Scheme, on: b8) -> Pointer --- // (gc on)

	gc_protect                :: proc(sc: ^Scheme, x: Pointer) -> i64 ---
	gc_unprotect_at           :: proc(sc: ^Scheme, loc: i64) ---
	gc_protected_at           :: proc(sc: ^Scheme, loc: i64) -> Pointer ---
	gc_protect_via_stack      :: proc(sc: ^Scheme, x: Pointer) -> Pointer ---
	gc_protect_2_via_stack    :: proc(sc: ^Scheme, x: Pointer, y: Pointer) -> Pointer ---
	gc_unprotect_via_stack    :: proc(sc: ^Scheme, x: Pointer) -> Pointer ---
	gc_protect_via_location   :: proc(sc: ^Scheme, x: Pointer, loc: i64) -> Pointer ---
	gc_unprotect_via_location :: proc(sc: ^Scheme, loc: i64) -> Pointer ---

	// any Pointer object held in C (as a local variable for example) needs to be
	//   protected from garbage collection if there is any chance the GC may run without
	//   an existing Scheme-level reference to that object.  s7_gc_protect places the
	//   object in a vector that the GC always checks, returning the object's location
	//   in that table.  s7_gc_unprotect_at unprotects the object (removes it from the
	//   vector) using the location passed to it.  s7_gc_protected_at returns the object
	//   at the given location.
	//
	// You can turn the GC on and off via s7_gc_on.
	//
	// There is a built-in lag between the creation of a new object and its first possible GC
	//    (the lag time is set indirectly by GC_TEMPS_SIZE in s7.c), so you don't need to worry about
	//    very short term temps such as the arguments to s7_cons in:
	//
	//    s7_cons(s7, s7_make_real(s7, 3.14), s7_cons(s7, s7_make_integer(s7, 123), s7_nil(s7)));

	is_eq         :: proc(a: Pointer, b: Pointer) -> b8 --- // (eq? a b)
	is_eqv        :: proc(sc: ^Scheme, a: Pointer, b: Pointer) -> b8 --- // (eqv? a b)
	is_equal      :: proc(sc: ^Scheme, a: Pointer, b: Pointer) -> b8 --- // (equal? a b)
	is_equivalent :: proc(sc: ^Scheme, x: Pointer, y: Pointer) -> b8 --- // (equivalent? x y)

	is_boolean   :: proc(x: Pointer) -> b8 --- // (boolean? x)
	boolean      :: proc(sc: ^Scheme, x: Pointer) -> b8 --- // Scheme boolean -> C bool
	make_boolean :: proc(sc: ^Scheme, x: b8) -> Pointer --- // C bool -> Scheme boolean

	// for each Scheme type (boolean, integer, string, etc), there are three
	//   functions: s7_<type>(...), s7_make_<type>(...), and s7_is_<type>(...):
	//
	//   s7_boolean(s7, obj) returns the C bool corresponding to the value of 'obj' (#f -> false)
	//   s7_make_boolean(s7, false|true) returns the s7 boolean corresponding to the C bool argument (false -> #f)
	//   s7_is_boolean(s7, obj) returns true if 'obj' has a boolean value (#f or #t).

	is_pair :: proc(p: Pointer) -> b8 --- // (pair? p)
	cons    :: proc(sc: ^Scheme, a: Pointer, b: Pointer) -> Pointer --- // (cons a b)

	car :: proc(p: Pointer) -> Pointer --- // (car p)
	cdr :: proc(p: Pointer) -> Pointer --- // (cdr p)

	set_car :: proc(p: Pointer, q: Pointer) -> Pointer --- // (set-car! p q)
	set_cdr :: proc(p: Pointer, q: Pointer) -> Pointer --- // (set-cdr! p q)

	cadr :: proc(p: Pointer) -> Pointer --- // (cadr p)
	cddr :: proc(p: Pointer) -> Pointer --- // (cddr p)
	cdar :: proc(p: Pointer) -> Pointer --- // (cdar p)
	caar :: proc(p: Pointer) -> Pointer --- // (caar p)

	caadr :: proc(p: Pointer) -> Pointer --- // etc
	caddr :: proc(p: Pointer) -> Pointer ---
	cadar :: proc(p: Pointer) -> Pointer ---
	caaar :: proc(p: Pointer) -> Pointer ---
	cdadr :: proc(p: Pointer) -> Pointer ---
	cdddr :: proc(p: Pointer) -> Pointer ---
	cddar :: proc(p: Pointer) -> Pointer ---
	cdaar :: proc(p: Pointer) -> Pointer ---

	caaadr :: proc(p: Pointer) -> Pointer ---
	caaddr :: proc(p: Pointer) -> Pointer ---
	caadar :: proc(p: Pointer) -> Pointer ---
	caaaar :: proc(p: Pointer) -> Pointer ---
	cadadr :: proc(p: Pointer) -> Pointer ---
	cadddr :: proc(p: Pointer) -> Pointer ---
	caddar :: proc(p: Pointer) -> Pointer ---
	cadaar :: proc(p: Pointer) -> Pointer ---
	cdaadr :: proc(p: Pointer) -> Pointer ---
	cdaddr :: proc(p: Pointer) -> Pointer ---
	cdadar :: proc(p: Pointer) -> Pointer ---
	cdaaar :: proc(p: Pointer) -> Pointer ---
	cddadr :: proc(p: Pointer) -> Pointer ---
	cddddr :: proc(p: Pointer) -> Pointer ---
	cdddar :: proc(p: Pointer) -> Pointer ---
	cddaar :: proc(p: Pointer) -> Pointer ---

	is_list        :: proc(sc: ^Scheme, p: Pointer) -> b8 --- // (list? p) -> (or (pair? p) (null? p))
	is_proper_list :: proc(sc: ^Scheme, p: Pointer) -> b8 --- // (proper-list? p)
	list_length    :: proc(sc: ^Scheme, a: Pointer) -> i64 --- // (length a)
	make_list      :: proc(sc: ^Scheme, len: i64, init: Pointer) -> Pointer --- // (make-list len init)
	list           :: proc(sc: ^Scheme, num_values: i64, #c_vararg args: ..any) -> Pointer --- // (list ...)
	list_nl        :: proc(sc: ^Scheme, num_values: i64, #c_vararg args: ..any) -> Pointer --- // (list ...) arglist should be NULL terminated (more error checks than s7_list)
	array_to_list  :: proc(sc: ^Scheme, num_values: i64, array: ^Pointer) -> Pointer --- // array contents -> list
	list_to_array  :: proc(sc: ^Scheme, list: Pointer, array: ^Pointer, len: i32) --- // list -> array (intended for old code)
	reverse        :: proc(sc: ^Scheme, a: Pointer) -> Pointer --- // (reverse a)
	append         :: proc(sc: ^Scheme, a: Pointer, b: Pointer) -> Pointer --- // (append a b)
	list_ref       :: proc(sc: ^Scheme, lst: Pointer, num: i64) -> Pointer --- // (list-ref lst num)
	list_set       :: proc(sc: ^Scheme, lst: Pointer, num: i64, val: Pointer) -> Pointer --- // (list-set! lst num val)
	assoc          :: proc(sc: ^Scheme, obj: Pointer, lst: Pointer) -> Pointer --- // (assoc obj lst)
	assq           :: proc(sc: ^Scheme, obj: Pointer, x: Pointer) -> Pointer --- // (assq obj lst)
	member         :: proc(sc: ^Scheme, obj: Pointer, lst: Pointer) -> Pointer --- // (member obj lst)
	memq           :: proc(sc: ^Scheme, obj: Pointer, x: Pointer) -> Pointer --- // (memq obj lst)
	tree_memq      :: proc(sc: ^Scheme, sym: Pointer, tree: Pointer) -> b8 --- // (tree-memq sym tree)


	is_string                       :: proc(p: Pointer) -> b8 --- // (string? p)
	string                          :: proc(p: Pointer) -> cstring --- // Scheme string -> C string (do not free the string)
	make_string                     :: proc(sc: ^Scheme, str: cstring) -> Pointer --- // C string -> Scheme string (str is copied)
	make_string_with_length         :: proc(sc: ^Scheme, str: cstring, len: i64) -> Pointer --- // same as s7_make_string, but provides strlen
	make_string_wrapper             :: proc(sc: ^Scheme, str: cstring) -> Pointer ---
	make_string_wrapper_with_length :: proc(sc: ^Scheme, str: cstring, len: i64) -> Pointer ---
	make_permanent_string           :: proc(sc: ^Scheme, str: cstring) -> Pointer --- // make a string that will never be GC'd
	make_semipermanent_string       :: proc(sc: ^Scheme, str: cstring) -> Pointer --- // for (s7) string permanent within one s7 instance (freed upon s7_free)

	string_length                   :: proc(str: Pointer) -> i64 --- // (string-length str)

	is_character   :: proc(p: Pointer) -> b8 --- // (character? p)
	character      :: proc(p: Pointer) -> u8 --- // Scheme character -> unsigned C char
	make_character :: proc(sc: ^Scheme, c: u8) -> Pointer --- // unsigned C char -> Scheme character


	is_number    :: proc(p: Pointer) -> b8 --- // (number? p)
	is_integer   :: proc(p: Pointer) -> b8 --- // (integer? p)
	integer      :: proc(p: Pointer) -> i64 --- // Scheme integer -> C integer (s7_int)
	make_integer :: proc(sc: ^Scheme, num: i64) -> Pointer --- // C s7_int -> Scheme integer

	is_real                       :: proc(p: Pointer) -> b8 --- // (real? p)
	real                          :: proc(p: Pointer) -> f64 --- // Scheme real -> C double
	make_real                     :: proc(sc: ^Scheme, num: f64) -> Pointer --- // C double -> Scheme real
	make_mutable_real             :: proc(sc: ^Scheme, n: f64) -> Pointer ---
	number_to_real                :: proc(sc: ^Scheme, x: Pointer) -> f64 --- // x can be any kind of number
	number_to_real_with_caller    :: proc(sc: ^Scheme, x: Pointer, caller: cstring) -> f64 ---
	number_to_real_with_location  :: proc(sc: ^Scheme, x: Pointer, caller: Pointer) -> f64 ---
	number_to_integer             :: proc(sc: ^Scheme, x: Pointer) -> i64 ---
	number_to_integer_with_caller :: proc(sc: ^Scheme, x: Pointer, caller: cstring) -> i64 ---

	is_rational              :: proc(arg: Pointer) -> b8 --- // (rational? arg) -- integer or ratio
	is_ratio                 :: proc(arg: Pointer) -> b8 --- // true if arg is a ratio, not an integer
	make_ratio               :: proc(sc: ^Scheme, a: i64, b: i64) -> Pointer --- // returns the Scheme object a/b
	rationalize              :: proc(sc: ^Scheme, x: f64, error: f64) -> Pointer --- // (rationalize x error)
	numerator                :: proc(x: Pointer) -> i64 --- // (numerator x)
	denominator              :: proc(x: Pointer) -> i64 --- // (denominator x)
	random                   :: proc(sc: ^Scheme, state: Pointer) -> f64 --- // (random x)
	random_state             :: proc(sc: ^Scheme, seed: Pointer) -> Pointer --- // (random-state seed)
	random_state_to_list     :: proc(sc: ^Scheme, args: Pointer) -> Pointer --- // (random-state->list r)
	set_default_random_state :: proc(sc: ^Scheme, seed: i64, carry: i64) ---
	is_random_state          :: proc(p: Pointer) -> b8 --- // (random-state? p)

	is_complex       :: proc(arg: Pointer) -> cstring --- // (complex? arg)
	make_complex     :: proc(sc: ^Scheme, a: f64, b: f64) -> f64 --- // returns the Scheme object a+bi
	real_part        :: proc(z: Pointer) -> f64 --- // (real-part z)
	imag_part        :: proc(z: Pointer) -> Pointer --- // (imag-part z)
	number_to_string :: proc(sc: ^Scheme, obj: Pointer, radix: i64) -> b8 --- // (number->string obj radix)

	is_vector             :: proc(p: Pointer) -> b8 --- // (vector? p)
	vector_length         :: proc(vec: Pointer) -> i64 --- // (vector-length vec)
	vector_rank           :: proc(vect: Pointer) -> i64 --- // number of dimensions in vect
	vector_dimension      :: proc(vec: Pointer, dim: i64) -> i64 ---
	vector_elements       :: proc(vec: Pointer) -> [^]Pointer --- // a pointer to the array of s7_pointers
	int_vector_elements   :: proc(vec: Pointer) -> [^]i64 ---
	byte_vector_elements  :: proc(vec: Pointer) -> [^]u8 ---
	float_vector_elements :: proc(vec: Pointer) -> [^]f64 ---
	is_float_vector       :: proc(p: Pointer) -> b8 --- // (float-vector? p)
	is_complex_vector     :: proc(p: Pointer) -> b8 --- // (complex-vector? p)
	is_int_vector         :: proc(p: Pointer) -> b8 --- // (int-vector? p)
	is_byte_vector        :: proc(p: Pointer) -> b8 --- // (byte-vector? p)

	vector_ref        :: proc(sc: ^Scheme, vec: Pointer, index: i64) -> Pointer --- // (vector-ref vec index)
	vector_set        :: proc(sc: ^Scheme, vec: Pointer, index: i64, a: Pointer) -> Pointer --- // (vector-set! vec index a)
	vector_ref_n      :: proc(sc: ^Scheme, vector: Pointer, indices: i64, #c_vararg args: ..any) -> Pointer --- // multidimensional vector-ref
	vector_set_n      :: proc(sc: ^Scheme, vector: Pointer, value: Pointer, indices: i64, #c_vararg args: ..any) -> Pointer --- // multidimensional vector-set!
	vector_dimensions :: proc(vec: Pointer, dims: [^]i64, dims_size: i64) -> i64 --- // vector dimensions
	vector_offsets    :: proc(vec: Pointer, offs: [^]i64, offs_size: i64) -> i64 ---

	int_vector_ref   :: proc(vec: Pointer, index: i64) -> i64 ---
	int_vector_set   :: proc(vec: Pointer, index: i64, value: i64) -> i64 ---
	byte_vector_ref  :: proc(vec: Pointer, index: i64) -> u8 ---
	byte_vector_set  :: proc(vec: Pointer, index: i64, value: u8) -> u8 ---
	float_vector_ref :: proc(vec: Pointer, index: i64) -> f64 ---
	float_vector_set :: proc(vec: Pointer, index: i64, value: f64) -> f64 ---

	make_vector               :: proc(sc: ^Scheme, len: i64) -> Pointer --- // (make-vector len)
	make_normal_vector        :: proc(sc: ^Scheme, len: i64, dims: i64, dim_info: ^i64) -> Pointer --- // make-vector but possibly multidimensional
	make_and_fill_vector      :: proc(sc: ^Scheme, len: i64, fill: Pointer) -> Pointer --- // (make-vector len fill)
	make_int_vector           :: proc(sc: ^Scheme, len: i64, dims: i64, dim_info: ^i64) -> Pointer ---
	make_byte_vector          :: proc(sc: ^Scheme, len: i64, dims: i64, dim_info: ^i64) -> Pointer ---
	make_float_vector         :: proc(sc: ^Scheme, len: i64, dims: i64, dim_info: ^i64) -> Pointer ---
	make_float_vector_wrapper :: proc(sc: ^Scheme, len: i64, data: ^f64, dims: i64, dim_info: ^i64, free_data: b8) -> Pointer ---

	// TODO
	// #if (!__TINYC__) && ((!defined(__clang__)) || (!__cplusplus))
	//   Pointer s7_make_complex_vector(sc: ^Scheme, len: i64, i64 dims, i64 *dim_info);
	//   Pointer s7_make_complex_vector_wrapper(sc: ^Scheme, len: i64, s7_complex *data, i64 dims, i64 *dim_info, b8 free_data);
	//   s7_complex *s7_complex_vector_elements(Pointer vec);
	//   s7_complex s7_complex_vector_ref(Pointer vec, i64 index);
	//   s7_complex s7_complex_vector_set(Pointer vec, i64 index, s7_complex value);
	// #endif

	vector_fill    :: proc(sc: ^Scheme, vec: Pointer, obj: Pointer) --- // (vector-fill! vec obj)
	vector_copy    :: proc(sc: ^Scheme, old_vect: Pointer) -> Pointer ---
	vector_to_list :: proc(sc: ^Scheme, vect: Pointer) -> Pointer --- // (vector->list vec)

	//  (vect i) is the same as (vector-ref vect i)
	//  (set! (vect i) x) is the same as (vector-set! vect i x)
	//  (vect i j k) accesses the 3-dimensional vect
	//  (set! (vect i j k) x) sets that element (vector-ref and vector-set! can also be used)
	//  (make-vector (list 2 3 4)) returns a 3-dimensional vector with the given dimension sizes
	//  (make-vector '(2 3) 1.0) returns a 2-dim vector with all elements set to 1.0

	is_hash_table   :: proc(p: Pointer) -> b8 --- // (hash-table? p)
	make_hash_table :: proc(sc: ^Scheme, size: i64) -> Pointer --- // (make-hash-table size)
	hash_table_ref  :: proc(sc: ^Scheme, table: Pointer, key: Pointer) -> Pointer --- // (hash-table-ref table key)
	hash_table_set  :: proc(sc: ^Scheme, table: Pointer, key: Pointer, value: Pointer) -> Pointer --- // (hash-table-set! table key value)
	hash_code       :: proc(sc: ^Scheme, obj: Pointer, eqfunc: Pointer) -> i64 --- // (hash-code obj [eqfunc])

	hook_functions :: proc(sc: ^Scheme, hook: Pointer) -> Pointer --- // (hook-functions hook)
	hook_set_functions :: proc(sc: ^Scheme, hook: Pointer, functions: Pointer) -> Pointer --- // (set! (hook-functions hook) ...)


	is_input_port    :: proc(sc: ^Scheme, p: Pointer) -> b8 --- // (input-port? p)
	is_output_port   :: proc(sc: ^Scheme, p: Pointer) -> b8 --- // (output-port? p)
	port_filename    :: proc(sc: ^Scheme, x: Pointer) -> cstring --- // (port-filename p)
	port_line_number :: proc(sc: ^Scheme, p: Pointer) -> i64 --- // (port-line-number p)

	current_input_port      :: proc(sc: ^Scheme) -> Pointer --- // (current-input-port)
	set_current_input_port  :: proc(sc: ^Scheme, p: Pointer) -> Pointer --- // (set-current-input-port)
	current_output_port     :: proc(sc: ^Scheme) -> Pointer --- // (current-output-port)
	set_current_output_port :: proc(sc: ^Scheme, p: Pointer) -> Pointer --- // (set-current-output-port)
	current_error_port      :: proc(sc: ^Scheme) -> Pointer --- // (current-error-port)
	set_current_error_port  :: proc(sc: ^Scheme, port: Pointer) -> Pointer --- // (set-current-error-port port)
	close_input_port        :: proc(sc: ^Scheme, p: Pointer) --- // (close-input-port p)
	close_output_port       :: proc(sc: ^Scheme, p: Pointer) --- // (close-output-port p)
	open_input_file         :: proc(sc: ^Scheme, name: cstring, mode: cstring) -> Pointer --- // (open-input-file name mode)

	open_output_file   :: proc(sc: ^Scheme, name: cstring, mode: cstring) -> Pointer --- // (open-output-file name mode)
	// mode here is an optional C style flag, "a" for "alter", etc ("r" is the input default, "w" is the output default)
	open_input_string  :: proc(sc: ^Scheme, input_string: cstring) -> Pointer --- // (open-input-string str)
	open_output_string :: proc(sc: ^Scheme) -> Pointer --- // (open-output-string)
	get_output_string  :: proc(sc: ^Scheme, out_port: Pointer) -> cstring --- // (get-output-string port) -- current contents of output string
	// don't free the string
	output_string      :: proc(sc: ^Scheme, p: Pointer) -> Pointer --- //    same but returns an s7 string
	flush_output_port  :: proc(sc: ^Scheme, p: Pointer) -> b8 --- // (flush-output-port port)

	open_output_function :: proc(sc: ^Scheme, function: proc "c" (sc: ^Scheme, c: u8, port: Pointer)) -> Pointer ---
	open_input_function  :: proc(sc: ^Scheme, function: proc "c" (sc: ^Scheme, read_choice: Read, port: Pointer) -> Pointer) -> Pointer ---

	read_char  :: proc(sc: ^Scheme, port: Pointer) -> Pointer --- // (read-char port)
	peek_char  :: proc(sc: ^Scheme, port: Pointer) -> Pointer --- // (peek-char port)
	read       :: proc(sc: ^Scheme, port: Pointer) -> Pointer --- // (read port)
	newline    :: proc(sc: ^Scheme, port: Pointer) --- // (newline port)
	write_char :: proc(sc: ^Scheme, c: Pointer, port: Pointer) -> Pointer --- // (write-char c port)
	write      :: proc(sc: ^Scheme, obj: Pointer, port: Pointer) -> Pointer --- // (write obj port)
	display    :: proc(sc: ^Scheme, obj: Pointer, port: Pointer) -> Pointer --- // (display obj port)
	format     :: proc(sc: ^Scheme, args: Pointer) -> cstring --- // (format ...)


	is_syntax   :: proc(p: Pointer) -> Pointer --- // (syntax? p)
	is_symbol   :: proc(p: Pointer) -> Pointer --- // (symbol? p)
	symbol_name :: proc(p: Pointer) -> cstring --- // (symbol->string p) -- don't free the string
	make_symbol :: proc(sc: ^Scheme, name: cstring) -> b8 --- // (string->symbol name)
	gensym      :: proc(sc: ^Scheme, prefix: cstring) -> b8 --- // (gensym prefix)

	is_keyword        :: proc(obj: Pointer) -> b8 --- // (keyword? obj)
	make_keyword      :: proc(sc: ^Scheme, key: cstring) -> Pointer --- // (string->keyword key)
	keyword_to_symbol :: proc(sc: ^Scheme, key: Pointer) -> Pointer --- // (keyword->symbol key)

	rootlet            :: proc(sc: ^Scheme) -> Pointer --- // (rootlet)
	shadow_rootlet     :: proc(sc: ^Scheme) -> Pointer ---
	set_shadow_rootlet :: proc(sc: ^Scheme, let: Pointer) -> Pointer ---
	curlet             :: proc(sc: ^Scheme) -> Pointer --- // (curlet)
	set_curlet         :: proc(sc: ^Scheme, e: Pointer) -> Pointer --- // returns previous curlet
	outlet             :: proc(sc: ^Scheme, e: Pointer) -> Pointer --- // (outlet e)
	sublet             :: proc(sc: ^Scheme, env: Pointer, bindings: Pointer) -> Pointer --- // (sublet e ...)
	inlet              :: proc(sc: ^Scheme, bindings: Pointer) -> Pointer --- // (inlet ...)
	varlet             :: proc(sc: ^Scheme, env: Pointer, symbol: Pointer, value: Pointer) -> Pointer --- // (varlet env symbol value)
	let_to_list        :: proc(sc: ^Scheme, env: Pointer) -> Pointer --- // (let->list env)
	is_let             :: proc(e: Pointer) -> b8 --- // (let? e)
	let_ref            :: proc(sc: ^Scheme, env: Pointer, sym: Pointer) -> Pointer --- // (let-ref e sym)
	let_set            :: proc(sc: ^Scheme, env: Pointer, sym: Pointer, val: Pointer) -> Pointer --- // (let-set! e sym val)
	openlet            :: proc(sc: ^Scheme, e: Pointer) -> Pointer --- // (openlet e)
	is_openlet         :: proc(e: Pointer) -> b8 --- // (openlet? e)
	method             :: proc(sc: ^Scheme, obj: Pointer, method: Pointer) -> Pointer ---

	// *s7*
	// these renamed because "s7_let_field" seems the same as "s7_let", but here we're referring to *s7*, not any let
	let_field_ref :: proc(sc: ^Scheme, sym: Pointer) -> Pointer --- // (*s7* sym)
	let_field_set :: proc(sc: ^Scheme, sym: Pointer, new_value: Pointer) -> Pointer --- // (set! (*s7* sym) new_value)
	// /* new names */
	starlet_ref :: proc(sc: ^Scheme, sym: Pointer) -> Pointer --- // (*s7* sym)
	starlet_set :: proc(sc: ^Scheme, sym: Pointer, new_value: Pointer) -> Pointer --- // (set! (*s7* sym) new_value)

	name_to_value            :: proc(sc: ^Scheme, name: cstring) -> Pointer --- // name's value in the current environment (after turning name into a symbol)
	symbol_table_find_name   :: proc(sc: ^Scheme, name: cstring) -> Pointer ---
	symbol_value             :: proc(sc: ^Scheme, sym: Pointer) -> Pointer ---
	symbol_set_value         :: proc(sc: ^Scheme, sym: Pointer, val: Pointer) -> Pointer ---
	symbol_local_value       :: proc(sc: ^Scheme, sym: Pointer, local_env: Pointer) -> Pointer ---
	symbol_initial_value     :: proc(symbol: Pointer) -> Pointer --- // #_symbol's value
	symbol_set_initial_value :: proc(sc: ^Scheme, symbol: Pointer, value: Pointer) -> Pointer ---

	for_each_symbol_name :: proc(sc: ^Scheme, symbol_func: proc "c" (symbol_name: cstring, data: rawptr) -> b8, data: rawptr) -> b8 ---
	for_each_symbol      :: proc(sc: ^Scheme, symbol_func: proc "c" (symbol_name: cstring, data: rawptr) -> b8, data: rawptr) -> b8 ---

	// these access the current environment and symbol table, providing
	//   a symbol's current binding (s7_name_to_value takes the symbol name as a char*,
	//   s7_symbol_value takes the symbol itself, s7_symbol_set_value changes the
	//   current binding, and s7_symbol_local_value uses the environment passed
	//   as its third argument).
	//
	// To iterate over the complete symbol table, use s7_for_each_symbol_name,
	//   and s7_for_each_symbol.  Both call 'symbol_func' on each symbol, passing it
	//   the symbol or symbol name, and the uninterpreted 'data' pointer.
	//   the current binding. The for-each loop stops if the symbol_func returns true,
	//   or at the end of the table.
	//
	
	dynamic_wind  :: proc(sc: ^Scheme, init: Pointer, body: Pointer, finish: Pointer) -> Pointer ---

	is_immutable  :: proc(p: Pointer) -> b8 ---
	set_immutable :: proc(sc: ^Scheme, p: Pointer) -> Pointer ---
	// TODO
	// #if (!DISABLE_DEPRECATED)
	//   Pointer s7_immutable(p: Pointer);
	// #endif

	define                             :: proc(sc: ^Scheme, env: Pointer, symbol: Pointer, value: Pointer) ---
	is_defined                         :: proc(sc: ^Scheme, name: cstring) -> b8 ---
	define_variable                    :: proc(sc: ^Scheme, name: cstring, value: Pointer) -> Pointer ---
	define_variable_with_documentation :: proc(sc: ^Scheme, name: cstring, value: Pointer, help: cstring) -> Pointer ---
	define_constant                    :: proc(sc: ^Scheme, name: cstring, value: Pointer) -> Pointer ---
	define_constant_with_documentation :: proc(sc: ^Scheme, name: cstring, value: Pointer, help: cstring) -> Pointer ---
	define_constant_with_environment   :: proc(sc: ^Scheme, envir: Pointer, name: cstring, value: Pointer) -> Pointer ---
	// These functions add a symbol and its binding to either the top-level environment
	//    or the 'env' passed as the second argument to s7_define.  Except for s7_define, they return
	//    the name as a symbol.
	//
	//    s7_define_variable(sc, "*features*", s7_nil(sc));
	//
	// in s7.c is equivalent to the top level form
	//
	//    (define *features* ())
	//
	// s7_define_variable is simply s7_define with string->symbol and the global environment.
	// s7_define_constant is s7_define but makes its "definee" immutable.
	// s7_define is equivalent to define in Scheme, except that it does not return the value.


	is_function       :: proc(p: Pointer) -> b8 ---
	is_procedure      :: proc(x: Pointer) -> b8 --- // (procedure? x)
	is_macro          :: proc(sc: ^Scheme, x: Pointer) -> b8 --- // (macro? x)
	closure_body      :: proc(sc: ^Scheme, p: Pointer) -> Pointer ---
	closure_let       :: proc(sc: ^Scheme, p: Pointer) -> Pointer ---
	closure_args      :: proc(sc: ^Scheme, p: Pointer) -> Pointer ---
	funclet           :: proc(sc: ^Scheme, p: Pointer) -> Pointer --- // (funclet x)
	is_aritable       :: proc(sc: ^Scheme, x: Pointer, args: i64) -> b8 --- // (aritable? x args)
	arity             :: proc(sc: ^Scheme, x: Pointer) -> Pointer --- // (arity x)
	help              :: proc(sc: ^Scheme, obj: Pointer) -> cstring --- // (help obj)
	make_continuation :: proc(sc: ^Scheme) -> Pointer --- // call/cc... (see example below)
	function_let      :: proc(sc: ^Scheme, obj: Pointer) -> Pointer --- // obj is from s7_make_c_function and friends

	documentation           :: proc(sc: ^Scheme, p: Pointer) -> Pointer --- // (documentation x) if any (don't free the string)
	set_documentation       :: proc(sc: ^Scheme, p: Pointer, new_doc: cstring) -> Pointer ---
	setter :: proc(sc: ^Scheme, obj: Pointer) -> Pointer --- // (setter obj)
	set_setter              :: proc(sc: ^Scheme, p: Pointer, setter: Pointer) -> Pointer --- // (set! (setter p) setter)
	signature               :: proc(sc: ^Scheme, func: Pointer) -> Pointer --- // (signature obj)
	make_signature          :: proc(sc: ^Scheme, len: i64, #c_vararg args: ..any) -> cstring --- // procedure-signature data
	make_circular_signature :: proc(sc: ^Scheme, cycle_point: i64, len: i64, #c_vararg args: ..any) -> cstring ---

	// possibly unsafe functions:
	make_function :: proc(sc: ^Scheme, name: cstring, fnc: Function, required_args: i64, optional_args: i64, rest_arg: b8, doc: cstring) -> Pointer ---

	// safe functions:
	make_safe_function                   :: proc(sc: ^Scheme, name: cstring, fnc: Function, required_args: i64, optional_args: i64, rest_arg: b8, doc: cstring) -> Pointer ---
	make_typed_function                  :: proc(sc: ^Scheme, name: cstring, fnc: Function, required_args: i64, optional_args: i64, rest_arg: b8, doc: cstring, signature: Pointer) -> Pointer ---
	make_typed_function_with_environment :: proc(sc: ^Scheme, name: cstring, fnc: Function, required_args: i64, optional_args: i64, rest_arg: b8, doc: cstring, signature: Pointer, let: Pointer) -> Pointer ---

	// arglist or body possibly unsafe:
	define_function :: proc(sc: ^Scheme, name: cstring, fnc: Function, required_args: i64, optional_args: i64, rest_arg: b8, doc: cstring) -> Pointer ---

	// arglist and body safe:
	define_safe_function  :: proc(sc: ^Scheme , name: cstring, fnc: Function, required_args: i64, optional_args: i64, rest_arg: b8, doc: cstring) -> Pointer ---
	define_typed_function :: proc(sc: ^Scheme, name: cstring, fnc: Function, required_args: i64, optional_args: i64, rest_arg: b8, doc: cstring, signature: Pointer) -> Pointer ---

	// arglist unsafe or body unsafe:
	define_unsafe_typed_function   :: proc(sc: ^Scheme, name: cstring, fnc: Function, required_args: i64, optional_args: i64, rest_arg: b8, doc: cstring, signature: Pointer) -> Pointer ---

	// arglist safe, body possibly unsafe:
	define_semisafe_typed_function :: proc(sc: ^Scheme, name: cstring, fnc: Function, required_args: i64, optional_args: i64, rest_arg: b8, doc: cstring, signature: Pointer) -> Pointer ---

	make_function_star         :: proc(sc: ^Scheme, name: cstring, fnc: Function, arglist: cstring, doc: cstring) -> Pointer ---
	make_safe_function_star    :: proc(sc: ^Scheme, name: cstring, fnc: Function, arglist: cstring, doc: cstring) -> Pointer ---
	define_function_star       :: proc(sc: ^Scheme, name: cstring, fnc: Function, arglist: cstring, doc: cstring) ---
	define_safe_function_star  :: proc(sc: ^Scheme, name: cstring, fnc: Function, arglist: cstring, doc: cstring) ---
	define_typed_function_star :: proc(sc: ^Scheme, name: cstring, fnc: Function, arglist: cstring, doc: cstring, signature: Pointer) ---
	define_macro               :: proc(sc: ^Scheme, name: cstring, fnc: Function, required_args: i64, optional_args: i64, rest_arg: b8, doc: cstring) -> Pointer ---
	define_expansion           :: proc(sc: ^Scheme, name: cstring, fnc: Function, required_args: i64, optional_args: i64, rest_arg: b8, doc: cstring) -> Pointer ---
	
	// s7_make_function creates a Scheme function object from the s7_function 'fnc'.
	//   Its name (for s7_describe_object) is 'name', it requires 'required_args' arguments,
	//   can accept 'optional_args' other arguments, and if 'rest_arg' is true, it accepts
	//   a "rest" argument (a list of all the trailing arguments).  The function's documentation
	//   is 'doc'.  The s7_make_functions return the new function, but the s7_define_function (and macro)
	//   procedures return the name as a symbol (a desire for backwards compatibility brought about this split).
	//
	// s7_define_function is the same as s7_make_function, but it also adds 'name' (as a symbol) to the
	//   global (top-level) environment, with the function as its value (and returns the symbol, not the function).
	//   For example, the Scheme function 'car' is essentially:
	//
	//     Pointer g_car(sc: ^Scheme, args: Pointer) {return(s7_car(s7_car(args)));}
	//
	//   then bound to the name "car":
	//
	//     s7_define_function(sc, "car", g_car, 1, 0, false, "(car obj)");
	//                                          ^ one required arg, no optional arg, no "rest" arg
	//
	// s7_is_function returns true if its argument is a function defined in this manner.
	// s7_apply_function applies the function (the result of s7_make_function) to the arguments.
	//
	// s7_define_macro defines a Scheme macro; its arguments are not evaluated (unlike a function),
	//   but the macro's returned value (assumed to be some sort of Scheme expression) is evaluated.
	//   s7_define_macro returns the name as a symbol.
	//
	// Use the "unsafe" definer if the function might call the evaluator itself in some way (s7_apply_function for example),
	//   or messes with s7's stack.
 
	// In s7, (define* (name . args) body) or (define name (lambda* args body))
	//   define a function that takes optional (keyword) named arguments.
	//   The "args" is a list that can contain either names (normal arguments),
	//   or lists of the form (name default-value), in any order.  When called,
	//   the names are bound to their default values (or #f), then the function's
	//   current arglist is scanned.  Any name that occurs as a keyword (":name")
	//   precedes that argument's new value.  Otherwise, as values occur, they
	//   are plugged into the environment based on their position in the arglist
	//   (as normal for a function).  So,
	//
	//   (define* (hi a (b 32) (c "hi")) (list a b c))
	//     (hi 1) -> '(1 32 "hi")
	//     (hi :b 2 :a 3) -> '(3 2 "hi")
	//     (hi 3 2 1) -> '(3 2 1)
	//
	//   :rest causes its argument to be bound to the rest of the arguments at that point.
	//
	// The C connection to this takes the function name, the C function to call, the argument
	//   list as written in Scheme, and the documentation string.  s7 makes sure the arguments
	//   are ordered correctly and have the specified defaults before calling the C function.
	//     s7_define_function_star(sc, "a-func", a_func, "arg1 (arg2 32)", "an example of C define*");
	//   Now (a-func :arg1 2) calls the C function a_func(2, 32). See the example program in s7.html.
	//
	// In s7 Scheme, define* can be used just for its optional arguments feature, but that is
	//   included in s7_define_function.  s7_define_function_star implements keyword arguments
	//   for C-level functions (as well as optional/rest arguments).
	//

	apply_function      :: proc(sc: ^Scheme, fnc: Pointer, args: Pointer) -> Pointer ---
	apply_function_star :: proc(sc: ^Scheme, fnc: Pointer, args: Pointer) -> Pointer ---

	call               :: proc(sc: ^Scheme, func: Pointer, args: Pointer) -> Pointer ---
	call_with_location :: proc(sc: ^Scheme, func: Pointer, args: Pointer, caller: cstring, file: cstring, line: i64) -> Pointer ---
	call_with_catch    :: proc(sc: ^Scheme, tag: Pointer, body: Pointer, error_handler: Pointer) -> Pointer ---

	// s7_call takes a Scheme function and applies it to 'args' (a list of arguments) returning the result.
	//   Pointer kar;
	//   kar = s7_make_function(sc, "car", g_car, 1, 0, false, "(car obj)");
	//   s7_integer(s7_call(sc, kar, s7_cons(sc, s7_cons(sc, s7_make_integer(sc, 123), s7_nil(sc)), s7_nil(sc))));
	//   returns 123.
	//
	// s7_call_with_location passes some information to the error handler.
	// s7_call makes sure some sort of catch exists if an error occurs during the call, but
	//   s7_apply_function does not -- it assumes the catch has been set up already.
	// s7_call_with_catch wraps an explicit catch around a function call ("body" above);
	//   s7_call_with_catch(sc, tag, body, err) is equivalent to (catch tag body err).
	//
	
	is_dilambda               :: proc(obj: Pointer) -> b8 ---
	dilambda                  :: proc(sc: ^Scheme, name: cstring, getter: proc "c" (sc: ^Scheme, args: Pointer) -> Pointer, get_req_args: i64, get_opt_args: i64, setter: proc "c" (sc: ^Scheme, args: Pointer) -> Pointer, set_req_args: i64, set_opt_args: i64, documentation: cstring) -> Pointer ---
	typed_dilambda            :: proc(sc: ^Scheme, name: cstring, getter: proc "c" (sc: ^Scheme, args: Pointer) -> Pointer, get_req_args: i64, get_opt_args: i64, setter: proc "c" (sc: ^Scheme, args: Pointer) -> Pointer, set_req_args: i64, set_opt_args: i64, documentation: cstring, get_sig: Pointer, set_sig: Pointer) -> Pointer ---
	dilambda_with_environment :: proc(sc: ^Scheme, envir: Pointer, name: cstring, getter: proc "c" (sc: ^Scheme, args: Pointer) -> Pointer, get_req_args: i64, get_opt_args: i64, setter: proc "c" (sc: ^Scheme, args: Pointer) -> Pointer, set_req_args: i64, set_opt_args: i64, documentation: cstring) -> Pointer ---

	values            :: proc(sc: ^Scheme, args: Pointer) -> Pointer --- // (values ...)
	is_multiple_value :: proc(obj: Pointer) -> b8 --- // is obj the results of (values ...)

	make_iterator      :: proc(sc: ^Scheme, e: Pointer) -> Pointer --- // (make-iterator e)
	is_iterator        :: proc(obj: Pointer) -> b8 --- // (iterator? obj)
	iterator_is_at_end :: proc(sc: ^Scheme, obj: Pointer) -> b8 --- // (iterator-at-end? obj)
	iterate            :: proc(sc: ^Scheme, iter: Pointer) -> Pointer --- // (iterate iter)

	copy    :: proc(sc: ^Scheme, args: Pointer) -> Pointer --- // (copy ...)
	fill    :: proc(sc: ^Scheme, args: Pointer) -> Pointer --- // (fill! ...)
	type_of :: proc(sc: ^Scheme, arg: Pointer) -> Pointer --- // (type-of arg)



	// --------------------------------------------------------------------------------
	// c types/objects
	// 
	mark :: proc(p: Pointer) ---

	is_c_object              :: proc(p: Pointer) -> b8 ---
	c_object_type            :: proc(obj: Pointer) -> i64 ---
	c_object_value           :: proc(obj: Pointer) -> rawptr ---
	c_object_value_checked   :: proc(obj: Pointer, type: i64) -> rawptr ---
	make_c_object            :: proc(sc: ^Scheme, type: i64, value: rawptr) -> Pointer ---
	make_c_object_with_let   :: proc(sc: ^Scheme, type: i64, value: rawptr, let: Pointer) -> Pointer ---
	make_c_object_without_gc :: proc(sc: ^Scheme, type: i64, value: rawptr) -> Pointer ---
	c_object_let             :: proc(obj: Pointer) -> Pointer ---
	c_object_set_let         :: proc(sc: ^Scheme, obj: Pointer, e: Pointer) -> Pointer ---
	// the "let" in s7_make_c_object_with_let and s7_c_object_set_let needs to be GC protected by marking it in the c_object's mark function

	make_c_type :: proc(sc: ^Scheme, name: cstring) -> i64 --- // create a new c_object type

	// old style free/mark/equal
	c_type_set_free  :: proc(sc: ^Scheme, tag: i64, gc_free: proc "c" (value: rawptr)) ---
	c_type_set_mark  :: proc(sc: ^Scheme, tag: i64, mark: proc "c" (value: rawptr)) ---
	c_type_set_equal :: proc(sc: ^Scheme, tag: i64, equal: proc "c" (value1: rawptr, value2: rawptr) -> b8) ---

	// new style free/mark/equal and equivalent
	c_type_set_gc_free       :: proc(sc: ^Scheme, tag: i64, gc_free:       proc "c" (sc: ^Scheme, obj: Pointer ) -> Pointer) --- // free c_object function, new style
	c_type_set_gc_mark       :: proc(sc: ^Scheme, tag: i64, mark:          proc "c" (sc: ^Scheme, obj: Pointer ) -> Pointer) --- // mark function, new style
	c_type_set_is_equal      :: proc(sc: ^Scheme, tag: i64, is_equal:      proc "c" (sc: ^Scheme, args: Pointer) -> Pointer) --- 
	c_type_set_is_equivalent :: proc(sc: ^Scheme, tag: i64, is_equivalent: proc "c" (sc: ^Scheme, args: Pointer) -> Pointer) --- 

	c_type_set_ref       :: proc(sc: ^Scheme, tag: i64, ref:       proc(sc: ^Scheme, args: Pointer) -> Pointer) ---
	c_type_set_set       :: proc(sc: ^Scheme, tag: i64, set:       proc(sc: ^Scheme, args: Pointer) -> Pointer) ---
	c_type_set_length    :: proc(sc: ^Scheme, tag: i64, length:    proc(sc: ^Scheme, args: Pointer) -> Pointer) ---
	c_type_set_copy      :: proc(sc: ^Scheme, tag: i64, copy:      proc(sc: ^Scheme, args: Pointer) -> Pointer) ---
	c_type_set_fill      :: proc(sc: ^Scheme, tag: i64, fill:      proc(sc: ^Scheme, args: Pointer) -> Pointer) ---
	c_type_set_reverse   :: proc(sc: ^Scheme, tag: i64, reverse:   proc(sc: ^Scheme, args: Pointer) -> Pointer) ---
	c_type_set_to_list   :: proc(sc: ^Scheme, tag: i64, to_list:   proc(sc: ^Scheme, args: Pointer) -> Pointer) ---
	c_type_set_to_string :: proc(sc: ^Scheme, tag: i64, to_string: proc(sc: ^Scheme, args: Pointer) -> Pointer) ---
	c_type_set_getter    :: proc(sc: ^Scheme, tag: i64, getter: Pointer) ---
	c_type_set_setter    :: proc(sc: ^Scheme, tag: i64, setter: Pointer) ---
	// For the copy function, either the first or second argument can be a c-object of the given type.

	// These functions create a new Scheme object type.  There is a simple example in s7.html.
	//
	// s7_make_c_type creates a new C-based type for Scheme.  It returns an i64 "tag" used to indentify this type elsewhere.
	//   The functions associated with this type are set via s7_c_type_set*:
	//
	//   free:          the function called when an object of this type is about to be garbage collected
	//   mark:          called during the GC mark pass -- you should call s7_mark
	//                  on any embedded associated: Pointer with the object (including its "let") to protect if from the GC.
	//   gc_mark and gc_free are new forms of mark and free, taking the c_object Pointer rather than its void* value
	//   equal:         compare two objects of this type; (equal? obj1 obj2) -- this is the old form
	//   is_equal:      compare objects as in equal? -- this is the new form of equal?
	//   is_equivalent: compare objects as in equivalent?
	//   ref:           a function that is called whenever an object of this type
	//                  occurs in the function position (at the car of a list; the rest of the list
	//                  is passed to the ref function as the arguments: (obj ...))
	//   set:           a function that is called whenever an object of this type occurs as
	//                  the target of a generalized set! (set! (obj ...) val)
	//   length:        the function called when the object is asked what its length is.
	//   copy:          the function called when a copy of the object is needed.
	//   fill:          the function called to fill the object with some value.
	//   reverse:       similarly...
	//   to_string:     object->string for an object of this type
	//   getter/setter: these help the optimizer handle applicable c-objects (see s7test.scm for an example)
	//
	// s7_is_c_object returns true if 'p' is a c_object
	// s7_c_object_type returns the c_object's type (the i64 passed to s7_make_c_object)
	// s7_c_object_value returns the value bound to that c_object (the void *value of s7_make_c_object)
	// s7_make_c_object creates a new Scheme entity of the given type with the given (uninterpreted) value
	// s7_mark marks any Scheme c_object as in-use (use this in the mark function to mark
	//    any embedded Pointer variables).

	// --------------------------------------------------------------------------------
	// the new clm optimizer!  this time for sure!
	//    d=double, i=integer, v=c_object, p=s7_pointer
	//    first return type, then arg types, d_vd -> returns double takes c_object and double (i.e. a standard clm generator)
	//
	// It is possible to tell s7 to call a foreign function directly, without any scheme-related
	//   overhead.  The call needs to take the form of one of the s7_*_t functions in s7.h.  For example,
	//   one way to call + is to pass it two f64 arguments and get an f64 back.  This is the
	//   s7_d_dd_t function (the first letter gives the return type, the rest give successive argument types).
	//   We tell s7 about it via s7_set_d_dd_function.  Whenever s7's optimizer encounters + with two arguments
	//   that it (the optimizer) knows are s7_doubles, in a context where an f64 result is expected,
	//   s7 calls the s7_d_dd_t function directly without consing a list of arguments, and without
	//   wrapping up the result as a scheme cell.

	optimize :: proc(sc: ^Scheme, expr: Pointer) -> PFunc ---

	float_optimize :: proc(sc: ^Scheme, expr: Pointer) -> Float_Function ---

	set_d_function :: proc(sc: ^Scheme, f: Pointer, D_T: D_T) ---
	d_function     :: proc(f: Pointer) -> D_T ---

	set_d_d_function :: proc(sc: ^Scheme, f: Pointer, D_D_T: D_D_T) ---
	d_d_function   :: proc(f: Pointer) -> D_D_T ---

	set_d_dd_function :: proc(sc: ^Scheme, f: Pointer, df: D_DD_T) ---
	d_dd_function     :: proc(f: Pointer) -> D_DD_T ---

	set_d_ddd_function :: proc(sc: ^Scheme, f: Pointer, df: D_DDD_T) ---
	d_ddd_function     :: proc(f: Pointer) -> D_DDD_T ---

	set_d_dddd_function :: proc(sc: ^Scheme, f: Pointer, df: D_DDDD_T) ---
	d_dddd_function     :: proc(f: Pointer) -> D_DDDD_T ---

	set_d_v_function :: proc(sc: ^Scheme, f: Pointer, df: D_V_T) ---
	d_v_function     :: proc(f: Pointer) -> D_V_T ---

	set_d_vd_function :: proc(sc: ^Scheme, f: Pointer, df: D_VD_T) ---
	d_vd_function     :: proc(f: Pointer) -> D_VD_T ---

	set_d_vdd_function :: proc(sc: ^Scheme, f: Pointer, df: D_VDD_T) ---
	d_vdd_function     :: proc(f: Pointer) -> D_VDD_T ---

	set_d_vid_function :: proc(sc: ^Scheme, f: Pointer, df: D_VID_T) ---
	d_vid_function     :: proc(f: Pointer) -> D_VID_T ---

	set_d_p_function :: proc(sc: ^Scheme, f: Pointer, df: D_P_T) ---
	d_p_function     :: proc(f: Pointer) -> D_P_T ---

	set_d_pd_function :: proc(sc: ^Scheme, f: Pointer, df: D_PD_T) ---
	d_pd_function     :: proc(f: Pointer) -> D_PD_T ---

	set_d_7pi_function :: proc(sc: ^Scheme, f: Pointer, df: D_7PI_T) ---
	d_7pi_function     :: proc(f: Pointer) -> D_7PI_T ---

	set_d_7pid_function :: proc(sc: ^Scheme, f: Pointer, df: D_7PID_T) ---
	d_7pid_function     :: proc(f: Pointer) -> D_7PID_T ---

	set_d_id_function :: proc(sc: ^Scheme, f: Pointer, df: D_ID_T) ---
	d_id_function     :: proc(f: Pointer) -> D_ID_T ---

	set_d_ip_function :: proc(sc: ^Scheme, f: Pointer, df: D_IP_T) ---
	d_ip_function     :: proc(f: Pointer) -> D_IP_T ---

	set_i_i_function :: proc(sc: ^Scheme, f: Pointer, df: I_I_T) ---
	i_i_function     :: proc(f: Pointer) -> I_I_T ---

	set_i_7d_function :: proc(sc: ^Scheme, f: Pointer, df: I_7P_T) ---
	i_7d_function     :: proc(f: Pointer) -> I_7P_T ---

	set_i_ii_function :: proc(sc: ^Scheme, f: Pointer, df: I_II_T) ---
	i_ii_function     :: proc(f: Pointer) -> I_II_T ---

	set_i_7p_function :: proc(sc: ^Scheme, f: Pointer, df: I_7P_T) ---
	i_7p_function     :: proc(f: Pointer) -> I_7P_T ---

	set_b_p_function :: proc(sc: ^Scheme, f: Pointer, df: B_P_T) ---
	b_p_function     :: proc(f: Pointer) -> B_P_T ---

	set_p_d_function :: proc(sc: ^Scheme, f: Pointer, df: P_D_T) ---
	p_d_function     :: proc(f: Pointer) -> P_D_T ---

	set_p_p_function :: proc(sc: ^Scheme, f: Pointer, df: P_P_T) ---
	p_p_function     :: proc(f: Pointer) -> P_P_T ---

	set_p_pp_function :: proc(sc: ^Scheme, f: Pointer, df: P_PP_T) ---
	p_pp_function     :: proc(f: Pointer) -> P_PP_T ---

	set_p_ppp_function :: proc(sc: ^Scheme, f: Pointer, df: P_PPP_T) ---
	p_ppp_function     :: proc(f: Pointer) -> P_PPP_T ---

	// /* Here is an example of using these functions; more extensive examples are in clm2xen.c in sndlib, and in s7.c.
	//  * (This example comes from a HackerNews discussion):
	//  * plus.c:
	//  * --------
	//  * #include "s7.h"
	//  *
	//  * Pointer g_plusone(sc: ^Scheme, args: Pointer) {return(s7_make_integer(sc, s7_integer(s7_car(args)) + 1));}
	//  * i64 plusone(i64 x) {return(x + 1);}
	//  *
	//  * void plusone_init(sc: ^Scheme)
	//  * {
	//  *   s7_define_safe_function(sc, "plusone", g_plusone, 1, 0, false, "");
	//  *   s7_set_i_i_function(sc, s7_name_to_value(sc, "plusone"), plusone);
	//  * }
	//  * --------
	//  * gcc -c plus.c -fPIC -O2 -lm
	//  * gcc plus.o -shared -o plus.so -ldl -lm -Wl,-export-dynamic
	//  * repl
	//  * <1> (load "plus.so" (inlet 'init_func 'plusone_init))
	//  * --------
	//  */
	// 
	// /* -------------------------------------------------------------------------------- */
	// 
	// /* maybe remove these? */
	// Pointer s7_slot(sc: ^Scheme, symbol: Pointer);
	// Pointer s7_slot_value(Pointer slot);
	// Pointer s7_slot_set_value(sc: ^Scheme, Pointer slot, value: Pointer);
	// Pointer s7_make_slot(sc: ^Scheme, env: Pointer, symbol: Pointer, value: Pointer);
	// void s7_slot_set_real_value(sc: ^Scheme, Pointer slot, f64 value);
	// 
	// /* -------------------------------------------------------------------------------- */
	// 
	// #if (!DISABLE_DEPRECATED)
	// typedef i64 s7_Int;
	// typedef f64 s7_Double;
	// 
	// #define s7_is_object          s7_is_c_object
	// #define s7_object_type        s7_c_object_type
	// #define s7_object_value       s7_c_object_value
	// #define s7_make_object        s7_make_c_object
	// #define s7_mark_object        s7_mark
	// #define s7_UNSPECIFIED(Sc)    s7_unspecified(Sc)
	// #endif
	// 
	// 
	// b8 s7_is_bignum(obj: Pointer);
	// #if WITH_GMP
	//   mpfr_t *s7_big_real(Pointer x);
	//   mpz_t  *s7_big_integer(Pointer x);
	//   mpq_t  *s7_big_ratio(Pointer x);
	//   mpc_t  *s7_big_complex(Pointer x);
	// 
	//   b8 s7_is_big_real(Pointer x);
	//   b8 s7_is_big_integer(Pointer x);
	//   b8 s7_is_big_ratio(Pointer x);
	//   b8 s7_is_big_complex(Pointer x);
	// 
	//   Pointer s7_make_big_real(sc: ^Scheme, mpfr_t *val);
	//   Pointer s7_make_big_integer(sc: ^Scheme, mpz_t *val);
	//   Pointer s7_make_big_ratio(sc: ^Scheme, mpq_t *val);
	//   Pointer s7_make_big_complex(sc: ^Scheme, mpc_t *val);
	// #endif

}
