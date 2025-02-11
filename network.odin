package main

import "core:io"
import "core:fmt"
import "core:mem"
import "core:os"
import "core:strings"
import "core:thread"
import "core:slice"
import "core:net"
import "core:path/filepath"


_address : net.Address
_port : int

_endpoint : net.Endpoint
_socket : net.UDP_Socket

@(private="file")
_server_message : cstring
init_server :: proc() {
	adr := net.parse_address("127.0.0.1")
	port := 1280
	_endpoint = net.Endpoint{adr, port}
	err : net.Network_Error
	_socket, err = net.make_bound_udp_socket(adr, port)
	if err != nil do fmt.printf("failed to create socket: {}\n", err)
	thread.run(_server_thread)
	_server_thread :: proc() {
		@static buf : [4096]u8
		for {
			length, from, err := net.recv_udp(_socket, buf[:])
			if err != nil {
				fmt.printf("failed to receive message: {}\n", err)
			} else {
				buf[length] = 0
				_server_message = cast(cstring)&buf[0]
			}
		}
	}
}
init_client :: proc() {
	_endpoint = net.Endpoint{net.parse_address("127.0.0.1"), 1280}
	err : net.Network_Error
	_socket, err = net.make_unbound_udp_socket(.IP4)
	if err != nil do fmt.printf("failed to create socket: {}\n", err)
}

server_check_message :: proc() -> cstring {
	if _server_message != nil {
		msg := _server_message
		_server_message = nil
		return msg
	}
	return nil
}

client_send_message :: proc(msg: cstring) {
	buf := transmute([]u8)cast(string)msg
	fmt.printf("send msg:\n{}\n", msg)
	net.send_udp(_socket, buf[:], _endpoint)
}
