5 cls7 let x = 2958 let y = 38510 graphics 015 graphics window 20,20,600,40020 if x > 590 then let x = 1521 if x < 10 then let x = 58522 sprite 1 x,y,14323 gosub 600 : rem works on presently onscreen targets24 gosub 20025 get m$27 if fat = 1 then let fat = 030 if m$ = "4" then let x = x-5 : goto 2035 if m$ = "6" then let x = x+5 : goto 2040 if m$ = "5" then gosub 100 : goto 2045 if m$ = "e" then cls : graphics -1 : end50 goto 20100 rem shoot routine110 let c = rnd(100)115 graphics color c120 moveto x,y122 let x2 = x123 let y2 = y-400125 lineto x2,y2130 let fat = 1145 gosub 160148 graphics color 0 : moveto x,y149 lineto x2,y2150 return160 for r = 1 to 2165 sound 3000,0.1,90170 sound 4000,0.05,90175 next r180 return200 rem target routine205 let ft = rnd(10)207 if st1 = 1 then goto 220210 let st = rnd(10)220 let bp = rnd(10)399 rem sitting target plotter400 if st <= 7 then goto 450402 if st1 = 1 then goto 450405 let x1 = rnd(600)407 let y1 = rnd(300)409 graphics color rnd(100)410 sprite 3 x1,y1,140415 let st1 = 1450 rem bonus point plotter3500 return600 rem update onscreen targets605 if st1 <> 1 then goto 700610 let bst = rnd(10)615 if bst < 8 then goto 650620 moveto x1,y1630 let c = graphics color rnd(100)633 lineto x1,y+400640 for r = 1 to 2642 sound 2000,0.1,80644 sound 1000,0.05,80646 next r647 graphics color 0648 lineto x1,y1650 rem u shoot target routine700 return2062812958 graphics -1