rootAPIs ; root level API handler functions
	;
	; Last updated 11/8/2023
	;
	QUIT
	;
errorResponse(errors,statusCode)
	;
	new crlf,header,json
	;
	if '$data(statusCode) set statusCode=422
	set json=$$arrayToJSON^%zmgwebUtils(.errors)
	s crlf=$c(13,10)
	s header="HTTP/1.1 "_statusCode
	if statusCode=404 do
	. s header=header_" Not Found"_crlf
	if statusCode=403 do
	. s header=header_" Forbidden"_crlf
	if statusCode=401 do
	. s header=header_" Unauthorized"_crlf
	if statusCode=400 do
	. s header=header_" Bad Request"_crlf
	if statusCode=422 do
	. s header_header_" Unprocessable Content"_crlf
	s header=header_"Content-type: application/json"_crlf_crlf
	QUIT header_json
	;
identity(req) ;
	;
	n username,errors,resp
	;
	s username=$$authenticate^security(.req,.errors)
	if $d(errors) QUIT $$errorResponse(.errors,403)
	;
	set resp("username")=username
	QUIT $$response^%zmgwebUtils(.resp)
	;
token(req) ;
	;
	n token,errors,header,crlf
	;
	set token=$$tryLogin^security(.req,.errors)
	if $d(errors) QUIT $$errorResponse(.errors,401)
	;
	set crlf=$c(13,10)
	set header="HTTP/1.1 200 OK"_crlf_"Content-type: application/json"_crlf_"Authorization: "_token
	QUIT header_"{}"
getGroups(req) ;
	new username,errors,results
	;
	; Validate user access token
	set username=$$authenticate^security(.req,.errors)
	if $data(errors) QUIT $$errorResponse(.errors,403)
	;
	$$getMemberGroups^groups(username,.results)
	QUIT $$response^%zmgwebUtils(.results)