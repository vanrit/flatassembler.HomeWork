; Ñèìîíîâè÷ Èâàí ÁÏÈ193
; Âàðèàíò 19
; Íîâûé ìàññèâ ñ çàìåíîé íóëåâûõ ýëåìåíòîâ, ïðåäøåñòâóþùèõ ïåðâîìó îòðèöàòåëüíîìó, åäèíèöåé
;
;     Ðàçðàáîòàòü ïðîãðàììó, êîòîðàÿ ââîäèò îäíîìåðíûé ìàññèâ A[N], ôîðìèðóåò èç ýëåìåíòîâ ìàññèâà A íîâûé ìàññèâ B,
;ñîñòîÿùèé èç èíäåêñîâ ïîëîæèòåëüíûõ ýëåìåíòîâ A, è âûâîäèò åãî. Ïàìÿòü ïîä ìàññèâû ìîæåò âûäåëÿòüñÿ êàê ñòàòè÷åñêè, òàê è äèíàìè÷åñêè ïî âûáîðó ðàçðàáîò÷èêà.
;Ðàçáèòü ðåøåíèå çàäà÷è íà ôóíêöèè ñëåäóþùèì îáðàçîì:
;        Ââîä è âûâîä ìàññèâîâ îôîðìèòü êàê ïîäïðîãðàììû.
;        Ôîðìèðîâàíèå ìàññèâà B îôîðìèòü êàê ïðîöåäóðó
;        Îðãàíèçîâàòü âûâîä êàê èñõîäíîãî, òàê è ñôîðìèðîâàííîãî ìàññèâîâ
;Óêàçàííûå ïðîöåäóðû ìîãóò èñïîëüçîâàòü äàííûå íàïðÿìóþ (èìèòàöèÿ ïðîöåäóð áåç ïàðàìåòðîâ). Èìèòàöèÿ ðàáîòû ñ ïàðàìåòðàìè òàêæå äîïóñòèìà.
;
; Симонович Иван БПИ193
; Вариант 19
; Новый массив с заменой нулевых элементов, предшествующих первому отрицательному, единицей
;
; Разработать программу, которая вводит одномерный массив A[N], формирует из элементов массива A новый массив B,
;состоящий из индексов положительных элементов A, и выводит его. Память под массивы может выделяться как статически, так и динамически по выбору разработчика.
;Разбить решение задачи на функции следующим образом:
; Ввод и вывод массивов оформить как подпрограммы.
; Формирование массива B оформить как процедуру
; Организовать вывод как исходного, так и сформированного массивов
;Указанные процедуры могут использовать данные напрямую (имитация процедур без параметров). Имитация работы с параметрами также допустима.
;

format PE console
entry start

include 'win32a.inc'

section '.data' data readable writable
        msgArraySizeInput   db 'Enter array size: ', 0
        msgBadArraySize     db 'Incorrect size of vector = %d', 10, 0
        msgArrayEntered     db 10,'Your array:', 10, 0
        msgArrayProcessed   db 10,'Result array:', 10, 0
        msgNumberEntered    db '[%d] = %d', 10, 0
        strOutputInt        db '%d', 10, 0
        strScanInt          db '%d', 0

        size     dd ?
        i        dd ?
        tmp      dd ?

        array    rd 100

section '.code' code readable executable

start:
        push msgArraySizeInput
        call [printf]

        push size
        push strScanInt
        call [scanf]

        cmp [size], 1
        jge goodArraySizeEntered
        push [size]
        push msgBadArraySize
        call [printf]
        jmp finish

goodArraySizeEntered:
        mov  [i], 0

loop1:
        push tmp
        push strScanInt
        call [scanf]

        inc [i]

        push esp
        push [tmp]
        push [i]
        push msgNumberEntered
        call [printf]

        mov eax, [i]
        mov ebx, 4
        mul ebx
        mov ebx, array
        add eax, ebx
        mov ebx, [tmp]
        mov [eax], ebx

        mov eax, [i]
        mov edx, [size]
        cmp eax, edx

        jne loop1

arrayEntered:
        push msgArrayEntered
        call [printf]

        mov  [i], 0
        loop2:
                inc [i]

                mov eax, [i]
                mov ebx, 4
                mul ebx
                mov ebx, array
                add eax, ebx ; àäðåñ íóæíîãî ÷èñëà â eax
                mov eax, [eax]
                mov [tmp], eax

                push [tmp]
                push [i]
                push msgNumberEntered
                mov eax, 0
                call [printf]

                mov eax, [i]
                mov edx, [size]
                cmp eax, edx
        jne loop2

        mov  [i], 0
        loop3:
                inc [i]

                mov eax, [i]
                mov ebx, 4
                mul ebx
                mov ebx, array
                add eax, ebx ; àäðåñ íóæíîãî ÷èñëà â eax

                cmp [eax], dword 0
                jne loop3skip
                mov [eax], dword 1
                loop3skip:
                jl loop3exit
                mov eax, [i]
                mov edx, [size]
                cmp eax, edx
        jne loop3
        loop3exit:

        push msgArrayProcessed
        call [printf]

        mov  [i], 0

        loop4:
                inc [i]

                mov eax, [i]
                mov ebx, 4
                mul ebx
                mov ebx, array
                add eax, ebx ; àäðåñ íóæíîãî ÷èñëà â eax
                mov eax, [eax]
                mov [tmp], eax

                push [tmp]
                push [i]
                push msgNumberEntered
                mov eax, 0
                call [printf]

                mov eax, [i]
                mov edx, [size]
                cmp eax, edx
        jne loop4

        jmp finish

printArray:
        mov  [i], 0
        printLoop:
                inc [i]

                mov eax, [i]
                mov ebx, 4
                mul ebx
                mov ebx, array
                add eax, ebx ; àäðåñ íóæíîãî ÷èñëà â eax
                mov eax, [eax]
                mov [tmp], eax

                push [tmp]
                push [i]
                push msgNumberEntered
                mov eax, 0
                call [printf]

                mov eax, [i]
                mov edx, [size]
                cmp eax, edx

        jne printLoop
        ret

replaceZeros:
        mov  [i], 0
        replaceZerosLoop:
                inc [i]

                mov eax, [i]
                mov ebx, 4
                mul ebx
                mov ebx, array
                add eax, ebx ; àäðåñ íóæíîãî ÷èñëà â eax

                cmp [eax], dword 0
                jne notEqualToZero
                mov [eax], dword 1
                notEqualToZero:
                jl replaceZerosExit
                mov eax, [i]
                mov edx, [size]
                cmp eax, edx
        jne replaceZerosLoop
        replaceZerosExit:
        ret

finish:
        call [getch]

        push 0
        call [ExitProcess]

;-------------------------------third act - including HeapApi--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'
