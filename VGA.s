.text
.global _start
.equ CHAR_BUFF_BASE, 0xC9000000
.equ PIXEL_BUFF_BASE, 0XC8000000
CHAR_TABLE:
.space 
.global VGA_clear_char_buff_ASM
.global VGA_clear_pixel_buff_ASM
.global VGA_write_char_ASM
.global VGA_write_byte_ASM
.global VGA_draw_point_ASM
_start:
; MOV R0, #65
; MOV R1, #40
; MOV R2, #65
; BL VGA_write_char_ASM



VGA_clear_char_buff_ASM:		//TODO: add callee save convention.
	
	MOV R0, #60				//OUTER LOOP COUNTER. I'll left shift, then add. since there are 240 y pixels. 
OUTER_LOOP_C:
	SUBS R0, R0, #1				//R0 IS OUTER LOOP INDEX
	LSL R2, R0, #7				//Y IS SECOND THE GROUP OF BITS, SO WE NEED TO FOFSET IT (240 positions - need only 8 bits!)
	LDR R10, =CHAR_BUFF_BASE	//I have to loop through all of the character buffer and set it all to 0. Best to do it in a nested loop.
	ADD R10, R10, R2			//starting at this row, clear everything.
	MOV R1, #80				//initialize loop counter
INNER_LOOP_C:
	SUBS R1, R1, #1				//decrement loop counter
	//LSL R3, R1, #1				//left shift because pixel addresses goes like base + 2^10 * y + 2 * x
	MOV R3, R1
	MOV R4, #0
	//ADD R4, R3, R10 			//change this later, want to see if i can form a gradient
	STRB R4, [R3, R10]
	CMP R1, #0
	BGT INNER_LOOP_C
INNER_LOOP_DONE_C:
	CMP R0, #0
	BGT OUTER_LOOP_C
	BX LR


VGA_clear_pixel_buff_ASM:
	
	MOV R0, #240				//OUTER LOOP COUNTER. I'll left shift, then add. since there are 240 y pixels. 
OUTER_LOOP_P:
	SUBS R0, R0, #1				//R0 IS OUTER LOOP INDEX
	LSL R2, R0, #10				//Y IS SECOND THE GROUP OF BITS, SO WE NEED TO FOFSET IT (240 positions - need only 8 bits!)
	LDR R10, =PIXEL_BUFF_BASE	//I have to loop through all of the character buffer and set it all to 0. Best to do it in a nested loop.
	ADD R10, R10, R2			//starting at this row, clear everything.
	MOV R1, #320				//initialize loop counter
INNER_LOOP_P:
	SUBS R1, R1, #1				//decrement loop counter
	LSL R3, R1, #1				//left shift because pixel addresses goes like base + 2^10 * y + 2 * x
	MOV R4, #0
	//ADD R4, R3, R10 			//change this later, want to see if i can form a gradient
	STRH R4, [R3, R10]
	CMP R1, #0
	BGT INNER_LOOP_P
INNER_LOOP_DONE_P:
	CMP R0, #0
	BGT OUTER_LOOP_P
	BX LR


VGA_write_char_ASM:
	PUSH {R3}	//will be used to hold the address, do callee save
	PUSH {R1}	//will be left shifted, so apply callee save
	//LSL R0, #1	//SHIFT THE X positions
	LSL R1, #7	//shift the y positions
	LDR R3, =CHAR_BUFF_BASE
	ADD R3, R3, R1
	ADD R3, R3, R0 //add the x and y offsets the buffer base
	STRB R2, [R3]
	POP {R1}
	POP {R3}
	BX LR




VGA_write_byte_ASM:
	PUSH {R3}	//will be used to hold the address, do callee save
	PUSH {R1}	//will be left shifted, so apply callee save
	//LSL R0, #1	//SHIFT THE X positions
	LSL R1, #7	//shift the y positions
	LDR R3, =CHAR_BUFF_BASE
	ADD R3, R3, R1
	ADD R3, R3, R0 //add the x and y offsets the buffer base
	STRB R2, [R3]
	POP {R1}
	POP {R3}
	BX LR

	
VGA_draw_point_ASM: