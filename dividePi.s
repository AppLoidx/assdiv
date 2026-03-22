# Pi / divisor with 9 decimal places for x86-64 Linux
# Output format: "X.XXXXXXXXX\n"
# Pi = 3.141592653... (stored as Pi * 10^9 = 3141592654)

.section .data
    pi_scaled: .quad 3141592654    # Pi * 10^9
    divisor:   .quad 7             # Divisor
    scale:     .quad 1000000000    # 10^9 for padding

.section .bss
    .lcomm buffer, 32

.section .text
    .globl _start

_start:
    # (Pi * 10^9) / divisor = result with 9 decimal digits
    movq pi_scaled(%rip), %rax
    xorq %rdx, %rdx
    divq divisor(%rip)            # RAX = quotient, RDX = remainder
    movq %rax, %r12               # save result

    # Calculate integer part: result / 10^9
    movq %r12, %rax
    xorq %rdx, %rdx
    divq scale(%rip)              # RAX = integer part, RDX = fractional
    movq %rax, %r13               # r13 = integer part (0 for Pi/7)
    movq %rdx, %r14               # r14 = fractional part (9 digits)

    # Build output from end
    lea buffer+30(%rip), %r8
    movb $10, (%r8)               # newline
    decq %r8

    # Convert fractional part (9 digits, pad with zeros)
    movq %r14, %rax
    movq $10, %rcx
    movq $9, %r9                  # digit counter

fraction_loop:
    xorq %rdx, %rdx
    divq %rcx
    addb $'0', %dl
    movb %dl, (%r8)
    decq %r8
    decq %r9
    jnz fraction_loop

    # Decimal point
    movb $'.', (%r8)
    decq %r8

    # Convert integer part
    movq %r13, %rax
    testq %rax, %rax
    jnz convert_int
    movb $'0', (%r8)              # integer part is 0
    decq %r8
    jmp done_convert

convert_int:
    xorq %rdx, %rdx
    divq %rcx
    addb $'0', %dl
    movb %dl, (%r8)
    decq %r8
    testq %rax, %rax
    jnz convert_int

done_convert:
    incq %r8                      # R8 = start of string
    lea buffer+31(%rip), %r9
    subq %r8, %r9                 # R9 = length

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
