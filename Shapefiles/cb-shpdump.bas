#!/usr/local/bin/basic

'
' Load arguments into an array for easier access
' Bit of a hack - fre doesn't do anything in the
' command line version, but ought to return a value
' in the windowed version, in which case we need
' to ask for some 'command line' arguments manually.
'
if fre = 0 then
	let argline$ = argv$
	let argline$ = mid$(argline$, instr(argline$," ")+1)
	let argline$ = mid$(argline$, instr(argline$," ")+1)
else
	input "Enter arguments: "; argline$
	' hack to match argv$'s extra final space
	let argline$ = argline$ + " "
endif
let argc = len(field$(argline$, -1))-1
if argc < 1 then
	print "Usage: [cb-shpdump.bas] hsgHSG shapefile"
	goto Finis
endif
dim args$(argc)
args$(0) = ""
for argi = 1 to argc
	let args$(argi) = field$(argline$, argi+1)
next argi

'
' Set default options and adjust according to mode argument
'
let showFileHeader = 0
let showShapeHeader = 0
let showGeometry = 0
let mode$ = lcase$(field$(argline$, 1))
if instr(mode$,"h") then let showFileHeader = 1
if instr(mode$,"s") then let showShapeHeader = 1
if instr(mode$,"g") then let showGeometry = 1

'
' Process each specified shapefile
'
for argi = 1 to argc
	
	'
	' Determine filenames from input arguments
	'
	if right$(args$(argi), 4) = ".shp" then
		let shpName$ = args$(argi)
		let shxName$ = left$(shpName$,len(shpName$)-4) + ".shx"
	else
		if right$(args$(argi), 4) = ".shx" then
			let shxName$ = args$(argi)
			let shpName$ = left$(shxName$,len(shxName$)-4) + ".shp"
		else
			let shpName$ = args$(argi) + ".shp"
			let shxName$ = args$(argi) + ".shx"
		endif
	endif
		
	'
	' Open files
	'
	open shpName$ for data input as #1 else goto Closing
	open shxName$ for data input as #2 else goto Closing
	
	'
	' Read SHP file header
	'
	let shpCode = ReadInteger(1,1)
	              ReadInteger(1,1)
	              ReadInteger(1,1)
	              ReadInteger(1,1)
	              ReadInteger(1,1)
	              ReadInteger(1,1)
	let shpSize = ReadInteger(1,1)
	let shpVers = ReadInteger(1,0)
	let shpType = ReadInteger(1,0)
	let shpMinX = ReadDouble(1)
	let shpMinY = ReadDouble(1)
	let shpMaxX = ReadDouble(1)
	let shpMaxY = ReadDouble(1)
	
	'
	' Read SHX file header
	'
	let shxCode = ReadInteger(2,1)
	              ReadInteger(2,1)
	              ReadInteger(2,1)
	              ReadInteger(2,1)
	              ReadInteger(2,1)
	              ReadInteger(2,1)
	let shxSize = ReadInteger(2,1)
	let shxVers = ReadInteger(2,0)
	let shxType = ReadInteger(2,0)
	let shxMinX = ReadDouble(2)
	let shxMinY = ReadDouble(2)
	let shxMaxX = ReadDouble(2)
	let shxMaxY = ReadDouble(2)
	
	'
	' Validate file headers
	' Should also check matching extents and possibly sensible sizes
	'
	if eof(1) or eof(2) then
		print "Error: End of file encountered while reading headers:"
		print "       ";shpName$;" or ";shxName$
		goto Closing
	endif
	if (shpCode <> 9994) or (shxCode <> 9994) then
		print "Error: Invalid file codes (should be 9994):"
		print "       ";shpName$;": ";str$(shpCode);", ";shxName$;": ";str$(shxCode)
		goto Closing
	endif
	if (shpVers <> 1000) or (shxVers <> 1000) then
		print "Warning: Unsupported version (expected 1000):"
		print "         ";shpName$;": ";str$(shpVers);", ";shxName$;": ";str$(shxVers)
	endif
	if shpType <> shxType then
		print "Error: Mismatched shape types:"
		print "       ";shpName$;": ";str$(shpType);", ";shxName$;": ";str$(shxType)
		goto Closing
	endif
	if (shpType <> 1) and (shpType <> 3) and (shpType <> 5) and (shpType <> 8) then
		print "Error: Unsupported shape type (1, 3, 5, and 8 are valid):"
		print "       ";shpName$;": ";str$(shpType)
		goto Closing
	endif
	
	'
	' Interpret header info
	' Since SHX index records are constant size (4 words or 8 bytes)
	' the number of records (shapes) can be easily determined. The
	' index file header is 100 bytes long (50 16-bit words).
	'
	let shpCount = (shxSize - 50) / 4
	
	'
	' Display file header
	'
	if showFileHeader then
		print
		print "Shapefile:", shpName$
		print "Shape_type:", shpType
		print "Shape_count:", shpCount
		print "Minimum_X:", shpMinX
		print "Minimum_Y:", shpMinY
		print "Maximum_X:", shpMaxX
		print "Maximum_Y:", shpMaxY
		print
	endif
	
	'
	' Display shape headers and/or geometry
	'
	if showShapeHeader or showGeometry then
	
		for shpi = 0 to shpCount-1
			
			'
			' Seek to index record to locate shape record
			'
			fseek #2, ((8 * shpi) + 100)
			let shpOffset = ReadInteger(2,1)
			let shpLength = ReadInteger(2,1)
			
			'
			' Seek and read generic shape record header
			'
			fseek #1, (2 * shpOffset)
			let recNumber = ReadInteger(1,1)
			let recLength = ReadInteger(1,1)
			
			'
			' Read actual shape record header
			'
			let recType = ReadInteger(1,0)
			' no null or single points after here:
			if (recType <> 0) and (recType <> 1) then
				let recMinX = ReadDouble(1)
				let recMinY = ReadDouble(1)
				let recMaxX = ReadDouble(1)
				let recMaxY = ReadDouble(1)
				' no multipoint here:
				if (recType = 3) or (recType = 5) then
					let recParts = ReadInteger(1,0)
				endif
				let recPoints = ReadInteger(1,0)
			else
				' for single points
				let recPoints = 1
			endif
			
			'
			' Display shape record header
			'
			if showShapeHeader then
				print recNumber
				print " Rec_Type:", recType
				' no null or single points after here:
				if (recType <> 0) and (recType <> 1) then
					' no multipoint here:
					if (recType = 3) or (recType = 5) then
						print " Num_Parts:",  recParts
					endif
					print " Num_Points:", recPoints
					print " Minimum_X:",  recMinX
					print " Minimum_Y:",  recMinY
					print " Maximum_X:",  recMaxX
					print " Maximum_Y:",  recMaxY
				endif
			endif
			
			'
			' Display record coordinates (if not null record)
			'
			if showGeometry and recType then
				
				'
				' Read and ingore part indices
				' (polyline and polygon only)
				'
				if (recType = 3) or (recType = 5) then
					for parti = 1 to recParts
						ReadInteger(1,0)
					next parti
				endif
				
				'
				' Read and display coordinate pairs
				' Handles single point pair too
				'
				for pointi = 1 to recPoints
					let pointX = ReadDouble(1)
					let pointY = ReadDouble(1)
					print "  ";str$(pointi);".", pointX, pointY
				next pointi
				
			endif
			
			print
			
		next shpi
	
	endif
	
	'
	' Close files (if open)
	'
	Closing:
	close #1
	close #2

next argi

'
' Quit thouroughly 
'
Finis:
if fre then
	end
else
	bye
endif



' 
' ReadInteger
'
' Return the value of a four-byte integer read from file #filenum
'
' Parameters:
'  filenum, the input file channel number
'  big, boolean indicating whether to interpret as a "big-endian" value
'
sub ReadInteger (filenum, big)
	
	let byte1 = fgetbyte(filenum) ' big endian high / little endian low
	let byte2 = fgetbyte(filenum)
	let byte3 = fgetbyte(filenum)
	let byte4 = fgetbyte(filenum) ' big endian low / little endian high
	
	if big then
		ReadInteger = (16777216 * byte1) + (65536 * byte2) + (256 * byte3) + (byte4)
	else
		ReadInteger = (16777216 * byte4) + (65536 * byte3) + (256 * byte2) + (byte1)
	endif
		
end sub

'
' ReadDouble
'
' Return the value of an eight-byte floating point "double-precision" number
' read from file #filenum. All shapefile doubles appear to be little endian.
' The tricky thing is that cbas uses 8-byte doubles (or more?) for everything.
'
' Notes:
'  This routine does not check for or recognize "infinity" or "NaN" status
'
' Sources:
'  http://www.cs.princeton.edu/introcs/91float/
'  http://babbage.cs.qc.edu/courses/cs341/IEEE-754.html
'  http://en.wikipedia.org/wiki/Binary_numeral_system
'  http://en.wikipedia.org/wiki/IEEE_floating-point_standard
'
' Parameters:
'  filenum, the input file channel number
'
sub ReadDouble (filenum)
	
	'
	' Useful values
	'
	let highBit      =  128 ' 128 = b10000000
	let nonHighBits  =  127 ' 127 = b01111111
	let highNibble   =  240 ' 240 = b11110000
	let lowNibble    =   15 '  15 = b00001111
	let exponentBias = 1023 ' subtract from stored exponent to determine actual exponent
	let twoToThe52   = 4503599627370496
	
	'
	' Read bytes from file
	'
	let byte1 = fgetbyte(filenum) ' little endian low
	let byte2 = fgetbyte(filenum)
	let byte3 = fgetbyte(filenum)
	let byte4 = fgetbyte(filenum)
	let byte5 = fgetbyte(filenum)
	let byte6 = fgetbyte(filenum)
	let byte7 = fgetbyte(filenum)
	let byte8 = fgetbyte(filenum) ' little endian high
	
	'
	' Determine sign
	'  Encoded in the highest bit of the highest byte
	'
	if (byte8 and highBit) = highBit then
		let sign = -1
	else
		let sign = 1
	endif
	
	'
	' Determine exponent
	'  Stored from the second highest bit of the highest byte
	'  to the fourth bit of the second highest byte (11 bits)
	'
	' ignore the high bit used for the sign
	let exponent = (byte8 and nonHighBits)
	' shift those 7 bits left four places to make room for the
	' bits stored in the upper half of byte 7 (times 2 to shift
	' 1 place; times 4 to shift 2 places, times 8 to shift 3, etc.)
	let exponent = exponent * 16
	' add the value of the upper half of byte 7 to the exponent
	' divide by 16 to shift it right to occupy the places freed above
	let exponent = exponent + ((byte7 and highNibble) / 16)
	' subtract the exponent bias from the calculated value
	' this allows a value from negative exponentBias to positive
	' exponentBias to be stored in an unsigned fashion from 0
	' to twice exponentBias.
	let exponent = exponent - exponentBias 
	
	'
	' Determine mantissa (fractional component of scientific notation expression)
	' These terms could easily be put in one line, but I like the aesthetics here
	'
	let mantissa = 0
	let mantissa = mantissa + (281474976710656 * (byte7 and lowNibble))
	let mantissa = mantissa + (1099511627776 * byte6) 
	let mantissa = mantissa + (4294967296 * byte5)
	let mantissa = mantissa + (16777216 * byte4)
	let mantissa = mantissa + (65536 * byte3)
	let mantissa = mantissa + (256 * byte2)
	let mantissa = mantissa + (byte1)
	' if the value at this point is zero,
	' leave it as-is so the result will be zero too
	if mantissa <> 0 then
		' bring the integer representation into a 1.fraction form
		let mantissa = mantissa / twoToThe52
		let mantissa = mantissa + 1
	endif
	
	'
	' Return value
	'
	ReadDouble = sign * mantissa * (2 ^ exponent)
	
end sub
