.MODEL SMALL
.STACK 100H
.DATA
    STRING DB 200 DUP(?)
    STRING_LEN DB 0
    WORD DB 200 DUP(?)
    WORD_LEN DB 0
    ENTER_STRING_ALERT DB "Enter string",13,10,"$"
    ENTER_STRING_ALERT_LEN EQU $ - ENTER_STRING_ALERT - 1
    ENTER_WORD_ALERT DB "Enter word",13,10,"$"
    ENTER_WORD_ALERT_LEN EQU $ - ENTER_WORD_ALERT_LEN - 1
    YOUR_STRING_ALERT DB 13,10,"Your string",13,10,"$"
    REENTER_ALERT DB 13,10,"You need to put word, reenter!",13,10,"$"
    SLASH_N DB 13,10,"$"
.CODE
    DELETE_SYMBOL MACRO  
    LOCAL DELETE_LOOP     
    PUSH SI             
    PUSH AX             
    DELETE_LOOP:           
        MOV AH, [SI + 1]
        MOV [SI], AH
        INC SI
    LOOP DELETE_LOOP

    POP AX                
    POP SI
    ENDM                 
    
    GET_STR PROC         
        PUSH SI         
        MOV SI,DX      
        MOV [SI], 200   

        MOV AH, 0AH     
        INT 21H 

        XOR AX,AX      
        MOV AL, [SI + 1] 
        ADD AL, 2        
        ADD SI,AX       
        MOV [SI], '$'    

        MOV SI,DX       
        MOV CX,AX       
        DELETE_SYMBOL     
        DEC AL           
        XOR AH,AH       
        MOV CX,AX       
        DELETE_SYMBOL
        DEC AL           

        POP SI
        RET
    GET_STR ENDP

    
    START:
        MOV AX,@DATA                  
        MOV DS,AX 
        MOV AH,9
        MOV DX,OFFSET ENTER_STRING_ALERT
        INT 21H
        MOV DX,OFFSET STRING
        CALL GET_STR
        MOV STRING_LEN,AL
        MOV AH,9
        MOV DX,OFFSET SLASH_N
        INT 21H
        MOV DX,OFFSET ENTER_WORD_ALERT
        INT 21H
        WORD_INPUT:
            MOV DX,OFFSET WORD
            CALL GET_STR
            MOV WORD_LEN,AL
        MOV SI,OFFSET WORD
        MOV CL,WORD_LEN
    
        WORD_CHECK1:
            CMP [SI],"$"
            JE  CHECK_SUCCESS
        
            CMP [SI],"A"
            JL  REENTER
            
            CMP [SI],"z"
            JG  REENTER
            
            JMP CHECK_END
            
            REENTER:
                MOV AH,9
                MOV DX,OFFSET REENTER_ALERT
                INT 21H
                JMP WORD_INPUT
                
            CHECK_END:
                INC SI
        LOOP WORD_CHECK1
        
        CHECK_SUCCESS:
                
        XOR AL,AL
        MOV SI,OFFSET STRING 
        MOV DI,OFFSET WORD
        MOV CL,STRING_LEN
        LOOP1:
            MOV DI,OFFSET WORD                         
            CMP STRING[SI],"A"        
            JL IS_FOUND2
            
            CMP STRING[SI],"z"
            JG IS_FOUND2              
            JMP LOOP_END              
                          
            IS_FOUND2:
                PUSH SI                
                MOV SI,DI              
                MOV BL,STRING[SI]      
                POP SI                 
                CMP STRING[SI + 1],BL  
                JE REMEMBER_BEG         
                JMP LOOP_END           
                
            REMEMBER_BEG:
                MOV DX,SI              
                PUSH CX                
                INC SI                 
                MOV AX,0               
                
                LOOP2:                 
                    PUSH SI             
                    MOV SI,DI          
                    MOV BL,STRING[SI]  
                    POP SI              
                    CMP STRING[SI],BL  
                    JE  INC_AX         
                    JMP BAD_LOOP2_END  
             
                    INC_AX:
                        INC AX             
                        CMP AL,WORD_LEN    
                        JE IS_FINALLY      
                        JMP GOOD_LOOP2_END 
                        
                    IS_FINALLY:
                        CMP STRING[SI + 1],"A" 
                        JL FIND_PREVIOUS_WORD
                        ;JE FIND_PREVIOUS_WORD        
                        
                        CMP STRING[SI + 1],"z"
                        JG FIND_PREVIOUS_WORD
                        
                        CMP STRING[SI + 1],"$"
                        JE FIND_PREVIOUS_WORD
                        JMP BAD_LOOP2_END
                  
                    GOOD_LOOP2_END:                
                        INC SI                     
                        INC DI
                        JMP END_OF_LOOP2           
                        
                    BAD_LOOP2_END:                 
                        MOV DI,OFFSET WORD        
                        MOV AX,0
                        ;DEC CX
                        JMP LOOP_END                   
                        
                    END_OF_LOOP2:                  
                LOOP LOOP2
                
                POP CX 
                SUB CX,SI                            
                                                    
                JMP LOOP_END
                
                FIND_PREVIOUS_WORD:
                    POP CX
                    PUSH SI                       
                    PUSH CX                        
                                                   
                                                  
                    MOV SI,DX
                    MOV CX,SI
                    CMP SI,0                       
                    JE AFTER_LOOP                
                    DEC SI                        
                    MOV DX,0                      
                    
                 
                    FIND_WORD_LOOP:
                        
                        CMP STRING[SI],"A"        
                        JGE CHECK_FOR_DEL_WORD    
                        JMP END_OF_LOOP3         
                        
                        CHECK_FOR_DEL_WORD:
                            CMP STRING[SI],"z"    
                            JLE FINALLY_DEL_CHECK 
                            JMP END_OF_LOOP3      
                        
                        FINALLY_DEL_CHECK:
                            INC DX
                            
                            CMP STRING[SI - 1],"A"
                            JL DELETE_WORD
                            
                            CMP STRING[SI - 1],"z"
                            JG DELETE_WORD
                            
                            CMP SI,0              
                            JE DELETE_WORD        
                            
                            
                        END_OF_LOOP3:
                            DEC SI                
                    LOOP FIND_WORD_LOOP
                    
                    AFTER_LOOP:
                    
                    POP CX
                    INC CX
                    POP SI
                    JMP LOOP_END
                    
                    DELETE_WORD:
                        ;INC SI
                        POP CX
                        PUSH CX
                        MOV DI,SI
                        MOV CX,DX
                        INC CX
                        MOV AL,STRING_LEN
                        SUB AX,SI
                        ;;;;;
                        DELETE_WORD_OUTER_LOOP:
                            PUSH CX
                            MOV CX,AX
                            DELETE_WORD_INNER_LOOP:
                                MOV BL,STRING[SI + 1]
                                MOV STRING[SI],BL
                                INC SI
                            LOOP DELETE_WORD_INNER_LOOP
                            POP CX
                            MOV SI,DI
                            
                        LOOP DELETE_WORD_OUTER_LOOP          
                        
                    POP CX                       
                    POP SI
                    CMP DX,CX
                    JGE ALTERNATIVE_WAY                        
                    SUB CX,DX                     
                    SUB SI,DX
                    INC CX  ;;;
                    DEC SI  ;;;
                    JMP LOOP_END
                    
                    ALTERNATIVE_WAY:
                        SUB SI,DX
                        DEC SI ;;;;;                    
                          
            LOOP_END:                           
                INC SI                                     
        LOOP LOOP1
        
        MOV AH,9
        MOV DX,OFFSET YOUR_STRING_ALERT
        INT 21H
        MOV DX,OFFSET STRING
        INT 21H
        INT 20H
     END START
