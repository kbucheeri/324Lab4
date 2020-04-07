.text
.global _start
.equ CHAR_BUFF_BASE, 0xC9000000
.equ PIXEL_BUFF_BASE, 0XC8000000
CHAR_TABLE: //table of number (HEX) to ASCII values. 
.word 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46 
.global VGA_clear_char_buff_ASM
.global VGA_clear_pixel_buff_ASM
.global VGA_write_char_ASM
.global VGA_write_byte_ASM
.global VGA_draw_point_ASM
.global test_char
.global test_byte
.global test_pixel
_start:
BL VGA_clear_char_buff_ASM
BL VGA_clear_pixel_buff_ASM
BL test_byte
DONE: B DONE


VGA_clear_char_buff_ASM:		//TODO: add callee save convention.
	MOV R0, #60				//OUTER LOOP COUNTER. I'll left shift, then add. since there are 240 y pixels. 
	PUSH {R10}
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
	POP {R10}
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
	CMP R0, #80		//compare the coordinates to the max to ensure they are valid.
	BXGT LR
	CMP R1, #60
	BXGT LR

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




VGA_write_byte_ASM: //48-57 are numbers, 65-70 are letters
	CMP R0, #79 	//compare the coordinates to the max to ensure they are valid. 79 this time because 2 characters will be used.
	BXGT LR
	CMP R1, #60
	BXGT LR

	PUSH {R1}	//will be used to hold the address, do callee save
	PUSH {R2}	//will be left shifted, so apply callee save
	PUSH {R3}
	PUSH {R4}	
	PUSH {R10}	
	//LSL R0, #1	//SHIFT THE X positions
	LSL R1, #7	//shift the y positions since the first byte is used for x, second is used for y.
	LDR R3, =CHAR_BUFF_BASE
	LDR R10, =CHAR_TABLE
	ADD R3, R3, R1
	ADD R3, R3, R0 //add the x and y offsets the buffer base

	MOV R4, R2	//temp register for operations on R2
	AND R4, #0xF	//keep only the last 4 bits for the first character
	LSL R4, R4, #2
	LDR	R4, [R10, R4]
	STRB R4, [R3, #1]

	MOV R4, R2
	AND R4, #0XF0	//KEEP ONLY 2ND BYTE
	ASR R4, R4, #2
	LDR R4, [R10, R4]
	STRB R4, [R3]	//store in the adjacent spot


	POP {R10}
	POP {R4}
	POP {R3}
	POP {R2}
	POP {R1}
	BX LR


	
VGA_draw_point_ASM:
	cmp r0, #320
	bxgt lr
	cmp r1, #240
	bxgt lr 
	push {r10}
	push {r3}	
	//OUTER LOOP COUNTER. I'll left shift, then add. since there are 240 y pixels. 
	LSL R3, R1, #10				//Y IS SECOND THE GROUP OF BITS, SO WE NEED TO FOFSET IT (240 positions - need only 8 bits!)
	LDR R10, =PIXEL_BUFF_BASE	//I have to loop through all of the character buffer and set it all to 0. Best to do it in a nested loop.
	ADD R10, R10, R3			//starting at this row, clear everything.
	LSL R3, R0, #1				//left shift because pixel addresses goes like base + 2^10 * y + 2 * x
	STRH R2, [R3, R10]
	pop {r3}
	pop {r10}
	BX LR

test_char:
push {r0}
push {r1}
push {r2}
		MOV R1, #0		//INT Y = 0
		MOV R2, #0		//CHAR C
	OUTER_LOOP_TESTC:
		MOV R0, #0 		//initialize X
	INNER_LOOP_TESTC:
		BL VGA_write_char_ASM	
		ADD R2, R2, #1
		ADD R0, R0, #1
		CMP R0, #80
		BLE INNER_LOOP_TESTC
		ADDS R1, R1, #1
		CMP R1, #60
		BLE	OUTER_LOOP_TESTC
pop {r2}
pop {r1}
pop {r0} 
	BX LR

test_byte:
push {r0}
push {r1}
push {r2}
		MOV R1, #0		//INT Y = 0
		MOV R2, #0		//CHAR C
	OUTER_LOOP_TESTB:
		MOV R0, #0 		//initialize X
	INNER_LOOP_TESTB:
		BL VGA_write_byte_ASM	
		ADD R2, R2, #1
		ADD R0, R0, #3
		CMP R0, #80
		BLE INNER_LOOP_TESTB
		ADDS R1, R1, #1
		CMP R1, #60
		BLE	OUTER_LOOP_TESTB
pop {r2}
pop {r1}
pop {r0} 
	BX LR

test_pixel: