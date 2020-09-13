format PE console

entry start

include 'win32a.inc'

section '.data' data readable writable

formatName db '%s', 0

formatAge db '%d', 0

name rd 2

age rd 1

firstQuestion db 'What is your name? ', 0

secondQuestion db 'How old are you? ', 0

hello db 'Hello, %s. Your age is %d. Nice HomeWork awesome Code ',0

NULL = 0

section '.code' code readable executable

start:

push firstQuestion

call [printf]

push name

push formatName

call [scanf]

push secondQuestion

call [printf]

push age

push formatAge

call [scanf]

push [age]

push name

push hello

call [printf]

call [getch]

push NULL

call [ExitProcess]

section '.idata' import data readable

library kernel, 'kernel32.dll',\
msvcrt, 'msvcrt.dll'

import kernel,\
ExitProcess, 'ExitProcess'

import msvcrt,\
printf, 'printf',\
scanf, 'scanf',\
getch, '_getch'