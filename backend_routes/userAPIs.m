userAPIs ; users specific endpoints
	;
	; Last updated 11/9/2023
	;
	;
	;
createUser(req) ;
	;
	new requiredFields,errors,username,password
	set requiredFields("username")=""
	set requiredFields("password")=""
	if $$bodyAndFields^common(.req,"user",.requiredFields,"",.errors)
	if $data(errors) QUIT $$errorResponse^common(.errors)
	;
	set username=req("body","user","username")
	set password=req("body","user","password")
	;
	if $$create^users(username,password,.errors)
	if $data(errors) QUIT $$errorResponse^common(.errors,409)
	QUIT $$header^%zmgweb()_"{}"
deleteUser(req) ;
	;
	new errors
	; Validate user access token
	set username=$$authenticate^security(.req,.errors)
	if $data(errors) QUIT $$errorResponse^common(.errors,403)
	;
	if $$delete^users(username,.errors)
	if $data(errors) QUIT $$errorResponse^common(.errors,404)
	QUIT $$header^%zmgweb()_"{}"
updateAllergies(req) ;
	;
	new errors
	; Validate user access token
	set username=$$authenticate^security(.req,.errors)
	if $data(errors) QUIT $$errorResponse^common(.errors,403)
	;
	if '$data(req("body","allergies")) do
	. set errors("errors","params",1)="Need list of allergy designations"
	. QUIT $$errorResponse^common(.errors,400)
	if $$updateAllergyList^users(.req,username,.errors)
	if $data(errors) QUIT $$errorResponse^common(.errors,400)
	QUIT $$header^%zmgweb()_"{}"