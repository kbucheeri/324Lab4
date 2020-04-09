.text
.equ PUSHDRESS, 0xFF200050
.equ EDGECAP, 0xFF20005C
.equ INTMASK, 0xFF200058
.global read_LEDs_ASM
.global write_LEDs_ASM
.global read_PB_data_ASM
.global PB_data_is_pressed_ASM
.global read_PB_edgecap_ASM 
.global PB_edgecap_is_pressed_ASM
.global PB_clear_edgecap_ASM
.global enable_PB_INT_ASM
.global disable_PB_INT_ASM

read_PB_data_ASM:
LDR R0, =PUSHDRESS
LDR R0, [R0]
AND R0, R0, #0xf
BX LR
PB_data_is_pressed_ASM: //only returns the status bit of the button that is passed in the function.
LDR R1, =PUSHDRESS
LDR R1, [R1]
AND R0, R1, R0 //R0 is input, anding to only get the desired value at the specific pushbutton passed. already in r0 so we're returning that.
BX LR
read_PB_edgecap_ASM: 
LDR R0, =EDGECAP
LDR R0, [R0]
AND R0, R0, #0xf
BX LR
PB_edgecap_is_pressed_ASM:
LDR R1, =EDGECAP
LDR R1, [R1]
AND R0, R1, R0 //R0 is input, anding to only get the desired value at the specific pushbutton passed. already in r0 so we're returning that.
BX LR
PB_clear_edgecap_ASM:
LDR R2, =EDGECAP
LDR R1, [R2]	//R1 contains state of the buttons.
AND R0, R0, #0XF //keep only the first 4 bits of R0, the input.
AND R1, R1, R0 //R0 is bits to clear, so we ANDN'T to clear those bits and re-store them in memory.
STR R1, [R2]	//store the cleared value once more
BX LR
enable_PB_INT_ASM:
LDR R2, =INTMASK
LDR R1, [R2]
ORR R1, R1, R0 //R0 is bits to clear, so we ANDN'T to clear those bits and re-store them in memory.
STR R1, [R2]	//store the cleared value once more
BX LR
disable_PB_INT_ASM:
LDR R2, =INTMASK
LDR R1, [R2]
BIC R1, R1, R0 //R0 is bits to clear, so we ANDN'T to clear those bits and re-store them in memory.
STR R1, [R2]	//store the cleared value once more
BX LR
.end
