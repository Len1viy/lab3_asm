bits 64


section .data

check:
	db	'1'

section .text

global _start
_start:
	mov	r11, 1000
	mov	bl, byte [check] 
	;push	r11
	push	bl
	mov	rax, 60
	mov	edi, 0
	syscall
