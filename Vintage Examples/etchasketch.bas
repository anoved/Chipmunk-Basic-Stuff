2 graphics button "",-1
5 cls
7 let r = 5
10 graphics window 30,30,600,400
12 gosub 100
14 let x = mouse(1)
15 let y = mouse(2)
20 sprite 1 x,y
25 let m$ = inkey$
26 if m$ = "c" then cls : goto 12
27 if m$ = "-" then sprite 1 penup : goto 25
28 if m$ = "=" then sprite 1 pendown : goto 25
30 if m$ = "r" then let r = r-1 : if r <= 0 then let r = 1 : goto 25
31 if m$ = "t" then let r = r+1 : goto 25
34 if asc(m$) = 30 then sprite 1 up r : goto 25
35 if asc(m$) = 31 then sprite 1 down r : goto 25
40 if asc(m$) = 28 then sprite 1 left r : goto 25
45 if asc(m$) = 29 then sprite 1 right r : goto 25
47 if m$ = "e" then graphics -1 : end
50 goto 25
100 rem Buttons: title, x, y, w, h, ascii-equivalent
105 graphics button "Erase",520,20,70,20,99
110 graphics button "Up",520,60,70,20,45
115 graphics button "Down",520,100,70,20,61
120 graphics button "Res +",520,140,70,20,114
125 graphics button "Res -",520,180,70,20,116
130 graphics button "End",520,220,70,20,101
200 return
