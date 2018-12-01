__includes [
  "globals.nls"

  "movingtrucks.nls"
  "highways.nls"

  "planners.nls"
  "zones.nls"
  "guielements.nls"
  "cursors.nls"

  "roads.nls"
  "intersections.nls"

  "resourceconsumers.nls"
  "houses.nls"
  "businesses.nls"
  "powerplants.nls"
  "pumps.nls"

  "roamingagents.nls"
  "persons.nls"
  "cars.nls"
  "offers.nls"
  "resources.nls"

  "warnings.nls"
  "betterlabels.nls"
]

; When NetLogo opens
to startup
  initGUI
  reset
end

to initGUI
  ask cursors [die]
  create-cursors 1 [initCursor]
  set gui-ready? true
end

to updateGUI
  if gui-ready? = 0 [ ; For some reason the init doesn't work on startup
    initGUI
  ]

  ask cursors [updateCursor]
  display
end

; Resets the entire game
to reset
  ca
  reset-ticks
  set time 0
  load
end

; Load game data from files
to load
  set-current-directory "./config/"
  loadShapes
  loadConfig
  loadGuielements
  loadHighways
  set-current-directory "./../"
end

to loadShapes
  set-default-shape cursors "gui cursor"
  set-default-shape planners "square 2"

  set-default-shape persons "person"
  set-default-shape highways "invisible"

  set-default-shape businesses "house colonial"
  set-default-shape houses "house efficiency"
  set-default-shape powerplants "building store"
  set-default-shape pumps "water tower"

  set-default-shape movingtrucks "truck"
  set-default-shape cars "car"
  set-default-shape offers "letter sealed"
  set-default-shape electricities "lightning"
  set-default-shape waters "drop outline"

  set warningEmployement "warning employement"
  set warningWorkforce "warning workforce"
  set warningElectricity "warning electricity"
  set warningWater "warning water"
  set warningTaxes "warning taxes"
end

to loadConfig
  file-open "config.txt"
  set dayLength file-read
  set hourLength dayLength / 24 ; Number of ticks in an hour

  set timeReleaseOffers file-read
  set timeLeaveHome file-read
  set timeLeaveWork file-read
  set timeSleep file-read

  set money file-read
  set roadPrice file-read
  set powerplantPrice file-read
  set pumpPrice file-read

  set houseTax file-read
  set businessTax file-read
  set incomeTaxRate file-read
  set roadUpkeep file-read
  set powerplantUpkeep file-read
  set pumpUpkeep file-read

  set baseSalary file-read
  set maxSalaryIncrease file-read

  set offerSpeed file-read
  set vehicleSpeed file-read
  set resourceSpeed file-read

  set labelColor file-read
  set terrainColor file-read
  ask patches [set pcolor terrainColor]
  set highwayColor file-read
  set roadColor file-read
  set houseZoneColor file-read
  set businessZoneColor file-read
  file-close
end

to save
  set-current-directory "./save/"
  saveRoads
  saveIntersections
  saveHouseZones
  saveBusinessZones
  savePowerplants
  savePumps
  set-current-directory "./../"
end

; Load save data from files
to loadSave
  set-current-directory "./save/"
  loadRoads
  loadIntersections
  loadHouseZones
  loadBusinessZones
  loadPowerplants
  loadPumps
  set-current-directory "./../"
end

; Update every tick
to update

  ask patches with [pcolor = houseZoneColor] [updateHouseZone]
  ask patches with [pcolor = businessZoneColor] [updateBusinessZone]

  ask persons [updatePerson]
  ask houses [updateHouse]
  ask businesses [updateBusiness]
  ask powerplants [updatePowerplant]
  ask pumps [updatePump]

  ask highways [updateHighway]
  ask movingtrucks [updateMovingtruck]

  ask cars [updateCar]
  ask offers [updateResource]
  ask electricities [updateResource]
  ask waters [updateResource]

  ask warnings [updateWarning]

  ifelse showPersons [ask persons [st]][ask persons [ht]]
  ifelse showOffers [ask offers [st]][ask offers [ht]]
  ifelse showElectricity [ask electricities [st]][ask electricities [ht]]
  ifelse showWater [ask waters [st]][ask waters [ht]]

  updateBetterlabels


  tick
  set time time + 1
  if time >= dayLength [
    set time 0
    updateMoney
  ]
end

to updateMoney
  set money money + getTaxes - getUpkeep
end
@#$#@#$#@
GRAPHICS-WINDOW
-3
75
1445
642
-1
-1
18.0
1
11
1
1
1
0
1
1
1
0
79
0
30
1
1
1
ticks
30.0

BUTTON
505
10
577
75
Play | Pause
update
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
693
10
810
43
showLabels
showLabels
1
1
-1000

SWITCH
1154
10
1271
43
showWater
showWater
1
1
-1000

SWITCH
1039
10
1156
43
showElectricity
showElectricity
1
1
-1000

SWITCH
924
10
1041
43
showOffers
showOffers
1
1
-1000

MONITOR
159
10
224
67
Clock
clock
4
1
14

PLOT
364
642
800
819
Statistics
Week
%
0.0
10.0
0.0
100.0
true
true
"" "set-plot-x-range (ticks - 7 * dayLength) (ticks + 1)"
PENS
"Houses Happiness" 1.0 0 -682921 true "" "plot getHousesHappiness"
"Businesses Happiness" 1.0 0 -6192707 true "" "plot getBusinessesHappiness"
"People Happiness" 1.0 0 -12030287 true "" "plot getPersonsHappiness"
"Average Happiness" 1.0 0 -14439633 true "" "plot getHappiness"
"Employement" 1.0 0 -2674135 true "" "plot getEmployement"

PLOT
800
642
1285
819
Production & Usage
Week
Amount
0.0
10.0
0.0
10.0
true
true
"" "set-plot-x-range (ticks - 7 * dayLength) (ticks + 1)"
PENS
"Electricity +" 1.0 0 -1184463 true "" "plot getElectricityProduction"
"Electricity -" 1.0 0 -4079321 true "" "plot getElectricityUsage"
"Water +" 1.0 0 -13791810 true "" "plot getWaterProduction"
"Water -" 1.0 0 -14730904 true "" "plot getWaterUsage"

MONITOR
-1
10
160
67
Calendar
calendar
17
1
14

BUTTON
1270
10
1325
43
Reset
startup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1378
10
1455
43
Reset & Load
reset\nloadSave
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
-1
642
364
819
Economy
Week
Money
0.0
100.0
0.0
100.0
true
true
"" "set-plot-x-range (ticks - 7 * dayLength) (ticks + 1)"
PENS
"Income" 1.0 0 -11085214 true "" "plot getTaxes"
"Upkeep" 1.0 0 -5298144 true "" "plot getUpkeep"

SWITCH
809
10
926
43
showPersons
showPersons
1
1
-1000

MONITOR
223
10
383
67
Money
formatNumber money
4
1
14

MONITOR
382
10
504
67
Cost
formatNumber getCost
4
1
14

BUTTON
639
10
694
75
Step
update
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
576
10
640
75
Use Cursor
UpdateGUI
T
1
T
OBSERVER
NIL
C
NIL
NIL
1

TEXTBOX
1216
61
1463
79
Enable \"Use Cursor\", then choose cursor below
11
0.0
1

TEXTBOX
544
12
580
30
Space
11
0.0
1

BUTTON
1324
10
1379
43
Save
save
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
693
43
845
76
incomeTaxRate
incomeTaxRate
0
1
0.2
0.01
1
NIL
HORIZONTAL

SLIDER
844
43
1002
76
houseTax
houseTax
0
500
50.0
5
1
$ / day
HORIZONTAL

SLIDER
1001
43
1173
76
businessTax
businessTax
0
1000
170.0
10
1
$ / day
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

betterlabel
false
0
Rectangle -7500403 true true 0 135 300 300

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

building store
false
0
Rectangle -7500403 true true 30 45 45 240
Rectangle -16777216 false false 30 45 45 165
Rectangle -7500403 true true 15 165 285 255
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 30 180 105 240
Rectangle -16777216 true false 195 180 270 240
Line -16777216 false 0 165 300 165
Polygon -7500403 true true 0 165 45 135 60 90 240 90 255 135 300 165
Rectangle -7500403 true true 0 0 75 45
Rectangle -16777216 false false 0 0 75 45
Polygon -7500403 false true 0 165
Polygon -16777216 false false 0 165 45 135 60 90 240 90 255 135 300 165 0 165
Polygon -16777216 false false 15 165 15 255 285 255 285 165

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

chess rook
false
0
Rectangle -7500403 true true 90 195 210 240
Line -16777216 false 75 195 225 195
Rectangle -16777216 false false 90 195 210 240
Polygon -7500403 true true 90 195 105 45 195 45 210 195
Polygon -16777216 false false 90 195 105 45 195 45 210 195
Rectangle -7500403 true true 75 90 120 60
Rectangle -7500403 true true 75 24 225 45
Rectangle -7500403 true true 135 90 165 60
Rectangle -7500403 true true 180 90 225 60
Polygon -16777216 false false 90 45 75 45 75 0 120 0 120 24 135 24 135 0 165 0 165 24 179 24 180 0 225 0 225 45

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cloud
false
0
Circle -7500403 true true 13 118 94
Circle -7500403 true true 86 101 127
Circle -7500403 true true 51 51 108
Circle -7500403 true true 118 43 95
Circle -7500403 true true 158 68 134

container
false
0
Rectangle -7500403 false false 0 75 300 225
Rectangle -7500403 true true 0 75 300 225
Line -16777216 false 0 210 300 210
Line -16777216 false 0 90 300 90
Line -16777216 false 150 90 150 210
Line -16777216 false 120 90 120 210
Line -16777216 false 90 90 90 210
Line -16777216 false 240 90 240 210
Line -16777216 false 270 90 270 210
Line -16777216 false 30 90 30 210
Line -16777216 false 60 90 60 210
Line -16777216 false 210 90 210 210
Line -16777216 false 180 90 180 210

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dollar bill
false
0
Rectangle -7500403 true true 15 90 285 210
Rectangle -1 true false 30 105 270 195
Circle -7500403 true true 120 120 60
Circle -7500403 true true 120 135 60
Circle -7500403 true true 254 178 26
Circle -7500403 true true 248 98 26
Circle -7500403 true true 18 97 36
Circle -7500403 true true 21 178 26
Circle -7500403 true true 66 135 28
Circle -1 true false 72 141 16
Circle -7500403 true true 201 138 32
Circle -1 true false 209 146 16
Rectangle -16777216 true false 64 112 86 118
Rectangle -16777216 true false 90 112 124 118
Rectangle -16777216 true false 128 112 188 118
Rectangle -16777216 true false 191 112 237 118
Rectangle -1 true false 106 199 128 205
Rectangle -1 true false 90 96 209 98
Rectangle -7500403 true true 60 168 103 176
Rectangle -7500403 true true 199 127 230 133
Line -7500403 true 59 184 104 184
Line -7500403 true 241 189 196 189
Line -7500403 true 59 189 104 189
Line -16777216 false 116 124 71 124
Polygon -1 true false 127 179 142 167 142 160 130 150 126 148 142 132 158 132 173 152 167 156 164 167 174 176 161 193 135 192
Rectangle -1 true false 134 199 184 205

dot
false
0
Circle -7500403 true true 90 90 120

drop outline
false
0
Circle -7500403 true true 73 133 152
Circle -16777216 false false 72 132 154
Polygon -7500403 true true 79 182 95 152 115 120 126 95 137 64 144 37 150 6 154 165
Polygon -7500403 true true 219 181 205 152 185 120 174 95 163 64 156 37 149 7 147 166
Line -16777216 false 150 1 149 15
Line -16777216 false 147 15 144 31
Line -16777216 false 145 30 141 47
Line -16777216 false 141 46 137 61
Line -16777216 false 138 61 132 75
Line -16777216 false 133 75 126 91
Line -16777216 false 127 89 120 105
Line -16777216 false 121 104 113 122
Line -16777216 false 113 121 104 137
Line -16777216 false 103 137 94 152
Line -16777216 false 206 151 210 165
Line -16777216 false 197 137 206 152
Line -16777216 false 186 121 195 137
Line -16777216 false 178 105 186 123
Line -16777216 false 173 89 180 105
Line -16777216 false 167 75 174 91
Line -16777216 false 162 61 168 75
Line -16777216 false 158 46 162 61
Line -16777216 false 154 30 158 47
Line -16777216 false 151 15 154 31
Line -16777216 false 150 1 151 15

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

factory
false
0
Rectangle -7500403 true true 76 194 285 270
Rectangle -7500403 true true 36 95 59 231
Rectangle -16777216 true false 90 210 270 240
Line -7500403 true 90 195 90 255
Line -7500403 true 120 195 120 255
Line -7500403 true 150 195 150 240
Line -7500403 true 180 195 180 255
Line -7500403 true 210 210 210 240
Line -7500403 true 240 210 240 240
Line -7500403 true 90 225 270 225
Circle -1 true false 37 73 32
Circle -1 true false 55 38 54
Circle -1 true false 96 21 42
Circle -1 true false 105 40 32
Circle -1 true false 129 19 42
Rectangle -7500403 true true 14 228 78 270

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

gui business
true
0
Rectangle -7500403 true true 255 60 270 240
Rectangle -7500403 true true 30 120 255 240
Rectangle -16777216 true false 109 180 172 241
Rectangle -16777216 true false 45 180 90 225
Rectangle -16777216 true false 45 135 90 165
Rectangle -16777216 true false 195 135 240 165
Line -16777216 false 255 120 255 240
Polygon -7500403 true true 15 120 270 120 225 75 60 75
Line -16777216 false 15 120 270 120
Line -16777216 false 240 90 270 120
Line -7500403 true 139 180 139 240
Rectangle -16777216 true false 195 180 240 225
Rectangle -16777216 true false 120 135 165 165
Polygon -16777216 false false 15 120 60 75 225 75 255 105 255 60 270 60 270 240 30 240 30 120
Circle -7500403 false true 0 0 300

gui cursor
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250
Circle -7500403 false true 0 0 298

gui house
true
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120
Circle -7500403 false true 2 2 295

gui intersection
true
0
Polygon -7500403 true true 150 300 105 225 195 225
Polygon -7500403 true true 135 226 135 150 139 141 147 136 154 136 161 141 165 149 165 226
Polygon -7500403 true true 0 150 75 105 75 195
Polygon -7500403 true true 74 135 150 135 159 139 164 147 164 154 159 161 151 165 74 165
Polygon -7500403 true true 300 150 225 105 225 195
Polygon -7500403 true true 226 135 150 135 141 139 136 147 136 154 141 161 149 165 226 165
Polygon -7500403 true true 150 0 105 75 195 75
Polygon -7500403 true true 135 74 135 150 139 159 147 164 154 164 161 159 165 151 165 74
Circle -7500403 false true 0 0 300

gui powerplant
true
0
Rectangle -7500403 true true 30 45 45 240
Rectangle -16777216 false false 30 45 45 165
Rectangle -7500403 true true 15 165 285 255
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 30 180 105 240
Rectangle -16777216 true false 195 180 270 240
Line -16777216 false 0 165 300 165
Polygon -7500403 true true 0 165 45 135 60 90 240 90 255 135 300 165
Rectangle -7500403 true true 0 0 75 45
Rectangle -16777216 false false 0 0 75 45
Polygon -7500403 false true 0 165
Polygon -16777216 false false 0 165 45 135 60 90 240 90 255 135 300 165 0 165
Polygon -16777216 false false 15 165 15 255 285 255 285 165
Circle -7500403 false true 2 2 295

gui pump
true
0
Rectangle -7500403 true true 90 225 210 270
Line -16777216 false 75 225 225 225
Rectangle -16777216 false false 90 225 210 270
Polygon -7500403 true true 90 225 105 75 195 75 210 225
Polygon -16777216 false false 90 225 105 75 195 75 210 225
Rectangle -7500403 true true 75 90 120 60
Rectangle -7500403 true true 75 54 225 75
Rectangle -7500403 true true 135 150 165 120
Rectangle -7500403 true true 180 90 225 60
Polygon -16777216 false false 90 75 75 75 75 30 120 30 120 54 135 54 135 30 165 30 165 54 179 54 180 30 225 30 225 75
Circle -7500403 false true 0 0 300

gui road
true
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

house bungalow
false
0
Rectangle -7500403 true true 210 75 225 255
Rectangle -7500403 true true 90 135 210 255
Rectangle -16777216 true false 165 195 195 255
Line -16777216 false 210 135 210 255
Rectangle -16777216 true false 105 202 135 240
Polygon -7500403 true true 225 150 75 150 150 75
Line -16777216 false 75 150 225 150
Line -16777216 false 195 120 225 150
Polygon -16777216 false false 165 195 150 195 180 165 210 195
Rectangle -16777216 true false 135 105 165 135

house colonial
false
0
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 45 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 60 195 105 240
Rectangle -16777216 true false 60 150 105 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Polygon -7500403 true true 30 135 285 135 240 90 75 90
Line -16777216 false 30 135 285 135
Line -16777216 false 255 105 285 135
Line -7500403 true 154 195 154 255
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 135 150 180 180
Polygon -16777216 false false 30 135 75 90 240 90 270 120 270 75 285 75 285 255 45 255 45 135

house efficiency
false
0
Rectangle -7500403 true true 180 90 195 195
Rectangle -7500403 true true 90 165 210 255
Rectangle -16777216 true false 165 195 195 255
Rectangle -16777216 true false 105 202 135 240
Polygon -7500403 true true 225 165 75 165 150 90
Line -16777216 false 75 165 225 165
Polygon -16777216 false false 90 165 90 255 210 255 210 165
Polygon -16777216 false false 75 165 150 90 180 120 180 90 195 90 195 135 225 165

house ranch
false
0
Rectangle -7500403 true true 270 120 285 255
Rectangle -7500403 true true 15 180 270 255
Polygon -7500403 true true 0 180 300 180 240 135 60 135 0 180
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 45 195 105 240
Rectangle -16777216 true false 195 195 255 240
Line -7500403 true 75 195 75 240
Line -7500403 true 225 195 225 240
Line -16777216 false 270 180 270 255
Line -16777216 false 0 180 300 180

house two story
false
0
Polygon -7500403 true true 2 180 227 180 152 150 32 150
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 75 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 90 150 135 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Rectangle -7500403 true true 15 180 75 255
Polygon -7500403 true true 60 135 285 135 240 90 105 90
Line -16777216 false 75 135 75 180
Rectangle -16777216 true false 30 195 93 240
Line -16777216 false 60 135 285 135
Line -16777216 false 255 105 285 135
Line -16777216 false 0 180 75 180
Line -7500403 true 60 195 60 240
Line -7500403 true 154 195 154 255

intersection 0
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

intersection 1
true
0
Polygon -7500403 true true 150 0 105 75 195 75
Polygon -7500403 true true 135 74 135 150 139 159 147 164 154 164 161 159 165 151 165 74

intersection 2
true
0
Polygon -7500403 true true 0 150 75 195 75 105
Polygon -7500403 true true 74 165 150 165 159 161 164 153 164 146 159 139 151 135 74 135
Polygon -7500403 true true 150 0 105 75 195 75
Polygon -7500403 true true 135 74 135 150 139 159 147 164 154 164 161 159 165 151 165 74

intersection 2bis
true
0
Polygon -7500403 true true 150 0 105 75 195 75
Polygon -7500403 true true 135 226 135 150 139 141 147 136 154 136 161 141 165 149 165 226
Polygon -7500403 true true 150 300 105 225 195 225
Polygon -7500403 true true 135 74 135 150 139 159 147 164 154 164 161 159 165 151 165 74

intersection 3
true
0
Polygon -7500403 true true 0 150 75 195 75 105
Polygon -7500403 true true 74 165 150 165 159 161 164 153 164 146 159 139 151 135 74 135
Polygon -7500403 true true 150 300 105 225 195 225
Polygon -7500403 true true 135 226 135 150 139 141 147 136 154 136 161 141 165 149 165 226
Polygon -7500403 true true 150 0 105 75 195 75
Polygon -7500403 true true 135 74 135 150 139 159 147 164 154 164 161 159 165 151 165 74

intersection 4
true
0
Polygon -7500403 true true 150 300 105 225 195 225
Polygon -7500403 true true 135 226 135 150 139 141 147 136 154 136 161 141 165 149 165 226
Polygon -7500403 true true 0 150 75 105 75 195
Polygon -7500403 true true 74 135 150 135 159 139 164 147 164 154 159 161 151 165 74 165
Polygon -7500403 true true 300 150 225 105 225 195
Polygon -7500403 true true 226 135 150 135 141 139 136 147 136 154 141 161 149 165 226 165
Polygon -7500403 true true 150 0 105 75 195 75
Polygon -7500403 true true 135 74 135 150 139 159 147 164 154 164 161 159 165 151 165 74

invisible
true
0

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

letter sealed
false
0
Rectangle -7500403 true true 30 90 270 225
Rectangle -16777216 false false 30 90 270 225
Line -16777216 false 270 105 150 180
Line -16777216 false 30 105 150 180
Line -16777216 false 270 225 181 161
Line -16777216 false 30 225 119 161

lightning
false
0
Polygon -7500403 true true 120 135 90 195 135 195 105 300 225 165 180 165 210 105 165 105 195 0 75 135
Polygon -16777216 false false 75 135 195 0 165 105 210 105 180 165 225 165 105 300 135 195 90 195 120 135 75 135

line
true
0
Line -7500403 true 150 0 150 300

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

spinner
true
0
Polygon -7500403 true true 150 0 105 75 195 75
Polygon -7500403 true true 135 74 135 150 139 159 147 164 154 164 161 159 165 151 165 74

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

train
false
0
Rectangle -7500403 true true 30 105 240 150
Polygon -7500403 true true 240 105 270 30 180 30 210 105
Polygon -7500403 true true 195 180 270 180 300 210 195 210
Circle -7500403 true true 0 165 90
Circle -7500403 true true 240 225 30
Circle -7500403 true true 90 165 90
Circle -7500403 true true 195 225 30
Rectangle -7500403 true true 0 30 105 150
Rectangle -16777216 true false 30 60 75 105
Polygon -7500403 true true 195 180 165 150 240 150 240 180
Rectangle -7500403 true true 135 75 165 105
Rectangle -7500403 true true 225 120 255 150
Rectangle -16777216 true false 30 203 150 218

train passenger car
false
0
Polygon -7500403 true true 15 206 15 150 15 135 30 120 270 120 285 135 285 150 285 206 270 210 30 210
Circle -16777216 true false 240 195 30
Circle -16777216 true false 210 195 30
Circle -16777216 true false 60 195 30
Circle -16777216 true false 30 195 30
Rectangle -16777216 true false 30 140 268 165
Line -7500403 true 60 135 60 165
Line -7500403 true 60 135 60 165
Line -7500403 true 90 135 90 165
Line -7500403 true 120 135 120 165
Line -7500403 true 150 135 150 165
Line -7500403 true 180 135 180 165
Line -7500403 true 210 135 210 165
Line -7500403 true 240 135 240 165
Rectangle -16777216 true false 5 195 19 207
Rectangle -16777216 true false 281 195 295 207
Rectangle -13345367 true false 15 165 285 173
Rectangle -2674135 true false 15 180 285 188

train passenger engine
false
0
Rectangle -7500403 true true 0 180 300 195
Polygon -7500403 true true 283 161 274 128 255 114 231 105 165 105 15 105 15 150 15 195 15 210 285 210
Circle -16777216 true false 17 195 30
Circle -16777216 true false 50 195 30
Circle -16777216 true false 220 195 30
Circle -16777216 true false 253 195 30
Rectangle -16777216 false false 0 195 300 180
Rectangle -1 true false 11 111 18 118
Rectangle -1 true false 270 129 277 136
Rectangle -16777216 true false 91 195 210 210
Rectangle -16777216 true false 1 180 10 195
Line -16777216 false 290 150 291 182
Rectangle -16777216 true false 165 90 195 90
Rectangle -16777216 true false 290 180 299 195
Polygon -13345367 true false 285 180 267 158 239 135 180 120 15 120 16 113 180 113 240 120 270 135 282 154
Polygon -2674135 true false 284 179 267 160 239 139 180 127 15 127 16 120 180 120 240 127 270 142 282 161
Rectangle -16777216 true false 210 115 254 135
Line -7500403 true 225 105 225 150
Line -7500403 true 240 105 240 150

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

truck cab only
false
0
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Rectangle -1 true false 291 158 300 173

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

ufo side
false
0
Polygon -1 true false 0 150 15 180 60 210 120 225 180 225 240 210 285 180 300 150 300 135 285 120 240 105 195 105 150 105 105 105 60 105 15 120 0 135
Polygon -16777216 false false 105 105 60 105 15 120 0 135 0 150 15 180 60 210 120 225 180 225 240 210 285 180 300 150 300 135 285 120 240 105 210 105
Polygon -7500403 true true 60 131 90 161 135 176 165 176 210 161 240 131 225 101 195 71 150 60 105 71 75 101
Circle -16777216 false false 255 135 30
Circle -16777216 false false 180 180 30
Circle -16777216 false false 90 180 30
Circle -16777216 false false 15 135 30
Circle -7500403 true true 15 135 30
Circle -7500403 true true 90 180 30
Circle -7500403 true true 180 180 30
Circle -7500403 true true 255 135 30
Polygon -16777216 false false 150 59 105 70 75 100 60 130 90 160 135 175 165 175 210 160 240 130 225 100 195 70

van side
false
0
Polygon -7500403 true true 26 147 18 125 36 61 161 61 177 67 195 90 242 97 262 110 273 129 260 149
Circle -16777216 true false 43 123 42
Circle -16777216 true false 194 124 42
Polygon -16777216 true false 45 68 37 95 183 96 169 69
Line -7500403 true 62 65 62 103
Line -7500403 true 115 68 120 100
Polygon -1 true false 271 127 258 126 257 114 261 109
Rectangle -16777216 true false 19 131 27 142

warning electricity
true
0
Polygon -7500403 true true 120 135 90 195 135 195 105 300 225 165 180 165 210 105 165 105 195 0 75 135
Polygon -16777216 false false 75 135 195 0 165 105 210 105 180 165 225 165 105 300 135 195 90 195 120 135 75 135

warning employement
true
0
Rectangle -7500403 true true 30 90 270 225
Rectangle -16777216 false false 30 90 270 225
Line -16777216 false 270 105 150 180
Line -16777216 false 30 105 150 180
Line -16777216 false 270 225 181 161
Line -16777216 false 30 225 119 161

warning taxes
true
0
Rectangle -7500403 true true 15 90 285 210
Rectangle -1 true false 30 105 270 195
Circle -7500403 true true 120 120 60
Circle -7500403 true true 120 135 60
Circle -7500403 true true 254 178 26
Circle -7500403 true true 248 98 26
Circle -7500403 true true 18 97 36
Circle -7500403 true true 21 178 26
Circle -7500403 true true 66 135 28
Circle -1 true false 72 141 16
Circle -7500403 true true 201 138 32
Circle -1 true false 209 146 16
Rectangle -16777216 true false 64 112 86 118
Rectangle -16777216 true false 90 112 124 118
Rectangle -16777216 true false 128 112 188 118
Rectangle -16777216 true false 191 112 237 118
Rectangle -1 true false 106 199 128 205
Rectangle -1 true false 90 96 209 98
Rectangle -7500403 true true 60 168 103 176
Rectangle -7500403 true true 199 127 230 133
Line -7500403 true 59 184 104 184
Line -7500403 true 241 189 196 189
Line -7500403 true 59 189 104 189
Line -16777216 false 116 124 71 124
Polygon -1 true false 127 179 142 167 142 160 130 150 126 148 142 132 158 132 173 152 167 156 164 167 174 176 161 193 135 192
Rectangle -1 true false 134 199 184 205

warning water
true
0
Circle -7500403 true true 73 133 152
Circle -16777216 false false 72 132 154
Polygon -7500403 true true 79 182 95 152 115 120 126 95 137 64 144 37 150 6 154 165
Polygon -7500403 true true 219 181 205 152 185 120 174 95 163 64 156 37 149 7 147 166
Line -16777216 false 150 1 149 15
Line -16777216 false 147 15 144 31
Line -16777216 false 145 30 141 47
Line -16777216 false 141 46 137 61
Line -16777216 false 138 61 132 75
Line -16777216 false 133 75 126 91
Line -16777216 false 127 89 120 105
Line -16777216 false 121 104 113 122
Line -16777216 false 113 121 104 137
Line -16777216 false 103 137 94 152
Line -16777216 false 206 151 210 165
Line -16777216 false 197 137 206 152
Line -16777216 false 186 121 195 137
Line -16777216 false 178 105 186 123
Line -16777216 false 173 89 180 105
Line -16777216 false 167 75 174 91
Line -16777216 false 162 61 168 75
Line -16777216 false 158 46 162 61
Line -16777216 false 154 30 158 47
Line -16777216 false 151 15 154 31
Line -16777216 false 150 1 151 15

warning workforce
true
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

water tower
false
0
Rectangle -7500403 true true 90 195 210 240
Polygon -7500403 true true 90 195 105 45 195 45 210 195
Rectangle -7500403 true true 75 90 120 60
Rectangle -7500403 true true 45 0 255 30
Rectangle -7500403 true true 180 90 225 60
Rectangle -7500403 true true 60 0 240 45
Rectangle -7500403 true true 75 15 225 60
Polygon -16777216 false false 45 0 255 0 255 30 240 30 240 45 225 45 225 60 195 60 210 195 210 240 90 240 90 195 105 60 75 60 75 45 60 45 60 30 45 30 45 0

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
