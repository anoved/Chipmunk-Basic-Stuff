# CBGet: HTTP in Chipmunk Basic

`cbget` stands for "Chipmunk Basic Getter," because it's a cbas program that gets web pages. This program was written as an exercise to figure out what sockets were and how to work with them in Chipmunk Basic. It also provided an opportunity to learn more about HTTP.

	Usage: ./cbget.bas [host port path [file]]

Called with no arguments or from within the Macintosh GUI version of Chipmunk Basic, `cbget` prompts the user for input interactively. As indicated above, it is possible to provide the same configuration via command line arguments. As you can see from the following example, the interactive input fields correspond directly to the command line arguments (pressing Return without entering a `file` name is the same as omitting that argument):

	>run
	Host? anoved.net
	Port? 80
	Path? /cbget.html
	File?
	...

If no file is given, the contents of the requested resource are printed to the console. If a file is given, the content is saved to that file instead (note the clever use of file #0).

## Host/Port/Path

If you want to retrieve a web page with a URL such as `http://www.w3.org/Protocols/HTTP/1.1/spec.html`, the host you provide to cbget is `www.w3.org` and the path is the remainder of the URL: `/Protocols/HTTP/1.1/spec.html`. Port `80` is typically the default `port` for HTTP connections.

## Download

[`cbget.bas`](cbget.bas)


You may need to `chmod +x cbget.bas` if you wish to run it directly from the command line.

## Wish List

- accept regular URLs as input
- better newline handling
- print response headers
- follow HTTP redirects
