1 cls5 graphics 07 graphics window 20,20,600,40010 let x = 300 : let y = 30011 graphics color 25620 let a = mouse(1) : let b = mouse(2)23 gosub 10025 let gfh = int(a+((x-a)/3)) : let gfv = int(b+((y-b)/3))30 let gbh = int(a+((x-a)/2)) : let gbv = int(b+((y-b)/2))32 graphics color 25135 graphics fillrect gfh-10,gfv-10,gfh+10,gfv+1036 graphics fillrect gfh-2,gfv-17,gfh+2,gfv-1039 graphics color 25340 graphics fillrect gbh-20,gbv-20,gbh+20,gbv+2042 moveto gbh-20,gbv-20 : lineto gfh-10,gfv-1044 moveto gbh+20,gbv-20 : lineto gfh+10,gfv-1046 moveto gbh-20,gbv+20 : lineto gfh-10,gfv+1048 moveto gbh+20,gbv+20 : lineto gfh+10,gfv+1050 graphics color 30,30,252 graphics fillrect gbh-8,gbv+20,gbh+8,gbv+5060 let q$ = inkey$ : if q$ = "e" then graphics -1 : cls : end65 gosub 20070 goto 20100 rem erase102 graphics color 0105 graphics fillrect gfh-10,gfv-10,gfh+10,gfv+10,-1107 graphics fillrect gfh-2,gfv-17,gfh+2,gfv-10110 graphics fillrect gbh-20,gbv-20,gbh+20,gbv+20,-1115 graphics fillrect gbh-8,gbv+20,gbh+8,gbv+50,-1120 moveto gbh-20,gbv-20 : lineto gfh-10,gfv-10122 moveto gbh+20,gbv-20 : lineto gfh+10,gfv-10124 moveto gbh-20,gbv+20 : lineto gfh-10,gfv+10126 moveto gbh+20,gbv+20 : lineto gfh+10,gfv+10150 return200 rem check206 if mouse(0) then graphics color 80,0,0 : graphics filloval a-5,b-5,a+5,b+5210 return