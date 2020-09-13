 format PE console 4.0
 
include 'win32a.inc'
start:  cinvoke printf,  req, 41h   ; Вывод на экран 
    cinvoke scanf, tpt, A       ; ввод A
    cinvoke printf,  req, 42h   ; Вывод на экран 
    cinvoke scanf, tpt, B       ; ввод B
    mov eax,[A]
    mul [B]
    cinvoke printf, tpo, eax
    invoke  sleep, 5000     ; 5 sec. delay
; выход
gtfo:   invoke  exit, 0
req db  'Enter %c:',0
tpo db  'A * B = '
tpt db  '%d',0
A   dd  ?
B   dd  ?
; import data in the same section
 data import
 
 library msvcrt,'MSVCRT.DLL',\
    kernel32,'KERNEL32.DLL'
 
 import kernel32,\
    sleep,'Sleep'
 
 import msvcrt,\
    puts,'puts',\
    scanf,'scanf',\
        printf,'printf',\ 
    exit,'exit'
end data
