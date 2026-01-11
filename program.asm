# ==============================================================================
# RISC-V Pipeline Test Suite
# Tests: RAW Hazards (Forwarding), Load-Use Hazards (Stalls), Control Hazards (Flushes)
# ISA Coverage: R-Type, I-Type, Load/Store, Branch, Jump, LUI
# ==============================================================================

_start:
    # ---------------------------------------------------------
    # 1. Setup & I-Type Arithmetic (ADDI)
    # ---------------------------------------------------------
    addi x1, x0, 10      # x1 = 10
    addi x2, x0, 5       # x2 = 5
    addi x3, x0, -1      # x3 = -1 (0xFFFFFFFF)

    # ---------------------------------------------------------
    # 2. R-Type Arithmetic & Logic (Checks Standard ALU)
    # ---------------------------------------------------------
    add  x4, x1, x2      # x4 = 15
    sub  x5, x1, x2      # x5 = 5
    and  x6, x1, x2      # x6 = 10 & 5 = 0
    or   x7, x1, x2      # x7 = 10 | 5 = 15
    xor  x8, x1, x3      # x8 = 10 ^ -1 = ~10 (0xFFFFFFF5)

    # ---------------------------------------------------------
    # 3. RAW Hazard Test: Forwarding from EX Stage
    # ---------------------------------------------------------
    # x4 was written in previous cycle (currently in WB), 
    # but let's test immediate back-to-back dependency
    add  x9, x4, x4      # x9 = 15 + 15 = 30 
                         # (Requires Forwarding from MA stage or WB stage depending on timing)

    # ---------------------------------------------------------
    # 4. RAW Hazard Test: Forwarding from MEM Stage
    # ---------------------------------------------------------
    add  x10, x0, x9     # x10 = 30 (Forwarding from WB if needed)
    
    # ---------------------------------------------------------
    # 5. Shift Instructions & SLT
    # ---------------------------------------------------------
    sll  x11, x1, x2     # x11 = 10 << 5 = 320
    srl  x12, x3, x2     # x12 = -1 >> 5 (Logical) = 0x07FFFFFF
    sra  x13, x3, x2     # x13 = -1 >>> 5 (Arithmetic) = -1 (0xFFFFFFFF)
    slt  x14, x3, x1     # x14 = (-1 < 10)? 1 : 0 = 1
    sltu x15, x3, x1     # x15 = (-1 < 10) Unsigned? (Huge > 10) = 0

    # ---------------------------------------------------------
    # 6. Upper Immediate (LUI)
    # ---------------------------------------------------------
    lui  x16, 0x12345    # x16 = 0x12345000

    # ---------------------------------------------------------
    # 7. Memory & Load-Use Hazard Test
    # ---------------------------------------------------------
    sw   x16, 0(x0)      # Store 0x12345000 at address 0
    lw   x17, 0(x0)      # Load 0x12345000 into x17
    
    # !! LOAD-USE HAZARD !! 
    # The next instruction needs x17 immediately. 
    # The pipeline should STALL 1 cycle.
    add  x18, x17, x1    # x18 = 0x12345000 + 10
                         # If stall fails, x18 will be wrong.

    # ---------------------------------------------------------
    # 8. Control Hazard Test: BEQ (Branch Taken)
    # ---------------------------------------------------------
    beq  x1, x1, LABEL_A # 10 == 10, Branch Taken
    
    # !! FLUSH ZONE !!
    # These instructions should be flushed and NOT executed
    addi x19, x0, 999    # Should not write 999 to x19
    addi x20, x0, 888    # Should not write 888 to x20

LABEL_A:
    addi x19, x0, 100    # x19 = 100 (Correct execution path)

    # ---------------------------------------------------------
    # 9. Control Hazard Test: JAL (Jump & Link)
    # ---------------------------------------------------------
    jal  x21, LABEL_B    # Jump to B, store PC+4 in x21
    
    # !! FLUSH ZONE !!
    addi x22, x0, 777    # Should be flushed

LABEL_B:
    addi x22, x0, 200    # x22 = 200 (Correct path)

    # ---------------------------------------------------------
    # 10. Completion Loop
    # ---------------------------------------------------------
DONE:
    beq x0, x0, DONE     # Infinite loop to end simulation