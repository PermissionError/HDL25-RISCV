# RISC-V Full Coverage Test Program
# Tests: LUI, BEQ, LW, SW, JAL
#        ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
#        ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND

.text
.globl _start

_start:
    # ---------------------------------------------------------
    # 1. SETUP & U-TYPE
    # ---------------------------------------------------------
    lui  x1, 0x10000        # x1 = 0x10000000 (Base Memory Address)
    addi x2, x0, 10         # x2 = 10 
    addi x3, x0, -5         # x3 = -5 

    # ---------------------------------------------------------
    # 2. I-TYPE ARITHMETIC & LOGIC
    # ---------------------------------------------------------
    addi  x4, x2, 20        # x4 = 30
    xori  x5, x2, -1        # x5 = ~10 = -11 (0xFFFFFFF5)
    andi  x6, x5, 0xF       # x6 = 5
    ori   x7, x6, 0x10      # x7 = 21 (0x15)
    
    # ---------------------------------------------------------
    # 3. I-TYPE SHIFTS
    # ---------------------------------------------------------
    slli  x8, x2, 2         # x8 = 40 (0x28)
    srli  x9, x3, 2         # x9 = 0x3FFFFFFE (Logical Shift Right)
    srai  x10, x3, 2        # x10 = -2 (Arithmetic Shift Right)

    # ---------------------------------------------------------
    # 4. I-TYPE COMPARISONS 
    # ---------------------------------------------------------
    slti  x11, x3, 10       # x11 = 1 (True: -5 < 10)
    sltiu x12, x3, 10       # x12 = 0 (False: Unsigned large < 10)

    # ---------------------------------------------------------
    # 5. R-TYPE ARITHMETIC
    # ---------------------------------------------------------
    add   x13, x2, x3       # x13 = 5
    sub   x14, x2, x3       # x14 = 15

    # ---------------------------------------------------------
    # 6. R-TYPE LOGICAL
    # ---------------------------------------------------------
    and   x15, x2, x3       # x15 = 10 (0x0A)
    or    x16, x2, x3       # x16 = -5
    xor   x17, x2, x3       # x17 = -15 (0xFFFFFFF1)

    # ---------------------------------------------------------
    # 7. R-TYPE SHIFTS (Register)
    # ---------------------------------------------------------
    addi  x18, x0, 1        # x18 = 1
    sll   x19, x2, x18      # x19 = 20
    srl   x20, x3, x18      # x20 = 0x7FFFFFFD
    sra   x21, x3, x18      # x21 = -3

    # ---------------------------------------------------------
    # 8. R-TYPE COMPARISONS
    # ---------------------------------------------------------
    slt   x22, x3, x2       # x22 = 1 (True)
    sltu  x23, x3, x2       # x23 = 0 (False)

    # ---------------------------------------------------------
    # 9. MEMORY OPERATIONS
    # ---------------------------------------------------------
    sw    x22, 0(x1)        # Store 1 to memory
    lw    x24, 0(x1)        # Load 1 back into x24

    # ---------------------------------------------------------
    # 10. CONTROL FLOW (BEQ / JAL)
    # ---------------------------------------------------------
    # Test Branch Not Taken (10 != -5)
    beq   x2, x3, fail_loc  
    
    # Test Branch Taken (10 == 10)
    beq   x2, x2, jump_loc  

fail_loc:
    # If we get here, BEQ failed (it took a branch it shouldn't have)
    addi  x25, x0, 0        # x25 = 0 means FAIL
    jal   x0, end_loc       

jump_loc:
    # If we get here, BEQ worked (it skipped fail_loc)
    addi  x25, x0, 1        # x25 = 1 means PASS
    
    # Test JAL
    jal   x26, end_loc      # Jump to end. x26 should hold address of next line (unused)

end_loc:
    jal   x0, end_loc       # Infinite Loop