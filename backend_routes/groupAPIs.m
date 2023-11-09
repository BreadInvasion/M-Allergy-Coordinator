groupAPIs ;
	;
	; Last updated 11/8/2023
	;
	QUIT
	;
createGroup(req) ;
	new requiredFields,username,errors,id
	set requiredFields("name")=""
	set requiredFields("description")=""
	if $$bodyAndFields^common(.req,"group",.requiredFields,"",.errors)
	if $data(errors) QUIT $$errorResponse^common(.errors)
	; Validate user access token
	set username=$$authenticate^security(.req,.errors)
	if $data(errors) QUIT $$errorResponse^common(.errors,403)
	; Validate request body
	set id=$$create^groups(requiredFields("name"),requiredFields("description"),username)
	QUIT $$header^%zmgweb()_"{""groupID"": """_id_"""}"
	;
deleteGroup(req) ;
	new username,errors,groupID,requiredFields
	; Validate user access token
	set username=$$authenticate^security(.req,.errors)
	if $data(errors) QUIT $$errorResponse^common(.errors,403)
	; Validate parameters
	set requiredFields("groupID")=""
	if $$bodyAndFields^common(.req,"group",.requiredFields,"",.errors)
	if $data(errors) QUIT $$errorResponse^common(.errors)
	; Retrieve parameters
	set groupID=req("body","group","groupID")
	; Make sure group exists
	if '$data(^groups(groupID)) do
	. set errors("errors","params",1)="Group does not exist"
	. QUIT $$errorResponse^common(.errors,404)
	; Make sure group is owned by user
	if username'=^groups(groupID,"owner") do
	. set errors("errors","auth",1)="User does not own target group"
	. QUIT $$errorResponse^common(.errors,403)
	if $$delete^groups(groupID)
	QUIT $$header^%zmgweb()_"{}"
	;
editGroup(req) ;
	;
	new username,errors,groupID,requiredFields,name,description
	; Validate user access token
	set username=$$authenticate^security(.req,.errors)
	if $data(errors) QUIT $$errorResponse^common(.errors,403)
	; Validate parameters
	set requiredFields("groupID")=""
	set requiredFields("name")=""
	set requiredFields("description")=""
	if $$bodyAndFields^common(.req,"group",.requiredFields,"",.errors)
	if $data(errors) QUIT $$errorResponse^common(.errors)
	; Retrieve parameters
	set groupID=req("body","group","groupID")
	set name=req("body","group","name")
	set description=req("body","group","description")
	; Make sure group exists
	if '$data(^groups(groupID)) do
	. set errors("errors","params",1)="Group does not exist"
	. QUIT $$errorResponse^common(.errors,404)
	; Make sure group is owned by user
	if username'=^groups(groupID,"owner") do
	. set errors("errors","auth",1)="User does not own target group"
	. QUIT $$errorResponse^common(.errors,403)
	$$changeName^groups(groupID,name,.errors)
	if $data(errors) QUIT $$errorResponse^common(.errors,404)
	$$changeDescription^groups(groupID,description,.errors)
	if $data(errors) QUIT $$errorResponse^common(.errors,404)
	QUIT $$header^%zmgweb()_"{}"
addUser(req) ;
	;
	new username,errors,groupID,newMember,requiredFields
	; Validate user access token
	set username=$$authenticate^security(.req,.errors)
	if $data(errors) QUIT $$errorResponse^common(.errors,403)
	; Validate parameters
	set requiredFields("groupID")=""
	set requiredFields("newMember")=""
	if $$bodyAndFields^common(.req,"group",.requiredFields,"",.errors)
	if $data(errors) QUIT $$errorResponse^common(.errors)
	; Retrieve parameters
	set groupID=req("body","group","groupID")
	set newMember=req("body","group","newMember")
	; Make sure group exists
	if '$data(^groups(groupID)) do
	. set errors("errors","params",1)="Group does not exist"
	. QUIT $$errorResponse^common(.errors,404)
	; Make sure group is owned by user
	if username'=^groups(groupID,"owner") do
	. set errors("errors","auth",1)="User does not own target group"
	. QUIT $$errorResponse^common(.errors,403)
	; Make sure they exist
	if '$data(^users(newUsername)) do
	. set errors("errors","params",1)="New user does not exist"
	. QUIT $$errorResponse^common(.errors,404)
	; Perform the operation
	if $$addMember^groups(groupID,newUsername,errors)
	if $data(errors) QUIT $$errorResponse^common(.errors,400)
	QUIT $$header^%zmgweb()_"{}"
removeUser(req) ;
	;
	new username,errors,groupID,requiredFields,targetMember
	; Validate user access token
	set username=$$authenticate^security(.req,.errors)
	if $data(errors) QUIT $$errorResponse^common(.errors,403)
	; Validate parameters
	set requiredFields("groupID")=""
	set requiredFields("targetMember")=""
	if $$bodyAndFields^common(.req,"group",.requiredFields,"",.errors)
	if $data(errors) QUIT $$errorResponse^common(.errors)
	; Retrieve parameters
	set groupID=req("body","group","groupID")
	set targetMember=req("body","group","targetMember")
	; Make sure group exists
	if '$data(^groups(groupID)) do
	. set errors("errors","params",1)="Group does not exist"
	. QUIT $$errorResponse^common(.errors,404)
	; Make sure group is owned by user
	if username'=^groups(groupID,"owner") do
	. set errors("errors","auth",1)="User does not own target group"
	. QUIT $$errorResponse^common(.errors,403)
	; Perform the operation
	if $$removeMember^groups(groupID,targetMember,errors)
	if $data(errors) QUIT $$errorResponse^common(.errors,400)
	QUIT $$header^%zmgweb()_"{}"
	;
createAllergyList(req) ;
	;
	new username,groupID,includeOwner
	; Validate user access token
	set username=$$authenticate^security(.req,.errors)
	if $data(errors) QUIT $$errorResponse^common(.errors,403)
	;	
	; Validate content
	new requiredFields
	set requiredFields("groupID")=""
	if $$bodyAndFields(.req,"params",.requiredFields,"",.errors)
	if $data(errors) QUIT $$errorResponse(.errors)
	; Retrieve content
	set groupID=req("body","params","groupID")
	set includeOwner=$get(req("body","params","includeOwner"),"")
	; Make sure group exists
	if '$data(^groups(groupID)) do
	. set errors("errors","params",1)="Group does not exist"
	. QUIT $$errorResponse^common(.errors,404)
	; Make sure group is owned by user
	if username'=^groups(groupID,"owner") do
	. set errors("errors","auth",1)="User does not own target group"
	. QUIT $$errorResponse^common(.errors,403)
	; Perform the operation
	if $$assembleAllergyList^groups(id,$data(includeOwner),output,errors)
	if $data(errors) QUIT $$errorResponse^common(.errors,400)
	QUIT $$response^%zmgwebUtils(.output)