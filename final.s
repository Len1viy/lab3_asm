bits	64
section	.data
size	equ	1
err2:
	db	"No such file or direcrtory!", 10
err13:
	db	"Permission denied!", 10
err17:
	db	"File doesn't exists!", 10
err21:
	db	"It is a directory!", 10
err150:
	db	"Program should require 1 parameter!", 10
err151:
	db	"Error reading filename!", 10
err255:
	db	"Unknown error!", 10
fdr:
	dd	-1
section	.text
global	_start
_start:
	cmp	qword [rsp], 2
	je	.m0
	mov	ebx, 150
	jmp	.error150
.m0:
	mov	r15, [rsp]
	mov	rdi, [rsp + 8 * r15]
	mov	rax, 2
	xor	rsi, rsi
	syscall
	or	eax, eax
	jge	.m1
	mov	ebx, eax
	neg	ebx
	jmp	.error17
.m1:
	mov	[fdr], eax
	mov	edi, eax
	call	work
	mov	ebx, eax
	neg	ebx
	cmp	ebx, 2
	je	.error2
	cmp	ebx, 13
	je	.error13
	cmp	ebx, 21
	je	.error21
	cmp	ebx, 151
	je	.error151
	cmp	ebx, 255
	je	.error255
	jmp	.m4
.error150:
	mov	esi, err150
	xor	edx, edx
	jmp	.error_counting
.error_counting:
	inc	edx
	cmp	byte [rsi + rdx - 1], 10
	jne	.error_counting
	mov	eax, 1
	mov	edi, 1
	syscall
	jmp	.end
.error2:
	mov	esi, err2
	xor	edx, edx
	jmp	.error_counting
.error13:
	mov	esi, err13
	xor	edx, edx
	jmp	.error_counting
.error21:
	mov	esi, err21
	xor	edx, edx
	jmp	.error_counting
.error151:
	mov	esi, err151
	xor	edx, edx
	jmp	.error_counting
.error255:
	mov	esi, err255
	xor	edx, edx
	jmp	.error_counting
.error17:
	mov	esi, err17
	xor	edx, edx
	jmp	.error_counting

.m4:
	cmp	dword [fdr], -1
	je	.end
	mov	eax, 3
	mov	edi, [fdr]
	syscall
.end:
	mov	edi, ebx
	mov	eax, 60
	syscall



bufin	equ	size
bufout	equ	size+bufin
fr	equ	bufout+4
work:
	push	rbp
	mov	rbp, rsp
	sub	rsp, fr
	push	rbx ; кол-во уже обработанных букв в строке
	push	r12 ; кол-во букв в данном слове
	push	r13 ; кол-во символов в буфере на вывод
	push	r14 ; последняя первая буква в слове
	mov	[rbp-fr], edi
	xor	r13, r13
	xor	rcx, rcx
	xor	rbx, rbx
	xor	r12, r12
.check_before_output:
	cmp	r13, size
	je	.output
.load_buffer_out:
	lea	rdi, [rbp-bufout]
	xor	r13, r13
.check_buffer_in:
	or	ecx, ecx ; сколько прочитано из файла
	je	.load_buffer_in
	jne	.loop_before_start
.loop_before_start:
	loop	.m1
	jmp	.load_buffer_in
.load_buffer_in:
	push	rdi
	mov	eax, 0
	mov	edi, [rbp-fr]
	lea	rsi, [rbp-bufin]
	mov	rdx, size
	syscall
	or	eax, eax
	je	.end
	jle	.end_with_error
	lea	rsi, [rbp-bufin]
	pop	rdi
	mov	ecx, eax
	jmp	.m1
.start_loop:
	dec	rcx
	or	rcx, rcx
	jle	.load_buffer_in
.m1:
	mov	al, [rsi]
	inc	rsi
	cmp	al, 10
	je	.m4
	cmp	al, ' '
	je	.m4
	cmp	al, 9
	je	.m4
	cmp	al, r14b
	je	.m6
	;je	.m4
.m2:
	or	r12, r12
	jne	.not_first_letter
.first_letter:
	or	ebx, ebx
	je	.big_first_letter
	mov	r14b, al
	mov	byte [rdi], ' '
	inc	rdi
	inc	r13
	cmp	r13, size
	je	.output1
	jne	.not_first_letter
.big_first_letter:
	mov	r14b, al
	jmp	.not_first_letter
.load_buf_space:
	lea	rdi, [rbp - bufout]
	xor	r13, r13
.not_first_letter:
	mov	[rdi], al
	inc	rdi
	inc	r12
	inc	r13
	inc	ebx
	jmp	.m6
.m4:
	xor	r14, r14
	or	r12, r12
	je	.m5
	xor	r12, r12
.m5:
	cmp	al, 10
	jne	.m6
;	xor	edx, edx
	mov	byte [rdi], 10
	inc	rdi
	inc	r13
	jmp	.m_after_cycle
.m6:
	cmp	r13, size
	je	.check_before_output
	jmp	.start_loop
.m_after_cycle:
	or	r13, r13
	je	.end_string
.m7:
	push	rcx
	push	rsi
	lea	rsi, [rbp-bufout]
	mov	rdx, r13
	mov	eax, 1
	mov	edi, 1
	syscall
	pop	rsi
	pop	rcx
	jmp	.end_string
.output:
	push	rcx
	push	rdi
	push	rsi
	mov	eax, 1
	mov	rdx, r13
	lea	rsi, [rbp-bufout]
	mov	rdi, 1
	syscall
	pop	rsi
	pop	rdi
	pop	rcx
	jmp	.load_buffer_out
.output1:
	push	rcx
	push	rdi
	push	rsi
	push	rax
	mov	eax, 1
	mov	rdx, r13
	lea	rsi, [rbp-bufout]
	mov	rdi, 1
	syscall
	pop	rax
	pop	rsi
	pop	rdi
	pop	rcx
	jmp	.load_buf_space
.end_string:
	xor	r13, r13
	xor	r14, r14
	xor	rbx, rbx
	jmp	.check_before_output
.end:
	mov	eax, 0
	pop	r14
	pop	r13
	pop	r12
	pop	rbx
	leave
	ret
.end_with_error:
	pop	r14
	pop	r13
	pop	r12
	pop	rbx
	leave
	ret
