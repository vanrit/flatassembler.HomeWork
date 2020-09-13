format  pe Console
         entry   start
         include 'win32a.inc'

 section '.data' data readable writeable

 helloStr db 'Hello world!I am John Simonovich',0
 NULL=0

 section '.code' code readable executable

 start:
         push helloStr
         call [printf]

        call [getch]

        push NULL
        call [ExitProcess]


 section '.idata' import data readable writeable
         library kernel32,'kernel32.dll',\
                 msvcrt,'msvcrt.dll'

         import  kernel32,\
                 ExitProcess,'ExitProcess'

         import  msvcrt,\
                 printf,'printf',\
                 getch,'_getch'
