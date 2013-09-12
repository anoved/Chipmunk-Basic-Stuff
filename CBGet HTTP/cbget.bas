#!/usr/local/bin/basic
' cbget 1.0.1 by Jim DeVona
'  1.0.1 adds Connection: close request header to prevent keep-alive hang
' Demonstrates how to use Chipmunk Basic sockets for HTTP retrieval
' HTTP Basics: http://en.wikipedia.org/wiki/HTTP (sufficient for this)
' HTTP Spec: http://www.w3.org/Protocols/HTTP/1.1/spec.html (build a browser!)
' Biggest problem is handling variable CR+LF/LF newlines;
'  if a server does not use CR+LF for HTTP response headers,
'  cbget.bas may not recognize the end of header/start of content.

' Determine argument count (and CLI/GUI environment, implicitly)
if argv$ = "" then argc = 0 : else argc = len(field$(argv$,-1))	

' Establish what to do with errors (particularly failed socket opens)
on error goto err

if argc = 5 or argc = 6 then
	' Command line configuration
	host$ = field$(argv$,3)
	port  = val(field$(argv$,4))
	path$ = field$(argv$,5)
	' Optional output file path
	if argc = 6 then file$ = field$(argv$,6) : else file$ = ""
elseif argc = 0 or argc = 2 then
	' Interactive configuration (GUI or no arguments)
	input "Host? "; host$
	input "Port? "; port
	input "Path? "; path$
	input "File? "; file$
else
	' Command line has too few/many arguments; show usage and exit with error
	print "Usage: ";field$(argv$,2);" [host port path [file]]"
	exit 1
endif

' Assemble HTTP GET request (with CR+LF DOS newlines)
'  First line states request type, path of requested resource, and HTTP version
'  Host header field is required by HTTP 1.1 (to differentiate subdomains)
'  Connection header close prevents keep-alive connection hangs
'  Blank line indicates end of request
newline$ = chr$(13) + chr$(10)
request$ = "GET " + path$ + " HTTP/1.1" + newline$
request$ = request$ + "Host: " + host$ + newline$
request$ = request$ + "Connection: close" + newline$
request$ = request$ + newline$

' Open sockets like files
'  Our request is send to the server via #2
'  The server's response is received via #1
socket$ = "socket:" + host$
open socket$,port for input as #1
open socket$,port for output as #2

' Prepare output file
if file$ <> "" then
	open file$ for output as #3
	filenum = 3
else
	' File #0 is "standard output"
	filenum = 0
endif

' Submit HTTP GET request exactly as we built it (no extra newline, etc)
print #2, request$;

' Receive header (assumes HTTP response headers use CR+LF DOS newlines)
'  The header fields could be parsed to do useful things;
'  We're just looking for the blank line that indicates the start of content
while
	input #1, response$
	input #1, newline$
wend response$ = "" or eof(1)

' Receive content
'  If every other line is blank, content probably uses CR+LF DOS newlines
'  Probably not uncommon, but it seems difficult to filter cleanly
' format like header. difficult to resolve with cbas.
' allegedly there is a 254 char limit on strings like response$,
' but I've tested at least 300 and found it to print out OK
while
	input #1, response$ : if eof(1) then exit while
	print #filenum, response$
wend

' Close files
if file$ <> "" then close #3
close #2
close #1

ok:
if argc <> 0 then exit 0 else end

err:
print "Error: ";errorstatus$;" [";str$(ERL);"]"
if left$(errorstatus$,14) = "File not found" then
	print "       Host or port is probably invalid"
endif
if argc <> 0 then exit 1 else end