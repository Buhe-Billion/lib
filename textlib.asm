;Description           : On this version we demonstrate the power of EXTERN & GLOBAL
;                      : This file serves as a library for hexdumpv4.asm usw.
;

SECTION .bss           ; Section containing uninitialised data

BUFFLEN EQU 10h
BUFF:   RESB BUFFLEN

SECTION .data          ; Section containing initialised data

DUMPLINE: DB  " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
DUMPLEN   EQU $-DUMPLINE
ASCLINE:  DB  "|................|",10
ASCLEN    EQU $-ASCLINE
FULLLEN   EQU $-DUMPLINE

; The equates shown above must be applied to variables to be exported:
DUMPLENGTH: DQ DUMPLEN
ASCLENGTH:  DQ ASCLEN
FULLLENGTH: DQ FULLLEN
BUFFLENGTH: DQ BUFFLEN

;NASM allows for the exportation of equates, but I agree with the sentiment
;that it can lead to trouble. Use that power sparringly.
SYS_WRITE_CALL_VAL EQU 1
STDERR_FD          EQU 2
SYS_READ_CALL_VAL  EQU 0
STDIN_FD           EQU 0
STDOUT_FD          EQU 1
EXIT_SYSCALL       EQU 60
OK_RET_VAL         EQU 0
EOF_VAL						 EQU 0

HEXDIGITS: DB "0123456789ABCDEF"

;This table allows us to generate text equivalents for binary numbers.
;Index into the table by the nybble using a scale of 4:
;[BINDIGITS + RCX*4]
BINDIGITS:
DB "0000","0001","0010","0011"
DB "0100","0101","0110","0111"
DB "1000","1001","1010","1011"
DB "1100","1101","1110","1111"

;Exported data items and procedures:
GLOBAL BUFF, DUMPLINE, ASCLINE, HEXDIGITS, BINDIGITS
GLOBAL CLEARLINE, DUMPCHAR, NEWLINES, PRINTLINE, LOADBUFF

DOTXLAT:
DB 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
DB 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
DB 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh
DB 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh
DB 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
DB 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh
DB 60h,61h,62h,63h,64h,65h,66h,67h,68h,69h,6Ah,6Bh,6Ch,6Dh,6Eh,6Fh
DB 70h,71h,72h,73h,74h,75h,76h,77h,78h,79h,7Ah,7Bh,7Ch,7Dh,7Eh,2Eh
DB 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
DB 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
DB 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
DB 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
DB 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
DB 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
DB 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
DB 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh


SECTION .text         ; Section containing code

CLEARLINE:
          PUSH RAX
          PUSH RBX
          PUSH RCX
          PUSH RDX

          MOV RDX,15
.POKE:
          MOV RAX, 0
          CALL DUMPCHAR
          SUB RDX,1
          JAE .POKE

          POP RDX
          POP RCX
          POP RBX
          POP RAX

          RET

DUMPCHAR:
          PUSH RBX
          PUSH RDI

          MOV BL,[DOTXLAT+RAX]
          MOV [ASCLINE+RDX+1],BL      ;+1 Coz ASCLINE starts with a pipe |

          MOV RBX,RAX
          LEA RDI,[RDX*2+RDX]

          AND RAX,000000000000000Fh
          MOV AL,[HEXDIGITS+RAX]
          MOV [DUMPLINE+RDI+2],AL

          AND RBX,00000000000000F0h
          SHR RBX,4
          MOV BL,[HEXDIGITS+RBX]
          MOV [DUMPLINE+RDI+1],BL

          POP RDI
          POP RBX
          RET

NEWLINES:
          PUSH RAX
          PUSH RSI
          PUSH RDI
          PUSH RCX
          PUSH RDX
          PUSH R11

          CMP RDX,15
          JA .EXIT
          MOV RCX,EOLS
          MOV RAX,SYS_WRITE_CALL_VAL
          MOV RDI,STDOUT_FD
          SYSCALL

.EXIT:
          POP R11
          POP RDX
          POP RCX
          POP RDI
          POP RSI
          POP RAX
          RET
          
;Tis acceptable to put constant data in the procedure itself
;rather than .bss or .data
EOLS DB 10,10,10,10,10,10,10,10,10,10,10,10,10,10,10

PRINTLINE:
          PUSH RAX
          PUSH RBX
          PUSH RCX
          PUSH RDX
          PUSH RSI
          PUSH RDI
          PUSH R11

          MOV RAX,SYS_WRITE_CALL_VAL
          MOV RDI,STDOUT_FD
          MOV RSI,DUMPLINE
          MOV RDX,FULLLEN
          SYSCALL

          POP R11
          POP RDI
          POP RSI
          POP RDX
          POP RCX
          POP RBX
          POP RAX

          RET

LOADBUFF:
          PUSH RAX
          PUSH RDX
          PUSH RSI
          PUSH RDI

          MOV RAX,SYS_READ_CALL_VAL
          MOV RDI,STDIN_FD
          MOV RSI,BUFF
          MOV RDX,BUFFLEN
          SYSCALL

          MOV R15,RAX
          XOR RCX,RCX

          POP RDI
          POP RSI
          POP RDX
          POP RAX

          RET
