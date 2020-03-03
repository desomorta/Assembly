.MODEL SMALL
.STACK 100H
.DATA
    STRING DB "hi Hello hi Hello hi Hello           hi Hello World!$"
    STRING_LEN EQU $ - OFFSET STRING - 1
    WORD DB "Hello$"
    WORD_LEN EQU $ - OFFSET WORD - 1
.CODE
    START:
        MOV AX,@DATA                  
        MOV DS,AX 
        MOV SI,OFFSET STRING 
        MOV DI,OFFSET WORD
        MOV CX,STRING_LEN
        
        LOOP1:
            MOV DI,OFFSET WORD                         
            CMP STRING[SI]," "        ;������ �� ������,�� ����� ������ ����� ��� ������� ����� ��� ��� ������
            JE IS_FOUND2              ;���� ����� ����� �� 2 ��������
            JMP LOOP_END              ;����� � ����� ����
                          
            IS_FOUND2:
                PUSH SI                ;������ �������� ��,��-�� ���� ��� ����� �� ������ ��������
                MOV SI,DI              ;������ �������� �� �� �� ��� ���������,�� ����� �� ������ (8 � 16)
                MOV BL,STRING[SI]      ;������ � �� �������� string[SI],�� �� ������ ��������
                POP SI                 ;������� �� �����
                CMP STRING[SI + 1],BL  ;����������,��������� �� �������
                JE REMEMBER_BEG        ;���������� ������ ����� 
                JMP LOOP_END           ;����� � ����� ����
                
            REMEMBER_BEG:
                MOV DX,SI              ;���������� ������� �������
                PUSH CX                ;1� ����������� ��������
                INC SI                 ;��������� SI ��� ������ ��������� �����
                MOV AX,0               ;������� ��������� �������� �� ���� ����
                
                LOOP2:                 ;���� ���������
                    PUSH SI            ;������ �� ��� ����,����� ����� ��������� � ������ ����� 
                    MOV SI,DI          ;������ ��-�� ���������
                    MOV BL,STRING[SI]  ;��������e
                    POP SI             ;������� CB 
                    CMP STRING[SI],BL  ;���������� �� �������
                    JE  INC_AX         ;���� �� �� ������� � ��� ��
                    JMP BAD_LOOP2_END  ;����� � ������ ����� ����
             
                    INC_AX:
                        INC AX             ;��� �� ���� ������� �� ���� ���� �������
                        CMP AX,WORD_LEN    ;��������� � ������ �����
                        JE IS_FINALLY      ;���� ���������� �� ������� � ���� ��������
                        JMP GOOD_LOOP2_END ;���� ��� �� � ������� ���������� ����� ��� ����������� ��������� �����
                        
                    IS_FINALLY:
                        CMP STRING[SI + 1]," " ;����� ����� ����� ����� ������?
                        JE FIND_PREVIOUS_WORD        ;���� �� �� ���� ��������
                        JMP BAD_LOOP2_END      ;���� ��� �� ������ ���������� �����
                       
                    GOOD_LOOP2_END:                
                        INC SI                     ;���������� �� � ��
                        INC DI
                        JMP END_OF_LOOP2           ;� ����� �����
                        
                    BAD_LOOP2_END:
                        MOV DI,OFFSET WORD         ;���������� � �� ������ �����
                        MOV CX,1                   ;���������� ���������� �����
                        
                    END_OF_LOOP2:                  ;������� ����� �����
                LOOP LOOP2
                
                POP CX 
                SUB CX,SI                            ;������� �� ����� �� ������ ���
                                                     ;��������� ���������� �������� ��. ����� ������ ����������
                JMP LOOP_END
                
                FIND_PREVIOUS_WORD:
                    ;INT 20H
                    POP CX
                    PUSH SI                        ;���������� ��,�� ��� ����� ����� ����
                    PUSH CX                        ;���������� ��������� ������� ������,����� ����� �������� ����� ���������
                    MOV CX,SI                      ;������������ CX � SI ��� ����,����� ��� ��  = 0 ���� ����������
                    MOV SI,DX                      ;���������� SI �� ������ ����� ������
                    CMP SI,0                       ;����� �� �� ������ ������
                    JE END_OF_LOOP3                ;���� �� - �� � ����� �����
                    DEC SI                         ;����� ���� ����� �� ������ ������ �����
                    MOV DX,0                       ;������� �������� � �����
                    
                 
                    FIND_WORD_LOOP:
                        CMP STRING[SI],"A"        ;���������� ����� ��� ���
                        JGE CHECK_FOR_DEL_WORD    ;�������� �� �����
                        JMP END_OF_LOOP3          ;����� � ����� ����
                        
                        CHECK_FOR_DEL_WORD:
                            CMP STRING[SI],"z"    ;�������� ������ ��� ���
                            JLE FINALLY_DEL_CHECK ;���� �� �� ���� ��������
                            JMP END_OF_LOOP3      ;����� ����� � ����� �����
                        
                        FINALLY_DEL_CHECK:
                            INC DX
                            CMP STRING[SI - 1]," ";����� ��� ���
                            JE DELETE_WORD        ;���� �� �� �������
                            
                            CMP SI,0              ;����� � ������ ������
                            JE DELETE_WORD        ;���� �� �� �������
                            
                        END_OF_LOOP3:
                            DEC SI                ;���� ����� �� ������
                    LOOP FIND_WORD_LOOP
                    
                    DELETE_WORD:
                        POP CX
                        PUSH CX
                        MOV DI,SI
                        MOV CX,DX
                        MOV AX,STRING_LEN
                        SUB AX,SI
                        
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
                        
                    POP CX                        ;���������� ��������� ������
                    POP SI                        ;���������� ��
                    SUB CX,DX                     ;�������� ��������� ��������� ������������� � ���������� ����.��������
                    SUB SI,DX                     ;�������� ���������� �������� � ����������� � ����������� ����.��������
                          
            LOOP_END:                           ;���������� SI
                INC SI                          ;CMP STRING[SI],STRING[SI + OFFSET,WORD]            
        LOOP LOOP1
        
        MOV DX,OFFSET STRING
        MOV AH,9
        INT 21H
        INT 20H
     END START