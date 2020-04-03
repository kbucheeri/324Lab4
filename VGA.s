.text
.global _start
.equ CHAR_BUFF_BASE, 0xC8000000
.equ PIXEL_BUFF_BASE, 0XC9000000
.global VGA_clear_char_buff_ASM
.global VGA_clear_pixel_buff_ASM
.global VGA_write_char_ASM
.global VGA_write_byte_ASM
.global VGA_draw_point_ASM
_start:
VGA_clear_char_buff_ASM:		
	LDR R0, =CHAR_BUFF_BASE //I have to loop through all of the character buffer and set it all to 0. Best to do it in a nested loop.
	MOV R1, #5				//OUTER LOOP COUNTER
	B VGA_clear_char_buff_ASM
VGA_clear_pixel_buff_ASM:
VGA_write_char_ASM:
VGA_write_byte_ASM:
VGA_draw_point_ASM: