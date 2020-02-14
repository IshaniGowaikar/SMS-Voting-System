       


         gsm     bit     1
	 us1     bit     2
	 us2     bit     3
	 us3     bit     4
	 us4     bit     5
	 us5     bit     6
         vvt     bit     7


         dl0     equ     30H
         dl1     equ     31H
         dl2     equ     32H
	 scnt    equ     33h
	 ccnt1	 equ	 37h
	 ccnt2	 equ	 38h
	 ccnt3	 equ	 39h
	 ccnt4	 equ	 3ah


         org      0000h
	 lcall    delay1
         clr      p2.4
         mov      scon,#50h		;serial init
         mov      tmod,#20h
         mov      tl1,#0fdh
         mov      th1,#0fdh
         setb     tr1
         mov      ie,#80h
         setb     tr1
         lcall    lcdinit		;lcd init
	 mov      20h,#0
         lcall    delay
	 mov      ccnt1,#0
	 mov      ccnt2,#0
	 mov      ccnt3,#0
	 mov      ccnt4,#0

chk_voting:
         lcall    delay
         lcall   chk_gsm		;chk gsm connect
         jnb     gsm,agn1
         lcall   delay
         lcall   send_init
         lcall   delay
         lcall   delet_all
         lcall   delay
         lcall   delay
         lcall   rd_cntr
         mov     scnt,46h
         lcall   delay
	 mov     r4,#50

agn1:	lcall   clear
        mov      dptr,#msg1	;disp init msg 
        mov      R7,#16
        lcall    disp_msg
        lcall    delay
        lcall    delay

        lcall   delay
	jnb     gsm,nogs 
        sjmp    read_msgcntr

nogs:	 mov     a,#0c0h
	 acall   command
         mov     dptr,#ngsm
         mov     R7,#16
         lcall   disp_msg
	 lcall   delay
	 lcall   delay
	 lcall   delay
here:	 sjmp    here

read_msgcntr:
       jb       p2.0,chk_msg		;count key
       lcall    delay1
       jb       p2.0,chk_msg
       ajmp     counting
chk_msg:
       lcall    delay
       lcall    delay
       lcall    delay
       lcall    delay
       lcall    rd_cntr
       lcall    disp_cntr
       mov      a,scnt
       cjne     a,46h,newmsg
       sjmp     read_msgcntr
                                
newmsg:mov     scnt,46h
       lcall   read_sms
       lcall   disp_sms
       lcall   delay
       lcall   delay
       lcall   delay
       lcall   delay
       sjmp    chkk_msg

inv_m:   lcall  clear 
         MOV    DPTR,#invm
         MOV    R7,#16
         lcall   disp_msg
         lcall  DELAY
         lcall   send_init
         lcall   delay
	 lcall  delet_all
	 lcall  delay
         lcall  rd_cntr
          mov   scnt,46h
         ajmp   read_msgcntr

chkk_msg:mov    a,50h
         cjne   a,#'#',chk_vt
	 mov    a,51h
         cjne   a,#'1',inv_m
	 mov    a,52h
         cjne   a,#'1',inv_m
         lcall  clear 
         MOV    DPTR,#cndrq
         MOV    R7,#16
         lcall   disp_msg
         lcall  DELAY
	 lcall  send_cand
	 lcall  delay
         lcall   send_init
         lcall   delay
	 lcall  delet_all
	 lcall  delay
         lcall  rd_cntr
         mov    scnt,46h
         ajmp   read_msgcntr

 
chk_vt:  cjne   a,#'*',inv_m
         lcall  clear 
         MOV    DPTR,#psrc
         MOV    R7,#16
         lcall   disp_msg
         lcall  delay
	 mov    a,51h
	 cjne   a,#'1',chk_ps2 
	 mov    a,52h
	 cjne   a,#'5',chk_ps2 
	 jb     us1,alrd_dn
	 lcall  chk_vote
         jnb    vvt,out_v1
	 setb   us1
         ajmp   vote_dn 
chk_ps2:
	 cjne   a,#'2',chk_ps3 
	 mov    a,52h
	 cjne   a,#'6',chk_ps3 
	 jb     us2,alrd_dn
	 lcall  chk_vote
         jnb    vvt,out_v1
	 setb   us2
         ajmp   vote_dn 
chk_ps3:
	 cjne   a,#'3',chk_ps4 
	 mov    a,52h
	 cjne   a,#'7',chk_ps4 
	 jb     us3,alrd_dn
	 lcall  chk_vote
         jnb    vvt,out_v1
	 setb   us3
         ajmp   vote_dn 
chk_ps4:
	 cjne   a,#'4',inv_vt
	 mov    a,52h
	 cjne   a,#'8',inv_vt
	 jb     us4,alrd_dn
	 lcall  chk_vote
         jnb    vvt,out_v1
	 setb   us4
         ajmp   vote_dn 

inv_vt:  lcall  clear 
         MOV    DPTR,#invt
         MOV    R7,#16
         lcall   disp_msg
	 setb    p2.4			;buzzer indication
         lcall  DELAY
         lcall  DELAY
	 clr    p2.4 
	 lcall  send_invt
	 lcall  delay
         lcall   send_init
         lcall   delay
	 lcall  delet_all
	 lcall  delay
         lcall  rd_cntr
         mov    scnt,46h
out_v1:  ajmp   read_msgcntr

alrd_dn: lcall  clear 
         MOV    DPTR,#alrdn
         MOV    R7,#16
         lcall   disp_msg
	 setb    p2.4           ;buzzer indication
         lcall  DELAY
         lcall  DELAY
	 clr    p2.4 
         lcall  DELAY
         lcall  DELAY
	 setb    p2.4
         lcall  DELAY
         lcall  DELAY
	 clr    p2.4 
	 lcall  send_alrdn
	 lcall  delay
         lcall  send_init
         lcall  delay
	 lcall  delet_all
	 lcall  delay
         lcall  rd_cntr
         mov    scnt,46h
         ajmp   read_msgcntr

vote_dn: lcall  clear 
         MOV    DPTR,#vtdn
         MOV    R7,#16
         lcall   disp_msg
         lcall  DELAY
	 lcall  send_vtdn
	 lcall  delay
         lcall  send_init
         lcall  delay
	 lcall  delet_all
	 lcall  delay
         lcall  rd_cntr
         mov    scnt,46h
         ajmp   read_msgcntr

chk_vote:clr    vvt
	 mov    a,53h
         cjne   a,#'1',chk_cd2
         inc    ccnt1
	 setb   vvt
         ret
chk_cd2: cjne   a,#'2',chk_cd3
         inc    ccnt2
	 setb   vvt
         ret
chk_cd3: cjne   a,#'3',chk_cd4
         inc    ccnt3
	 setb   vvt
         ret
chk_cd4: cjne   a,#'4',inv_cnd
         inc    ccnt4
	 setb   vvt
         ret

inv_cnd: lcall  clear 
         MOV    DPTR,#invcd
         MOV    R7,#16
         lcall   disp_msg
	 setb    p2.4
         lcall  DELAY
         lcall  DELAY
	 clr    p2.4 
         lcall  DELAY
	 lcall  send_invcd
	 lcall  delay
         lcall  send_init
         lcall  delay
	 lcall  delet_all
	 lcall  delay
         lcall  rd_cntr
         mov    scnt,46h
	 ret

;--------------------------------------------------

counting:
        lcall   delay
        lcall   delay
	lcall   clear
 	mov     a,#'B'
	lcall   display
 	mov     a,#'J'
	lcall   display
 	mov     a,#'P'
	lcall   display
 	mov     a,#':'
	lcall   display
	mov     a,ccnt1
	mov     b,#10
	div     ab
	lcall   display1
	mov     a,b
	lcall   display1

	mov     a,#88h
	lcall   command 
 	mov     a,#'C'
	lcall   display
 	mov     a,#'N'
	lcall   display
 	mov     a,#'G'
	lcall   display
 	mov     a,#':'
	lcall   display
	mov     a,ccnt2
	mov     b,#10
	div     ab
	lcall   display1
	mov     a,b
	lcall   display1


	mov     a,#0c0h
	lcall   command 
 	mov     a,#'N'
	lcall   display
 	mov     a,#'C'
	lcall   display
 	mov     a,#'P'
	lcall   display
 	mov     a,#':'
	lcall   display
	mov     a,ccnt3
	mov     b,#10
	div     ab
	lcall   display1
	mov     a,b
	lcall   display1

	mov     a,#0c8h
	lcall   command 
 	mov     a,#'M'
	lcall   display
 	mov     a,#'N'
	lcall   display
 	mov     a,#'S'
	lcall   display
 	mov     a,#':'
	lcall   display
	mov     a,ccnt4
	mov     b,#10
	div     ab
	lcall   display1
	mov     a,b
	lcall   display1
	lcall   delay
here1:  sjmp    here1

;------------------------------------------------------------------------------------------------


disp_msg:MOV    A,#0
        MOVC    A,@A+DPTR
        lcall   DISPLAY
        INC     DPTR
        DJNZ    R7,DISP_MSG
        RET

lcdinit:mov     a,#38h
        lcall   command
        mov     a,#0eh
        lcall   command
        mov     a,#06h
        lcall   command
CLEAR:  MOV     A,#01H
        lcall   COMMAND
        RET

COMMAND:lcall   READY
        MOV     P0,A
        CLR     P2.5
        CLR     P2.6
        SETB    P2.7
        CLR     P2.7
        RET

DISPLAY1:ADD   A,#30H
DISPLAY:lcall  READY
        MOV    P0,A
        SETB   P2.5
        CLR    P2.6
        SETB   P2.7
        CLR    P2.7
        RET

READY:  CLR   P2.7
        MOV   P0,#0FFH
        CLR   P2.5
        SETB  P2.6
WAIT:   CLR   P2.7
        SETB  P2.7
        JB    P0.7,WAIT
        CLR   P2.7
        RET

MSG1:  DB    'SMS Voting Syst. '

vmd:   db    'Voting mode      '
cmd:   db    'Counting mode    '

psrc:  db    'Voting received '
invt:  db    'Invalid voter   ' 
alrdn: db    'Already done    ' 
vtdn:  db    'Voting done     ' 
cndrq: db    'Candidate req.  '
invcd: db    'Invalid candt.  '

delay1: mov     dl1,#250
l21:    mov     dl0,#250
l11:    djnz    dl0,l11
        djnz    dl1,l21
        ret

DELAY:  MOV     DL2,#5
l3:     MOV     DL1,#0ffh
l2:     MOV     DL0,#0ffh
l1:     DJNZ    DL0,l1
        DJNZ    DL1,l2
        DJNZ    DL2,l3
        RET

;------------------------------------------------------------------------

chk_gsm: mov      r5,#100
         mov      r4,#100               ;
         CLR      GSM
         mov      dptr,#init
         mov      r6,#2
         lcall    send_data
         mov      a,#0dh
         lcall    trans
         mov      a,#0ah
         lcall    trans
         CLR      RI
gsm_chk: jnb      ri,d_sec
         clr      ri
         mov      a,sbuf
         cjne     a,#0AH,d_sec
         lcall   clear
         mov     dptr,#ygsm
         mov     R7,#16
         lcall   DISP_MSG
         lcall   delay
         lcall   delay
         setb     gsm
         ret

d_sec:   mov     r7,#100
         djnz    r7,$
         djnz    r4,gsm_chk
         mov     r4,#100
         djnz    r5,gsm_chk
         clr     gsm

         lcall   clear
         mov     dptr,#ngsm
         mov     R7,#16
         lcall   DISP_MSG
         lcall   delay
         lcall   delay
         ret

new_msg: lcall   clear
         mov     dptr,#nsms
         mov     R7,#11
         lcall   DISP_MSG
         lcall   delay
         lcall   delay
         ret

send_cand:
	lcall    send_mobno
        mov      dptr,#cand
        mov      r6,#81
        lcall    send_data
        lcall    delay
        mov      a,#1ah          ;ctr. z
        lcall    trans
        mov      a,#0dh
        lcall    trans
        mov      a,#0ah
        lcall    trans
        lcall    delay
        lcall    delay
        ret

send_invt:
	lcall    send_mobno
        mov      dptr,#invt
        mov      r6,#16
        lcall    send_data
        lcall    delay
        mov      a,#1ah          ;ctr. z
        lcall    trans
        mov      a,#0dh
        lcall    trans
        mov      a,#0ah
        lcall    trans
        lcall    delay
        lcall    delay
        ret

send_alrdn:
	lcall    send_mobno
	mov      dptr,#alrdn
        mov      r6,#16
        lcall    send_data
        lcall    delay
        mov      a,#1ah          ;ctr. z
        lcall    trans
        mov      a,#0dh
        lcall    trans
        mov      a,#0ah
        lcall    trans
        lcall    delay
        lcall    delay
        ret

send_vtdn:
	lcall    send_mobno
        mov      dptr,#vtdn
        mov      r6,#16
        lcall    send_data
        lcall    delay
        mov      a,#1ah          ;ctr. z
        lcall    trans
        mov      a,#0dh
        lcall    trans
        mov      a,#0ah
        lcall    trans
        lcall    delay
        lcall    delay
        ret

send_invcd:
	lcall    send_mobno
        mov      dptr,#invcd
        mov      r6,#17
        lcall    send_data
        lcall    delay
        mov      a,#1ah          ;ctr. z
        lcall    trans
        mov      a,#0dh
        lcall    trans
        mov      a,#0ah
        lcall    trans
        lcall    delay
        lcall    delay
        ret

send_mobno:
        mov      dptr,#mmno
        mov      r6,#8
        lcall    send_data
        mov     a,#'"'
        lcall   trans
        mov     r0,#40h
        mov     r1,#10
ssss3:   mov     a,@r0
        lcall   trans
        inc     r0
        djnz    r1,ssss3
        mov     a,#'"'
        lcall   trans
        mov      a,#0dh
        lcall    trans
        mov      a,#0ah
        lcall    trans
sss4:   jnb      ri,$
        clr      ri
        mov      a,sbuf
        cjne     a,#'>',sss4
	ret


delet_all:
        mov      dptr,#sdel
        mov      r6,#11
        lcall    send_data
        mov      a,#0dh
        lcall    trans
        mov      a,#0ah
        lcall    trans
        clr      ri
ddd0:   jnb      ri,$
        clr      ri
        mov      a,sbuf
        cjne     a,#0ah,ddd0

ddd1:   jnb      ri,$
        clr      ri
        mov      a,sbuf
        cjne     a,#0ah,ddd1

ddd2:   jnb      ri,$
        clr      ri
        mov      a,sbuf
        cjne     a,#0ah,ddd2

        lcall    delay
        ret

;-------------------------------------------------------------------------

send_init:mov    dptr,#init
       mov      r6,#2
       lcall    send_data
       mov      a,#0dh
       lcall    trans
       mov      a,#0ah
       lcall    trans
agg:   jnb      ri,$
       clr      ri
       mov      a,sbuf
       cjne     a,#0AH,agg
sel_mode:mov    dptr,#tmd
       mov      r6,#9
       lcall    send_data
       mov      a,#0dh
       lcall    trans
       mov      a,#0ah
       lcall    trans
agg0:  jnb       ri,$
       clr      ri
       mov      a,sbuf
       cjne     a,#0ah,agg0
       lcall    delay
       ret

;--------------------------------------------------------------------------

rd_cntr:mov     dptr,#mmem
       mov      r6,#8
       lcall    send_data
       mov      a,#0dh
       lcall    trans
       mov      a,#0ah
       lcall    trans
agg231:jnb      ri,$
       clr      ri
       mov      a,sbuf
       cjne     a,#':',agg231

       MOV      R0,#40H
       clr      ri
agg11: jnb      ri,$
       clr      ri
       mov      a,sbuf
       MOV      @R0,A
       inc      r0
       cjne     a,#0ah,agg11
       ret

disp_cntr:lcall clear
       mov      dptr,#inb
       mov      r7,#7
       lcall    disp_msg
       mov      a,46h
       lcall    display
       lcall    delay
       ret
;----------------------------------------------------------
read_sms:mov    dptr,#sred
       mov      r6,#8
       lcall    send_data
       mov      a,scnt
       lcall    trans
       mov      a,#0dh
       lcall    trans
       mov      a,#0ah
       lcall    trans

agg23: jnb      ri,$
       clr      ri
       mov      a,sbuf
       cjne     a,#0AH,agg23

;agg24: jnb      ri,$
;       clr      ri
;       mov      a,sbuf
;       cjne     a,#0AH,agg24

agg224:jnb      ri,$
       clr      ri
       mov      a,sbuf
       cjne     a,#'1',agg224

       mov      r0,#40h
agg25: jnb      ri,$
       clr      ri
       mov      a,sbuf
       mov      @r0,a
       inc      r0
       cjne     a,#0AH,agg25

       mov      r0,#50h
agg26: jnb      ri,$
       clr      ri
       mov      a,sbuf
       mov      @r0,a
       inc      r0
       cjne     a,#0AH,agg26
       lcall    delay
       ret

disp_sms:lcall clear
       mov      r0,#50h
       mov      r1,#16
dss2:  mov      a,@r0
       cjne     a,#0ah,diss1
       ajmp     outrd
diss1: lcall    display
       inc      r0
       djnz     r1,dss2
outrd: ret
;-----------------------------------------------------------------------
send_data:clr   a
        movc    a,@a+dptr
        lcall   trans
        inc     dptr
        djnz    r6,send_data
        ret

trans1: add     a,#30h
trans:  mov     sbuf,a
        jnb     ti,$
        clr     ti
        ret

;------------------------------------------------------------

init:   db     'AT'
tmd:    db     'AT+CMGF=1'
mmem:   db     'AT+CPMS?'
mmno:   db     'AT+CMGS='
sred:   db     'AT+CMGR='
sdel:   db     'AT+CMGD=1,4'

ygsm:   db     '  yes gsm      '
ngsm:   db     '  no gsm        '
inb:    db     'In Box:'
nsms:   db     'New message'
mrcd:   db     'message received'
invm:   db     'invalid message '

cand:   db     '1-BJP-Narenra Modi  2-Cong.-Rahul Gandhi  3-NCP-Sharad Pawar  4-MNS-Raj Thakarye.'

;----------------------------------------------------------------------------

             end
