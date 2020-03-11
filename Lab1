.MODEL SMALL
.STACK 100H
.DATA 
    SYMBOL_STRING db "Hello,wordl!",13,10,"$"
.CODE
    START:
        MOV AX,@DATA
        MOV DS,AX
        MOV CX,5
        LOOP1:
            MOV AH,9
            MOV DX,OFFSET SYMBOL_STRING
            INT 21H
        LOOP LOOP1
        INT 20H
    END START
