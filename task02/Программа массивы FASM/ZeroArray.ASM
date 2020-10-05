; Симонович Иван БПИ193
; Вариант 19
; Новый массив с заменой нулевых элементов, предшествующих первому отрицательному, единицей
;
;     Разработать программу, которая вводит одномерный массив A[N], формирует из элементов массива A новый массив B,
;состоящий из индексов положительных элементов A, и выводит его. Память под массивы может выделяться как статически, так и динамически по выбору разработчика.
;Разбить решение задачи на функции следующим образом:
;        Ввод и вывод массивов оформить как подпрограммы.
;        Формирование массива B оформить как процедуру
;        Организовать вывод как исходного, так и сформированного массивов
;Указанные процедуры могут использовать данные напрямую (имитация процедур без параметров). Имитация работы с параметрами также допустима.
;

format PE console
entry start

include 'win32a.inc'

MAX_ARRAY_SIZE =100

section '.data' data readable writable
        msgArraySizeInput   db 'Enter array size: ', 0
        msgBadArraySize     db 'Incorrect size of vector = %d', 10, 0
        msgArrayEntered     db 10,'Your array:', 10, 0
        msgArrayNoChanges   db 10,'No numbers can be replaced.', 10, 0
        msgFirstNegative    db 10,'First negative number index: %d', 10, 0
        msgArrayProcessed   db 10,'Result array:', 10, 0
        msgNumberEntered    db '[%d] = %d', 10, 0
        strOutputInt        db '%d', 10, 0
        strScanInt          db '%d', 0

        size     dd ?
        i        dd ?
        tmp      dd ?

        array    rd MAX_ARRAY_SIZE

section '.code' code readable executable

start:
    push msgArraySizeInput
    call [printf]
    add  esp, 4 * 1

    push size
    push strScanInt
    call [scanf]
    add  esp, 4 * 2

    cmp  [size], 0
    jle  @f
    cmp  [size], MAX_ARRAY_SIZE
    jle  readInitialArray 
    
    @@:
        push [size]
        push msgBadArraySize
        call [printf]
        add  esp, 4 * 2
    
        jmp  exit

readInitialArray:
    mov  [i], 0
    @@:
        inc  [i]
    
        push tmp
        push strScanInt
        call [scanf]
        add  esp, 4 * 2

        push [tmp]
        push [i]
        push msgNumberEntered
        call [printf]
        add  esp, 4 * 3
    
        mov  eax, [i]
        mov  ebx, 4
        mul  ebx
        mov  ebx, array
        add  eax, ebx
        mov  ebx, [tmp]
        mov  [eax], ebx
    
        mov  eax, [i]
        mov  edx, [size]
        cmp  eax, edx
    
        jne  @b

printInitialArray:
    push msgArrayEntered
    call [printf]
    add  esp, 4 * 1
    
    call printArray

processArray:
    call replaceZeros

printProcessedArray:
    push msgArrayProcessed
    call [printf]
    add  esp, 4 * 1
    
    call printArray

exit:
    call [getch]
    push 0

    call [ExitProcess]

printArray:
    mov  [i], 0
    @@:
        inc  [i]

        mov  eax, [i]
        mov  ebx, 4
        mul  ebx
        mov  ebx, array
        add  eax, ebx ; адрес нужного числа в eax
        mov  eax, [eax]
        mov  [tmp], eax

        push [tmp]
        push [i]
        push msgNumberEntered
        call [printf]
        add  esp, 4 * 3

        mov  eax, [i]
        mov  edx, [size]
        cmp  eax, edx

        jne  @b
    ret

replaceZeros:
    cmp  [size], 1
    je   _noChanges
    
    mov  [i], 0
    @@:
        inc  [i]
        mov  ecx, [i]

        mov  eax, [i]
        mov  ebx, 4
        mul  ebx
        mov  ebx, array
        add  eax, ebx

        cmp  [eax], dword 0
        jl   @f

        mov  eax, [i]
        mov  edx, [size]
        cmp  eax, edx
        jne  @b

    _noChanges:
    push msgArrayNoChanges
    call [printf]
    add  esp, 4 * 1
    ret
    
    @@:
    cmp  [i], 1
    je   _noChanges
    
    push [i]
    push msgFirstNegative
    call [printf]
    add  esp, 4 * 2
    
    @@:
        dec [i]
        mov  eax, [i]
        mov  ebx, 4
        mul  ebx
        mov  ebx, array
        add  eax, ebx

        cmp  [eax], dword 0
        jne  _afterReplacement
        mov  [eax], dword 1
        
        _afterReplacement:
        mov  eax, [i]
        mov  edx, 0
        cmp  eax, edx
        jne  @b
    ret
    
section '.idata' data readable import
        library kernel32, 'kernel32.dll', \
                msvcrt,   'msvcrt.dll'
        import kernel32, ExitProcess, 'ExitProcess'
        import msvcrt, printf, 'printf', \
                       scanf,  'scanf',\
                       getch, '_getch'