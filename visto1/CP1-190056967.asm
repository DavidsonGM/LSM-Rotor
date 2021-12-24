; Aluno: 		David Gonçalves Mendes
; Matrícula:	190056967
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
RT_TAM 		.equ 		32 					;Tamanho dos rotores (32 simbolos)

VISTO1: 	MOV 		#MSG,R5
 			MOV 		#GSM,R6
			CALL 		#ENIGMA 			;Cifrar
 			;CALL 		#RESETE 			;Restaurar posição original

			MOV 		#GSM,R5
 			MOV			#DCF,R6
 			CALL 		#ENIGMA 			;Cifrar
 			JMP $
			NOP
;
; Definição da chave do Enigma
CHAVE: 		.byte 		2, 6, 3, 10, 5, 12, 2
;
; Coloque aqui sua sub-rotina ENIGMA
ENIGMA:		MOV			#CHAVE, R11			; Armazenando a chave em R11
			CALL		#SELECIONA_ROTOR	; Armazena em R13 o rotor que sera utilizado
			CALL		#SELECIONA_REFLETOR ; Armazena em R12 o refletor que sera utilizado
			MOV.B		0(R5), R7			; Passando o valor da primeira letra do vetor lido para R7
			CMP			#0, R7				; Verificando se nao e 0 (que marca final do vetor)
			JZ			RETURN				; Encerrando a subrotina caso seja final de vetor
			CMP			#0x5B, R7			; Verificando se e um caractere ASCII valido
			JGE			COPIA				; Caso seja maior que 0x5A significa que e pontuacao (deve ser mantida)
			SUB			#0x3B, R7			; Subtraindo o valor em ASCII para o caractere ';' (primeiro caractere valido)
			JL			COPIA				; Caso o caractere seja anterior a ';' sera caracterizado como pontuacao e sera mantido
			MOV			#GSM, R8			; Verificando se estamos chamando a funcao com GSM
			CMP			R6, R8				;em R6 ou em R5
			JNE			DECIFRA				; Caso nao esteja em R6, ja esta cifrada entao devemos decifrar a mensagem
			MOV			#1, R8				; Setando R8 = 1 para marcar operacao de cifragem

CIFRA:		CALL		#EMBARALHA_ROTOR	; Girando o rotor de acordo com a configuracao
			ADD			R7, R13				; Incrementando o ponteiro do rotor armazenado em R13 de acordo com a posicao do caractere
			MOV.B		0(R13), 0(R6)		; Copiando o valor do vetor na posicao de acordo com o caractere
			SUB			R7, R13				; Voltando a posicao inicial do rotor
			ADD.B		#0x3B, 0(R6)		; Somando o valor em ASCII da letra A para voltar ao valor da letra
			INC			R5					; Incrementando o ponteiro da mensagem original
			INC			R6					; Incrementando o ponteiro da mensagem cifrada
			MOV.B		0(R5), R7
			CMP			#0, R7
			JZ			RETURN
			CMP			#0x5B, R7
			JGE			COPIA
			SUB			#0x3B, R7
			JL			COPIA
			JMP			CIFRA				; Loop para cifrar a mensagem ate encontrar seu final


DECIFRA:
			MOV			#0, R8				; Setando R8 = 0 para marcar operacao de decifragem
			ADD			R7, R12				; Incrementando o ponteiro para o refletor armazenado em R12 de acordo com a posicao do caractere
			MOV.B		0(R12), R9			; Colocando em R9 o valor do caractere refletido
			SUB			R7, R12				; Retornando o ponteiro a posicao inicial
			MOV			#-1, R10			; Contador, sera usado para ver a posicao do rotor que resulta no caractere
			ADD			R10, R13			; Usado apenas para corrigir a decrementacao no inicio do loop

LOOP:		SUB			R10, R13			; Voltando o rotor para a posicao original
			INC			R10					; Incrementando o contador
			ADD			R10, R13			; Ponteiro do rotor na posicao do contador
			CMP.B		0(R13), R9			; Vendo a posicao do rotor que resulta no caractere
			JNE			LOOP				; Segue no loop ate encontrar a posicao do caractere

			SUB			R10, R13
			CALL		#DESEMBARALHA_ROTOR	; Girando o rotor no sentido contrario de acordo com a configuracao
			MOV.B		R10, 0(R6)			; Copiando a posicao do caractere para a memoria, o que nos da o valor original refletido
			ADD.B		#0x3B, 0(R6)		; Somando o valor em ASCII de ';' para voltar ao valor do caractere
			INC			R5					; Incrementando o ponteiro da mensagem original
			INC			R6					; Incrementando o ponteiro da mensagem cifrada
			MOV.B		0(R5), R7
			CMP			#0, R7
			JZ			RETURN
			CMP			#0x5B, R7
			JGE			COPIA
			SUB			#0x3B, R7
			JL			COPIA
			JMP			DECIFRA				; Loop para decifrar a mensagem ate encontrar seu final

SELECIONA_ROTOR:
			MOV.B		0(R11), R13			; Selecionando apenas o primeiro rotor passado na chave
			CMP			#1, R13				; Verificando qual o vetor foi selecionado
			JEQ			LOADRT1				; e carregando-o em R13
			CMP			#2, R13
			JEQ			LOADRT2
			CMP			#3, R13
			JEQ			LOADRT3
			CMP			#4, R13
			JEQ			LOADRT4
			CMP			#5, R13
			JEQ			LOADRT5

LOADRT1:	MOV			#RT1, R13
			RET
LOADRT2:	MOV			#RT2, R13
			RET
LOADRT3:	MOV			#RT3, R13
			RET
LOADRT4:	MOV			#RT4, R13
			RET
LOADRT5:	MOV			#RT5, R13
			RET

SELECIONA_REFLETOR:
			MOV.B		6(R11), R12			; Pegando o refletor que foi passado na chave
			CMP			#1, R12				; Verificando cada uma das opcoes e
			JEQ			LOADRF1				; carregando o vetor correto em R12
			CMP			#2, R12
			JEQ			LOADRF2
			CMP			#3, R12
			JEQ			LOADRF3

LOADRF1:	MOV			#RF1, R12
			RET
LOADRF2:	MOV			#RF2, R12
			RET
LOADRF3:	MOV			#RF3, R12
			RET

EMBARALHA_ROTOR:
			ADD.B		1(R11), R7			; Somando a configuracao do rotor para obter a nova posicao de cada caractere
			CMP			#RT_TAM, R7			; Vendo se a nova posicao do caractere seria superior ao maior valor possivel
			JL			RETURN
			SUB			#RT_TAM, R7			; Caractere no comeco do rotor caso ultrapasse o maior valor possivel
			RET

DESEMBARALHA_ROTOR:
			SUB.B		1(R11), R10			; Subtraindo a configuracao do rotor para obter a posicao original de cada caractere
			JGE			RETURN				; Vendo se a nova posicao do caractere seria inferior ao menor valor possivel
			ADD			#RT_TAM, R10		; Caractere volta para o fim do rotor caso ultrapasse o menor valor possivel
			RET

COPIA:		MOV.B		0(R5), 0(R6)		; Copiando o primeiro caractere do vetor lido para o escrito
			INC			R5
			INC			R6
			MOV.B		0(R5), R7
			CMP			#0, R7
			JZ			RETURN
			CMP			#0x5B, R7
			JGE			COPIA
			SUB			#0x3B, R7			; Subtraindo o valor em ASCII de ';'
			JL			COPIA
			CMP			#0, R8
			JNZ			CIFRA
			JMP			DECIFRA

RETURN:		RET


;
; Área de dados
 			.data
MSG: 		.byte 		"UMA NOITE DESTAS, VINDO DA CIDADE PARA O ENGENHO NOVO,"
 			.byte 		" ENCONTREI NO TREM DA CENTRAL UM RAPAZ AQUI DO BAIRRO,"
 			.byte 		" QUE EU CONHECO DE VISTA E DE CHAPEU.",0 ;Don Casmurro

GSM: 		.byte 		"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
 			.byte 		"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
 			.byte 		"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",0

DCF: 		.byte 		"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
 			.byte 		"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
 			.byte		"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",0

;Rotores com 32 posições
ROTORES:
RT1: 		.byte 		13, 23, 0, 9, 4, 2, 5, 11, 12, 17, 21, 6, 28, 25, 30, 10
 			.byte 		22, 1, 3, 26, 24, 31, 8, 14, 29, 15, 18, 16, 19, 7, 27, 20
RT2:		.byte 		6, 24, 2, 8, 25, 20, 16, 29, 23, 0, 7, 19, 30, 17, 12, 15
 			.byte 		5, 4, 26, 10, 11, 18, 28, 27, 14, 9, 13, 1, 21, 31, 22, 3
RT3: 		.byte 		6, 15, 23, 7, 27, 13, 19, 3, 16, 4, 17, 20, 24, 25, 0, 10
 			.byte 		30, 26, 22, 1, 8, 11, 14, 31, 9, 28, 5, 18, 12, 2, 29, 21
RT4: 		.byte 		15, 16, 5, 18, 31, 26, 19, 28, 1, 2, 14, 12, 24, 20, 21, 0
 			.byte 		11, 23, 4, 10, 7, 3, 25, 29, 27, 8, 17, 6, 9, 13, 22, 30
RT5: 		.byte 		13, 25, 1, 26, 6, 12, 9, 2, 28, 11, 16, 15, 4, 8, 3, 31
 			.byte 		5, 18, 23, 17, 24, 27, 0, 22, 29, 19, 7, 10, 14, 21, 20, 30

;Refletores com 32 posições
REFLETORES:
RF1: 		.byte 		26, 23, 31, 9, 29, 20, 16, 11, 27, 3, 14, 7, 21, 28, 10, 25
 			.byte		6, 22, 24, 30, 5, 12, 17, 1, 18, 15, 0, 8, 13, 4, 19, 2
RF2: 		.byte 		20, 29, 8, 9, 23, 27, 21, 11, 2, 3, 25, 7, 13, 12, 22, 16
 			.byte 		15, 28, 30, 26, 0, 6, 14, 4, 31, 10, 19, 5, 17, 1, 18, 24
RF3: 		.byte 		14, 30, 7, 5, 15, 3, 18, 2, 23, 17, 29, 28, 25, 27, 0, 4
 			.byte 		19, 9, 6, 16, 26, 22, 21, 8, 31, 12, 20, 13, 11, 10, 1, 24
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
            
