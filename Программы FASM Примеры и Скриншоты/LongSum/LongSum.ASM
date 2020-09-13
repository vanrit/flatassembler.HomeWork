              format PE console
entry start 

include 'win32a.inc'

FIRST_PARAMETER  EQU DWORD[EBP+0x08]
SECOND_PARAMETER EQU DWORD[EBP+0x0C]

section '.data' data readable writeable

        RequestInput   db      "> ", 0
        fmt            db      "Sum : %d", 10,13,0
        buffer         db      16    dup(0)
        bytes_read     dd      0

section '.text' code readable executable 

;
; __stdcall signed int Addition (signed int a, signed int b)
;
Addition:
     push       ebp
     mov        ebp,    esp     ; setting up our stack frame.

     mov        ecx,    FIRST_PARAMETER    ; get a
     mov        eax,    SECOND_PARAMETER   ; get b
     add        eax,    ecx     ; adds ECX to EAX and result is stored in EAX

     pop        ebp             ; restore old stack frame pointer
     ret        4 * 2           ; POP 2 DWORD values from stack

start:
     push       -10                ; Get standard input handle
     call       [GetStdHandle]
     mov         ebx,    eax
     xor         esi,    esi
.input:
     push       RequestInput
     call       [printf]
     add        esp,    4       ; restore the stack

     ; read 12 bytes from console
     push      NULL
     push      bytes_read
     push      12             ; bytes to read
     push      buffer
     push      ebx            ; console handle
     call      [ReadFile]

     ; now attempt to convert the buffer to number
     push      10            ; Our RADIX
     push      NULL          ; NULL
     push      buffer
     call      [strtol]
     add       esp,   4

     ; 0 could be an error or completion signal
     test      eax,   eax
     je       .show_results

.add_number:
     ; add number
     push      esi
     push      eax
     call      Addition
     mov       esi,  eax  ; sum += Addition (input, sum);

     jmp       .input

.show_results:
     push      esi
     push      fmt
     call      [printf]
     add       esp, 4*2

     ; pause the console
     call     [getchar]

     push     0x0
     call     [ExitProcess]

section '.idata' import data readable 

        library msvcrt, 'MSVCRT.DLL', \ 
                kernel, 'KERNEL32.DLL' 

        import msvcrt, \ 
                       printf, 'printf', \ 
                       getchar, 'getchar', \
                       strtol,'strtol'

        import kernel, \ 
                       ExitProcess, 'ExitProcess',\
                       GetStdHandle,'GetStdHandle',\
                       ReadFile,'ReadFile'
