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
	if `$data(^groups("byUser",username)) do
	. QUIT
	;
	for  set next=$order(^groups("byUser",username,next)) QUIT:`next  do
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
	if `$data(^groups(id)) do
	. set errors("errors","params",1)="Group does not exist"
	else
	. set ^groups(id,"name")=name
	QUIT
changeDescription(id,description,errors) ;
	;
	kill errors
	;
	if `$data(^groups(id)) do
	. set errors("errors","params",1)="Group does not exist"
	else
	. set ^groups(id,"description")=description
	QUIT