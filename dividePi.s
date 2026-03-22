# Pi / divisor with FPU precision (9 decimal places)
# Uses x87 FPU with built-in Pi constant

.section .data
    divisor:  .long 7
    billion:  .quad 1000000000

.section .bss
    .lcomm buffer, 32
    .lcomm int_part, 8
    .lcomm frac_part, 8
    .lcomm fpu_cw, 2

.section .text
    .globl _start

_start:
    # Load Pi and divide by divisor
    fldpi
    fildl divisor(%rip)
    fdivrp                        # ST0 = Pi / divisor

    # Save rounding mode
    fnstcw fpu_cw(%rip)

    # Set truncation mode (RC = 11)
    movzwl fpu_cw(%rip), %eax
    orw $0x0C00, %ax
    pushw %ax
    fldcw (%rsp)
    addq $2, %rsp

    # Extract integer part
    fld %st(0)
    fistpq int_part(%rip)

    # Restore rounding mode
    fldcw fpu_cw(%rip)

    # Calculate fractional part
    fildq int_part(%rip)
    fsubrp                        # ST0 = fractional

    # Multiply by 10^9
    fildq billion(%rip)
    fmulp                         # ST0 = fractional * 10^9

    # Round to nearest for store
    movzwl fpu_cw(%rip), %eax
    andw $0xF3FF, %ax
    pushw %ax
    fldcw (%rsp)
    addq $2, %rsp

    fistpq frac_part(%rip)

    fldcw fpu_cw(%rip)
    ffree %st(0)

    # Load results
    movq int_part(%rip), %r13
    movq frac_part(%rip), %r14

    # Build output string
    lea buffer+30(%rip), %r8
    movb $10, (%r8)
    decq %r8

    # Fractional digits (9 digits, zero-padded)
    movq %r14, %rax
    movq $10, %rcx
    movq $9, %r9

frac_loop:
    xorq %rdx, %rdx
    divq %rcx
    addb $'0', %dl
    movb %dl, (%r8)
    decq %r8
    decq %r9
    jnz frac_loop

    movb $'.', (%r8)
    decq %r8

    # Integer part
    movq %r13, %rax
    testq %rax, %rax
    jnz int_convert
    movb $'0', (%r8)
    decq %r8
    jmp done

int_convert:
    xorq %rdx, %rdx
    divq %rcx
    addb $'0', %dl
    movb %dl, (%r8)
    decq %r8
    testq %rax, %rax
    jnz int_convert

done:
    incq %r8
    lea buffer+31(%rip), %r9
    subq %r8, %r9

    movq $1, %rax
    movq $1, %rdi
    movq %r8, %rsi
    movq %r9, %rdx
    syscall

    movq $60, %rax
    xorq %rdi, %rdi
    syscall
