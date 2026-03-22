# Integer division for x86-64 Linux
# dividend / divisor -> stdout

.section .data
    dividend: .long 100
    divisor:  .long 7

.section .bss
    .lcomm buffer, 16

.section .text
    .globl _start

_start:
    movl dividend(%rip), %eax
    cltd
    divl divisor(%rip)           # EAX = quotient, EDX = remainder
    movl %eax, %r12d

    # Convert to ASCII string (reverse order)
    lea buffer+14(%rip), %r8
    movb $10, (%r8)              # newline
    decq %r8

    movl %r12d, %eax
    movl $10, %ecx

convert_loop:
    xorl %edx, %edx
    divl %ecx                    # EAX / 10 -> digit in EDX
    addb $'0', %dl
    movb %dl, (%r8)
    decq %r8
    testl %eax, %eax
    jnz convert_loop

    incq %r8
    lea buffer+15(%rip), %r9
    subq %r8, %r9                # R9 = length

    # write(1, buf, len)
    movq $1, %rax
    movq $1, %rdi
    movq %r8, %rsi
    movq %r9, %rdx
    syscall

    # exit(0)
    movq $60, %rax
    xorq %rdi, %rdi
    syscall
