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
			bic.b	#BIT2,		P1DIR
			bis.b	#BIT2,		P1IE
			bis.b	#BIT2,		P1IES
			bis.b	#BIT2,		P1REN
			bic.b	#BIT2,		&P1IFG
			nop
			bis		#GIE,		SR; Habilita todos os interrupts
			nop

			bic.b	#BIT1,		&P1DIR
			bis.b	#BIT1,		&P1REN
			bis.b	#BIT1,		&P1OUT

off			bit.b	#BIT1, &P1IN
			jnz		sequence

sequence	bit.b   #BIT1, &P1IN
            jz      invert
			bic.b	#BIT4, P8OUT
			bic.b	#BIT5, P8OUT
			bic.b	#BIT6, P8OUT
			bic.b	#BIT7, P8OUT
			bit.b   #BIT1, &P1IN
            jz      invert
			call	#delay
			bit.b   #BIT1, &P1IN
            jz      invert
			xor.b	#BIT4, P8OUT
			call	#delay
			bit.b   #BIT1, &P1IN
            jz      invert
			bic.b	#BIT4, P8OUT
			xor.b	#BIT5, P8OUT
			call	#delay
			bit.b   #BIT1, &P1IN
            jz      invert
			bic.b	#BIT5, P8OUT
			xor.b	#BIT6, P8OUT
			call	#delay
			bit.b   #BIT1, &P1IN
            jz      invert
			bic.b	#BIT6, P8OUT
			xor.b	#BIT7, P8OUT
			call	#delay
			bit.b   #BIT1, &P1IN
            jz      invert
            jmp		off

invert		bit.b	#BIT1, &P1IN
			jz		sequence
			bic.b	#BIT4, P8OUT
			bic.b	#BIT5, P8OUT
			bic.b	#BIT6, P8OUT
			bic.b	#BIT7, P8OUT
			bit.b	#BIT1, &P1IN
			jz		sequence
			call	#delay
			xor.b	#BIT7, P8OUT
			call	#delay
			bit.b	#BIT1, &P1IN
			jz		sequence
			bic.b	#BIT7, P8OUT
			xor.b	#BIT6, P8OUT
			call	#delay
			bit.b	#BIT1, &P1IN
			jz		sequence
			bic.b	#BIT6, P8OUT
			xor.b	#BIT5, P8OUT
			call	#delay
			bit.b	#BIT1, &P1IN
			jz		sequence
			bic.b	#BIT6, P8OUT
			xor.b	#BIT5, P8OUT
			call	#delay
			bit.b	#BIT1, &P1IN
			jz		sequence
			bic.b	#BIT5, P8OUT
			xor.b	#BIT4, P8OUT
			call	#delay
			bit.b	#BIT1, &P1IN
			jz		sequence
			jmp 	invert

delay		mov.b	#0x20000, R4
decrease	dec		R4
			jnz		decrease
			ret

P1_ISR:
			nop
			bis		#GIE,		SR; Habilita todos os interrupts
			nop
			bic.b	#BIT2,		&P1IFG;Libera a flag de interrupção
			bic.b	#BIT1,		P1IE;Desativa a interrupção na p1.1
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
			bit.b	#BIT2, P1IN
			jz		sequence
			jmp		blink
			bic.b	#BIT2,		&P1IFG;Libera a flag de interrupção
          	reti

WDT_ISR:
			bic		#WDTIE,			SFRIE1
			bic		#WDTIFG,		SFRIFG1
			mov.w   #WDTPW|WDTHOLD,&WDTCTL
			bis.b	#BIT2,		P1IE
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

