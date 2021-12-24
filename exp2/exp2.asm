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
EXP2: 		MOV #MSG,R5
 			MOV #GSM,R6
 			CALL #ENIGMA2 ;Cifrar
		 	;
		 	MOV #GSM,R5
		 	MOV #DCF,R6
		 	CALL #ENIGMA2 ;Decifrar
		 	JMP $
		 	NOP
;
; Sua rotina ENIGMA (Exp 2)
ENIGMA2: 	MOV.B	0(R5), R7
			SUB		#0x41, R7		; Subtraindo o valor em ASCII para a letra A
			JL		RETURN
			MOV		#GSM, R8
			CMP		R6, R8
			JNE		DECIFRA

CIFRA:		MOV.B	RT1(R7), 0(R6)	; Copiando o valor do vetor RT1 na posicao de acordo com a letra
			ADD.B	#0x41, 0(R6)	; Somando o valor em ASCII da letra A para voltar ao valor da letra
			INC		R5				; Incrementando o ponteiro da mensagem original
			INC		R6				; Incrementando o ponteiro da mensagem cifrada
			MOV.B	0(R5), R7
			SUB		#0x41, R7		; Subtraindo o valor em ASCII para a letra A
			JL		RETURN
			JMP		CIFRA

DECIFRA:	MOV.B	RF1(R7), R9		; Colocando em r9 o valor do caractere refletido
			MOV		#-1, R10		; Contador

LOOP:		INC		R10
			CMP.B	RT1(R10), R9	; Vendo a posicao do caractere no vetor RT1
			JNE		LOOP

			MOV.B	R10, 0(R6)		; Copiando a posicao do caractere para a memoria, o que nos da o valor original refletido
			ADD.B	#0x41, 0(R6)	; Somando o valor em ASCII da letra A para voltar ao valor da letra
			INC		R5				; Incrementando o ponteiro da mensagem original
			INC		R6				; Incrementando o ponteiro da mensagem cifrada
			MOV.B	0(R5), R7
			SUB		#0x41, R7		; Subtraindo o valor em ASCII para a letra A
			JL		RETURN
			JMP		DECIFRA

RETURN:		RET
;
; Dados para o enigma
 			.data
MSG: 		.byte 		"CABECAFEFACAFAD",0 ;Mensagem em claro
GSM: 		.byte 		"XXXXXXXXXXXXXXX",0 ;Mensagem cifrada
DCF: 		.byte 		"XXXXXXXXXXXXXXX",0 ;Mensagem decifrada
RT1: 		.byte 		2, 4, 1, 5, 3, 0 	;Trama do Rotor
RF1: 		.byte 		3, 5, 4, 0, 2, 1 	;Tabela do Refletor


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
            
