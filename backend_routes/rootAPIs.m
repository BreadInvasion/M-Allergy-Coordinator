rootAPIs ; root level API handler functions
	;
	; Last updated 11/8/2023
	;
	QUIT
	;
identity(req) ;
	;
	new username,errors,resp
	; Validate identity token
	set username=$$authenticate^security(.req,.errors)
	if $d(errors) QUIT $$errorResponse^common(.errors,403)
	;
	set resp("username")=username
	QUIT $$response^%zmgwebUtils(.resp)
	;
token(req) ;
	;
	n token,errors,header,crlf
	;
	set token=$$tryLogin^security(.req,.errors)
	if $d(errors) QUIT $$errorResponse^common(.errors,401)
	;
	set crlf=$c(13,10)
	set header="HTTP/1.1 200 OK"_crlf_"Content-type: application/json"_crlf_"Authorization: "_token
	QUIT header_"{}"
getGroups(req) ;
	new username,errors,results
	;
	; Validate user access token
	set username=$$authenticate^security(.req,.errors)
	if $data(errors) QUIT $$errorResponse^common(.errors,403)
	;
	if $$getMemberGroups^groups(username,.results)
	QUIT $$response^%zmgwebUtils(.results)