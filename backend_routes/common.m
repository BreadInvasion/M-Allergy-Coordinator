common ; shared helper functions
	;
	; Last updated November 9, 2023
	;
	QUIT
	;
addError(type,text,errors) ;
	n id
	s id=$increment(errors("errors",type))
	s errors("errors",type,id)=text
	QUIT 1
	;
bodyAndFields(req,category,requiredFields,optionalFields,errors) ;
	;
	new field,noFields
	;
	kill errors
	;
	if '$data(req("body"))!('$data(req("body",category))) do  QUIT $data(errors)
	. if $$addError("body","can't be empty",.errors)
	if $data(requiredFields) do
	. set field=""
	. for  set field=$o(requiredFields(field)) quit:field=""  do
	. . if '$data(req("body",category,field)) do  quit
	. . . if $$addError(field,"must be defined",.errors)
	. . if req("body",category,field)="" do  quit
	. . . if $$addError(field,"can't be empty",.errors)
	if $data(optionalFields),optionalFields'="" do
	. set field=""
	. set noFields=1
	. for  set field=$o(optionalFields(field)) quit:field=""  do
	. . if $d(req("body",category,field)) do  quit
	. . . set noFields=0
	. . . if req("body",category,field)="" do  quit
	. . . . if $$addError(field,"can't be blank",.errors)
	. if noFields do
	. . if $$addError(field,"doesn't contain any of the expected fields",.errors)
	QUIT $data(errors)
	;
errorResponse(errors,statusCode)
	;
	new crlf,header,json
	;
	if '$data(statusCode) set statusCode=422
	set json=$$arrayToJSON^%zmgwebUtils("errors")
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
	. s header=header_" Unprocessable Content"_crlf
	s header=header_"Content-type: application/json"_crlf_crlf
	QUIT header_json
	;