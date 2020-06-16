.MODEL small
.STACK 100h
.DATA
    numberBuffer db 9 DUP(?)
    massive dw 30 DUP(?)
    size db 0
    temp dw 5
    Iterator db "[00] (32767 max): $"
    zero_res_int_excep db '0'                                                          
    negative equ -1 
    max dw -32767
    min dw 32767
    
    OutPuting db 0Ah, 0Dh, "That is a result" , 0Ah, 0Dh, '$' 
    A dw ?, ?
    B dw ?, ?

    MinBorder dw ?
    MaxBorder dw ?
    MinBorderMess db 0Ah, 0Dh, "Enter your Minimal border", 0Ah, 0Dh, '$'
    MaxBorderMess db 0Ah, 0Dh, "Enter your Maximal border", 0Ah, 0Dh, '$'
    double dw 2h
    max_min dw 0
    hig_low dw 0

    enter_size_call db 10,13,"Enter array size(2-30): $" 
    reentering_msg db 10,13,"Reenter$",10,13
    exception_flag db '0' 
    is_minus db '0'
    is_ok   db '0'
    is_num  db '0'
    result_msg db 10,13,"Result",10,13,"$"
    error_division_by_zero db 10,13, "Division by zero, exitting...",10,13,"$"
    error_WrongInput db 10,13,"Wrong input. Other symbols in integer number.",10,13,"Reenter...",10,13,"$"
    error_Overflow db "Overflow. ABS of number is bigger than 32767",10,13,"Reenter...$"
    error_NotNumber db "Not a number!",10,13,"Reenter....$"   
    error_InResult_Overflow db 10,13,"Overflow in result vraiable. Can't calculate.",10,13,'$'
        
    enter_msg db "Enter number $"
.CODE
;#############################################; 
OutInt proc  
    push cx
   test    ax, ax
   jns     oi1
   mov  cx, ax
   mov     ah, 02h
   mov     dl, '-'
   int     21h
   mov  ax, cx
   neg     ax
 oi1:  
    xor     cx, cx
    mov     bx, 10 
 oi2:
    xor     dx,dx
    div     bx
    push    dx
    inc     cx
    test    ax, ax
    jnz     oi2
    mov     ah, 02h
 oi3:
    pop     dx
    add     dl, '0'
    int     21h
    loop    oi3
    pop cx
    ret
OutInt endp
;#############################################;  
print macro string
    push dx
    push ax
    lea dx, string
    mov ah, 09H
    int 21h
    pop ax
    pop dx
endm
;#############################################;
println macro
    push dx
    push ax
        mov ah, 02h
        
        mov dl, 0Ah ; \n
        int 21h

        mov dl, 0Dh ; \r
        int 21h
    pop ax
    pop dx
endm
;#############################################;
get_string proc
    push si  
    push cx
    mov si, dx
    mov [si], 7

    mov ah, 0Ah
    int 21h 

    xor ax, ax
    mov al, [si + 1]
 
    add si, ax
    mov [si + 2], '$'

    pop cx          
    pop si
    ret
get_string endp  
;#############################################;
atoi proc
    push di
    push si
    push bx
    mov temp,5
    xor si, si
    mov si, 2
    cmp numberBuffer[si], '-'
    jne positive
    mov di, 1 ;flag for minus
    inc si

    positive:
        cmp numberBuffer[si], '0'
        jb notANumber
        cmp numberBuffer[si], '9'
        ja notANumber
                                               
    xor ax, ax
    mov cx, 10
    atoi_loop:
        xor bx, bx
        mov bl, numberBuffer[si]

        cmp bl, '0'
        jb created                  
        cmp bl, '9'
        ja created

        sub bl, '0'
        
        mov dx, ax  ;ovrfl
        
        mul cx
        
        cmp temp,0
        jne continue_ati
        
        cmp ax,dx   ;ovrfl
        ja overflow
        
        continue_ati: 
        add ax, bx
        
        mov bx, ax  
        
        and bx, 8000h
        jnz overflow
        dec temp    
        inc si
    jmp atoi_loop

    overflow:
        cmp di,1
        jne err
        cmp ax,8000h
        je created
        err:
        print error_Overflow     
        printLn
        mov is_ok,'0'
        jmp finish
    notANumber:
        print error_NotNumber  
        println
        jmp finish

    created:      
        xor cx, cx
        cmp di, 1
        jne finish       
        xor ax, negative
        inc ax 
    finish:
    pop dx
    pop si
    pop di 
    ret
atoi endp
;#############################################;
func PROC 
    ;(number - min)/(max - min) * (high - low) + low
 ;   | temp in code | | max_min |    | hig_low |
    mov bx,max
    mov cx,min
    sub bx,cx;max-min
    mov max_min,bx

    mov bx,MaxBorder
    mov cx,MinBorder
    sub bx,cx;high-low
    mov hig_low,bx

    mov si,offset massive
    mov cl,size
    mov ch,0

    func_loop:
    push cx

    mov bx,[si]
    mov cx,min
    sub bx,cx;num-min

    mov ax,bx
    imul hig_low
    cmp dx,0
    jne overflow_end


    mov cx,max_min
    mov dx,0
    idiv cx;res in ax(int part)

    mov cx,ax

    add ax,MinBorder

    cmp MinBorder,0
    jg greater_0

    lower_0:
    cmp ax,cx
    jg overflow_end
    jmp crtd;(created)
    greater_0:
    cmp ax,cx
    jl overflow_end

    crtd:
    mov [si],ax
    
    pop cx
    add si,2
    loop func_loop
    jmp fin_func

    overflow_end:
    printLn
    print error_InResult_Overflow
    printLn
    mov is_ok,'0'
    pop cx
    jmp fin_func
    
    error:
    printLn 
    print error_division_by_zero
    printLn
    mov is_ok,'0'
    pop cx
    fin_func:
    ret
func ENDP
;#############################################;
getMax macro
    local arrayLoop, next
    push si
    push ax
    push cx
    xor cx, cx
    mov cl, size
    mov si,0
    array_Loop_max:
        mov ax, massive[si]
        cmp ax, max
        jle next

        mov ax, massive[si]
        mov max, ax

        next:
        add si, 2
    loop array_Loop_max

    pop cx
    pop ax
    pop si
endm
;#############################################;
getMin macro
    push si
    push ax
    push cx
    xor cx, cx
    mov cl, size
    mov si,0
    array_Loop_min:
        mov ax, massive[si]
        cmp ax, min
        jge next

        mov ax, massive[si]
        mov min, ax

        next:
        add si, 2
    loop array_Loop_min

    pop cx
    pop ax
    pop si
endm
;#############################################;
Check_num PROC
    push si
    mov is_ok,'0' 
    jmp check_start  
    
    err_min_zero:
    mov is_ok,'0'
    jmp finish_check_num    
    
    check_start:
    mov si,offset numberBuffer+2
    
    mov is_minus,'0'
    mov is_ok,'0'
    
    cmp [si],'-'
    jne check_num_for
    mov is_minus,'1'
    inc si 
             
    cmp [si],'0'
    je err_min_zero
    
    check_num_for:
    
    call Compare_num
    cmp is_num,'0'
    je finish_check_num
    
    inc si
    cmp [si],'$'
    jne check_num_for
    
    mov is_ok,'1'
    
    finish_check_num:
    pop si
    ret
Check_num ENDP
;#############################################;
Compare_num PROC
    mov is_num,'0'
    mov ah,[si] ;[si] - string element
    cmp ah,'0'
    jb fin
    cmp ah,'9'
    ja fin
    mov is_num,'1'
    fin:
    ret
Compare_num ENDP
;#############################################;
Element PROC
    push bx
    push si
    push cx
    xor ax,ax
    
    mov bl,10
    mov al,cl
    div bl
    
    mov si,offset Iterator
    add al,48
    mov [si+1],al 
    
    add ah,48
    mov [si+2],ah
    
    pop cx
    pop si
    pop bx
    ret
Element ENDP
;#############################################;
start:
    mov ax, @DATA
    mov ds, ax
        
    jmp enter_size
     
    enterLoop_err:
    print error_wrongInput
    jmp enterLoop
    
    mov dx, offset numberBuffer
    
    enter_size:
    print enter_size_call
    lea dx,numberBuffer
    call get_string
    call Check_num
    cmp is_ok,'0'
    je enter_size
    call atoi
    cmp ax,2
    jb enter_size
    cmp ax,30
    ja enter_size
    mov cx,ax

    mov si,0

    enterLoop:
                            push si
        mov is_ok,'0'
        println  
        print enter_msg
        call Element
        print Iterator   
        lea dx, numberBuffer
        call get_string
        
        call Check_num
        cmp is_ok,'0'
        je enterLoop_err
          
        printLn
                                                                                                       
        push cx                                                                                         
        call atoi          
        cmp cx, 0
        pop cx
        jne enterLoop
                            pop si
        mov massive[si], ax  
        inc size
        add si, 2 ;mas element is 2 byte
        
        dec cx
        cmp cx,0
        jne enterLoop
    
    border_enter_low:
        println  
        print MinBorderMess
        lea dx, numberBuffer
        call get_string
        
        call Check_num
        cmp is_ok,'0'
        je border_enter_low
        call atoi
        cmp is_ok,'0'
        je border_enter_low
        mov MinBorder,ax
    border_enter_hight:
        println  
        print MaxBorderMess
        lea dx, numberBuffer
        call get_string
        
        call Check_num
        cmp is_ok,'0'
        je border_enter_hight
        call atoi
        cmp is_ok,'0'
        je border_enter_hight
        mov MaxBorder,ax
    
    getMin
    getMax
    
    call func 
    cmp is_ok,'0'
    je fin_main
    ;that means that borders should be swapped
    printLn 
    print result_msg
    printLn
    
    mov ch,0
    mov cl,size
    mov si,offset massive
    output_loop:
    mov ax,[si]
    
    call OutInt
    printLn
    add si,2
    loop output_loop
    fin_main:
    mov ax,4C00h
	int 21h
end start
