;
;  This pcell extends the basic transistor by adding a stretchable contact
;  to the diffusion region on either side of the gate.  More access to
;  technology information is demonstrated as well as additional ROD rectangle
;  creation and alignment.  The name of the master view is:
;
;     ROD step3 layout
;
;  This pcell accepts these parameters:
;
;     width      Width of the transistor's active area (note: this is a
;                distance measured in the Y-direction).
;                (float, default = 2.4)
;
;     length     Length of the transistor's active area (note: this is a
;                distance measured in the X-direction).
;                (float, default = 0.6)
;
;     polyLayer  Name of the poly layer.
;                (string, default = "poly")
;
;     diffLayer  Name of the diffusion layer.
;                (string, default = "pdiff")
;
;     contLayer  Name of the contact layer.
;                (string, default = "cont")
;
pcDefinePCell(

   ;  Identify the target cellview.
   list(ddGetObj("ROD") "ptran" "layout")

   ;  Define formal parameter name-value pairs.
   (
      (width 4.0)
      (length 1.0)
      (polyLayer "poly1")
      (diffLayer "pdiff")
      (contLayer "cont")
   )

   ;  Define the contents of this cellview.
   let((tfId polyExtend contWidth polyContSep diffContEnclose diffObj gateObj
        leftCont rightCont)

      ;  Get the technology information for this cell.
      tfId = techGetTechFile(ddGetObj("cellTechLib"))

      ;  Get the minimum extension of 'poly' beyond diffusion.
      polyExtend = techGetSpacingRule(tfId "minExtension" polyLayer)

      ;  Get the minimum contact width.
      contWidth = techGetSpacingRule(tfId "minWidth" contLayer)

      ;  Get the minimum poly to contact spacing.
      polyContSep = techGetSpacingRule(tfId "minSpacing" polyLayer contLayer)

      ;  Get the minimum diffusion enclosure of contact.
      diffContEnclose =
      techGetOrderedSpacingRule(tfId "minEnclosure" diffLayer contLayer)

      ;  Create the diffusion area.
      diffObj = rodCreateRect(
         ?name "diff"
         ?layer list(diffLayer "drawing")
         ?width (length + 2.0*(contWidth + polyContSep + diffContEnclose))
         ?length width
      )

      ;  Create the gate area.
      gateObj = rodCreateRect(
         ?name "gate"
         ?layer list(polyLayer "drawing")
	 ?width length
         ?length (width + 2.0*polyExtend)
      )

      ;  Align the gate and diffusion rectangles on their center-points.
      rodAlign(
         ?alignObj diffObj
         ?alignHandle "centerCenter"
         ?refObj gateObj
         ?refHandle "centerCenter"
      )

      ;  Create the left-side contact.
      leftCont = rodCreateRect(
         ?name "leftcont"
         ?layer list(contLayer "drawing")
         ?width contWidth
         ?length width - 2.0*diffContEnclose
      )

      ;  Align the left-side contact.
      rodAlign(
         ?alignObj leftCont
         ?alignHandle "centerRight"
         ?refObj gateObj
         ?refHandle "centerLeft"
         ?xSep -polyContSep
      )

      ;  Create the right-side contact.
      rightCont = rodCreateRect(
         ?name "rightcont"
         ?layer list(contLayer "drawing")
         ?width contWidth
         ?length width - 2.0*diffContEnclose
      )

      ;  Align the right-side contact.
      rodAlign(
         ?alignObj rightCont
         ?alignHandle "centerLeft"
         ?refObj gateObj
         ?refHandle "centerRight"
         ?xSep polyContSep
      )
   )
)
