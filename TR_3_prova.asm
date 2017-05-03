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
limparPM5	xor.b	#LOCKLPM5, PM5CTL0

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
			bis.b	#BIT4,		P8DIR
			bis.b	#BIT4,		P8OUT
			bis.b	#BIT5,		P8DIR
			bis.b	#BIT5,		P8OUT
			bis.b	#BIT6,		P8DIR
			bis.b	#BIT6,		P8OUT
			bis.b	#BIT7,		P8DIR
			bis.b	#BIT7,		P8OUT

			;S2 (P2.0 - INTERRUPÇÃO)
			bic.b	#BIT0,		P2DIR
			bis.b	#BIT0,		P2IE
			bis.b	#BIT0,		P2IES
			bis.b	#BIT0,		P2REN
			bic.b	#BIT0,		P2IFG
			nop
			bis		#GIE,		SR; Habilita todos os interrupts
			nop

			;S1	(P4.0 - VARREDURA)
			bic.b	#BIT0,		&P4DIR
			bis.b	#BIT0,		&P4REN
			bis.b	#BIT0,		&P4OUT

loop		bit.b	#BIT0, &P4IN
			jnz		sequence

sequence	call	#clear
			call	#delay_sequence
			xor.b	#BIT4, P8OUT
			call	#delay_sequence
			bic.b	#BIT4, P8OUT
			xor.b	#BIT5, P8OUT
			call	#delay_sequence
			bic.b	#BIT5, P8OUT
			xor.b	#BIT6, P8OUT
			call	#delay_sequence
			bic.b	#BIT6, P8OUT
			xor.b	#BIT7, P8OUT
			call	#delay_sequence
            jmp		sequence

invert		call 	#clear
			call	#delay_invert
			xor.b	#BIT7, P8OUT
			call	#delay_invert
			bic.b	#BIT7, P8OUT
			xor.b	#BIT6, P8OUT
			call	#delay_invert
			bic.b	#BIT6, P8OUT
			xor.b	#BIT5, P8OUT
			call	#delay_invert
			bic.b	#BIT6, P8OUT
			xor.b	#BIT5, P8OUT
			call	#delay_invert
			bic.b	#BIT5, P8OUT
			xor.b	#BIT4, P8OUT
			call	#delay_invert
			jmp 	invert

delay		mov.b	#0x20000, R4
decrease	dec		R4
			jnz		decrease
			ret

pin_sweep_invert bit.b	#BIT0, &P4IN
				 jz		sequence
				 ret

pin_sweep_sequence bit.b   #BIT0, &P4IN
            	   jz      invert
            	   ret

delay_sequence call 	#pin_sweep_sequence
			   call		#delay
			   call 	#pin_sweep_sequence
			   ret

delay_invert   call		#pin_sweep_invert
			   call		#delay
			   call		#pin_sweep_invert
			   ret

clear		bic.b	#BIT4, P8OUT
			bic.b	#BIT5, P8OUT
			bic.b	#BIT6, P8OUT
			bic.b	#BIT7, P8OUT
			ret

P1_ISR:
			bic.b	#BIT0, P2IFG;Libera a flag de interrupção
			bic.b	#BIT0, P2IE;Desativa a interrupção na p2.0
blink		bic.b	#BIT4, P8OUT
			bic.b	#BIT5, P8OUT
			bic.b	#BIT6, P8OUT
			bic.b	#BIT7, P8OUT
			call	#delay
			bis.b	#BIT4, P8OUT
			bis.b	#BIT5, P8OUT
			bis.b	#BIT6, P8OUT
			bis.b	#BIT7, P8OUT
			call	#delay
			bit.b	#BIT0, P2IN
			jz		sequence
			jmp		blink
			bic.b	#BIT0, P2IFG;Libera a flag de interrupção
          	reti

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack

;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
			.sect	PORT1_VECTOR
            .short	P1_ISR
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET

