;*************** rodmosBuild ***************************************
; Last revision 2/11/98
procedure(rodmosBuild(cv w l splitting splitType fingers threshold m
	sourceCntPosition drainCntPosition leftStretch rightStretch
	minNumCnts tapRule tapPosition wellRule routePoly routePolydir
	routeSD pw sourceCoverage rightCnts leftCnts mw ms drainCoverage
	tfId diff implant poly contact metal1 cw cs m1oc pext doc dop
	pcs pds bn abutRule snapGrid)
 
  let(( step polyPinWidth placePin gate sfig gatePins sourcePins strap_width
        stepGate drainPins dfig lastsfig midfig cnt gateGroup polyfig diffBBox
 	sourceShapes sourceShapes2 drainShapes drainShapes2 sourcesize
	drainsize ypoint metlist half_pw intermetal midmetal midxpnt xpnt name
	contactname intername currPin nextPin poly_left poly_right diff_top
	diff_bot contMidY contMidX tapDiffObj tapMetObj tapImpRule tapContObj
	tmpRodObj diff_left diff_right polyMidY sourceMetals drainMetals
	tmpBBox tmpNum sourceRouteSide drainRouteSide minContDiff impBBox
	wellBBox tapMetPinObj )
 

    ;; Add the permuteRule for permutable pins.
    ;; Note that using a substrate contact would mess up permutable pins.
    dbSetq(cv "p(S D)" permuteRule)

    ;; If we're getting passed a string, evalute it.
    when(stringp(w)
	w = cdfParseFloatString(w)
    )
    ;; Make sure were not getting a real small number caused by parsing
    ;; schematic strings containing unit letters at the end.
    when(w < .001
        w = w * 1e6
    )
    w = spcRound(w snapGrid)

    ;; Multiply the width by the value of m.
    when(m
	when(stringp(m)
	    m = cdfParseFloatString(m)
	)
	when(numberp(m) && plusp(m)
	    w = w * m
	)
    )

    leftCnts = leftCnts && leftCnts != "FALSE"
    rightCnts = rightCnts && rightCnts != "FALSE"
    splitting = splitting && splitting != "FALSE"

    ;; Since this code doesn't handle dogbone type contacts, make sure
    ;; we can at least get one contact in the width.
    minContDiff = 2 * doc + cw
    when(w < minContDiff
        w = minContDiff
    )

    ;; If we're getting passed a string, evalute it.
    when(stringp(l)
	l = cdfParseFloatString(l)
    )
    ;; Make sure were not getting a real small number caused by parsing
    ;; schematic strings containing unit letters at the end.
    when(l < .001
        l = l * 1e6
    )
    l = spcRound(l snapGrid)

    sourceCoverage = sourceCoverage * 0.01
    drainCoverage = drainCoverage * 0.01
    step = pcs + cw/2 + l/2
    ;-----------------------------------------------
    ; Catch the case where the poly to diffusion 
    ; spacing is greater then the extension of poly
    ; and set the poly pin width
    ;-----------------------------------------------
    if( pds >= pext then
        polyPinWidth = snapGrid
        placePin = w + 2 * pext
    else
        polyPinWidth = pext - pds
        placePin = w + 2 * pds
    )

    ;minCntW = (minNumCnts * (cw + cs)) - cs + (2 * doc)
    ;------------------------------------------------
    ; figure out how many fingers are required and the 
    ; corresponding width for threshold
    ;------------------------------------------------
    when(splitting && splitting != "FALSE"
	if( splitType == "Threshold" then
	  fingers = fix(w/threshold)
	  unless( float( fingers ) == (w/threshold)
	    fingers = fingers+1
	  )
	else
	  unless(plusp(fingers)
	    fingers = 1
	  )
	); if threshold
        w = fix( (w/fingers)/snapGrid ) * snapGrid
    ); when splitting
    ;-------------------------------------------------
    ; Create the first gate. The createGates procedure
    ; creates a gate with top and bottom pin.  The 
    ; procedure returns the gate id and the pin id's 
    ;
    ; list(gate list(topPin~>dbId~>pin bottomPin~>dbId~>pin) topPin bottomPin)
    ;-------------------------------------------------
    gate = createGates(cv l w+2*pext polyPinWidth placePin "G" poly
	    "gate.0") 
    ; this will go away when align with memory is fixed
    rodAlign(
	?alignObj nth(2 gate)
	?alignHandle "upperCenter"
	?refObj car(gate)
	?refHandle "upperCenter"
    )
    rodAlign(                           ; wai: add align to bottom gate pin
        ?alignObj nth(3 gate)
        ?alignHandle "lowerCenter"
        ?refObj car(gate)
        ?refHandle "lowerCenter"
    )

    gateGroup = nth(1 gate)
    gatePins = cons(gateGroup gatePins)
    ;-------------------------------------------
    ; build the mos device      
    ;-------------------------------------------
    cond(
      ( (!splitting || splitting == "FALSE")
        fingers = 1
        unless(leftCnts && leftCnts != "FALSE"
	  sourceCntPosition = "None" 
	)
        unless(rightCnts && rightCnts != "FALSE"
	  drainCntPosition = "None" 
	)

	;; createEnds returns a list of rod objects. The car of the list is
	;; rod id of the diffusion pins created. The cadr of the list is the
	;; rod id of metal1 pin created if contacts are being created.

        sfig = createEnds(cv contact sourceCntPosition snapGrid doc cw
	  pcs l dop car(gate) diff w "S" sourceCoverage metal1 cs 
	  m1oc step pext
	  0.0
          "centerRight" "centerLeft" "leftdiff" "contact.0" leftStretch
	  cons(list("left" "leftCnts" "G" "leftStretch") abutRule))

        dfig = createEnds(cv contact drainCntPosition snapGrid doc cw
          pcs l dop car(gate) diff w "D" drainCoverage metal1 cs
          m1oc -((fingers - 1) * 2 * step + step) pext
          ((fingers - 1) * 2 * step)
	  "centerLeft" "centerRight" "rightdiff" "contact.1" rightStretch
	  cons(list("right" "rightCnts" "G" "rightStretch") abutRule))
        gateExternal(cv gatePins )

      ); splitting is nil
      ( t 
        when(fingers == 1 fingers = 2)
        sfig = createSplitEnds(cv contact sourceCntPosition snapGrid doc cw
	  pcs l dop car(gate) diff w "S" sourceCoverage metal1 cs m1oc 
	  step pext 0.0 "centerRight" "centerLeft" leftCnts
          "leftdiff" "contact.0" leftStretch
	  cons(list("left" "leftCnts" "G" "leftStretch") abutRule))
        if((!leftCnts || leftCnts == "FALSE") then
	  ;; Make sure the diffusion pins gets connected.
	  dbExternallyConnectPins(list(sfig~>dbId~>pin))
	else
	  sourcePins = cons(car(sfig) sourcePins)
	  sourceShapes = cons(cadr(sfig) sourceShapes)
	  sourceShapes2 = cons(caddr(sfig) sourceShapes2)
	)
        for(i 1 fingers - 1
          contactname = strcat("contact." sprintf(nil "%n" i))
	  name = strcat("gate." sprintf(nil "%n" i))
	  stepGate = createGates(cv l w+2*pext polyPinWidth placePin "G"
            poly name)
          gateGroup = nth(1 stepGate)
	  gatePins = cons(gateGroup gatePins)
          rodAlign(
	    ?alignObj car(stepGate)
	    ?alignHandle "centerCenter"
	    ?refObj car(gate)
	    ?refHandle "centerCenter"
	    ?xSep step * 2  * i
          )
          ; soon as align gets memory the following two align commands will not
          ; be necessary
	  rodAlign(
	    ?alignObj nth(2 stepGate)
	    ?alignHandle "upperCenter"
	    ?refObj car(gate)
	    ?refHandle "upperCenter"
	    ?xSep step * 2 * i
	  )
	  rodAlign(
	    ?alignObj nth(3 stepGate)
	    ?alignHandle "lowerCenter"
	    ?refObj car(gate)
	    ?refHandle "lowerCenter"
	    ?xSep step * 2 * i
	  )
	  if(evenp(i) then
            cnt = createCnts(cv sourceCntPosition sourceCoverage metal1
		    contact m1oc cw cs w doc "S" snapGrid car(stepGate)
		    step pext contactname)
            sourcePins = cons(car(cnt) sourcePins)
	    sourceShapes = cons(cadr(cnt) sourceShapes)
	    sourceShapes2 = cons(caddr(cnt) sourceShapes2)
          else
            cnt = createCnts(cv drainCntPosition drainCoverage metal1
		    contact m1oc cw cs w doc "D" snapGrid car(stepGate)
		    step pext contactname)
            drainPins = cons(car(cnt) drainPins)
	    drainShapes = cons(cadr(cnt) drainShapes)
	    drainShapes2 = cons(caddr(cnt) drainShapes2)
          )
        );for
	if(evenp(fingers) then
          lastsfig = createSplitEnds(cv contact sourceCntPosition snapGrid
		doc cw pcs l dop car(gate) diff w "S" sourceCoverage metal1
		cs m1oc -((fingers - 1) * 2 * step + step)
            pext ((fingers - 1) * 2 * step) "centerLeft" "centerRight"
            rightCnts "rightdiff" strcat("contact." sprintf(nil "%n" fingers))
	    rightStretch cons(list("right" "rightCnts" "G" "rightStretch")
	    abutRule))
          if((!rightCnts || rightCnts == "FALSE") then
            ;; Make sure the diffusion pins gets connected.
            dbExternallyConnectPins(list(lastsfig~>dbId~>pin))
          else
	    sourcePins = cons(car(lastsfig) sourcePins)
	    sourceShapes = cons(cadr(lastsfig) sourceShapes)
	    sourceShapes2 = cons(caddr(lastsfig) sourceShapes2)
          )
	else
	  dfig = createSplitEnds(cv contact drainCntPosition snapGrid doc
	    cw pcs l dop car(gate) diff w "D" drainCoverage metal1 cs m1oc
	    -((fingers - 1) * 2 * step + step)
            pext ((fingers - 1) * 2 * step) "centerLeft" "centerRight"
	    rightCnts "rightdiff" strcat("contact." sprintf(nil "%n" fingers))
	    rightStretch cons(list("right" "rightCnts" "G" "rightStretch")
	    abutRule))
          if((!rightCnts || rightCnts == "FALSE") then
            ;; Make sure the diffusion pins gets connected.
            dbExternallyConnectPins(list(dfig~>dbId~>pin))
          else
	    drainPins = cons(car(dfig) drainPins)
	    drainShapes = cons(cadr(dfig) drainShapes)
	    drainShapes2 = cons(caddr(dfig) drainShapes2)
	  )
        )
        midfig = rodCreateRect(
	  ?cvId cv
	  ?name "midfig"
	  ?layer diff
	  ?width (2 * step) * (fingers - 1)
 	  ?length w
        )
        rodAlign(
	  ?alignObj midfig
	  ?alignHandle "centerLeft"
	  ?refObj car(gate)
	  ?refHandle "centerCenter"
        )
        when((leftCnts && leftCnts != "FALSE") ||
	    (evenp(fingers) && (rightCnts && rightCnts != "FALSE")) ||
	    fingers > 3
          makeExternal( sourcePins )
        )
        when((oddp(fingers) && (rightCnts && rightCnts != "FALSE")) ||
	    fingers > 2
          makeExternal( drainPins )
        )
        if( (!routePoly || routePoly == "FALSE") then
          gateExternal(cv gatePins )
        else
	  ;; We need a path here.
	  strap_width = (fingers - 1) * 2 * step + l
	  half_pw = pw*.5
	  polyfig = rodCreatePath(
	    ?cvId cv
	    ?layer poly
	    ?width pw
	    ?pts list(0:half_pw strap_width:half_pw)
	    ?termName "G"
	    ?pin t
	  )
          cond(
            ( routePolydir == "Top" 
 	      rodAlign(
	        ?alignObj polyfig
	        ?alignHandle "lowerLeft"
	        ?refObj nth(2 gate)
	        ?refHandle "upperLeft"
              )
            )
            ( routePolydir == "Bottom" 
	      rodAlign(
	        ?alignObj polyfig
	        ?alignHandle "upperLeft"
	        ?refObj nth(3 gate)
	        ?refHandle "lowerLeft"
	      )
            )
          )
	  spcClearGatePins( gatePins )
        );when routePoly

	if(bn == "S" then
	    if(tapPosition == "Top" then
		;; Route source on top.
		;; Route drain on bottom.
		sourceRouteSide = "Top"
		drainRouteSide = "Bottom"
	    else
		;; Route source on bottom.
		;; Route drain on top.
		sourceRouteSide = "Bottom"
		drainRouteSide = "Top"
	    )
	else
	    if(tapPosition == "Top" then
		;; Route source on bottom.
		;; Route drain on top.
		sourceRouteSide = "Bottom"
		drainRouteSide = "Top"
	    else
		;; Route source on top.
		;; Route drain on bottom.
		sourceRouteSide = "Top"
		drainRouteSide = "Bottom"
	    )
	)

        when(routeSD == "Source" || routeSD == "Source&Drain"
	  sourcesize = length(sourceShapes)
          sourceShapes = reverse(sourceShapes)
	  ypoint = ms + mw/2
	  when(sourcesize > 1
	    if(sourceRouteSide == "Top" then
	      metlist = list(car(rodGetHandle(nth(0 sourceShapes)
              "upperCenter")):0 
	      car(rodGetHandle(nth(0 sourceShapes) "upperCenter")):ypoint
	      car(rodGetHandle(nth(1 sourceShapes) "upperCenter")):ypoint
	      car(rodGetHandle(nth(1 sourceShapes) "upperCenter")):0)
	    else
	      metlist = list(car(rodGetHandle(nth(0 sourceShapes)
              "upperCenter")):0 
	      car(rodGetHandle(nth(0 sourceShapes) "upperCenter")):-ypoint
	      car(rodGetHandle(nth(1 sourceShapes) "upperCenter")):-ypoint
	      car(rodGetHandle(nth(1 sourceShapes) "upperCenter")):0)
	   )
	   intermetal = rodCreatePath(
	        ?cvId cv
		?name "firstSwire"
		?layer metal1
		?width mw
		?pts metlist
		?termName "S"
		?pin t
	  )
	  if(sourceRouteSide == "Top" then
	     rodAlign(
	       ?alignObj intermetal
	       ?alignHandle "start0"
	       ?refObj nth(0 sourceShapes)
	       ?refHandle "upperCenter"
	     )
	  else
	     rodAlign(
	       ?alignObj intermetal
	       ?alignHandle "start0"
	       ?refObj nth(0 sourceShapes)
	       ?refHandle "lowerCenter"
	     )
	  )
	  sourceMetals = cons(intermetal sourceMetals)

	  currPin = nth(0 sourceShapes2)~>dbId~>pin
	  nextPin = nth(1 sourceShapes2)~>dbId~>pin
	  dbStronglyConnectPins(list(currPin nextPin))
	  for(i 1 sourcesize - 2
	     xpnt = car(rodGetHandle(nth(i sourceShapes) "upperCenter"))
	     midxpnt = car(rodGetHandle(nth((i+1) sourceShapes) "upperCenter"))
	     if(sourceRouteSide == "Top" then
		metlist = list(xpnt:ypoint midxpnt:ypoint midxpnt:0)
	     else
		metlist = list(xpnt:-ypoint midxpnt:-ypoint midxpnt:0)
	     )
	     midmetal = rodCreatePath(
	        ?cvId cv
		?layer metal1
		?width mw
		?pts metlist
		?termName "S"
		?pin t
	     )
	     if(sourceRouteSide == "Top" then
	        rodAlign(
		  ?alignObj midmetal
		  ?alignHandle "start0"
		  ?refObj nth(i sourceShapes)
		  ?refHandle "upperCenter"
		  ?ySep ypoint
	        )
	     else
	        rodAlign(
		  ?alignObj midmetal
		  ?alignHandle "start0"
		  ?refObj nth(i sourceShapes)
		  ?refHandle "lowerCenter"
		  ?ySep -ypoint
	        )
	     )
	     sourceMetals = cons(midmetal sourceMetals)

	     currPin = nth(i sourceShapes2)~>dbId~>pin
	     nextPin = nth(i+1 sourceShapes2)~>dbId~>pin
	     when(currPin && nextPin
		  dbStronglyConnectPins(list(currPin nextPin))
	     )
          );for
	);when sourcesize
      );when routeSD == "Source"
      (when routeSD == "Drain" || routeSD == "Source&Drain"
	 ypoint = ms + mw/2
	 drainsize = length(drainShapes)
	 drainShapes = reverse(drainShapes)
         when(drainsize > 1
	    if(drainRouteSide == "Bottom" then
	      metlist = list(car(rodGetHandle(nth(0 drainShapes)
                "lowerCenter")):0 
	        car(rodGetHandle(nth(0 drainShapes) "lowerCenter")):-ypoint
	        car(rodGetHandle(nth(1 drainShapes) "lowerCenter")):-ypoint
	        car(rodGetHandle(nth(1 drainShapes) "lowerCenter")):0)
	    else
	      metlist = list(car(rodGetHandle(nth(0 drainShapes)
                "lowerCenter")):0 
	        car(rodGetHandle(nth(0 drainShapes) "lowerCenter")):ypoint
	        car(rodGetHandle(nth(1 drainShapes) "lowerCenter")):ypoint
	        car(rodGetHandle(nth(1 drainShapes) "lowerCenter")):0)
	    )
	    intermetal = rodCreatePath(
	        ?cvId cv
		?name "dwire.0"
		?layer metal1
		?width mw
		?pts metlist
		?termName "D"
		?pin t
	   )
	   if(drainRouteSide == "Bottom" then
	     rodAlign(
	       ?alignObj intermetal
	       ?alignHandle "start0"
	       ?refObj nth(0 drainShapes)
	       ?refHandle "lowerCenter"
	     )
	   else
	     rodAlign(
	       ?alignObj intermetal
	       ?alignHandle "start0"
	       ?refObj nth(0 drainShapes)
	       ?refHandle "upperCenter"
	     )
	   )
	   drainMetals = cons(intermetal drainMetals)

           currPin = nth(0 drainShapes2)~>dbId~>pin
           nextPin = nth(1 drainShapes2)~>dbId~>pin
           dbStronglyConnectPins(list(currPin nextPin))

	   for(i 1 drainsize - 2
	     xpnt = car(rodGetHandle(nth(i drainShapes) "lowerCenter"))
	     midxpnt = car(rodGetHandle(nth((i+1) drainShapes) "lowerCenter"))
             intername = strcat("dwire." sprintf(nil "%n" i))
	     if(drainRouteSide == "Bottom" then
		metlist = list(xpnt:-ypoint midxpnt:-ypoint midxpnt:0)  
	     else
		metlist = list(xpnt:ypoint midxpnt:ypoint midxpnt:0)  
	     )
	     midmetal = rodCreatePath(
	        ?cvId cv
	        ?name intername
		?layer metal1
		?width mw
		?pts metlist
		?termName "D"
		?pin t
	      )
	      if(drainRouteSide == "Bottom" then
	        rodAlign(
		  ?alignObj midmetal
		  ?alignHandle "start0"
		  ?refObj nth(i drainShapes)
		  ?refHandle "lowerCenter"
		  ?ySep -ypoint
	        )
	      else
	        rodAlign(
		  ?alignObj midmetal
		  ?alignHandle "start0"
		  ?refObj nth(i drainShapes)
		  ?refHandle "upperCenter"
		  ?ySep ypoint
	        )
	      )
	      drainMetals = cons(midmetal drainMetals)
 
              currPin = nth(i drainShapes2)~>dbId~>pin
              nextPin = nth(i+1 drainShapes2)~>dbId~>pin
	      when(currPin && nextPin
		  dbStronglyConnectPins(list(currPin nextPin))
	      )
          );for
	);when drainsize
      );when routeSD == "Drain"
      );t splitting
    );cond

    ;; Add the implant
    diffBBox = nil
    foreach(shp setof(shape cv~>shapes shape~>layer == diff)
	diffBBox = mergeBBoxes(shp~>bBox diffBBox)
    )

    when(implant && diffBBox
	impBBox = sizeBBox(diffBBox cadr(implant))
	rodCreateRect(
	    ?cvId cv
	    ?layer car(implant)
	    ?bBox impBBox
	)
    )

    ;; Add the tap.
    ;; tapRule = list(tapLayer tapOLcont tapDiffSpacing tapPolySpacing
    ;; list(tapImpLayer tapImpOLtap) list(wellLayer wellOLdiff wellOLtap))
    when(tapRule
    cond(
      ( (!splitting || splitting == "FALSE")
	if(bn == "S" then
	    ;; rodObj for gate topPin = caddr(gate)
	    ;; rodObj for source diff pin = car(sfig)
	    poly_left = xCoord(caddr(gate)~>upperLeft)
	    contMidX = poly_left - cadddr(tapRule) - cadr(tapRule) - cw*.5
	    if(tapPosition == "Top" then
		diff_top = yCoord(car(sfig)~>upperLeft)
		contMidY = diff_top + caddr(tapRule) + cadr(tapRule) + cw*.5
	    else
		diff_bot = yCoord(car(sfig)~>lowerRight)
		contMidY = diff_bot - caddr(tapRule) - cadr(tapRule) - cw*.5
	    )
	else   
	    ;; rodObj for gate bottomPin = cadddr(gate)
	    ;; rodObj for drain diff pin = car(dfig)
	    poly_right = xCoord(cadddr(gate)~>lowerRight)
	    contMidX = poly_right + cadddr(tapRule) + cadr(tapRule) + cw*.5
	    if(tapPosition == "Top" then
		diff_top = yCoord(car(sfig)~>upperLeft)
		contMidY = diff_top + caddr(tapRule) + cadr(tapRule) + cw*.5
	    else
		diff_bot = yCoord(car(sfig)~>lowerRight)
		contMidY = diff_bot - caddr(tapRule) - cadr(tapRule) - cw*.5
	    )
	)

	tapContObj = rodCreateRect(
	    ?cvId cv
	    ?name "tapContact"
	    ?layer contact
	    ?bBox sizeBBox(list(contMidX:contMidY contMidX:contMidY) cw*.5)
	    ?termName bn
	)
	tapDiffObj = rodCreateRect(
	    ?cvId cv
	    ?name "tapDiffusion"
	    ?layer car(tapRule)
	    ?bBox sizeBBox(tapContObj~>dbId~>bBox cadr(tapRule))
	    ?termName bn
	    ?pin t
	)
	when((tapImpRule = nth(4 tapRule))
	    rodCreateRect(
		?cvId cv
		?layer car(tapImpRule)
		?bBox sizeBBox(tapDiffObj~>dbId~>bBox cadr(tapImpRule))
	    )
	)
	tapMetObj = rodCreateRect(
	    ?cvId cv
	    ?name "tapMetal"
	    ?layer metal1
	    ?bBox sizeBBox(tapContObj~>dbId~>bBox m1oc)
	    ?termName bn
	    ?pin t
	)
	dbExternallyConnectPins(list(tapMetObj~>dbId~>pin))
      );splitting == "FALSE"
      ( t
	diff_left = xCoord(lowerLeft(diffBBox))
	diff_right = xCoord(upperRight(diffBBox))
	if(tapPosition == "Top" then
	    diff_top = yCoord(upperRight(diffBBox))
	    contMidY = diff_top + caddr(tapRule) + cadr(tapRule) + cw*.5

	    if(routePoly && routePoly != "FALSE" then
		if(routePolydir == "Top" then
		    ;; Make sure we clear the poly strap.
		    polyMidY = yCoord(polyfig~>upperRight) + pds +
			    cadr(tapRule) + cw*.5
		else
		    ;; rodObj for gate topPin = caddr(gate)
		    polyMidY = yCoord(caddr(gate)~>upperRight) + pds +
			    cadr(tapRule) + cw*.5
		)
            else
		;; rodObj for gate topPin = caddr(gate)
		polyMidY = yCoord(caddr(gate)~>upperRight) + pds +
			cadr(tapRule) + cw*.5
            )
	    when(polyMidY > contMidY
		contMidY = polyMidY
	    )
        else
	    diff_bot = yCoord(lowerLeft(diffBBox))
	    contMidY = diff_bot - caddr(tapRule) - cadr(tapRule) - cw*.5

	    if(routePoly && routePoly != "FALSE" then
		if(routePolydir == "Bottom" then
		    ;; Make sure we clear the poly strap.
		    polyMidY = yCoord(polyfig~>lowerLeft) - pds -
			    cadr(tapRule) - cw*.5
		else
		    ;; rodObj for gate bottomPin = cadddr(gate)
		    polyMidY = yCoord(cadddr(gate)~>lowerLeft) - pds -
			    cadr(tapRule) - cw*.5
		)
            else
		;; rodObj for gate bottomPin = cadddr(gate)
		polyMidY = yCoord(cadddr(gate)~>lowerLeft) - pds -
			cadr(tapRule) - cw*.5
            )
	    when(polyMidY < contMidY
		contMidY = polyMidY
	    )
        )
 
	;; Create tap between diff_left and diff_right centered on contMidY.
        tapDiffObj = rodCreateRect(
	    ?cvId cv
            ?name "tapDiffusion"
            ?layer car(tapRule)
            ?bBox list(diff_left:contMidY - cadr(tapRule) - cw*.5
		    diff_right:contMidY + cadr(tapRule) + cw*.5)
            ?termName bn
            ?pin t
	)

	when((tapImpRule = nth(4 tapRule))
	    rodCreateRect(
		?cvId cv
		?layer car(tapImpRule)
		?bBox sizeBBox(tapDiffObj~>dbId~>bBox cadr(tapImpRule))
	    )
	)

        tapMetObj = rodCreatePath(
	    ?cvId cv
            ?name "tapMetal"
            ?layer metal1
	    ?termName bn
	    ?width cw+2*m1oc
            ?endType "offset"
            ?pts list(diff_left+doc+cw*.5:contMidY
		diff_right-doc-cw*.5:contMidY)
	    ?subRect list(
		;; Left contact path
		list(
		    ?layer          contact
		    ?width          cw
		    ?length         cw
		    ?space          cs
		    ?sep            0.0
		    ?beginOffset    cw*.5
		    ?endOffset      cw*.5
		)
	    )
        )
	tapMetPinObj = rodCreateRect(
	    ?cvId cv
	    ?name "tapMetalPin"
	    ?layer metal1
	    ?termName bn
	    ?pin t
	    ?bBox list(tapMetObj~>lowerLeft tapMetObj~>upperRight)
	)

        if(bn == "S" then
	    tmpRodObj = nil
	    when(routeSD == "Source" || routeSD == "Source&Drain" &&
		    sourcesize > 1
		;; Check metal1 space between tap and source strap.
		tmpBBox = nil
		foreach(dmet sourceMetals
		    tmpBBox = mergeBBoxes(dmet~>dbId~>bBox tmpBBox)
		)
		
		when(tmpBBox
		    if(tapPosition == "Top" then
			when((tmpNum = yCoord(tapMetObj~>lowerLeft) -
				yCoord(upperRight(tmpBBox))) && plusp(tmpNum)
				&& tmpNum < ms
			    tmpRodObj = rodCreateRect(
				?cvId cv
				?layer metal1
				?bBox list(list(xCoord(lowerLeft(tmpBBox))
					yCoord(upperRight(tmpBBox))) list(
					xCoord(upperRight(tmpBBox))
					yCoord(tapMetObj~>lowerLeft)))
				?termName bn
			    )
			)
		    else
			when((tmpNum = yCoord(lowerLeft(tmpBBox)) -
				yCoord(tapMetObj~>upperRight)) && plusp(tmpNum)
				&& tmpNum < ms
			    tmpRodObj = rodCreateRect(
				?cvId cv
				?layer metal1
				?bBox list(list(xCoord(lowerLeft(tmpBBox))
					yCoord(tapMetObj~>upperRight)) list(
					xCoord(upperRight(tmpBBox))
					yCoord(lowerLeft(tmpBBox))))
				?termName bn
			    )
			)
		    )
		)
	    )
	    unless(tmpRodObj
		dbExternallyConnectPins(list(tapMetPinObj~>dbId~>pin))
	    )
	else
	    tmpRodObj = nil
	    when(routeSD == "Drain" || routeSD == "Source&Drain" &&
		    drainsize > 1
		
		;; Check metal1 space between tap and drain strap.
		tmpBBox = nil
		foreach(dmet drainMetals
		    tmpBBox = mergeBBoxes(dmet~>dbId~>bBox tmpBBox)
		)
                when(tmpBBox
		    if(tapPosition == "Bottom" then
			when((tmpNum = yCoord(lowerLeft(tmpBBox)) -
				yCoord(tapMetObj~>upperRight)) && plusp(tmpNum)
				&& tmpNum < ms
			    tmpRodObj = rodCreateRect(
				?cvId cv
				?layer metal1
				?bBox list(list(xCoord(lowerLeft(tmpBBox))
					yCoord(tapMetObj~>upperRight)) list(
					xCoord(upperRight(tmpBBox))
					yCoord(lowerLeft(tmpBBox))))
				?termName bn
				?pin t
			    )
			)
		    else
			when((tmpNum = yCoord(tapMetObj~>lowerLeft) -
				yCoord(upperRight(tmpBBox))) && plusp(tmpNum)
				&& tmpNum < ms
			    tmpRodObj = rodCreateRect(
				?cvId cv
				?layer metal1
				?bBox list(list(xCoord(lowerLeft(tmpBBox))
					yCoord(upperRight(tmpBBox))) list(
					xCoord(upperRight(tmpBBox))
					yCoord(tapMetObj~>lowerLeft)))
				?termName bn
				?pin t
			    )
			)
		    )
                )
	    )
	    unless(tmpRodObj
		dbExternallyConnectPins(list(tapMetPinObj~>dbId~>pin))
	    )
	)
      );splitting == "TRUE"
    );cond
    );when tapRule

    ;; Add the well
    when(diffBBox && wellRule
	wellBBox = mergeBBoxes(sizeBBox(diffBBox cadr(wellRule))
		sizeBBox(tapDiffObj~>dbId~>bBox caddr(wellRule)))
	rodCreateRect(
	    ?cvId cv
	    ?name "well"
	    ?layer car(wellRule)
	    ?bBox wellBBox
	)
    )

    spcMakeRectPins(cv)

    t
))

procedure(createCnts(cvId position coverage metal1 contact m1oc cw cs
        w doc terminal snapGrid gate step pext name)
 
  let((length oriX oriY mcnt cnt minLength)
 
    length = ((w - (2 * (doc - m1oc))) * coverage/snapGrid) + .00001
    minLength = cw + (2 * m1oc) + .00001 
    when(length < minLength 
      length = minLength
    )
    length = fix(length) *  snapGrid

    oriX = oriY = 0

    mcnt = rodCreatePath(
      ?cvId cvId
      ?layer metal1
      ?termName terminal
      ?width 2 * m1oc + cw
      ?pts list(oriX:oriY oriX:length)
      ?subRect list( list(
         ?layer contact
         ?length cw
         ?width cw
         ?space cs
         ?endOffset -m1oc
      ))
    )
    cnt = rodCreateRect(
	?cvId cvId
	?name name
	?layer metal1
	?termName terminal
	?pin t
	?bBox list(mcnt~>lowerLeft mcnt~>upperRight)
    )

    case( position
      ("Top"
	foreach(met_cnt list(mcnt cnt)
	    rodAlign(
	      ?alignObj met_cnt
	      ?alignHandle "upperCenter"
	      ?refObj gate
	      ?refHandle "upperCenter"
	      ?xSep -step
	      ?ySep m1oc - doc - pext
	    )
        )
      )
      ("Bottom"
	foreach(met_cnt list(mcnt cnt)
	    rodAlign(
	      ?alignObj met_cnt
	      ?alignHandle "lowerCenter"
	      ?refObj gate
	      ?refHandle "lowerCenter"
	      ?xSep -step
	      ?ySep  pext + doc - m1oc
	    )
        )
      )
      ("Center"
	foreach(met_cnt list(mcnt cnt)
	    rodAlign(
	      ?alignObj met_cnt
	      ?alignHandle "centerCenter"
	      ?refObj gate
	      ?refHandle "centerCenter"
	      ?xSep -step
	    )
	)
      )
    );case

    list(cnt~>dbId~>pin mcnt cnt)
))

procedure(createEnds(cvId contact cntPosition snapGrid doc cw pcs l
	dop gate diff w terminal coverage metal1 cs m1oc step pext placeMos
	orient gateorient name contactname stretchRule abutRule)
    let(( pinWidth width diffRodObj met1RodObj metal_obj metal_x diff_off
	    diff_miny diff_maxy extraDiffWidth extraDiffRodObj )

	if(cntPosition == "None" then
	    ;width = dop + l/2
	    ;pinWidth = 2 * snapGrid
	    width = stretchRule + l/2
	    pinWidth = stretchRule

	    diffRodObj = createMos(cvId diff w width pinWidth terminal l
		    gate placeMos orient gateorient name snapGrid)
	    when(abutRule && car(abutRule) && cdr(abutRule)
		dbReplaceProp(diffRodObj~>dbId "abutAccessDir" "list"
			list(car(car(abutRule))))
		dbReplaceProp(diffRodObj~>dbId "abutCondInclusion" "string"
			cadr(car(abutRule)))
		dbReplaceProp(diffRodObj~>dbId "abutGateNet" "string"
			caddr(car(abutRule)))
		dbReplaceProp(diffRodObj~>dbId "abutStretchMat" "list"
		    list(cadddr(car(abutRule))
			;; default
			list("abutCurrExt" car(cdr(abutRule)))
			;; minEnclosure diff gate
			list("abutMinExt" cadr(cdr(abutRule)))
			;; minSpacing gate
			list("abutRule1Ext" caddr(cdr(abutRule)))
			;; minSpacing gate diff
			list("abutRule2Ext" cadddr(cdr(abutRule)))
			;; minEnclosure diff gate with contact
			list("abutContactExt" car(cddddr(cdr(abutRule))))
		    )
		)
	    )
	    dbExternallyConnectPins(list(diffRodObj~>dbId~>pin))

	    list(diffRodObj)
	else
	    ;width = doc + cw + pcs + l/2
	    ;pinWidth = doc + cw + pcs
	    width = stretchRule + l/2
	    pinWidth = stretchRule
	    ;; createMos returns the rodObj id of the diffusion pin created.
	    diffRodObj = createMos(cvId diff w width pinWidth terminal l
		    ;gate placeMos orient gateorient strcat(name "_str")
		    gate placeMos orient gateorient name
		    snapGrid)
            when(abutRule && car(abutRule) && cdr(abutRule)
                dbReplaceProp(diffRodObj~>dbId "abutAccessDir" "list"
                        list(car(car(abutRule))))
                dbReplaceProp(diffRodObj~>dbId "abutCondInclusion" "string"
                        cadr(car(abutRule)))
                dbReplaceProp(diffRodObj~>dbId "abutGateNet" "string"
                        caddr(car(abutRule)))
                dbReplaceProp(diffRodObj~>dbId "abutStretchMat" "list"
                    list(cadddr(car(abutRule))
                        ;; default
                        list("abutCurrExt" car(cdr(abutRule)))
                        ;; minEnclosure diff gate
                        list("abutMinExt" cadr(cdr(abutRule)))
                        ;; minSpacing gate
                        list("abutRule1Ext" caddr(cdr(abutRule)))
                        ;; minSpacing gate diff
                        list("abutRule2Ext" cadddr(cdr(abutRule)))
                        ;; minEnclosure diff gate with contact
                        list("abutContactExt" car(cddddr(cdr(abutRule))))
                    )
                )
            )
	    met1RodObj = createCnts(cvId cntPosition coverage metal1
		    contact m1oc cw cs w doc terminal snapGrid gate
		    step pext contactname)
	    dbExternallyConnectPins(list(car(met1RodObj)))

	    ;; Build diffusion for contact as a workaround for device
	    ;; abutment.
	    metal_obj = cadr(met1RodObj)
	    metal_x = xCoord(metal_obj~>startCenter0)
	    diff_off = cw*.5 + doc
	    diff_miny = yCoord(diffRodObj~>lowerLeft)
	    diff_maxy = yCoord(diffRodObj~>upperRight)

	    list(diffRodObj met1RodObj)
	);cond
    )
)

procedure(createSplitEnds(cvId contact cntPosition snapGrid doc cw pcs l
        dop gate diff w terminal coverage metal1 cs m1oc step pext placeMos
        orient gateorient cnts name contactname stretchRule abutRule)
 
  let(( diffPinWidth diffRodObj width metal_obj metal_x diff_off diff_miny
	diff_maxy extraDiffWidth )
    cnts = cnts && cnts != "FALSE"
    cond(
      ( cnts
        ;width = doc + cw + pcs + l/2
	;diffPinWidth = doc + cw + pcs
        width = stretchRule + l/2
	diffPinWidth = stretchRule
        diffRodObj = createMos(cvId diff w width diffPinWidth terminal l
		gate placeMos orient gateorient strcat(name "_str")
		snapGrid)

        when(abutRule && car(abutRule) && cdr(abutRule)
            dbReplaceProp(diffRodObj~>dbId "abutAccessDir" "list"
                    list(car(car(abutRule))))
            dbReplaceProp(diffRodObj~>dbId "abutCondInclusion" "string"
                    cadr(car(abutRule)))
            dbReplaceProp(diffRodObj~>dbId "abutGateNet" "string"
                    caddr(car(abutRule)))
            dbReplaceProp(diffRodObj~>dbId "abutStretchMat" "list"
                list(cadddr(car(abutRule))
                    ;; default
                    list("abutCurrExt" car(cdr(abutRule)))
                    ;; minEnclosure diff gate
                    list("abutMinExt" cadr(cdr(abutRule)))
                    ;; minSpacing gate
                    list("abutRule1Ext" caddr(cdr(abutRule)))
                    ;; minSpacing gate diff
                    list("abutRule2Ext" cadddr(cdr(abutRule)))
		    ;; minEnclosure diff gate with contact
		    list("abutContactExt" car(cddddr(cdr(abutRule))))
                )
            )
        )

	;; Return a list containing the metal pin dbId and
	;; the ROD id for metal path/pin.
        met1RodObj = createCnts(cvId cntPosition coverage metal1 contact
		m1oc cw cs w doc terminal snapGrid gate step pext contactname)

	;; Build diffusion for contact as a workaround for device
	;; abutment.
	metal_obj = cadr(met1RodObj)
	metal_x = xCoord(metal_obj~>startCenter0)
	diff_off = cw*.5 + doc
	diff_miny = yCoord(diffRodObj~>lowerLeft)
	diff_maxy = yCoord(diffRodObj~>upperRight)
	rodCreateRect(
	    ?cvId cvId
	    ?name name
	    ?layer diff
	    ?bBox list( metal_x-diff_off:diff_miny
		metal_x+diff_off:diff_maxy )
	    ?length w
	    ?termName terminal
	    ?pin t
	)

	met1RodObj
      )
      ( !cnts
        ;width = dop + l/2
	;diffPinWidth = 2 * snapGrid
        width = stretchRule + l/2
	diffPinWidth = stretchRule

	;; Return ROD id for the mos pin.
        diffRodObj = createMos(cvId diff w width diffPinWidth terminal l
		gate placeMos orient gateorient name snapGrid)

	when(abutRule && car(abutRule) && cdr(abutRule)
	    dbReplaceProp(diffRodObj~>dbId "abutAccessDir" "list"
		    list(car(car(abutRule))))
	    dbReplaceProp(diffRodObj~>dbId "abutCondInclusion" "string"
		    cadr(car(abutRule)))
	    dbReplaceProp(diffRodObj~>dbId "abutGateNet" "string"
		    caddr(car(abutRule)))
	    dbReplaceProp(diffRodObj~>dbId "abutStretchMat" "list"
		list(cadddr(car(abutRule))
		    ;; default
		    list("abutCurrExt" car(cdr(abutRule)))
		    ;; minEnclosure diff gate
		    list("abutMinExt" cadr(cdr(abutRule)))
		    ;; minSpacing gate
		    list("abutRule1Ext" caddr(cdr(abutRule)))
		    ;; minSpacing gate diff
		    list("abutRule2Ext" cadddr(cdr(abutRule)))
		    ;; minEnclosure diff gate with contact
		    list("abutContactExt" car(cddddr(cdr(abutRule))))
		)
	    )
	)

	diffRodObj
      )
    );cond
))


procedure(createGates(cvId l length polyPinWidth placePin terminal poly name)
 
  let((gate topPin bottomPin dbId)
 
    gate = rodCreateRect(
        ?cvId cvId
	?name name
        ?layer poly
        ?width l
        ?length length
        ?origin (-.5*l):(-.5*length)    ; wai: channel centered at 0:0
	?termName "G"
    )

    ;; Terminal label that shows connected net name.
    ;; These labels make the bBox of the instance offGrid.
;    dbId = dbCreateLabel( cvId "text" gate~>centerCenter
;            sprintf(nil "lxLab(\"%s\")" terminal) "centerCenter"
;            "R90" "stick" .5 )
;    dbId~>labelType = "ILLabel"

    ;;Hierarchical Extraction (lxBlockOverlapCheck on poly).
    dbReplaceProp(gate~>dbId "lxBlockOverlapCheck" "boolean" t)

    ;;Must Connect.
    topPin = rodCreateRect(
        ?cvId cvId
        ?layer poly
        ?width l
        ?length polyPinWidth
        ?termName terminal
	?pin t
	?pinAccessDir list("left" "top" "right")
    )
    bottomPin = rodCreateRect(
        ?cvId cvId
        ?layer poly
        ?width l
        ?length polyPinWidth
        ?termName terminal
	?pin t
	?pinAccessDir list("left" "bottom" "right")
    )

    rodAssignHandleToParameter(
            ?parameter 'w
            ?displayName "width"
            ?displayExpression "w"
            ?rodObj topPin
            ?handleName 'upperCenter
            ?stretchDir 'y
            ?stretchType "relative"
            ?moveOrigin nil
            ?userFunction 'mosStretchCB
    )
    rodAssignHandleToParameter(
            ?parameter 'w
            ?displayName "width"
            ?displayExpression "w"
            ?rodObj bottomPin
            ?handleName 'lowerCenter
            ?stretchDir 'y
            ?stretchType "relative"
            ?moveOrigin nil
            ?userFunction 'mosStretchCB
    )
    rodAssignHandleToParameter(
            ?parameter 'l
            ?displayName "length"
            ?displayExpression "l"
            ?rodObj gate
            ?handleName 'centerLeft
            ?stretchDir 'x
            ?stretchType "relative"
            ?moveOrigin nil
            ?userFunction 'mosStretchCB
    )
    rodAssignHandleToParameter(
            ?parameter 'l
            ?displayName "length"
            ?displayExpression "l"
            ?rodObj gate
            ?handleName 'centerRight
            ?stretchDir 'x
            ?stretchType "relative"
            ?moveOrigin nil
            ?userFunction 'mosStretchCB
    )

    list(gate list(list(topPin) list(bottomPin)) topPin bottomPin)
))

procedure(createMos(cvId diff w width ext terminal l gate placeMos orient
	gateorient name snapGrid)
/* this function builds a diffusion rectangle that can be
used either for the source or drain along with a pin.
The figure is added to the net and then the pin and the figures are
aligned to the gate.  This function returns the pin.
*/
  let((fig pin dbId pinw pplaceMos)
 
    fig = rodCreateRect(
	?cvId cvId
	?name name
        ?layer diff
        ?width width
        ?length w
	?termName terminal
    )

    if(zerop(ext) then
	pinw = 2 * snapGrid
        pplaceMos = (cond ((orient=="centerLeft") placeMos - pinw)
                        ((orient=="centerRight") placeMos + pinw))
    else
	pinw = ext
	pplaceMos = placeMos
    )
    pin = rodCreateRect(
	?cvId cvId
        ?layer diff
        ?width pinw
        ?length w
        ?termName terminal
	?pin t
        ?pinAccessDir (cond ((orient=="centerLeft") "right") ; wai: accessDir
                            ((orient=="centerRight") "left")
                            (t "any"))
    )

;    dbCreateLabel( pin~>cvId "text"
;	    list((cond ((orient=="centerLeft") 1)
;                            ((orient=="centerRight") -1)
;                            (t 0)) 0) sprintf(nil "%s %L"
;	    terminal (cond ((orient=="centerLeft") "right")
;                            ((orient=="centerRight") "left")
;                            (t "any")))
;	    "centerCenter" "R90" "stick" 1.0)
 
    rodAlign(
        ?alignObj pin
        ?alignHandle orient
        ?refObj gate
        ?refHandle gateorient 
        ?xSep pplaceMos
    )
    rodAlign(
	?alignObj fig
	?alignHandle orient
	?refObj gate
	?refHandle "centerCenter"
	?xSep placeMos
    )

    ;; Terminal label that shows connected net name.
    ;; These labels make the bBox of the instance offGrid.
;    dbId = dbCreateLabel( cvId "text" fig~>centerCenter
;	    sprintf(nil "lxLab(\"%s\")" terminal) "centerCenter"
;	    "R90" "stick" .5 )
;    dbId~>labelType = "ILLabel"

    ;;Hierarchical Extraction (lxBlockExtractCheck on diff).
    dbReplaceProp(fig~>dbId "lxBlockExtractCheck" "boolean" t)

    pin
))

procedure(makeExternal( pinlist )
  let(( sizelist pin )
    sizelist = length(pinlist)
    for(i 0 sizelist - 2
      pin = nth(i pinlist)
      dbExternallyConnectPins(list(pin))
    )
  )
)

procedure(gateExternal(cv pinlist )
    spcBuildNetHier(cv "G" pinlist t "input")
)

;; We need to find out how many fingers we have so the width will
;; increment correctly.
procedure(mosStretchCB(spcInfo)
    let(( (paramValue spcInfo->paramVal) (handleName spcInfo->handleName)
            (increment spcInfo->increment) string_var paramValueNum
	    numFingers )

;fprintf(stderr "handleName = %L\n" handleName)
;fprintf(stderr "increment = %L\n" increment)
;fprintf(stderr "paramValue = %L\n" paramValue)
 
        if(stringp(paramValue) then
            string_var = t
            paramValueNum = spcParseFloatString(paramValue)
        else
            paramValueNum = paramValue
        )
        when(paramValueNum < .001
            paramValueNum = paramValueNum * 1e6
        )
 
;fprintf(stderr "paramValueNum = %L\n" paramValueNum)
 
        numFingers = spcInfo->origInstId~>fingers || 1
 
        case(handleName
            ("upperCenter"
                newValue = spcRound((paramValueNum + (increment * numFingers))
                        .001)
            )
            ("lowerCenter"
                newValue = spcRound((paramValueNum + (increment * numFingers))
                        .001)
            )
            ("centerLeft"
                newValue = spcRound((paramValueNum + (increment * numFingers))
                        .001)
            )
            ("centerRight"
                newValue = spcRound((paramValueNum + (increment * numFingers))
                        .001)
            )
            (t
                newValue = paramValueNum
            )
        )
        if(plusp(newValue) then
            when(string_var
                sprintf(newValue "%gu" newValue)
            )
        else
            newValue = paramValue
        )
 
        when(string_var
            sprintf(newValue "%gu" newValue)
        )
 
;fprintf(stderr "newValue = %L\n \n" newValue)

        newValue
    )
)

