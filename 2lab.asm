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
            CMP STRING[SI]," "        ;Чекаем на пробел,тк иначе искать слово без пробела перед ним нет смысла
            JE IS_FOUND2              ;Если нашли джамп на 2 проверку
            JMP LOOP_END              ;иначе в конец лупа
                          
            IS_FOUND2:
                PUSH SI                ;сейвим значение СИ,из-за того что потом не сможем сравнить
                MOV SI,DI              ;меняем значение СИ на ДИ для сравнения,тк потом не сможем (8 и 16)
                MOV BL,STRING[SI]      ;пихаем в БЛ значение string[SI],тк не сможем сравнить
                POP SI                 ;достаем из стека
                CMP STRING[SI + 1],BL  ;сравниваем,одинаковы ли символы
                JE REMEMBER_BEG        ;запоминаем начало слова 
                JMP LOOP_END           ;иначе в конец лупа
                
            REMEMBER_BEG:
                MOV DX,SI              ;запоминаем позицию пробела
                PUSH CX                ;1е запоминание счетчика
                INC SI                 ;инкремент SI для начала сравнения слова
                MOV AX,0               ;счетчик совпавших символов из двух слов
                
                LOOP2:                 ;цикл сравнения
                    PUSH SI            ;сейвим СИ для того,чтобы потом вернуться к началу слова 
                    MOV SI,DI          ;пихаем из-за сравнения
                    MOV BL,STRING[SI]  ;сравнениe
                    POP SI             ;достаем CB 
                    CMP STRING[SI],BL  ;одинаковые ли символы
                    JE  INC_AX         ;если да то переход к ИНК АХ
                    JMP BAD_LOOP2_END  ;иначе в плохой конец лупа
             
                    INC_AX:
                        INC AX             ;ИНК АХ если символы из двух слов совпали
                        CMP AX,WORD_LEN    ;сравнение с длиной слова
                        JE IS_FINALLY      ;если одинаковые то прыгаем в ласт проверку
                        JMP GOOD_LOOP2_END ;если нет то в обычное завершение цикла для дальнейшего сравнения строк
                        
                    IS_FINALLY:
                        CMP STRING[SI + 1]," " ;после конца слова стоит пробел?
                        JE FIND_PREVIOUS_WORD        ;если да то ласт проверка
                        JMP BAD_LOOP2_END      ;если нет то плохое завершение цикла
                       
                    GOOD_LOOP2_END:                
                        INC SI                     ;увеличение СИ и ДИ
                        INC DI
                        JMP END_OF_LOOP2           ;в конец цикла
                        
                    BAD_LOOP2_END:
                        MOV DI,OFFSET WORD         ;возвращаем в ДХ начало слова
                        MOV CX,1                   ;экстренное завершение цикла
                        
                    END_OF_LOOP2:                  ;обычный конец цикла
                LOOP LOOP2
                
                POP CX 
                SUB CX,SI                            ;достаем из стека СХ первый раз
                                                     ;уменьшаем количество итераций тк. длина строки уменьшится
                JMP LOOP_END
                
                FIND_PREVIOUS_WORD:
                    ;INT 20H
                    POP CX
                    PUSH SI                        ;запоминаем СХ,тк тут будет новый цикл
                    PUSH CX                        ;запоминаем указатель текущей строки,чтобы после удаления слова вернуться
                    MOV CX,SI                      ;приравниваем CX к SI для того,чтобы при СИ  = 0 цикл завершился
                    MOV SI,DX                      ;перемещаем SI на пробел перед словом
                    CMP SI,0                       ;дошли ли до начала строки
                    JE END_OF_LOOP3                ;если да - то в конец цикла
                    DEC SI                         ;иначе идем назад по строке искать слово
                    MOV DX,0                       ;счетчик символов в слове
                    
                 
                    FIND_WORD_LOOP:
                        CMP STRING[SI],"A"        ;сравниваем слово или нет
                        JGE CHECK_FOR_DEL_WORD    ;проверка на слово
                        JMP END_OF_LOOP3          ;иначе в конец лупа
                        
                        CHECK_FOR_DEL_WORD:
                            CMP STRING[SI],"z"    ;проверка символ или нет
                            JLE FINALLY_DEL_CHECK ;если да то ласт проверка
                            JMP END_OF_LOOP3      ;иначе джамп в конец цикла
                        
                        FINALLY_DEL_CHECK:
                            INC DX
                            CMP STRING[SI - 1]," ";слово или нет
                            JE DELETE_WORD        ;если да то удалить
                            
                            CMP SI,0              ;слово в начале строки
                            JE DELETE_WORD        ;если да то удалить
                            
                        END_OF_LOOP3:
                            DEC SI                ;идти назад по строке
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
                        
                    POP CX                        ;возвращаем указатель строки
                    POP SI                        ;возвращаем СХ
                    SUB CX,DX                     ;отнимаем положение указателя всоответствии с количество удал.символов
                    SUB SI,DX                     ;отнимаем количество итераций в соотношении с количеством удал.символов
                          
            LOOP_END:                           ;увеличение SI
                INC SI                          ;CMP STRING[SI],STRING[SI + OFFSET,WORD]            
        LOOP LOOP1
        
        MOV DX,OFFSET STRING
        MOV AH,9
        INT 21H
        INT 20H
     END START