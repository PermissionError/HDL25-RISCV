    .option norvc
    .text
    .globl _start

    # ----------------------------
    # EDIT THESE CONSTANTS
    # ----------------------------
    .equ ARRAY_BASE, 0x040      # byte address of array in D-RAM
    .equ DONE_ADDR,  0x200      # byte address of DONE flag in D-RAM

_start:
    # DONE = 0
    addi  t0, x0, DONE_ADDR
    sw    x0, 0(t0)

    # s0 = base pointer to array
    addi  s0, x0, ARRAY_BASE

    # i = 1 (s1)
    addi  s1, x0, 1

outer_loop:
    # if (i < 32) continue else done
    addi  t1, x0, 32
    slt   t2, s1, t1          # t2=1 if i<32
    beq   t2, x0, done        # if t2==0 -> done

    # key = A[i]
    slli  t3, s1, 2           # t3 = i*4
    add   t4, s0, t3          # t4 = &A[i]
    lw    s2, 0(t4)           # s2 = key

    # j = i-1 (s3)
    addi  s3, s1, -1

inner_loop:
    # if (j < 0) goto insert
    slt   t5, s3, x0          # t5=1 if j<0
    beq   t5, x0, j_nonneg
    jal   x0, insert

j_nonneg:
    # Aj = A[j]
    slli  t6, s3, 2           # t6 = j*4
    add   a0, s0, t6          # a0 = &A[j]
    lw    a1, 0(a0)           # a1 = Aj

    # if (key < Aj) goto shift else insert
    slt   a2, s2, a1          # a2=1 if key<Aj
    beq   a2, x0, do_insert
    jal   x0, shift

shift:
    # A[j+1] = Aj
    addi  t0, s3, 1           # t0 = j+1
    slli  t1, t0, 2           # t1 = (j+1)*4
    add   t2, s0, t1          # t2 = &A[j+1]
    sw    a1, 0(t2)

    # j--
    addi  s3, s3, -1
    jal   x0, inner_loop

do_insert:
insert:
    # A[j+1] = key
    addi  t0, s3, 1
    slli  t1, t0, 2
    add   t2, s0, t1
    sw    s2, 0(t2)

    # i++
    addi  s1, s1, 1
    jal   x0, outer_loop

done:
    # DONE = 0xCAFEBABE
    addi  t0, x0, DONE_ADDR

    # Build constant safely: 0xCAFEC000 + (-0x542) = 0xCAFEBABE
    lui   t1, 0xCAFEC
    addi  t1, t1, -1346

    sw    t1, 0(t0)

halt:
    jal   x0, halt