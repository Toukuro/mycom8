1000						ORG		1000H

1000 21 10 10				LD		HL, MSG
1003 11 00 D0				LD		DE, VRAM
1006 06 17					LD		B, MSGLEN
1008 7E				LOOP:	LD		A, (HL)
1009 12						LD		(DE), A
100A 23						INC		HL
100B 13						INC		DE
100C 05						DEC		B
100D 20	F9					JR		NZ, LOOP
100F 76						HALT
						
					VRAM:	EQU		D000H
					MSGLEN:	EQU		23
1010 6B 6B 6B 00 0D			MSG:	DEFS	'*** MONITOR SP-1002 ***'
     0F 0E 09 14 0F
     12 00 13 10 2A
     21 20 20 22 00
     6B 6B 6B
							END
