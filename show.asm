SECTION .data

EXTERN CLRHOME, CLRLEN, SYS_WRITE_CALL_VAL, STDOUT_FD, FILLCHR, EOL, RULERSTRING

SECTION .bss
;This extern does'nt work because assembly time calculations can't be made with
;objects that don't yet exist? Basically: We can't do assembly time calculations
;during link time!?!? I think that's it.
;But the EXTERN on .data works!!!!??? With the assembly time calculations:
;CLRLEN!
;Error thrown for the .bss EXTERN is:
;show.asm:70{this line # may change as we edit}: error: unable to multiply two non-scalar objects
;show.asm:158{same here}: error: unable to multiply two non-scalar objects
;maybe it's just an issue of multiplying during assembly time with unknown objects?
;let me assembly on the other file and see the results ...
; ...It assemblies correctly, though we have a logic bug I'll get back to.
;EXTERN COLS, ROWS, VIDEOBUFFER
;


COLS               EQU  81         ; Line length + 1 char for EOL
ROWS               EQU  25         ; Number of lines in display
VIDEOBUFFER        RESB COLS*ROWS  ; Buffer size adapts to ROWS & COLS


SECTION .text

GLOBAL CLEARTERMINAL, CLEARVID, RULER, SHOW

CLEARTERMINAL:

PUSH R11
PUSH RAX
PUSH RCX
PUSH RDX
PUSH RSI
PUSH RDI

MOV RAX,SYS_WRITE_CALL_VAL
MOV RDI,STDOUT_FD
MOV RSI,CLRHOME             ;Address of escape sequence
MOV RDX,CLRLEN              ;Length of escape sequence
SYSCALL

POP RDI
POP RSI
POP RDX
POP RCX
POP RAX
POP R11

RET

;-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-
; CLEARVID: Clears buffer to spaces and replaces EOLs
; IN: Nothing
; RETURNS: Nothing
; MODIFIES: VIDEOBUFFER, DF
; CALLS: Nothing
; DESCRIPTION: Fills the buffer VIDEOBUFFER with a predefined character
; (FILLCHR) and then places an EOL character at the end of every line,
; where a line ends every COLS bytes in VIDEOBUFFER.

CLEARVID:

PUSH RAX
PUSH RCX
PUSH RDI

CLD                             ;Clear DF; we're counting up memory
MOV AL,FILLCHR                  ;Put the buffer filler char in AL
MOV RCX,COLS*ROWS               ;Put count of chars stored in RCX
REP STOSB                       ;Blast byte-length chars at the buffer

MOV RDI,VIDEOBUFFER
DEC RDI
MOV RCX,ROWS

.PTEOL:
ADD RDI,COLS
MOV BYTE [RDI],EOL
LOOP .PTEOL

POP RDI
POP RCX
POP RAX

RET

;-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-
; RULER: Generates a "1234567890" -­ style ruler at X,Y
; IN: The 1-­based X pos (row #) is passed in RBX
; The 1 -­based Y pos (column #) is passed in RAX
; The length of the ruler in chars is passed in RCX
; RETURNS: Nothing
; MODIFIES: VIDEOBUFFER
; CALLS: Nothing
; DESCRIPTION: Writes a ruler to the video buffer VIDEOBUFFER, at
; the 1-­based X,Y position passed in RBX,RAX.
; The ruler consists of a repeating sequence of the digits 1 through 0. The
;ruler will wrap to subsequent lines and overwrite whatever EOL characters fall
; within its length, if it will not fit entirely on the line where it begins.
; Note that the SHOW procedure must be called after Ruler to display the ruler on the console.

RULER:

PUSH RAX
PUSH RBX
PUSH RCX
PUSH RDX
PUSH RDI

MOV RDI,VIDEOBUFFER
DEC RAX
DEC RBX
MOV AH,COLS
MUL AH
ADD RDI,RAX
ADD RDI,RBX

MOV RDX,RULERSTRING

DORULE:

MOV AL,[RDX]
STOSB
INC RDX
LOOP DORULE

POP RDI
POP RDX
POP RCX
POP RBX
POP RAX

RET

;-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-­-
; SHOW: Display a text buffer to the Linux console
; IN: Nothing
; RETURNS: Nothing
; MODIFIES: Nothing
; CALLS: Linux sys_write
; DESCRIPTION: Sends the buffer VIDEOBUFFER to the Linux console via
; sys_write. The number of bytes sent to the console
; calculated by multiplying the COLS equate by the ROWS equate.

SHOW:

PUSH R11
PUSH RAX
PUSH RCX
PUSH RDX
PUSH RSI
PUSH RDI

MOV RAX,SYS_WRITE_CALL_VAL
MOV RDI,STDOUT_FD
MOV RSI,VIDEOBUFFER
MOV RDX,COLS*ROWS               ;Pass the length of the buffer
SYSCALL

POP RDI
POP RSI
POP RDX
POP RCX
POP RAX
POP R11

RET
