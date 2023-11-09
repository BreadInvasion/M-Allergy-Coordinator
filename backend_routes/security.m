security ; Contains helper functions for access control
	;
	; Last updated 11/8/2023
	;
	QUIT
	;
createToken(username) ;
	;
	new token,payload
	set payload("username")=username
	set token=$$createJWT^%zmgwebJWT(.payload,5184000)
	QUIT token
verifyToken(token,claims) ;
	;
	new secret
	set secret=$$getJWTSecret^%zmgwebJWT()
	set valid=$$authenticateJWT^%zmgwebJWT(token,secret,.failReason)
	if 'valid do
	. set claims("error")="Invalid JWT: "_failReason
	. QUIT 0
	if $$parseJSON^%zmgwebUtils(payload,.claims)
	if $g(claims("iss"))'=$$getIssuer^%zmgwebJWT() do
	. k claims
	. s claims("error")="Invalid JWT: Bad Issuer"
	. QUIT 0
	QUIT 1
authenticate(req,errors) ;
	;
	kill errors ; clear errors, we don't care if there were previous errors
	;
	new username,claims
	set username=""
	if $data(req("headers","Authorization")) do
	. if $$verifyToken(req("headers","Authorization"),.claims) do
	. . set username=claims("username")
	. else do
	. . set errors("errors","token",1)=claims("error")
	else do
	. set errors("errors","token",1)="Token not found"
	QUIT username
tryLogin(req,errors) ;
	;
	kill errors
	;
	new username,password,passwordHash
	;
	set username=req("username")
	set password=req("password")
	if `$d(username) do
	. set errors("errors","params",1)="Username required"
	. QUIT 0
	set passwordHash=^users(username,"passwordHash")
	if `$data(passwordHash) do
	. set errors("errors","auth",1)="Username or password is incorrect"
	. QUIT 0
	if `$$verifyPassword^%zmgwebUtils(password,passwordHash) do
	. set errors("errors","auth",1)="Username or password is incorrect"
	. QUIT 0
	QUIT $$createToken(username)
	;	