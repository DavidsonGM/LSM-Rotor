;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
EXP1:		MOV		#MSG, R5
			MOV		#GSM, R6
			CALL	#ENIGMA1
			JMP		$
			NOP

ENIGMA1:	MOV.B	0(R5), R7		; Passando o valor de cada letra para o registrador R7
			SUB		#0x41, R7		; Subtraindo o valor em ASCII para a letra A
			JL		RETURN

LOOP:		MOV.B	RT1(R7), 0(R6)	; Copiando o valor do vetor RT1 na posicao de acordo com a letra
			ADD.B	#0x41, 0(R6)	; Somando o valor em ASCII da letra A para voltar ao valor da letra
			INC		R5				; Incrementando o ponteiro da mensagem original
			INC		R6				; Incrementando o ponteiro da mensagem cifrada
			MOV.B	0(R5), R7
			SUB		#0x41, R7		; Subtraindo o valor em ASCII para a letra A
			JL		RETURN
			JMP		LOOP

RETURN:		RET


			.data
MSG:		.byte		"CABECAFEFACAFAD", 0
GSM:		.byte		"XXXXXXXXXXXXXXX", 0
RT1:		.byte		2, 4, 1, 5, 3, 0
                                            

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
