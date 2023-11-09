userAPIs ; users specific endpoints
	;
	; Last updated 11/9/2023
	;
	;
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
createUser(req) ;
	;
	new errors
	;
	if ('$data(req("body","username")))!('$data(req("body","password"))) do
	. set errors("errors","params",1)="Username and password required"
	. QUIT $$errorResponse(.errors,400)
	$$create^users(req("body","username"),req("body","password"),.errors)
	if $data(errors) QUIT $$errorResponse(.errors,404)
	QUIT $$header^%zmgweb()_"{}"
deleteUser(req) ;
	;
	new errors
	; Validate user access token
	set username=$$authenticate^security(.req,.errors)
	if $data(errors) QUIT $$errorResponse(.errors,403)
	;
	$$delete^users(username,.errors)
	if $data(errors) QUIT $$errorResponse(.errors,404)
	QUIT $$header^%zmgweb()_"{}"
updateAllergies(req) ;
	;
	new errors
	; Validate user access token
	set username=$$authenticate^security(.req,.errors)
	if $data(errors) QUIT $$errorResponse(.errors,403)
	;
	if '$data(req("body","allergies")) do
	. set errors("errors","params",1)="Need list of allergy designations"
	. QUIT $$errorResponse(.errors,400)
	$$updateAllergyList^users(.req,username,.errors)
	if $data(errors) QUIT $$errorResponse(.errors,400)
	QUIT $$header^%zmgweb()_"{}"