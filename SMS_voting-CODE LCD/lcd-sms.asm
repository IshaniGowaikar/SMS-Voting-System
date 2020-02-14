
;LCD TEST
               
           
               org 	00h
               mov 	a,#38h
               acall 	command
               mov 	a,#0eh
               acall 	command
               mov 	a,#06h
               acall 	command

  again:             mov  a,#01h
               acall 	command

               mov 	a,#80h
               acall 	command
              mov 	dptr,#MSG1
              mov 	r1,#16
     back1:   clr 	a
              movc 	a,@a+dptr
              acall 	DISPLAY
              inc 	dptr
              djnz 	r1,back1


              mov a,#0c0h
	      acall command
	      mov 	dptr,#MSG2
              mov 	r1,#16
     back2:   clr 	a
              movc 	a,@a+dptr
              acall 	DISPLAY
              inc 	dptr
              djnz 	r1,back2
	      acall  delay
	      acall  delay

	      setb p1.1
	      acall delay
	      clr p1.1
	      acall delay
     
		
              sjmp 	again

              
COMMAND:ACALL READY
        MOV   P0,A
        CLR   P2.3
        CLR   P2.4
        SETB  P2.5
        CLR   P2.5
        RET

DISPLAY:ACALL READY
        MOV   P0,A
        SETB  P2.3
        CLR   P2.4
        SETB  P2.5
        CLR   P2.5
        RET

READY:  CLR   P2.5
        MOV   P0,#0FFH
        CLR   P2.3
        SETB  P2.4
WAIT:   CLR   P2.5
        SETB  P2.5
        JB    P0.7,WAIT
        CLR   P2.5
        RET





delay:    mov r2,#6

here2:    mov r3,#255
here1:    mov r4,#255
here:     djnz r4,here
          djnz r3,here1
          djnz r2,here2
          ret




MSG1: db   '   SMS Voting   '
MSG2: db   '    system      '



               end