;��������� ���� ��� 193-2 ������� 19
; ����������� ���������, ������������ ����� ���������������� ��������
; ����� ����� '011' � �������� �������� �����



format PE console

include 'win32a.inc'

entry start

section '.data' data readable writable
    msgNumberInput          db 'Okay, throw me 32-bit number: ', 0
    msgNumberOutOfRange     db 'Invalid input, not a number was entered, or it is not a machine word', 10, 0
    msgResult               db 'Result: %d triples of 011.', 10, 0
    msgTS                   db 'Number in the binary num system:', 10, 0
    msgEnd                  db '', 10, 0
    
    strScanInt              db '%d', 0 ;������ ����� ������ �����

    targetSequence          dd 3 ; 011 � �������� ������� ���������
    targetSequenceLength    dd 3 ; 3
    i                       dd ? ; ��������� �����
    tmp                     dd ? ; ��������� ����������

section '.code' code readable executable

start:
    push    msgNumberInput      ;��������� ���������� � �����  � ����
    call    [printf]            ;������� ���������� � �����
    add     esp, 4 * 1           ;������� �����
    
    push    i          ;��������� � ���� ����������, ���� ����� �������� �����
    push    strScanInt ;��������� � ���� ���������� � �����
    call    [scanf]    ;�������� ����� ���������� ����� � ���������� � i

    ;push    [i]          ;��������� � ���� ����������, ���� ����� �������� �����
    ;push    strScanInt ;��������� � ���� ���������� � �����
    ;call    [printf]

    ;�������� ��� ������� ����� ����� � ������
    cmp eax,0
    je @f

    add     esp, 4 * 2 ;������� �����

    push    [i]          ;��������� � ���� �������� ���������� i,��������� �����
    call    systemTwo    ;�������� ����� �������� � �������� �������
    add     esp, 4 * 1   ;������� �����
    
    push    [i]          ;��������� � ���� �������� ���������� i,��������� �����
    call    countTriples ;�������� ����� �������� ����� ����� '011'
    add     esp, 4 * 1   ;������� �����
    
    jmp     exit ; ����� ������
    
    @@: ;����� �����������, ���� ��� ������ �������� ������
    push    msgNumberOutOfRange ;���������� � ������ �� ����� 32-������� �����
    call    [printf]            ;����� ����������, ��� ������� ������������ �����
    add     esp, 4 * 1          ;������� �����
    
    jmp     exit;����� ������

systemTwo:; ����� ������������� ����� � �������� ������� ���������

    push    msgTS     ;����� ������ � �������
    call    [printf]
    add     esp, 4 * 1

    xor     ebx, ebx     ; �������� ��������
    xor     ecx, ecx
    xor     eax, eax
    mov     ecx, 32      ;���������� � ���������� ������ ������������ ���-�� ��� �����
    sub     ecx, 1;

    simpleLoop:;����
        mov     eax, [esp + 4] ; ���������� ��������� ����� [i] � eax

        bt      eax,ecx        ; ��������� ��� � eax �� ������� ecx

        jc     @f ;������� � @@, ���� ����������� ��� ����� 1

        mov     [tmp], ecx; ���������� ecx

        push    0;
        push    strScanInt ;��������� � ���� ���������� � �����
        call    [printf]

        add     esp, 4 * 2 ;������� �����

        mov     ecx, [tmp];  ���������� �������� ecx
        jmp next;��������� � ����� � ���������

        @@:
        mov     [tmp], ecx; ���������� ecx

         push    1
         push    strScanInt ;��������� � ���� ���������� � �����
         call    [printf]

        add     esp, 4 * 2 ;������� �����

        mov     ecx, [tmp];  ���������� �������� ecx

        next:;������� � ��������� ��������
        dec     ecx; ��������� ���������� ������ �� ����
        jns     simpleLoop ;���� �������� ��� �����-, �� ����� ��������� ���� countTriplesLoop

    push    msgEnd ;����� ������ �������� � �������
    call    [printf]
    add     esp, 4 * 1
    
    ret;��������� �����

countTriples:;����� �������� ����� �� ���������� � �� ��������� ������� ��������
    xor     ebx, ebx     ; �������� ebx
    mov     ecx, 32      ;���������� � ���������� ������ ������������ ���-�� ��� �����
    sub     ecx, [targetSequenceLength];�������� �� ����� ����� ����� ������������������'011'
    
    countTriplesLoop:;���� �������� ���������������� ����� '011'
        mov     eax, [esp + 4] ; ���������� ��������� ����� [i] � ax
        
        push    ecx ;��������� ���������� �������� ����� � ����
        
        mov     edx, 32 ;���������� � ������� ����� ������������ ���-�� ��� �����
        sub     edx, ecx ;�������� �� ������� ����� ���������� ������
        sub     edx, [targetSequenceLength];�������� ��  ������� ����� ������ ������������������'011'

        mov     ecx, edx ;��������� ���������� ������ �� ������� �����

        ;��������� ����� �����-������, ����� ������ ������� ���� ����� ����������� ������� �����
        shl     eax, cl
        shr     eax, cl
        
        pop     ecx ;������� ���������� �������� �������
        
        shr     eax, cl ;��������� ����� ������, ����� ������ ������� ���� �� ����������� ������

        mov     edx, [targetSequence];���������� � dx ����� 3='011'
        
        xor     eax, edx;���� ��� ���� ������� �����, �� ��������� xor �����=0,
        ;� ��� ������, ��� �� ����� ������������������ = '011'
        jnz     @f ;���� �� ����, �� ��������� � ��������� ����� @@ (������� ���� �� ����)
        inc     ebx   ;����������� ������� �����
        sub     ecx, [targetSequenceLength] ;�������� ����� ������������������=3 �� �����
        jns     countTriplesLoop ;���� �������� ��� �����-, �� ����� ��������� ���� countTriplesLoop
        @@: ;����������� ���� ������������������ 011 ���,����� ��������� �� 1 ���
        dec     ecx; ��������� ���������� ������ �� ����
        jns     countTriplesLoop ;���� �������� ��� �����-, �� ����� ��������� ���� countTriplesLoop
    
    push    ebx ;��������� ������� ����� � ����
    push    msgResult ;��������� ���������� ��� ���������
    call    [printf]  ;������� ���������� � �������
    add     esp, 4 * 2 ;������� �����
    
    ret;��������� �����

exit:
    call [getch];�������� ����� �� ������������
    push    0
    call    [ExitProcess];���������� ���������
    
section '.idata' data readable import
        library kernel32, 'kernel32.dll', \
                msvcrt,   'msvcrt.dll'
        import kernel32, ExitProcess, 'ExitProcess'
        import msvcrt, printf, 'printf', \
                       scanf,  'scanf',\
                       getch, '_getch'