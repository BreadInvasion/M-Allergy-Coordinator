groupAPIs ;
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
createGroup(req) ;
	new username,errors,id
	; Validate user access token
	set username=$$authenticate^security(.req,.errors)
	if $data(errors) QUIT $$errorResponse(.errors,403)
	; Validate request body
	if ('$data(req("body","name")))!('$data(req("body","description"))) do
	. set errors("errors","params","1")="Request body must contain group name and description"
	. QUIT $$errorResponse(.errors,400)
	set id=$$create^groups(req("body","name"),req("body","description"),username)
	QUIT $$header^%zmgweb()_"{""groupID"": """_id_"""}"
	;
deleteGroup(req) ;
	new username,errors,groupID
	; Validate user access token
	set username=$$authenticate^security(.req,.errors)
	if $data(errors) QUIT $$errorResponse(.errors,403)
	; Retrieve groupID from body
	if '$data(req("body","groupID")) do
	. set errors("errors","params",1)="Body must include target group ID"
	. QUIT $$errorResponse(.errors,400)
	set groupID=req("body","groupID")
	; Make sure group exists
	if '$data(^groups(groupID)) do
	. set errors("errors","params",1)="Group does not exist"
	. QUIT $$errorResponse(.errors,404)
	; Make sure group is owned by user
	if username'=^groups(groupID,"owner") do
	. set errors("errors","auth",1)="User does not own target group"
	. QUIT $$errorResponse(.errors,403)
	$$delete^groups(groupID)
	QUIT $$header^%zmgweb()_"{}"
	;
editGroup(req) ;
	;
	new username,errors,groupID
	; Validate user access token
	set username=$$authenticate^security(.req,.errors)
	if $data(errors) QUIT $$errorResponse(.errors,403)
	; Retrieve groupID from body
	if '$data(req("body","groupID")) do
	. set errors("errors","params",1)="Body must include target group ID"
	. QUIT $$errorResponse(.errors,400)
	set groupID=req("body","groupID")
	; Make sure group exists
	if '$data(^groups(groupID)) do
	. set errors("errors","params",1)="Group does not exist"
	. QUIT $$errorResponse(.errors,404)
	; Make sure group is owned by user
	if username'=^groups(groupID,"owner") do
	. set errors("errors","auth",1)="User does not own target group"
	. QUIT $$errorResponse(.errors,403)
	; Ensure body changes at least one of (name,description)
	if ('$data(req("body","description")))&('$data(req("body","name"))) do
	. set errors("errors","params",1)="Body must include new name and/or description"
	. QUIT $$errorResponse(.errors,400)
	if $data(req("body","name")) do
	. $$changeName^groups(groupID,req("body","name"),.errors)
	. if $data(errors) QUIT $$errorResponse(.errors,404)
	if $data(req("body","name")) do
	. $$changeDescription^groups(groupID,req("body","description"),.errors)
	. if $data(errors) QUIT $$errorResponse(.errors,404)
	QUIT $$header^%zmgweb()_"{}"
addUser(req) ;
	;
	new username,errors,groupID
	; Validate user access token
	set username=$$authenticate^security(.req,.errors)
	if $data(errors) QUIT $$errorResponse(.errors,403)
	; Retrieve groupID from body
	if '$data(req("body","groupID")) do
	. set errors("errors","params",1)="Body must include target group ID"
	. QUIT $$errorResponse(.errors,400)
	set groupID=req("body","groupID")
	; Make sure group exists
	if '$data(^groups(groupID)) do
	. set errors("errors","params",1)="Group does not exist"
	. QUIT $$errorResponse(.errors,404)
	; Make sure group is owned by user
	if username'=^groups(groupID,"owner") do
	. set errors("errors","auth",1)="User does not own target group"
	. QUIT $$errorResponse(.errors,403)
	; Get new user's username
	if '$data(req("body","newUsername")) do
	. set errors("errors","params",1)="Body must include new user to add"
	. QUIT $$errorResponse(.errors,400)
	; Make sure they exist
	if '$data(^users(req("body","newUsername"))) do
	. set errors("errors","params",1)="New user does not exist"
	. QUIT $$errorResponse(.errors,404)
	; Perform the operation
	$$addMember^groups(groupID,req("body","newUsername"),errors)
	if $data(errors) QUIT $$errorResponse(.errors,400)
	QUIT $$header^%zmgweb()_"{}"
removeUser(req) ;
	;
	new username,errors,groupID
	; Validate user access token
	set username=$$authenticate^security(.req,.errors)
	if $data(errors) QUIT $$errorResponse(.errors,403)
	; Retrieve groupID from body
	if '$data(req("body","groupID")) do
	. set errors("errors","params",1)="Body must include target group ID"
	. QUIT $$errorResponse(.errors,400)
	set groupID=req("body","groupID")
	; Make sure group exists
	if '$data(^groups(groupID)) do
	. set errors("errors","params",1)="Group does not exist"
	. QUIT $$errorResponse(.errors,404)
	; Make sure group is owned by user
	if username'=^groups(groupID,"owner") do
	. set errors("errors","auth",1)="User does not own target group"
	. QUIT $$errorResponse(.errors,403)
	; Get target user's username
	if '$data(req("body","targetUsername")) do
	. set errors("errors","params",1)="Body must include target user"
	. QUIT $$errorResponse(.errors,400)
	; Perform the operation
	$$removeMember^groups(groupID,req("body","targetUsername"),errors)
	if $data(errors) QUIT $$errorResponse(.errors,400)
	QUIT $$header^%zmgweb()_"{}"
	;
createAllergyList(req) ;
	;
	new username,errors,groupID,includeOwner
	; Validate user access token
	set username=$$authenticate^security(.req,.errors)
	if $data(errors) QUIT $$errorResponse(.errors,403)
	; Retrieve groupID from body
	if '$data(req("body","groupID")) do
	. set errors("errors","params",1)="Body must include target group ID"
	. QUIT $$errorResponse(.errors,400)
	set groupID=req("body","groupID")
	; Make sure group exists
	if '$data(^groups(groupID)) do
	. set errors("errors","params",1)="Group does not exist"
	. QUIT $$errorResponse(.errors,404)
	; Make sure group is owned by user
	if username'=^groups(groupID,"owner") do
	. set errors("errors","auth",1)="User does not own target group"
	. QUIT $$errorResponse(.errors,403)
	if $data(req("body","includeOwner")) set includeOwner=req("body","includeOwner")
	; Perform the operation
	$$assembleAllergyList^groups(id,$data(includeOwner),output,errors)
	if $data(errors) QUIT $$errorResponse(.errors,400)
	QUIT $$response^%zmgwebUtils(.output)