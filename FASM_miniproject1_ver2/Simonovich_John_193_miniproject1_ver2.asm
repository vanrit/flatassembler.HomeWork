;Симонович Иван БПИ 193-2 Вариант 19
; Разработать программу, определяющую число непересекающихся повторов
; троек битов '011' в заданном машинном слове



format PE console

include 'win32a.inc'

entry start

section '.data' data readable writable
    msgNumberInput          db 'Okay, throw me 32-bit number: ', 0
    msgNumberOutOfRange     db 'Invalid input, not a number was entered, or it is not a machine word', 10, 0
    msgResult               db 'Result: %d triples of 011.', 10, 0
    msgTS                   db 'Number in the binary num system:', 10, 0
    msgEnd                  db '', 10, 0
    
    strScanInt              db '%d', 0 ;Формат ввода целого числа

    targetSequence          dd 3 ; 011 в двоичной системе счисления
    targetSequenceLength    dd 3 ; 3
    i                       dd ? ; считанное число
    tmp                     dd ? ; временная переменная

section '.code' code readable executable

start:
    push    msgNumberInput      ;добавляем информацию о вводе  в стек
    call    [printf]            ;Выводим информация о вводе
    add     esp, 4 * 1           ;очистка стека
    
    push    i          ;добавляем в стек переменную, куда будет записано число
    push    strScanInt ;добавляем в стек информацию о вводе
    call    [scanf]    ;вызываем метод считывания числа и записываем в i

    ;push    [i]          ;добавляем в стек переменную, куда будет записано число
    ;push    strScanInt ;добавляем в стек информацию о вводе
    ;call    [printf]

    ;проверка что введено целое число в строке
    cmp eax,0
    je @f

    add     esp, 4 * 2 ;очистка стека

    push    [i]          ;добавляем в стек значение переменной i,введенное число
    call    systemTwo    ;вызываем метод перевода в двоичную систему
    add     esp, 4 * 1   ;очистка стека
    
    push    [i]          ;добавляем в стек значение переменной i,введенное число
    call    countTriples ;вызываем метод подсчета троек битов '011'
    add     esp, 4 * 1   ;очистка стека
    
    jmp     exit ; метод выхода
    
    @@: ;метка запускается, если был введен неверный размер
    push    msgNumberOutOfRange ;информация о выходе за рамки 32-битного числа
    call    [printf]            ;вывод информации, что введено некорректное число
    add     esp, 4 * 1          ;очистка стека
    
    jmp     exit;метод выхода

systemTwo:; Вывод представления числа в двоичной системе счисления

    push    msgTS     ;Вывод строки в консоль
    call    [printf]
    add     esp, 4 * 1

    xor     ebx, ebx     ; обнуляем регистры
    xor     ecx, ecx
    xor     eax, eax
    mov     ecx, 32      ;записываем в количество циклов максимальное кол-во бит числа
    sub     ecx, 1;

    simpleLoop:;цикл
        mov     eax, [esp + 4] ; перемещаем считанное число [i] в eax

        bt      eax,ecx        ; проверяем бит в eax на позиции ecx

        jc     @f ;перейти к @@, если проверяемый бит равен 1

        mov     [tmp], ecx; запоминаем ecx

        push    0;
        push    strScanInt ;добавляем в стек информацию о вводе
        call    [printf]

        add     esp, 4 * 2 ;очистка стека

        mov     ecx, [tmp];  возвращаем значение ecx
        jmp next;переходим к метке с итерацией

        @@:
        mov     [tmp], ecx; запоминаем ecx

         push    1
         push    strScanInt ;добавляем в стек информацию о вводе
         call    [printf]

        add     esp, 4 * 2 ;очистка стека

        mov     ecx, [tmp];  возвращаем значение ecx

        next:;переход к следующей итерации
        dec     ecx; уменьшаем количество циклов на один
        jns     simpleLoop ;если значение без знака-, то опять запускаем цикл countTriplesLoop

    push    msgEnd ;Вывод строки переноса в консоль
    call    [printf]
    add     esp, 4 * 1
    
    ret;завершаем метод

countTriples:;метод подсчета троек не возвращает и не принимает никаких значений
    xor     ebx, ebx     ; обнуляем ebx
    mov     ecx, 32      ;записываем в количество циклов максимальное кол-во бит числа
    sub     ecx, [targetSequenceLength];отнимаем от общей длины длину последовательности'011'
    
    countTriplesLoop:;цикл подсчета непересекающихся троек '011'
        mov     eax, [esp + 4] ; перемещаем считанное число [i] в ax
        
        push    ecx ;добавляем количество итераций цикла в стек
        
        mov     edx, 32 ;записываем в текущую длину максимальное кол-во бит числа
        sub     edx, ecx ;отнимаем от текущей длины количество циклов
        sub     edx, [targetSequenceLength];отнимаем от  текущей длины размер последовательности'011'

        mov     ecx, edx ;обновляем количество циклов на текущую длину

        ;побитовый сдвиг влево-вправо, чтобы убрать старшие биты перед проверяемой тройкой битов
        shl     eax, cl
        shr     eax, cl
        
        pop     ecx ;достаем количество итераций обратно
        
        shr     eax, cl ;побитовый сдвиг вправо, чтобы убрать младшие биты до проверяемой тройки

        mov     edx, [targetSequence];записываем в dx число 3='011'
        
        xor     eax, edx;если все биты попарно равны, то результат xor будет=0,
        ;А это значит, что мы нашли последовательность = '011'
        jnz     @f ;если не ноль, то переходим к следующей метке @@ (которая ниже по коду)
        inc     ebx   ;увеличиваем счетчик троек
        sub     ecx, [targetSequenceLength] ;отнимаем длину последовательности=3 от длины
        jns     countTriplesLoop ;если значение без знака-, то опять запускаем цикл countTriplesLoop
        @@: ;запускается если последовательности 011 нет,тогда двигаемся на 1 бит
        dec     ecx; уменьшаем количество циклов на один
        jns     countTriplesLoop ;если значение без знака-, то опять запускаем цикл countTriplesLoop
    
    push    ebx ;добавляем счетчик троек в стек
    push    msgResult ;добавляем информацию про результат
    call    [printf]  ;выводим информацию и счетчик
    add     esp, 4 * 2 ;очистка стека
    
    ret;завершаем метод

exit:
    call [getch];ожидание ввода от пользователя
    push    0
    call    [ExitProcess];завершение программы
    
section '.idata' data readable import
        library kernel32, 'kernel32.dll', \
                msvcrt,   'msvcrt.dll'
        import kernel32, ExitProcess, 'ExitProcess'
        import msvcrt, printf, 'printf', \
                       scanf,  'scanf',\
                       getch, '_getch'