init:       LHI		R21,0x8000            ; set R21 = 0x80000000h (command address)
            LBU		R22,0x0000(R21)       ; CS_READ_STARTUP (read STARTUP signal into R22)
            BEQZ	R22,handler           ; if (STARTUP == 0) then jump to handler
      					      ; begin preamble: perform all startup initialization tasks here beacause interrupts are disabled
      					      ; storage of the incompatibility table
	    LHI		R23,0x0007            ; set R23 = 0x00070000h		row 1		1-I
            ADDUI	R1,R23,0xC024         ; set R1  = 0x0007C024h		row 1 		1-I
            LHI		R23,0x000B            ; set R23 = 0x000B0000h		row 2		1-II
            ADDUI	R2,R23,0xFFDB         ; set R2  = 0x000BFFDBh		row 2		1-II
            LHI		R23,0x000D            ; set R23 = 0x000D0000h		row 3		1-III
            ADDUI	R3,R23,0xFFDB         ; set R3  = 0x000DFFDBh		row 3		1-III
            LHI		R23,0x000E            ; set R23 = 0x000E0000h		row 4		I-1
            ADDUI	R4,R23,0xC000         ; set R4  = 0x000EC000h		row 4		I-1
            LHI		R23,0x000F            ; set R23 = 0x000F0000h		row 5		II-1
            ADDUI	R5,R23,0x7C00         ; set R5  = 0x000F7C00h		row 5		II-1
            ADDUI	R6,R23,0xBD08         ; set R6  = 0x000FBD08h		row 6		III-1
            LHI		R23,0x0006            ; set R23 = 0x00060000h		row 7		2-II
            ADDUI	R7,R23,0xDFDB         ; set R7  = 0x0006DFDBh		row 7		2-II
            ADDUI	R8,R23,0xEFDB         ; set R8  = 0x0006EFDBh		row 8		2-III
            ADDUI	R9,R23,0xF400         ; set R9  = 0x0006F400h		row 9		II-2
            ADDUI	R10,R23,0xF908        ; set R10 = 0x0006F908h		row 10     III-2
            ADDUI	R11,R23,0xB9DB        ; set R11 = 0x0006B9DBh		row 11		3-II
            ADDUI	R12,R23,0x76DB        ; set R12 = 0x000676DBh		row 12		3-III
            ADDUI	R13,R23,0x135B        ; set R13 = 0x0006135Bh		row 13		II-3
            ADDUI	R14,R23,0x339B        ; set R14 = 0x0006339Bh		row 14		III-3
            LHI		R23,0x0009            ; set R21 = 0x00090000h		row 15		4-I
            ADDUI	R15,R23,0x001F        ; set R15 = 0x0009001Fh		row 15		4-I
            LHI		R23,0x0006            ; set R21 = 0x00060000h		row 16		4-II
            ADDUI	R16,R23,0xBBEF        ; set R16 = 0x0006BBEFh		row 16		4-II
            ADDUI	R17,R23,0x77F7        ; set R17 = 0x000677F7h		row 17		4-III
            ADDUI	R18,R0,0x003B         ; set R18 = 0x0000003Bh		row 18		I-4
            LHI		R23,0x0002            ; set R23 = 0x00020000h		row 19		II-4
            ADDUI	R19,R23,0x13FD        ; set R19 = 0x000213FDh		row 19		II-4
            LHI		R23,0x0006            ; set R23 = 0x00060000h		row 20		III-4
            ADDUI	R20,R23,0x33FE        ; set R20 = 0x000633FE		row 20		III-4
                                              ; end of storage
      	    SB		R0,0x0001(R21)        ; CS_WRITE_0_STARTUP
                                              ; end of preamble
	    J		main                  ; jump to main
    
handler:    LW		R24,0x0004(R21)       ; CS_READ_C (read interrupt into R24)
            LHI		R25,0x0008            ; set R25 = 0x00080000h (only the 20th bit is equal to 1)
            AND		R26,R24,R25           ; turn off all bits except the 20th one which represents Cd1-I_SYNC
            BNEZ	R26,R_Cd1I            ; if BD19 is equal to 1, the Cd1-I route is managed
            LHI		R25,0x0004            ; set R25 = 0x00040000h (only the 19th bit is equal to 1)
            AND		R26,R24,R25           ; turn off all bits except the 19th one which represents Cd1-II_SYNC
            BNEZ	R26,R_Cd1II           ; if BD18 is equal to 1, the Cd1-II route is managed
            ...
            ...
            ANDI	R26,R24,0x2000		; turn off all bits except the 14th one which represents Cd2-II_SYNC
            BNEZ	R26,R_Cd2II			; if BD13 is equal to 1, the Cd2-II route is managed
            ...
            ...
	    RFE							; return to main
         
R_Cd2II:    LW		R30, 0x0008(R21)	; CS_READ_R (read the active itineraries into R30)
            AND		R27,R7,R30			; phase R: verification of incompatibilities of 2-II with active itineraries
       	    BEQZ	R27,DEV_Cd2II		; if (R27 == 0) then jump to RUN_Cd2II
       	    SB		R0,0x0002(R21)		; CS_DESTROY_Cd2-II (reset Cd2-II)
            LW		R24,0x0004(R21)		; CS_READ_C (read interrupt into R24)
       	    J		handler				; jump to handler
       								
RUN_Cd2II:  ADDUI	R28,R0,0x0001		; set R28 = 0x00000001h
            SB		R28,0x000C(R21)		; CS_M_DEV1 (with normal operation)
            SB		R28,0x000D(R21)		; CS_M_DEV2 (with normal operation)
	    SB		R0,0x0003(R21)		; CS_REGISTRATION_Rd2-II

            LW		R24,0x0004(R21)		; CS_READ_C (read interrupt into R24)
            J		handler				; jump to handler
       
main:						; DLX routine activities				
