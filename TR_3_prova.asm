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
			mov.b	#0x80,		P9DIR
			mov.b	#0x03,		P1DIR
			bis.b	#0x02,		P1IES
			bis.b	#0x02,		P1REN

			bis.b	#0x02,		P1IE
			bic.b	#0x02,		P1IFG
			bic.b	#0x02,		P1DIR
			mov.b	#0x03,		P1OUT
			mov.b	#0x80,		P9OUT

			nop
			bis		#GIE,		SR; Habilita todos os interrupts
			nop

			mov		#0x0001,		R6

blink1		cmp		#0x0001,		R6
			jne		blink2
			bic.b	#0x01, P1OUT
			bic.b	#0x80, P9OUT
			jmp		blink1

blink2		cmp		#0x0001,			R6
			jeq		blink1
			mov.b	#0x20000, R5
delay		dec 	R5
			jnz		delay
			xor.b	#0x01, P1OUT
			xor.b	#0x80, P9OUT
			jmp		blink2

P1_ISR:
			bic.b	#0x02,		P1IFG;Libera a flag de interrupção
			bic.b	#0x02,		P1IE;Desativa a interrupção na p1.1
			mov		#WDT_MDLY_32,	WDTCTL;Inicia WDT
			bic		#WDTIFG,		SFRIFG1
			or		#WDTIE,		SFRIE1
			xor		#0x0001,		R6
          	reti

WDT_ISR:
			bic		#WDTIE,			SFRIE1
			bic		#WDTIFG,		SFRIFG1
			mov.w   #WDTPW|WDTHOLD,&WDTCTL
			bis.b	#0x02,		P1IE
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

