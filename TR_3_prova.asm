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

			;S2 (P1.2 - INTERRUPÇÃO)
			bic.b	#BIT0,		P2DIR
			bis.b	#BIT0,		P2IE
			bis.b	#BIT0,		P2IES
			bis.b	#BIT0,		P2REN
			bic.b	#BIT0,		P2IFG
			bis.b	#BIT0,		P2OUT
			nop
			bis		#GIE,		SR; Habilita todos os interrupts
			nop

			bic.b	#BIT0,		&P4DIR
			bis.b	#BIT0,		&P4REN
			bis.b	#BIT0,		&P4OUT

loop		bit.b	#BIT0, &P4IN
			jnz		sequence

sequence	call	#clear
			call 	#pin_sweep_sequence
			call	#delay
			call 	#pin_sweep_sequence
			xor.b	#BIT4, P8OUT
			call	#delay
			call 	#pin_sweep_sequence
			bic.b	#BIT4, P8OUT
			xor.b	#BIT5, P8OUT
			call	#delay
			call 	#pin_sweep_sequence
			bic.b	#BIT5, P8OUT
			xor.b	#BIT6, P8OUT
			call	#delay
			call 	#pin_sweep_sequence
			bic.b	#BIT6, P8OUT
			xor.b	#BIT7, P8OUT
			call	#delay
			call 	#pin_sweep_sequence
            jmp		loop

invert		call 	#clear
			call    #pin_sweep_invert
			call	#delay
			xor.b	#BIT7, P8OUT
			call	#delay
			call    #pin_sweep_invert
			bic.b	#BIT7, P8OUT
			xor.b	#BIT6, P8OUT
			call	#delay
			call    #pin_sweep_invert
			bic.b	#BIT6, P8OUT
			xor.b	#BIT5, P8OUT
			call	#delay
			call    #pin_sweep_invert
			bic.b	#BIT6, P8OUT
			xor.b	#BIT5, P8OUT
			call	#delay
			call    #pin_sweep_invert
			bic.b	#BIT5, P8OUT
			xor.b	#BIT4, P8OUT
			call	#delay
			call    #pin_sweep_invert
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

clear		bic.b	#BIT4, P8OUT
			bic.b	#BIT5, P8OUT
			bic.b	#BIT6, P8OUT
			bic.b	#BIT7, P8OUT
			ret

P1_ISR:
			bic.b	#BIT0, P2IFG;Libera a flag de interrupção
			bic.b	#BIT0, P2IE;Desativa a interrupção na p1.1
			mov		#WDT_MDLY_32,	WDTCTL;Inicia WDT
			bic		#WDTIFG,		SFRIFG1
			or		#WDTIE,		SFRIE1
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

WDT_ISR:
			bic		#WDTIE,			SFRIE1
			bic		#WDTIFG,		SFRIFG1
			mov.w   #WDTPW|WDTHOLD,&WDTCTL
			bis.b	#BIT0,		P2IE
			reti

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack

;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
			.sect	WDT_VECTOR
			.short	WDT_ISR
			.sect	PORT1_VECTOR
            .short	P1_ISR
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET

