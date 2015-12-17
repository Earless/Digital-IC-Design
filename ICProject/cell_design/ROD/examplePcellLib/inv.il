;***********     inv.il        ****************
;Last REVISION 12/29/97 10:20 pdt

procedure(invBuild(cv nw nl nf pw pl pf supw h 
	hGrid tfId well pwell ndiff pdiff poly contact metal1 m1w m1s cw cs
 	m1oc pext poc ndoc pdoc wpe wne pwpe pwne ndop pdop pcs pnds ppds
	ndnds pdpds snapGrid ppw substrateCnts)

let((nmosId pmosId nsplit ncontacts nrightCnts nleftCnts psplit pcontacts
     prightCnts pleftCnts nxpnt pxpnt cellw dds gndpin vddpin nwell pwell
     xdist namepath lastgatepnt polyfig metfig contfig ypnt gatename xpnt
     gndypnt vddypnt metname gndxpnt vddxpnt maxpnt ptlist fig nypnt pypnt
     xcnt contdist hgridp pathpnts nInst pInst nInstList pInstList
     n_rightdiff n_leftdiff p_rightdiff p_leftdiff 
    )

   h = spcParseFloatString(h)
   hGrid = spcParseFloatString(hGrid)
   supw = spcRound(spcParseFloatString(supw) snapGrid)
   ;--------------------------------
   ; device definition section
   ;--------------------------------
   nmosId = dbOpenCellViewByType(cv~>lib "spcnmos" "layout")
   pmosId = dbOpenCellViewByType(cv~>lib "spcpmos" "layout")
 
   when(stringp(nw)
       nw = spcParseFloatString(nw)
   )
   when(stringp(nl)
       nl = spcParseFloatString(nl)
   )
   when(stringp(pw)
       pw = spcParseFloatString(pw)
   )
   when(stringp(pl)
       pl = spcParseFloatString(pl)
   )
   when(nw < .001
       nw = nw * 1e6
   )
   when(nl < .001
       nl = nl * 1e6
   )
   when(pw < .001
       pw = pw * 1e6
   )
   when(pl < .001
       pl = pl * 1e6
   )

   ;--------------------------------
   ; transistor parameter setting 
   ;--------------------------------
   if( nf == 1 then
     nsplit = nil
     nrightCnts = t
     nleftCnts = t
   else 
     nsplit = t
     nrightCnts = t
     nleftCnts = t
   )
     nInstList = list(
	list("w" "float" nw)
	list("l" "float" nl)
	list("splitting" "boolean" nsplit)
	list("fingers" "int" nf)
	list("sourceCntPosition" "string" "Top")
	list("drainCntPosition" "string" "Top") 
	list("rightCnts" "boolean" nrightCnts)
	list("leftCnts" "boolean" nleftCnts)
	;list("routeSD" "string" "Drain")		;; Is this needed ?
	list("substrateCnts" "boolean" substrateCnts)
	list("substrateCntPosition" "string" "Bottom")
	list("substrateWell" "boolean" t)
	list("leftStretch" "float" nmosId~>maxStretch)
	list("rightStretch" "float" nmosId~>maxStretch)
     )
   nInst = dbCreateParamInst(cv nmosId "nmos" 0:0 "R0" 1 nInstList)

   if( pf == 1 then
      psplit = nil
      prightCnts = t
      pleftCnts = t
   else
      psplit = t
      prightCnts = t
      pleftCnts = t
   )
     pInstList = list(
	list("w" "float" pw)
	list("l" "float" pl)
	list("splitting" "boolean" psplit)
	list("fingers" "int" pf)
	list("sourceCntPosition" "string" "Top")
	list("drainCntPosition" "string" "Top")
	list("rightCnts" "boolean" prightCnts)
	list("leftCnts" "boolean" pleftCnts)
        ;list("routeSD" "string" "Source")              ;; Is this needed ?
	list("substrateCnts" "boolean" substrateCnts)
	list("substrateCntPosition" "string" "Top")
	list("substrateWell" "boolean" t)
	list("leftStretch" "float" nmosId~>maxStretch)
	list("rightStretch" "float" nmosId~>maxStretch)
     )
   pInst = dbCreateParamInst(cv pmosId "pmos" 0:0 "R0" 1 pInstList)

 when((n_rightdiff = rodGetObj("nmos/rightdiff" cv)) &&
	(n_leftdiff = rodGetObj("nmos/leftdiff" cv)) &&
	(p_rightdiff = rodGetObj("pmos/rightdiff" cv)) &&
	(p_leftdiff = rodGetObj("pmos/leftdiff" cv))
   ;--------------------------------------
   ; get cell width
   ;--------------------------------------
   nxpnt = car(n_rightdiff~>lowerRight) -
           car(n_leftdiff~>lowerLeft)
   pxpnt = car(p_rightdiff~>upperRight) -
           car(p_leftdiff~>upperLeft)

   cellw = max( nxpnt pxpnt) 
   if(nxpnt >= pxpnt then
     dds = ndnds
   else
     dds = pdpds
   )
   ;------------------------------------
   ; rounding to hGrid 
   ;------------------------------------
   hgridp = fix(cellw/hGrid)
   unless( float( hgridp ) == (cellw/hGrid)
       hgridp = hgridp + 1
   )
   cellw = hgridp * hGrid   

   ;--------------------------------
   ; build gnd pin
   ;--------------------------------
   when((gndpin = rodCreateRect(?cvId cv
	?layer metal1
	?width cellw + dds
	?length supw
        ?pin t
        ?termName "gnd"
   ) ) &&
   ;-------------------------------
   ; top pin is vdd
   ;--------------------------------
   (vddpin = rodCreateRect(?cvId cv
	?layer metal1
	?width cellw + dds
	?length supw
	?pin t
	?termName "vdd"
   ))

    rodAssignHandleToParameter(
	    ?parameter 'h
	    ?displayName "Cell Height"
	    ?displayExpression "h"
	    ?rodObj vddpin
	    ?handleName 'upperCenter
	    ?stretchDir 'y
	    ?stretchType "relative"
	    ?moveOrigin t
	    ?userFunction 'invStretchCB
    )
    rodAssignHandleToParameter(
            ?parameter 'hGrid
            ?displayName "Cell Width"
            ?displayExpression "hGrid"
            ?rodObj vddpin
            ?handleName 'centerLeft
            ?stretchDir 'x
            ?stretchType "relative"
            ?moveOrigin t
            ?userFunction 'invStretchCB
    )
    rodAssignHandleToParameter(
            ?parameter 'hGrid
            ?displayName "Cell Width"
            ?displayExpression "hGrid"
            ?rodObj vddpin
            ?handleName 'centerRight
            ?stretchDir 'x
            ?stretchType "relative"
            ?moveOrigin t
            ?userFunction 'invStretchCB
    )

    rodAssignHandleToParameter(
	    ?parameter 'h
	    ?displayName "Cell Height"
	    ?displayExpression "h"
	    ?rodObj gndpin
	    ?handleName 'lowerCenter
	    ?stretchDir 'y
	    ?stretchType "relative"
	    ?moveOrigin t
	    ?userFunction 'invStretchCB
    )
    rodAssignHandleToParameter(
            ?parameter 'hGrid
            ?displayName "Cell Width"
            ?displayExpression "hGrid"
            ?rodObj gndpin
            ?handleName 'centerLeft
            ?stretchDir 'x
            ?stretchType "relative"
            ?moveOrigin t
            ?userFunction 'invStretchCB
    )
    rodAssignHandleToParameter(
            ?parameter 'hGrid
            ?displayName "Cell Width"
            ?displayExpression "hGrid"
            ?rodObj gndpin
            ?handleName 'centerRight
            ?stretchDir 'x
            ?stretchType "relative"
            ?moveOrigin t
            ?userFunction 'invStretchCB
    )

   ;-------------------------------
   ; align vdd pin to gnd pin
   ;-------------------------------
   rodAlign(
	?alignObj vddpin
	?alignHandle "upperCenter"
	?refObj gndpin
	?refHandle "lowerCenter"
	?ySep h
   )
   ;------------------------------
   ; place mos devices
   ;------------------------------
   if(nf == 1 then 
	 rodAlign(
	    ?alignObj rodGetObj("nmos/rightdiff" cv)
	    ?alignHandle "lowerLeft"
	    ?refObj gndpin
	    ?refHandle "upperCenter"
	    ?ySep m1s - (ndoc - m1oc)
	 )
   else
	 rodAlign(
	    ?alignObj rodGetObj("nmos/midfig" cv)
	    ?alignHandle "lowerCenter"
	    ?refObj gndpin
	    ?refHandle "upperCenter"
	    ?ySep m1s - (ndoc - m1oc)
	 )
   ) 
   if(pf == 1 then
	 rodAlign(
	    ?alignObj rodGetObj("pmos/rightdiff" cv)
	    ?alignHandle "upperLeft"
	    ?refObj vddpin
	    ?refHandle "lowerCenter"
	    ?ySep -(m1s - (pdoc - m1oc))
	 )
   else
	 rodAlign(
	    ?alignObj rodGetObj("pmos/midfig" cv)
	    ?alignHandle "upperCenter"
	    ?refObj vddpin
	    ?refHandle "lowerCenter"
	    ?ySep -(m1s - (pdoc - m1oc))
	 )
   ))


   ;-------------------------------
   ; get points of the fet with the
   ; most fingers
   ;-------------------------------
   if(nf >= pf then
     xdist = ndnds/2
     contdist = xdist + ndoc + cw/2
     namepath = strcat("nmos/gate." sprintf(nil "%n" nf-1))
     ;lastgatepnt = car(rodGetObj(namepath cv)~>lowerRight)
     lastgatepnt = rodPointX(rodGetObj(namepath cv)~>lowerRight)
   else
     xdist = pdpds/2
     contdist = xdist + pdoc + cw/2
     namepath = strcat("pmos/" "gate." sprintf(nil "%n" pf-1))
     ;lastgatepnt = car(rodGetObj(namepath cv)~>upperRight)
     lastgatepnt = rodPointX(rodGetObj(namepath cv)~>upperRight)
   )
   ;--------------------------------
   ; add input pin 
   ;--------------------------------
   pathpnts = list(contdist:((h + cw + 2 * poc + snapGrid/100)/2)    
		   contdist:((h - (cw + 2 * poc + snapGrid/100))/2)
              )
   polyfig = cadr(buildCnts(cv poly metal1 contact cw+2*poc cw cw pathpnts "in" 
		t poc-m1oc -poc  nil))
   ;--------------------------------
   ; wire gates
   ;--------------------------------
   ;ypnt = cadr(polyfig~>centerRight)
   ypnt = rodPointY(polyfig~>centerRight)
   rodCreatePath(
	?layer poly
	?width ppw
	?pts list(polyfig~>centerRight 
		lastgatepnt:ypnt)
   )
   for(i 0 nf - 1
     gatename = strcat("nmos/gate." sprintf(nil "%n" i))
     xpnt = car(rodGetObj(gatename cv)~>lowerCenter)
     rodCreatePath(
	?layer poly
	?pts list(rodGetObj(gatename cv)~>lowerCenter xpnt:ypnt)
     )
   )
   for(i 0 pf - 1
     gatename = strcat("pmos/gate." sprintf(nil "%n" i))
     xpnt = car(rodGetObj(gatename cv)~>upperCenter)
     rodCreatePath(
	?layer poly
	?pts list(rodGetObj(gatename cv)~>upperCenter xpnt:ypnt)
     )
   )
   ;--------------------------------
   ; wire diffusions to vdd and gnd
   ;--------------------------------
   gndypnt = cadr(gndpin~>upperLeft)
   vddypnt = cadr(vddpin~>lowerLeft)

   for(i 0 nf  
     when(evenp(i)
       metname = strcat("nmos/contact." sprintf(nil "%n" i)) 
       gndxpnt = car(rodGetObj(metname cv)~>lowerCenter)
       rodCreatePath(
	 ?layer metal1
	 ?width cw + 2 * m1oc
	 ?pts list(rodGetObj(metname cv)~>lowerCenter gndxpnt:gndypnt)
       )
     )
   )
   for(i 0 pf 
     when(evenp(i)
       metname = strcat("pmos/contact." sprintf(nil "%n" i))
       vddxpnt = car(rodGetObj(metname cv)~>upperCenter)
       rodCreatePath(
	 ?layer metal1
	 ?width cw + 2 * m1oc
	 ?pts list(rodGetObj(metname cv)~>upperCenter vddxpnt:vddypnt)
       )
     )
   )
   ;--------------------------------
   ; wire drain
   ;--------------------------------
   maxpnt = max(car(rodGetObj(strcat("nmos/contact." sprintf(nil "%n" nf)) 
 	         cv)~>upperCenter)
	      car(rodGetObj(strcat("pmos/contact." sprintf(nil "%n" pf))
		 cv)~>lowerCenter))
   nypnt = cadr(rodGetObj(strcat("nmos/contact." sprintf(nil "%n" nf))
		 cv)~>upperCenter) + m1s + m1w/2
   pypnt = cadr(rodGetObj(strcat("pmos/contact." sprintf(nil "%n" pf))
		 cv)~>lowerCenter) - (m1s + m1w/2)
   cond(
     ( pf == 1 && nf == 1
       ptlist = list(rodGetObj("pmos/contact.1" cv)~>lowerCenter
		   rodGetObj("nmos/contact.1" cv)~>upperCenter
 	        )
       fig = routeOut(ptlist cv metal1 m1w) 
       buildInvpin(cv metal1 2*m1w  "out" fig "midRight0" cw)
     )
     ( pf <= 2  
       xcnt = car(rodGetObj("pmos/contact.1" cv)~>lowerCenter)
       ptlist = list(rodGetObj("pmos/contact.1" cv)~>lowerCenter
		   xcnt:pypnt 
                   maxpnt:pypnt 
		   maxpnt:(h/2)
                )
       fig = routeOut(ptlist cv metal1 m1w)
       buildInvpin(cv metal1 2*m1w "out" fig "endRightLast" cw)
     )
     ( oddp(pf) && nf <= pf
       ptlist = list(rodGetObj("pmos/swire.0" cv)~>start1 
    		maxpnt:(h/2)
		)
       fig = routeOut(ptlist cv metal1 m1w)
       buildInvpin(cv metal1 2*m1w "out" fig "endRightLast" cw)
     )
     ( evenp(pf) || oddp(pf) && pf < nf
       ptlist = list(rodGetObj("pmos/swire.0" cv)~>start1
		  maxpnt:pypnt 
                  maxpnt:(h/2)
                )
       fig = routeOut(ptlist cv metal1 m1w)
       buildInvpin(cv metal1 2*m1w "out" fig "endRightLast" cw)
     )
   )
  cond(
     ( nf <= 2 && !(pf == 1 && nf ==1)
       xcnt = car(rodGetObj("nmos/contact.1" cv)~>upperCenter)
       ptlist = list(rodGetObj("nmos/contact.1" cv)~>upperCenter
		   xcnt:nypnt 
 		   maxpnt:nypnt 
		   maxpnt:(h/2)
                )
       routeOut(ptlist cv metal1 m1w)
     )
     ( oddp(nf) && nf >= pf && nf > 2 
       ptlist = list(rodGetObj("nmos/dwire.0" cv)~>start1
    		maxpnt:(h/2)
		)
       routeOut(ptlist cv metal1 m1w)
     )
     ( evenp(nf) || nf < pf
       ptlist = list(rodGetObj("nmos/dwire.0" cv)~>start1
		  maxpnt:nypnt 
                  maxpnt:(h/2)
                )
       routeOut(ptlist cv metal1 m1w)
     )
   )
 )
   ;--------------------------------
   ; place well contacts 
   ;--------------------------------
   ;--------------------------------
   ; place substrate contacts 
   ;--------------------------------
   dbClose(nmosId)
   dbClose(pmosId)

   spcMakeRectPins(cv)
   t
   ) ;let
) ;procedure

procedure(routeOut(ptlist cv metal1 m1w)
  let((fig)
    fig = rodCreatePath(
	?layer metal1
	?width m1w
	?pts ptlist
    )
))

procedure(buildInvpin(cv layer width terminal fig handle cw)
  let((rodfig)
     rodfig = rodCreateRect(
	?layer layer
	?width width
	?length width
	?pin t
	?termName terminal
	?pinLabel t
	?pinLabelHeight cw
	?pinLabelLayer "text"
    )
    rodAlign(
	?alignObj rodfig
	?alignHandle "centerLeft"
	?refObj fig
	?refHandle handle
    )
  )
)	

procedure(invStretchCB(spcInfo)
    let(( (paramValue spcInfo->paramVal) (handleName spcInfo->handleName)
            (increment spcInfo->increment) string_var )
        when(stringp(paramValue)
            string_var = t
            paramValue = spcParseFloatString(paramValue)
        )
 
        ;; relative stretching in the Y axis.
        case(handleName
            ("upperCenter"
                newValue = spcRound((paramValue + increment) .001)
            )
            ("lowerCenter"
                newValue = spcRound((paramValue + increment) .001)
            )
            ("centerLeft"
                newValue = spcRound((paramValue + increment) .001)
            )
            ("centerRight"
                newValue = spcRound((paramValue + increment) .001)
            )
            (t
                newValue = paramValue
            )
        )
 
        when(string_var
            sprintf(newValue "%gu" newValue)
        )
 
        ;printf("paramValue = %L\n" paramValue)
        ;printf("increment = %L\n" increment)
        ;printf("newValue = %L\n" newValue)
 
        newValue
    )
)
 

