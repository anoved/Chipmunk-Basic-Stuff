10 cls15 graphics window 100,100,100,10017 cr = 1 : cg = 1 : cb = 120 rem spacer25 x = mouse(3) : y = mouse(4)30 graphics pset x,y35 if inkey$ = "c" then gosub 10040 if inkey$ = "q" then  : graphics -1 : cls : end45 goto 25100 rem change color routine105 cr = val(inputbox("Percent red?","Color",str$(cr),0))110 cg = val(inputbox("Percent green?","Color",str$(cg),0))115 cb = val(inputbox("Percent blue?","Color",str$(cb),0))120 graphics color cr,cg,cb125 return