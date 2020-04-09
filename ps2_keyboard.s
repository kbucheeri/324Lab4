.text
.equ KB_BASE, 0xFF200100
.equ RVALID_POS, 0x8000
.global	read_PS2_data_ASM

read_PS2_data_ASM:
	PUSH {R1}		//CALLEE SAVE
	PUSH {R2}
	LDR R1, =KB_BASE
	LDR R1, [R1] //LOAD THE KEYBOARD WORD.
	LDR R2, =RVALID_POS //load the number containing a single bit in the position of RVALID_POS
	TST R1, R2 //TEST TO CHECK IF RVALID IS ON
	BEQ	INVALID	//RVALID = 0 SO MUST HAVE BEEN INVALID
VALID:
	AND R1, R1, #0xFF //keep only the last byte
	STRB R1, [R0]
	MOV R0, #1	 
	B DONE 
INVALID:
	MOV R0, #0
DONE:
	POP {R2}
	POP {R1}
	BX LR

.end