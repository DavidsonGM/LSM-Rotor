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
RT_TAM 		.equ 	6 ;Tamanho dos rotores
CONF1 		.equ 	1 ;Configuração do Rotor 1

EXP3: 		MOV		#MSG,R5
 			MOV 	#GSM,R6
 			CALL 	#ENIGMA3
 ; Dependendo da solução, pode ser necessária uma
 ; sub-rot para restaurar posição original do rotor

 			MOV 	#GSM,R5
 			MOV 	#DCF,R6
 			CALL 	#ENIGMA3
 			JMP	 	$
 			NOP

; Sua rotina ENIGMA (Experimento 3)
ENIGMA3: 	MOV.B	0(R5), R7
			SUB		#0x41, R7		; Subtraindo o valor em ASCII para a letra A
			JL		RETURN
			MOV		#GSM, R8
			CMP		R6, R8
			JNE		DECIFRA

CIFRA:		CALL	#EMBARALHA_ROTOR
			MOV.B	RT1(R7), 0(R6)	; Copiando o valor do vetor RT1 na posicao de acordo com a letra
			ADD.B	#0x41, 0(R6)	; Somando o valor em ASCII da letra A para voltar ao valor da letra
			INC		R5				; Incrementando o ponteiro da mensagem original
			INC		R6				; Incrementando o ponteiro da mensagem cifrada
			MOV.B	0(R5), R7
			SUB		#0x41, R7		; Subtraindo o valor em ASCII para a letra A
			JL		RETURN
			JMP		CIFRA

DECIFRA:
			MOV.B	RF1(R7), R9		; Colocando em r9 o valor do caractere refletido
			MOV		#-1, R10		; Contador

LOOP:		INC		R10
			CMP.B	RT1(R10), R9	; Vendo a posicao do caractere no vetor RT1
			JNE		LOOP

			CALL	#DESEMBARALHA_ROTOR
			MOV.B	R10, 0(R6)		; Copiando a posicao do caractere para a memoria, o que nos da o valor original refletido
			ADD.B	#0x41, 0(R6)	; Somando o valor em ASCII da letra A para voltar ao valor da letra
			INC		R5				; Incrementando o ponteiro da mensagem original
			INC		R6				; Incrementando o ponteiro da mensagem cifrada
			MOV.B	0(R5), R7
			SUB		#0x41, R7		; Subtraindo o valor em ASCII para a letra A
			JL		RETURN
			JMP		DECIFRA

RETURN:		RET

EMBARALHA_ROTOR:
			ADD		#CONF1, R7		; Somando a configuracao para obter a nova posicao de cada caractere
			CMP		#RT_TAM, R7		; Vendo se a nova posicao do caractere seria superior ao maior valor possivel
			JL		RETURN
			SUB		#RT_TAM, R7		; Caractere no comeco do rotor caso ultrapasse o maior valor possivel
			RET

DESEMBARALHA_ROTOR:
			SUB		#CONF1, R10		;
			JGE		RETURN
			ADD		#RT_TAM, R10
			RET

; Dados para o enigma
			.data
MSG: 		.byte 	"CABECAFEFACAFAD",0 ;Mensagem em claro
GSM: 		.byte 	"XXXXXXXXXXXXXXX",0 ;Mensagem cifrada
DCF: 		.byte 	"XXXXXXXXXXXXXXX",0 ;Mensagem decifrada
RT1: 		.byte 	2, 4, 1, 5, 3, 0 	;Trama do Rotor
RF1: 		.byte 	3, 5, 4, 0, 2, 1 	;Tabela do Refletor

                                            

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
            
