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
            mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
            bic.w   #LOCKLPM5,PM5CTL0       ;Desbloqueia os Pinos I/O
            mov.b   #1, P1DIR
            mov.b   #0, P1OUT
            mov.b   #0x80, P9DIR
            mov.b   #0x00, P9OUT
            bic.b   #BIT1, &P1DIR
            bis.b   #BIT1, &P1REN
            bis.b   #BIT1, &P1OUT

loop        bit.b   #BIT1, &P1IN            ;lê estado do S1
            jnz     off                     ;pula por padrão para o estado off

on          bic.b   #1, P1OUT               ;apaga o led P1.0
            mov.b   #0x20000, R5            ;inicializa o registrador R5
dec_on      dec     R5                      ;decrementa o R5 até 0
            cmp     #0x00000, R5
            jne     dec_on
            xor.b   #0x80, P9OUT
            bit.b   #BIT1, &P1IN
            jeq     off
            jmp     on

off         mov.b   #0x20000, R5
            mov.b   #0x00, P9OUT
dec_off     dec     R5
            cmp     #0x00000, R5
            jne     dec_off
            xor.b   #1, P1OUT
            jmp     loop
            jmp     off


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
            
