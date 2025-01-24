package fe

import "core:c"
import "core:c/libc"

when ODIN_DEBUG {
	foreign import fe "fe-windows-x64-msvc-debug.lib"
} else {
	foreign import fe "fe-windows-x64-msvc.lib"
}

@(default_calling_convention = "c")
@(link_prefix = "fe_")
foreign fe {
	open :: proc(ptr:rawptr, size :c.int) -> ^Context ---;
	close :: proc(ctx:^Context ) ---;
	handlers :: proc(ctx:^Context) -> ^Handlers ---;
	error :: proc(ctx:^Context, msg: cstring) ---;
	nextarg :: proc(ctx:^Context, arg:^^Object) -> ^Object ---;
	type :: proc(ctx:^Context, obj:^Object) -> c.int ---;
	isnil :: proc(ctx:^Context, obj:^Object) -> c.int ---;
	pushgc :: proc(ctx:^Context, obj:^Object) ---;
	restoregc :: proc(ctx:^Context, idx:c.int) ---;
	savegc :: proc(ctx:^Context) -> c.int ---;
	mark :: proc(ctx:^Context, obj:^Object) ---;
	cons :: proc(ctx:^Context, car:^Object, cdr:^Object) -> ^Object ---;
	bool :: proc(ctx:^Context, b:c.int) -> ^Object ---;
	number :: proc(ctx:^Context, n:Number) -> ^Object ---;
	string :: proc(ctx:^Context, str:cstring) -> ^Object ---;
	symbol :: proc(ctx:^Context, name:cstring) -> ^Object ---;
	cfunc :: proc(ctx:^Context, fn:CFunc) -> ^Object ---;
	ptr :: proc(ctx:^Context, ptr:rawptr) -> ^Object ---;
	list :: proc(ctx:^Context, objs: [^]^Object, n:c.int) -> ^Object ---;
	car :: proc(ctx:^Context, obj:^Object) -> ^Object ---;
	cdr :: proc(ctx:^Context, obj:^Object) -> ^Object ---;
	write :: proc(ctx:^Context, obj:^Object, fn:WriteFn, udata:rawptr, qt:c.int) ---;
	writefp :: proc(ctx:^Context, obj:^Object, fp:^libc.FILE) ---;
	tostring :: proc(ctx:^Context, obj:^Object, dst:^c.char, size:c.int) -> c.int ---;
	tonumber :: proc(ctx:^Context, obj:^Object) -> Number ---;
	toptr :: proc(ctx:^Context, obj:^Object) -> rawptr	---;
	set :: proc(ctx:^Context, sym:^Object, v: ^Object) ---;
	read :: proc(ctx:^Context, fn:ReadFn, udata:rawptr) -> ^Object ---;
	readfp :: proc(ctx:^Context, fp:^libc.FILE) -> ^Object ---;
	eval :: proc(ctx:^Context, obj:^Object) -> ^Object ---;
	hack_finish_error_handle :: proc() ---;
}

// Types

GCSTACKSIZE :: 256 
STRBUFSIZE	:: 63
GCMARKBIT	:: 0x2 

Context :: struct {
	handlers : Handlers,
	gcstack : [GCSTACKSIZE]^Object,
	gcstack_idx : c.int,
	objects : ^Object,
	object_count : c.int,
	calllist : ^Object,
	freelist : ^Object,
	symlist : ^Object,
	t : ^Object,
	nextchr : c.int,
};

Handlers :: struct { 
	error : ErrorFn,
	mark,gc : CFunc,
}

ErrorFn :: #type proc "c" (ctx:^Context, err:cstring, cl:^Object)
WriteFn :: #type proc "c" (ctx:^Context, udata:rawptr, chr: c.char)
ReadFn	:: #type proc "c" (ctx:^Context, udata:rawptr) -> c.char
CFunc	:: #type proc "c" (ctx:^Context, args: ^Object) -> ^Object

Object :: struct #raw_union {
	o: ^Object,
	f: CFunc,
	n: Number,
	c: c.char,
}

Number :: c.float
