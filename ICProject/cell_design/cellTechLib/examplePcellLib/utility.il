procedure( spcMinEmit(tfId cont base)
  let((contw)
  
  cw = techGetSpacingRule(tfId "minWidth" cont)
  boc = techGetOrderedSpacingRule(tfId "minEnclosure" base cont)
  contw = 2 * boc + cw
))

procedure( getExt(tfId poly ndiff)
  let((grid pinwidth minpinwidth)

  grid = techGetMfgGridResolution(tfId)
  pinwidth = techGetSpacingRule(tfId "minExtension" poly) -
	techGetSpacingRule(tfId "minSpacing" poly ndiff)
  if(pinwidth < grid then
    minpinwidth = grid
  else
    minpinwidth = pinwidth
  )
  minpinwidth
))

procedure( capCalcDim( cap minCapWidth capCoeff grid @optional (param1 nil))
  let( (param2 )
 
 
    cond(
      ( param1
        param2 = spcRound((cap/capCoeff/param1)*1e-6 grid)*1e-6
        when(param2 < minCapWidth
          spcMsg( 'warn "Dimensions were reset due to design rules.")
          param2 = capCalcDim( cap minCapWidth capCoeff grid)
          spcSetParam( 'w param2)
          spcSetParam( 'l param2)
          param2 = nil
        )
      )
      ( t
        param2 = spcRound(sqrt(cap/capCoeff) grid) * 1e-6
      )
    )
    param2
  )
)

procedure(spcDefResLength( tfId media)
   let(()
     grid = techGetMfgGridResolution(tfId)
     contact = techGetParam(tfId "cont")
     metal1 = techGetParam(tfId "metal1")
     minWidth = techGetSpacingRule(tfId "minWidth" media)
     sheetRes = techGetElectricalRule(tfId "sheetRes" media)
     contactRes = sheetRes * 0.25
     minRes = techGetParam(tfId "minRes")
     defLength = spcRound((8*minRes - 2 * contactRes)/sheetRes * minWidth grid)
     defLength
))
 
procedure(spcDefserpWidth( tfId media)
   let(()
     grid = techGetMfgGridResolution(tfId)
     contact = techGetParam(tfId "cont")
     metal1 = techGetParam(tfId "metal1")
     minWidth = techGetSpacingRule(tfId "minWidth" media)
     resSpacing = techGetSpacingRule(tfId "minSpacing" media)
     cw = techGetSpacingRule(tfId "minWidth" contact)
     resoc = spcRound(techGetOrderedSpacingRule(tfId "minEnclosure"
               media contact) grid)
     m1oc = spcRound(techGetOrderedSpacingRule(tfId "minEnclosure"
               metal1 contact) grid)
     if(resoc >= m1oc then
       oriX = resoc
     else
       oriX = m1oc
     )
     minSerpWidth = oriX + resoc + cw + resSpacing + minWidth
     minSerpWidth
))


procedure(spcRound( value grid)
   let(()
     value = float(round(value/grid)*grid)
     value
))

procedure(spcInputInt( param @optional (min nil) (max nil))
   let( (paramID paraValue)
     paramID = get(cdfgData param)
     paraValue = paramID->value
     unless( numberp(paraValue)
       spcMsg( 'err "%s must have an integer value, reset to last value."
         paramID->prompt)
       paraValue = paramID->formInit->lastValue
     )
     paraValue = fix(paraValue)
     when( min && paraValue < min
       spcMsg( 'warn "%s lower limit enforced." paramID->prompt)
       paraValue = min
     )
     when( max && paraValue > max
       spcMsg( 'warn "%s upper limit enforced." paramID->prompt)
       paraValue = max
     )
     spcSetParam(param paraValue)
     paraValue
  )
)

procedure(spcCalcLength(res width sheetRes segments resForm grid)
  let( (contactRes cornerRes length corners)
    contactRes = sheetRes * 0.25
    cornerRes = sheetRes * 0.559  
    if(resForm == "Straps" then
      length = ((res - 2 * segments * contactRes)/sheetRes) * width
      length = spcRound(length grid)
    else
      corners = 2 * (segments - 1)
      length = ((res - corners * cornerRes - 2 * contactRes)/sheetRes) * width
      length = spcRound(length grid)
    )
  length
))

procedure(spcCalcRes(length width sheetRes segments resForm)
  let( (contactRes cornerRes res corners)
    contactRes = sheetRes * 0.25
    cornerRes = sheetRes * 0.559  
    if(resForm == "Straps" then
      res = (length * sheetRes/width) + 2 * segments * contactRes 
      res = spcRound(res 1e-2)
    else
      corners = 2 * (segments - 1)
      res = length * sheetRes/width + corners * cornerRes + 2 * contactRes
      res = spcRound(res 1e-2)
    )
  res
))

procedure(spcInputDim(param roundFactor @optional (min nil) (max nil))
  let( ( paramID paraValue)
     paramID = get( cdfgData  param) ; returns cdfId
     paraValue = paramID->value ; returns the value of the param
     cond(
       ( numberp(paraValue) || (paraValue = car( errsetstring(paraValue)))
         when( min && lessp(spcRound(paraValue roundFactor)
		spcRound(min roundFactor))
           paraValue = min
           spcMsg( 'warn "Minimum %s, violated, clamped at %L"
                 paramID->prompt paraValue)
         )
         when( max && greaterp(spcRound(paraValue roundFactor)
		spcRound(max roundFactor))
           paraValue = max
           spcMsg( 'warn "Maximum %s, violated, clamped at %L"
                paramID->prompt paraValue)
         )
         paraValue = float(paraValue)
      ) 
      ( (paraValue = paramID->formField->lastValue) && evalstring(paraValue)
        spcMsg( 'err "Numeric value required for %s, reset to last value."
         paramID->prompt)
        paraValue = paramID->formField->lastValue
        paramID->value = paraValue
        paraValue = float(evalstring(paraValue))
      )
      ( numberp(min)
        spcMsg( 'err "Numeric value required for %s, set to minimum value."
         paramID->prompt)
        paraValue = sprintf(nil "%f" min)
        paramID->value = paraValue
        paraValue = evalstring(paraValue)
      )
    )
    when(paraValue
	spcSetParam(param paraValue)
    )
    paraValue
  )
)

procedure( spcSetParam( param value)
  let( (paraValue)
    when(value
      paraValue = get( cdfgData  param)
        cond(
          ( !paraValue 
	  spcMsg( 'err "spcSetParam:  undefined parameter %s." param)
          )
          ( paraValue->paramType == "string" && !stringp( value)
	  value = sprintf(nil "%g" value)
          )
          ( paraValue->paramType == "int"
	  value = fix( value)
          )
          ( paraValue->paramType == "float"
	  value = float( value)
        )
      )
      paraValue->value = value
    )
  )
)


;       spcMsg
;       a g.p. utility for displaying info, warning, and error
;       messages in a consistent way in the CIW log window.
 
;       the global variable spcEnableErrorDBox, when set to t,
;       causes a dialog box to appear when error messages are output,
;       the default is to just beep and write them to the CIW.
 
;       takes two or more arguments, the first must be a string or
;       symbol such as 'warn or 'err to indicate the severity of the
;       message, any other value is treated as an info message.
;       the second and additional arguments are the same as those
;       for the printf function.
 
spcEnableErrorDBox = nil
 
procedure( spcMsg( severity msg @rest r)
  let( ( hdr text)
 
    unless( severity severity = 'info)
    hdr = caseq( concat( severity)
      ( (warning warn)
        "spc:  *Warning*  ")
      ( (error err)
        "spc:  *Error*  ")
      ( t
        "spc:  ")
    )
 
    apply( 'sprintf cons( 'text cons( strcat( hdr msg) r)))
    hiRaiseWindow( hiGetCIWindow())
    printf( "%s\n" text)
    when( memq( severity '(error err))
      if( spcEnableErrorDBox then
        hiDisplayModalDBox( 'dbox "Library Error" text "" "" nil 6)
      else
        hiGetAttention())
    )
  )
)

procedure(buildCnts(cv layer1 layer2 layer3 width1 width3 length3 
	pathpnts terminal pinlabel enc offset chop) 
   ; pinlabel is a boolean that determines whether a label will be created
   let( ( fig pin_fig )
    
	if(layer1 != layer2 then
	   fig = rodCreatePath(
		?cvId cv
		?layer layer1
		?width width1
		?pts pathpnts
		?choppable nil
		?encSubPath list( list(
			?layer layer2
			?enclosure enc
			?choppable chop
			?termName terminal
			?pinLabel pinlabel
			?pinLabelHeight length3
			?pinLabelLayer "text"
	        ))
		?subRect list( list(
			?layer layer3
			?width width3
			?length length3
			?endOffset offset
		))
          )
	  pin_fig = rodCreateRect(
                ?cvId cv
                ?layer layer2
		?pin t
		?termName terminal
		?bBox sizeBBox(list(fig~>lowerLeft fig~>upperRight) -enc)
	  )
          rodAlign(
		?alignObj pin_fig
		?alignHandle "centerCenter"
		?refObj fig
		?refHandle "centerCenter"
          )
	else
           fig = rodCreatePath(
                ?cvId cv
                ?layer layer1
                ?width width1
                ?pts pathpnts
                ?choppable nil
		?termName terminal
          )
	  pin_fig = rodCreateRect(
                ?cvId cv
                ?layer layer1
		?pin t
		?termName terminal
		?bBox list(fig~>lowerLeft fig~>upperRight)
	  )
          rodAlign(
		?alignObj pin_fig
		?alignHandle "centerCenter"
		?refObj fig
		?refHandle "centerCenter"
          )
	)

	list(pin_fig fig)
    )
)

procedure( mergeBBoxes(bBox1 bBox2)
    let( (bBox ll1 ur1 ll2 ur2 llX llY urX urY)
 
        cond(
            (! isBBox(bBox1)
                bBox = bBox2
            )
            (! isBBox(bBox2)
                bBox = bBox1
            )
            (t
                ll1 = car(bBox1)
                ur1 = cadr(bBox1)
                ll2 = car(bBox2)
                ur2 = cadr(bBox2)
                llX = if( car(ll1) >= car(ll2)   then car(ll2) else car(ll1))
                llY = if( cadr(ll1) >= cadr(ll2) then cadr(ll2) else cadr(ll1))
                urX = if( car(ur1) >= car(ur2)   then car(ur1) else car(ur2))
                urY = if( cadr(ur1) >= cadr(ur2) then cadr(ur1) else cadr(ur2))
                bBox = list(list(llX llY) list(urX urY))
            )
        )
        bBox
    )
)

procedure(sizeBBox(bBox amount)
    when(isBBox(bBox)
	list(
	    list(caar(bBox)-amount cadar(bBox)-amount)
	    list(caadr(bBox)+amount cadadr(bBox)+amount)
	)
    )
)

procedure(stringToPointList(points_string "t")
    let(( tmp_list point_x point_y points_list )
 
        tmp_list = parseString(points_string "list(:)' XY=")
        points_list = nil
        for(i 0 length(tmp_list)
            when(evenp(i) && (point_x = nth(i tmp_list)) &&
                    (point_y = nth(i+1 tmp_list))
                point_x = cdfParseFloatString(point_x)
                point_y = cdfParseFloatString(point_y)
                when(numberp(point_x) && numberp(point_y)
                    points_list = cons(list(point_x point_y)
                            points_list)
                )
            )
        )
        reverse(points_list)
    )
)

procedure(getSegLength(seg)
    let(( (ll_x caar(seg)) (ll_y cadar(seg)) (ur_x caadr(seg))
	    (ur_y cadadr(seg)) dist_x dist_y )
	dist_x = abs(ur_x - ll_x)
	dist_y = abs(ur_y - ll_y)
	if(zerop(dist_x) then
	    if(zerop(dist_y) then
		;; We have a zerop length segment.
		0.0
	    else
		;; We have a vertical segment.
		dist_y
	    )
	else
	    if(zerop(dist_y) then
		;; We have a horizontal segment.
		dist_x
	    else
		sqrt((dist_x * dist_x) + (dist_y * dist_y))
	    )
	)
    )
)

procedure(getPointsLength(points @optional numPoints)
    let(( (total_length 0.0) )
	unless(numPoints
	    numPoints = length(points)
	)
	for(i 0 numPoints - 2
	    total_length = total_length +
		    getSegLength(list(nth(i points) nth(i+1 points)))
	)
	total_length
    )
)

procedure(spcParseFloatString(inString "t")
    let(( (outValue cdfParseFloatString(inString)) )
	when(numberp(outValue)
	    if(member(getchar(inString strlen(inString))
		    list('\0 '\1 '\2 '\3 '\4 '\5 '\6 '\7 '\8 '\9 '\.)) then
		outValue
	    else
		outValue = outValue * 1e6
	    )
	)
    )
)

procedure(spcStrongConnectPins( pinlist )
    let((currPin nextPin)
        for(i 0 length(pinlist)-1
            when((currPin = nth(i pinlist)) && (nextPin = nth(i+1 pinlist))
                dbStronglyConnectPins(list(currPin nextPin))
            )
        )
        t
    )
)

procedure(spcMakeRectPins(cv)
    let(( rod_objs term_name term_dir pin_fig pin_name pin_accessDir pin_net
	    name_index new_figs new_pin pin_deleted pin_list p_name )

	when(cv~>mode != "r"
	    rod_objs = rodGetNamedShapes(cv)

	    foreach(term cv~>terminals
		term_name = term~>name
		term_dir = term~>direction

		foreach(pin term~>pins
		    p_name = pin~>name
		    when((pin_fig = pin~>fig) && pin_fig~>objType != "rect" &&
			    (new_figs = layerTile(cv list(pin_fig~>layerName
			    pin_fig~>purpose) list(pin_fig)))

			;; Check to see if its a named shape
			pin_name = car(setof(r_obj rod_objs
				r_obj~>dbId == pin_fig))~>name
			;; What about subShapes?

			pin_accessDir = pin~>accessDir
			pin_net = pin~>net

			if(length(new_figs) > 1 then
			    name_index = 1
			    abutAccessDir = nil
			    abutCondInclusion = nil
			    abutGateNet = nil
			    abutStretchMat = nil
			else
			    name_index = nil
			    abutAccessDir = pin_fig~>abutAccessDir
			    abutCondInclusion = pin_fig~>abutCondInclusion
			    abutGateNet = pin_fig~>abutGateNet
			    abutStretchMat = pin_fig~>abutStretchMat
			)
			pin_deleted = nil
			pin_list = nil
			foreach(new_fig new_figs
			    when(new_fig~>objType == "rect"
				when(pin_net && (new_pin =
					dbCreatePin(pin_net new_fig))
				    new_pin~>accessDir = pin_accessDir
				    pin_list = cons(new_pin pin_list)
				)
				if(name_index then
				    when(pin_name
					rodNameShape(?shapeId new_fig
						?name sprintf(nil "%s_rpin%d"
						pin_name name_index))
					name_index++
				    )
				else
				    when(abutAccessDir
					new_pin~>abutAccessDir =
						abutAccessDir
				    )
				    when(abutCondInclusion
					new_pin~>abutCondInclusion =
						abutCondInclusion
				    )
				    when(abutGateNet
					new_pin~>abutGateNet =
						abutGateNet
				    )
				    when(abutStretchMat
					new_pin~>abutStretchMat =
						abutStretchMat
				    )

				    dbDeleteObject(pin)
				    new_pin~>name = p_name
				    pin_deleted = t

				    when(pin_name
					rodNameShape(?shapeId new_fig
						?name sprintf(nil "%s_rpin"
						pin_name))
				    )
				)
			    )
			)

			when(length(pin_list) > 1
			    ;; StrongConnect the pins
			    spcStrongConnectPins(pin_list)
			)
			unless(pin_deleted
			    dbDeleteObject(pin)
			    new_pin~>name = p_name
			)
		    )
		)
	    )

	    t
	)
    )
)

procedure(spcDebugMsg(in_string "t")
    fprintf(stderr "%s" in_string)
)

;; WeakConnect Model:
;;                           +---> "G_Weak1_Sub1" ------> "6"
;;        +---> "G_Weak1" ---+---> "G_Weak1_Sub2" ---> "5"
;; "G" ---+
;;        +---> "G_Weak2" ---+---> "G_Weak2_Sub1" ------> "9"
;;                           +---> "G_Weak2_Sub2" ---> "10"
;;
;; MustConnect Model:
;;                                         _     +---> "4"
;;        +---> "D_Must1" ---> "D_Must1_Sub1" ---+---> "7" / "3"
;; "D" ---+
;;        +---> "D_Must2" ---> "D_Must2_Sub1" ---+---> "12" / "13"
;;                                               +---> "11"
;;
procedure(spcBuildNetHier( cv net_name in_list
	@optional (make_pin nil) (net_dir "inputOutput") (net_parent nil) )
    let(( net_id item_id subnet_name subnet_id accessDir pinId
            (counter 1) )
 
        net_id = dbMakeNet(cv net_name net_parent)
	;fprintf(stderr "Making net %s.\n" net_name)

        foreach(item in_list
	    case(type(item)
		;; Attach the database object to the net.
		(dbobject
		    item_id = item
		    if(make_pin then
			if((pinId = item_id~>pin) then
			    accessDir = pinId~>accessDir
			    dbDeleteObject(pinId)
			else
			    accessDir = nil
			)
			pinId = dbCreatePin(net_id item_id)
			when(accessDir
			    pinId~>accessDir = accessDir
			)
		    else
			dbAddFigToNet(item_id net_id)
		    )
		    ;fprintf(stderr "*** Adding figure %L to net %s.\n"
			    ;item_id net_name)
		)
		;; rod objects return the other type.
		;; Attach the database object to the net.
		(other
		    when((item_id = item~>dbId)
			if(make_pin then
			    if((pinId = item_id~>pin) then
				accessDir = pinId~>accessDir
				dbDeleteObject(pinId)
			    else
				accessDir = nil
			    )
			    pinId = dbCreatePin(net_id item_id)
			    when(accessDir
				pinId~>accessDir = accessDir
			    )
			else
			    dbAddFigToNet(item_id net_id)
			)
			;fprintf(stderr "*** Adding figure %L to net %s.\n"
				;item_id net_name)
		    )
		)
		(list
		    sprintf(subnet_name "%s_subnet%n" net_name counter++)
		    spcBuildNetHier(cv subnet_name item make_pin net_dir net_id)
		)
	    )
        )

	t
    )
)

procedure(spcClearGatePins(pinlist)
    foreach(plist pinlist
	foreach(plist2 plist
	    foreach(pin plist2
		dbDeleteObject(pin~>dbId~>pin)
	    )
	)
    )
)
