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
                add eax, ebx ; ����� ������� ����� � eax
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
                add eax, ebx ; ����� ������� ����� � eax

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
                add eax, ebx ; ����� ������� ����� � eax
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
                add eax, ebx ; ����� ������� ����� � eax
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
                add eax, ebx ; ����� ������� ����� � eax

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