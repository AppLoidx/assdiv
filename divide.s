# Integer division with remainder for x86-64 Linux
# Output format: "quotient R remainder\n"

.section .data
    dividend: .long 100
    divisor:  .long 7

.section .bss
    .lcomm buffer, 32

.section .text
    .globl _start

_start:
    movl dividend(%rip), %eax
    cltd
    divl divisor(%rip)           # EAX = quotient, EDX = remainder
    movl %eax, %r12d             # save quotient
    movl %edx, %r13d             # save remainder

    # Build output string from end to start
    lea buffer+30(%rip), %r8
    movb $10, (%r8)              # newline
    decq %r8

    # Convert remainder
    movl %r13d, %eax
    movl $10, %ecx
remainder_loop:
    xorl %edx, %edx
    divl %ecx
    addb $'0', %dl
    movb %dl, (%r8)
    decq %r8
    testl %eax, %eax
    jnz remainder_loop

    # Add " R "
    movb $' ', (%r8)
    decq %r8
    movb $'R', (%r8)
    decq %r8
    movb $' ', (%r8)
    decq %r8

    # Convert quotient
    movl %r12d, %eax
quotient_loop:
    xorl %edx, %edx
    divl %ecx
    addb $'0', %dl
    movb %dl, (%r8)
    decq %r8
    testl %eax, %eax
    jnz quotient_loop

    incq %r8
    lea buffer+31(%rip), %r9
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
