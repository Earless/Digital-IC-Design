; Get current cellview
cv = geGetEditCellView()

; Get right contact of I1
cont1Id = rodGetObj("I1/rightcont" cv)

; Get left contact of I2
cont2Id = rodGetObj("I2/leftcont" cv)

;align right contact of I1 with left contact of I2 separated by 2.0u
rodAlign(
   ?alignObj    cont1Id
   ?alignHandle "centerRight"
   ?refObj      cont2Id
   ?refHandle   "centerLeft"
   ?xSep        -2.0
)

; Note the negative separation implies that the aligned object is to the right
; of the reference object.

; Now select any one of the instances and move it upwards by a few grid 
; spaces. Notice how the other instance moves such that the aligment
; is maintained.
