' setup
ReadConfig()
InitRandom()
InitWindow()

' main variables
correct = 1
stage = 0
sequence$ = ""
attempt$ = ""

' game loop
get ready$
while correct
		
	' add a random panel to the sequence
	sequence$ = sequence$ + str$(rnd(gNumPanels) + 1) + " "
	
	' display the sequence
	macfunction("wintitle", "Stage " + str$(stage + 1) + " - Computer")
	macfunction("wait", gTimeStage)
	DisplaySequence(sequence$)
	
	' if player mimics sequence correctly, proceed to next stage
	macfunction("wintitle", "Stage " + str$(stage + 1) + " - You")
	correct = PlayerSequence(sequence$)
	if correct then stage = stage + 1
	
wend

' game over announcement and sound
macfunction("wintitle","Game Over! Passed Stage " + str$(stage))
sound -2, 1, 33, 100, 2, 2

' riff through the stumper sequence
gTimeOn = 0.1
gTimeOff = 0.03
macfunction("wait", gTimeStage)
DisplaySequence(sequence$)
DisplaySequence(sequence$)

end

'
' ReadConfig
' Loads layout data into configuration variables and arrays
'
sub ReadConfig()
		
	' read general configuration
	read gWidth, gHeight
	read gRed, gGreen, gBlue
	read gTimeOn, gTimeOff, gTimeStage, gTimePress
	read gVoice
	read gMarkSize
	read gRedGuess, gGreenGuess, gBlueGuess
	read gRedActual, gGreenActual, gBlueActual
	read gNumPanels
	
	' allocate panel arrays
	dim gulx(gNumPanels), guly(gNumPanels), gbrx(gNumPanels), gbry(gNumPanels)
	dim groff(gNumPanels), ggoff(gNumPanels), gboff(gNumPanels)
	dim gron(gNumPanels), ggon(gNumPanels), gbon(gNumPanels)
	dim gpitch(gNumPanels)
	dim gkey$(gNumPanels)
	
	' read each panel configuration
	for panel = 1 to gNumPanels
		read gulx(panel), guly(panel), gbrx(panel), gbry(panel)
		read groff(panel), ggoff(panel), gboff(panel)
		read gron(panel), ggon(panel), gbon(panel)
		read gpitch(panel)
		read gkey$(panel)
	next panel
	
end sub

'
' InitRandom
' Initialize random number generator using time
'
sub InitRandom()
	rseed =  100000 * (timer - int(timer))
	randomize rseed
	print rseed
end sub

'
' InitWindow
' Create window, configure font, and draw background and panels
'
sub InitWindow()
	graphics window gWidth, gHeight
	macfunction("wintitle", "Press any key to begin")
	graphics textsetup macfunction("GetFNum", "monaco"), 48, 1
	graphics color gRed, gGreen, gBlue
	graphics fillrect 0, 0, gWidth-1, gHeight-1, 1
	for panel = 1 to gNumPanels
		DrawInert(panel)
	next panel
end sub

'
' DrawInert
' Draw the specified panel using its inert color scheme:
' background uses inert color; border and label use active color
'
sub DrawInert(panel)
	graphics color groff(panel), ggoff(panel), gboff(panel)
	graphics fillrect gulx(panel), guly(panel), gbrx(panel), gbry(panel), 1
	graphics color gron(panel), ggon(panel), gbon(panel)
	graphics rect gulx(panel), guly(panel), gbrx(panel), gbry(panel)
	graphics moveto ((gbrx(panel) + gulx(panel)) / 2) - 18, ((gbry(panel) + guly(panel)) / 2) + 20
	graphics drawtext gkey$(panel)	
end sub

'
' DrawActive
' Draw the specified panel using its active color scheme:
' background uses active color; border and label use inert color
'
sub DrawActive(panel)
	graphics color gron(panel), ggon(panel), gbon(panel)
	graphics fillrect gulx(panel), guly(panel), gbrx(panel), gbry(panel), 1
	graphics color groff(panel), ggoff(panel), gboff(panel)
	graphics rect gulx(panel), guly(panel), gbrx(panel), gbry(panel)
	graphics moveto ((gbrx(panel) + gulx(panel)) / 2) - 18, ((gbry(panel) + guly(panel)) / 2) + 20
	graphics drawtext gkey$(panel)
end sub

'
' DisplaySequence
' Flash each panel listed in the specified sequence
'
sub DisplaySequence(sequence$)
	for field = 1 to len(field$(sequence$, -1))
		panel = val(field$(sequence$, field))
		sound -2, gVoice, gpitch(panel), 100, gTimeOn
		DrawActive(panel)
		macfunction("wait", gTimeOn)
		DrawInert(panel)
		macfunction("wait", gTimeOff)
	next field
end sub

'
' PlayerSequence
' Return 1 if player correctly mimics specified sequence, 0 otherwise
'
sub PlayerSequence(sequence$)
	result = 1
	for field = 1 to len(field$(sequence$, -1))
		panel = val(field$(sequence$, field))
		
		' wait for a panel key to be input
		while
			get guesskey$
			guess = KeyPanel(guesskey$)
		wend guess <> -1
		
		' flash the panel
		sound -2, gVoice, gpitch(guess), 100, gTimeOn
		DrawActive(guess)
		macfunction("wait", gTimePress)
		DrawInert(guess)

		' stop if the guess was wrong
		if guess <> panel then
			' highlight right and wrong panels
			graphics pensetup gMarkSize, gMarkSize
			graphics color gRedGuess, gGreenGuess, gBlueGuess
			graphics rect gulx(guess) - gMarkSize, guly(guess) - gMarkSize, gbrx(guess) + gMarkSize, gbry(guess) + gMarkSize
			graphics color gRedActual, gGreenActual, gBlueActual
			graphics rect gulx(panel) - gMarkSize, guly(panel) - gMarkSize, gbrx(panel) + gMarkSize, gbry(panel) + gMarkSize
			graphics pensetup 1, 1
			result = 0
		endif
		if guess <> panel then exit for
		
	next field
	PlayerSequence = result
end sub

'
' KeyPanel
' Return panel ID of specified key (-1 if none associated)
'
sub KeyPanel(key$)
	retpanel = -1
	for kpanel = 1 to gNumPanels
		if gkey$(kpanel) = key$ then
			retpanel = kpanel
			exit for
		endif
	next kpanel
	KeyPanel = retpanel
end sub

' traditional simon layout
data 640,480,0,20,0,0.12,0.05,0.5,0.1,1,3,100,0,0,0,100,0,4,10,10,315,235,0,50
data 0,0,100,0,69,"u",325,10,630,235,50,0,0,100,0,0,57,"i",325,245,630,470,0,0
data 50,0,0,100,62,"k",10,245,315,470,50,50,0,100,100,0,67,"j"

' numeric keypad layout
'data 340,340,11,5,5,0.15,0.05,0.5,0.1,2,3,100,0,0,0,100,0,9,10,10,110,110,33
'data 33,33,100,100,0,68,"7",120,10,220,110,33,33,33,100,100,0,75,"8",230,10
'data 330,110,33,33,33,100,100,0,79,"9",10,120,110,220,33,33,33,100,100,0,63
'data "4",120,120,220,220,33,33,33,100,100,0,71,"5",230,120,330,220,33,33,33
'data 100,100,0,77,"6",10,230,110,330,33,33,33,100,100,0,55,"1",120,230,220,330
'data 33,33,33,100,100,0,66,"2",230,230,330,330,33,33,33,100,100,0,74,"3"

' keyboard home row layout
'data 750,120,80,80,90,0.18,0.08,0.5,0.1,1,3,100,0,0,0,100,0,8,10,30,90,110,100
'data 100,100,0,0,0,55,"a",100,20,180,100,100,100,100,0,0,0,65,"s",190,15,270
'data 95,100,100,100,0,0,0,76,"d",280,10,360,90,100,100,100,0,0,0,86,"f",390,10
'data 470,90,100,100,100,0,0,0,81,"j",480,15,560,95,100,100,100,0,0,0,70,"k"
'data 570,20,650,100,100,100,100,0,0,0,60,"l",660,30,740,110,100,100,100,0,0,0
'data 50,";"