users ; users database and helper functions
	;
	; Last updated 11/8/2023
	;
create(username,password,errors) ;
	kill errors
	;
	if $data(^users(username)) do
		set errors("errors","params",1)="Username taken"
		QUIT
	set ^users(username)=username
	set ^users(username,"passwordHash")=$$hashPassword^%zmgwebUtils(password)
	;
delete(username,errors) ;
	kill errors
	if '$data(^users(username)) do
		set errors("errors","params",1)="User does not exist"
		QUIT
	kill ^users(username)
updateAllergyList(req,username,errors) ;
	kill errors
	new nextAllergy
	set nextAllergy=""
	for  set nextAllergy=$order(req("body","allergies",nextAllergy)) QUIT:'nextAllergy  do
	. if '$data(req("body","allergies",nextAllergy,"severity"))!(req("body","allergies",nextAllergy,"severity")<0)!(req("body","allergies",nextAllergy,"severity")>5) do
	. . set errors("errors","params",1)="Allergy severity must be between 0 and 5"
	. . QUIT
	for  set nextAllergy=$order(req("body","allergies",nextAllergy)) QUIT:'nextAllergy  do
	. set ^users(username,"allergies",req("body","allergies",nextAllergy,"name"))=req("body","allergies",nextAllergy,"name")
	. set ^users(username,"allergies",req("body","allergies",nextAllergy,"name"),"severity")=req("body","allergies",nextAllergy,"severity")
	. if ^users(username,"allergies",req("body","allergies",nextAllergy,"name"),"severity")=0 do
	. . kill ^users(username,"allergies",req("body","allergies",nextAllergy,"name"))
	QUIT
	;