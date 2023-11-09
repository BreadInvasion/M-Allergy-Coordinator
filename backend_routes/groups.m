groups ; groups database and helper functions
	;
	; Last updated 11/8/2023
	;
getNextId() ;
	QUIT $increment(^groups("nextId"))
create(name,description,owner) ;
	;
	new id
	set id=$$getNextId()
	set ^groups(id,"name")=name
	set ^groups(id,"description")=description
	set ^groups(id,"owner")=owner
	set ^groups("byUser",owner,id)=id
	QUIT id
delete(id) ;
	;
	new findNext,next,member
	set findNext="$order(^groups(id,""members"",""""))"
	for  set next=@findNext QUIT:‘next  kill ^groups("byUser",^groups(id,"members",next),id)
	;
	kill ^groups("byUser",^groups(id,"owner"),id)
	kill ^groups(id)
	QUIT
getMemberGroups(username,output) ;
	;
	kill output
	;
	new next,groupID
	set next=""
	;
	if '$data(^groups("byUser",username)) do
	. QUIT
	;
	for  set next=$order(^groups("byUser",username,next)) QUIT:'next  do
	. set groupID=^groups("byUser",username,next)
	. set output(groupID)=groupID
	. set output(groupID,"name")=^groups(groupID,"name")
	. set output(groupID,"description")=^groups(groupID,"description")
	. set output(groupID,"owner")=^groups(groupID,"owner")
	QUIT
changeName(id,name,errors) ;
	;
	kill errors
	;
	if '$data(^groups(id)) do
	. set errors("errors","params",1)="Group does not exist"
	else
	. set ^groups(id,"name")=name
	QUIT
changeDescription(id,description,errors) ;
	;
	kill errors
	;
	if '$data(^groups(id)) do
	. set errors("errors","params",1)="Group does not exist"
	else
	. set ^groups(id,"description")=description
	QUIT
addMember(id,username,errors) ;
	;
	kill errors
	;
	if '$data(^groups(id)) do
	. set errors("errors","params",1)="Group does not exist"
	. QUIT
	if $data(^groups(id,"members",username)) do
	. set errors("errors","params",1)="User already in group"
	. QUIT
	if username=^groups(id,"owner") do
	. set errors("errors","params",1)="User is owner"
	set ^groups(id,"members",username)=username
	set ^groups("byUser",username,id)=id
	QUIT
removeMember(id,username,errors) ;
	;
	kill errors
	;
	if '$data(^groups(id)) do
	. set errors("errors","params",1)="Group does not exist"
	. QUIT
	if '$data(^groups(id,"members",username)) do
	. set errors("errors","params",1)="User not in group, or is owner"
	. QUIT
	kill ^groups(id,"members",username)
	kill ^groups("byUser",username,id)
	QUIT
assembleAllergyList(id,includeOwner,output,errors) ;
	;
	kill output,errors
	new nextUser,nextAllergy
	set nextUser=""
	set nextAllergy=""
	;
	if '$data(^groups(id)) do
	. set errors("errors","params",1)="Group does not exist"
	. QUIT
	;
	for  set nextUser=$order(^groups(id,"members",nextUser)) QUIT:'nextUser  do
	. for  set nextAllergy=$order(^users(nextUser,"allergies",nextAllergy)) QUIT:'nextAllergy  do
	. . if $data(^output(^users(nextUser,"allergies",nextAllergy))) do
	. . . if ^output(^users(nextUser,"allergies",nextAllergy),"severity")<^users(nextUser,"allergies",nextAllergy,"severity") do
	. . . . set ^output(^users(nextUser,"allergies",nextAllergy),"severity")=^users(nextUser,"allergies",nextAllergy,"severity")
	. . else do
	. . . set ^output(^users(nextUser,"allergies",nextAllergy))=^users(nextUser,"allergies",nextAllergy)
	. . . set ^output(^users(nextUser,"allergies",nextAllergy),"severity")=^users(nextUser,"allergies",nextAllergy,"severity")
	if includeOwner do
	. for  set nextAllergy=$order(^users(^groups(id,"owner"),"allergies",nextAllergy)) QUIT:'nextAllergy  do
	. . if $data(^output(^users(^groups(id,"owner"),"allergies",nextAllergy))) do
	. . . if ^output(^users(^groups(id,"owner"),"allergies",nextAllergy),"severity")<^users(^groups(id,"owner"),"allergies",nextAllergy,"severity") do
	. . . . set ^output(^users(^groups(id,"owner"),"allergies",nextAllergy))=^users(^groups(id,"owner"),"allergies",nextAllergy,"severity")
	. . else do
	. . . set ^output(^users(^groups(id,"owner"),"allergies",nextAllergy))=^users(^groups(id,"owner"),"allergies",nextAllergy)
	. . . set ^output(^users(^groups(id,"owner"),"allergies",nextAllergy),"severity")=^users(^groups(id,"owner"),"allergies",nextAllergy,"severity")
	QUIT