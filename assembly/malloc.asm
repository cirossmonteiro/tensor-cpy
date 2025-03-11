[BITS 64]

section .text
    global malloc

; Simple malloc wrapper
malloc:
    ; Argument: rdi = size
    push rsi
    push rdx
    push r10
    push r8
    push r9
    push rcx
    push r11

    mov rax, 9                  ; syscall mmap
    mov rsi, rdi                ; length (size from caller)
    push rdi
    mov rdi, 0                  ; addr = NULL
    mov rdx, 0x3                ; PROT_READ | PROT_WRITE
    mov r10, 0x22               ; MAP_ANONYMOUS | MAP_PRIVATE
    mov r8, -1                  ; fd = -1 (MAP_ANONYMOUS)
    mov r9, 0                   ; offset = 0
    syscall

    pop rdi
    pop r11
    pop rcx
    pop r9
    pop r8
    pop r10
    pop rdx
    pop rsi

    ret                         ; Return address in RAX

; _start:
;     ; Allocate memory (1 page = 4096 bytes)
;     mov rdi, 4096               ; size = 4096 bytes
;     call malloc

;     ; Now RAX holds the pointer to the allocated memory
;     mov rbx, rax                ; save pointer in RBX

;     ; Write a string into allocated memory
;     mov byte [rbx], 'H'
;     mov byte [rbx+1], 'i'
;     mov byte [rbx+2], '!'
;     mov byte [rbx+3], 10        ; newline character

;     ; Write syscall to display "Hi!\n" to stdout
;     mov rax, 1                  ; syscall write
;     mov rdi, 1                  ; file descriptor (stdout)
;     mov rsi, rbx                ; buffer address
;     mov rdx, 4                  ; buffer length
;     syscall

;     ; Exit syscall
;     mov rax, 60                 ; syscall exit
;     xor rdi, rdi                ; exit status 0
;     syscall