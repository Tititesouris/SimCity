; At time A, every business releases offers for every job they have
; Offers roam around from time A to time B
; If a house sees an offer, they send out people in cars
; At time B every roaming offer dies
; Cars roam around from time A to time C
; At time C every car still roaming dies
; At time D, everyone leaves work and gets in a car
; Cars roam around from time D to time E
; At time E, every house is filled back up, everyone becomes unemployed and the roaming cars die

globals [
  dayLength ; Number of ticks in a day
  time ; Current tick of the day
  timeReleaseOffers ; Number of ticks to wait after a new day starts for businesses to release offers
  timeLeaveHome ; Number of ticks to wait after a new day starts for people to leave their home to go work
  timeLeaveWork ; Number of ticks to wait after a new day starts for people to leave work to go home
  timeSleep ; Number of ticks to wait after a new day starts for people to go to sleep

  roadColor ; Color of road patches
  offerSpeed ; Speed of offers
  carSpeed ; Speed of cars
]

breed [intersections intersection]
intersections-own [
  directions
]

breed [businesses business]
businesses-own [
  nbJobs ; Total number of jobs available at the business
  nbEmployees ; Number of employees currently working
]

breed [houses house]
houses-own [
  nbResidents ; Total number of people living in the house
  nbEmployed ; Number of people employed living in the house
  nbPeople ; Number of people currently in the house
]

breed [offers offer]
offers-own [
  speed ; Movement speed of the offer
  reach ; Number of ticks the offer is still valid for
  nbOpenJobs ; Number of employees to recruit
  group ; ID of the group this offer belongs to
]

breed [cars car]
cars-own [
  speed ; Movement speed of the car
  reach ; Number of ticks the car can still drive for
  nbPassengers ; Number of people in the car
]



; Resets the entire game
to reset
  ca
  reset-ticks

  set dayLength 2400
  set time 0
  set timeReleaseOffers 100
  set timeLeaveHome 700
  set timeLeaveWork 1800
  set timeSleep 2300

  set roadColor red
  set offerSpeed 0.5
  set carSpeed 0.5

  set-default-shape businesses "house colonial"
  set-default-shape houses "house"
  set-default-shape cars "car"
  set-default-shape offers "circle"
  load
end

; Load game data from files
to load
  file-open "intersections.txt"
  while [not file-at-end?] [
    let x file-read
    let y file-read
    let north (file-read = 1)
    let east (file-read = 1)
    let south (file-read = 1)
    let west (file-read = 1)
    create-intersections 1 [initIntersection x y north east south west]
  ]
  file-close
  file-open "roads.txt"
  while [not file-at-end?] [
    let xA file-read
    let yA file-read
    let xB file-read
    let yB file-read
    ask patches with [min list xA xB <= pxcor and pxcor <= max list xA xB and min list yA yB <= pycor and pycor <= max list yA yB] [set pcolor roadColor]
  ]
  file-close
  file-open "businesses.txt"
  while [not file-at-end?] [
    let x file-read
    let y file-read
    let :nbJobs file-read
    let :color file-read
    create-businesses 1 [initBusiness x y :nbJobs :color]
  ]
  file-close
  file-open "houses.txt"
  while [not file-at-end?] [
    let x file-read
    let y file-read
    let :nbResidents file-read
    let :color file-read
    create-houses 1 [initHouse x y :nbResidents :color]
  ]
  file-close
end

; Update every tick
to update
  ask businesses [updateBusinesses]
  ask houses [updateHouses]
  ask offers [updateOffers]
  ask cars [updateCars]
  tick
  set time time + 1
  if time > dayLength [
    set time 0
  ]
end

; Roads

to initIntersection [x y :north :east :south :west]
  setxy x y
  set heading 0
  set directions []
  let :nbDirections 0
  let :direction 0
  if :north [
    set directions lput patch-ahead 1 directions
    set :nbDirections :nbDirections + 1
    set :direction 0
  ]
  if :east [
    set directions lput patch-right-and-ahead 90 1 directions
    set :nbDirections :nbDirections + 1
    set :direction 90
  ]
  if :south [
    set directions lput patch-ahead -1 directions
    set :nbDirections :nbDirections + 1
    if not :west [
      set :direction 180
    ]
  ]
  if :west [
    set directions lput patch-left-and-ahead 90 1 directions
    set :nbDirections :nbDirections + 1
    if not :north [
      set :direction 270
    ]
  ]
  set shape word "intersection " :nbDirections
  set color black
  set heading :direction
end


; Businesses

to initBusiness [x y :nbJobs :color]
  setxy x y
  set nbJobs :nbJobs
  set color :color
  set nbEmployees 0

  set size 2
  set label (word nbEmployees " | " nbJobs)
end

to updateBusinesses
  let :nbOpenJobs nbJobs - nbEmployees
  ; Working hours
  ifelse timeReleaseOffers < time and time < timeLeaveWork [
    welcomeEmployees
  ][
    ifelse time = timeReleaseOffers [
      startWorkday
    ][
      if time = timeLeaveWork [
        endWorkday
      ]
    ]
  ]

  set label (word nbEmployees " | " nbJobs)
end

to welcomeEmployees
  if nbJobs - nbEmployees > 0 [
    let carsAround cars in-radius 1.5
    ask carsAround [
      let :nbOpenJobs [nbJobs - nbEmployees] of myself
      ifelse nbPassengers <= :nbOpenJobs [
        ask myself [set nbEmployees nbEmployees + [nbPassengers] of myself]
        die
      ][
        ask myself [set nbEmployees nbJobs]
        set nbPassengers nbPassengers - :nbOpenJobs
      ]
    ]
  ]
end

to startWorkday
  if nbJobs > 0 [
    let :reach timeLeaveHome - timeReleaseOffers
    hatch-offers 1 [initOffer xcor ycor :reach [nbJobs] of myself -1]
  ]
end

to endWorkday
  if nbEmployees > 0 [
    let :nbCars random nbEmployees + 1
    let :nbPassengers floor (nbEmployees / :nbCars)
    let :nbPassengersLeft nbEmployees mod :nbCars

    let :reach timeSleep - timeLeaveWork
    hatch-cars :nbCars [initCar xcor ycor :reach :nbPassengers]
    if :nbPassengersLeft > 0 [
      hatch-cars 1 [initCar xcor ycor :reach :nbPassengersLeft]
    ]
    set nbEmployees 0
  ]
end


; Houses

to initHouse [x y :nbResidents :color]
  setxy x y
  set nbResidents :nbResidents
  set color :color
  set nbPeople nbResidents
  set nbEmployed 0

  set size 2
  set label (word nbEmployed " | " nbPeople " | " nbResidents)
end

to updateHouses
  ifelse timeReleaseOffers <= time and time < timeLeaveHome [
    findJob
  ][
    ifelse time = timeLeaveHome [
      goWorking
    ][
      ifelse timeLeaveWork <= time and time < timeSleep [
        getHome
      ][
        if time = timeSleep [
          goSleep
        ]
      ]
    ]
  ]

  set label (word nbEmployed " | " nbPeople " | " nbResidents)
end

to findJob
  if nbEmployed < nbPeople [
    let offersAround offers in-radius 1.5
    ask offersAround [
      let :nbUnemployed [nbPeople - nbEmployed] of myself
      ifelse nbOpenJobs <= :nbUnemployed [
        ask myself [getHired [nbOpenJobs] of myself]
        ask offers with [group = [group] of myself] [die]
      ][
        ask offers with [group = [group] of myself] [set nbOpenJobs nbOpenJobs - :nbUnemployed]
        ask myself [getHired :nbUnemployed]
      ]
    ]
  ]
end

to getHired [:nbJobs]
  set nbEmployed nbEmployed + :nbJobs
end

to goWorking
  if nbEmployed > 0 [
    let :reach timeLeaveWork - time - dayLength / 24 ; Can drive until 1h before work closes
    set nbPeople nbResidents - nbEmployed
    hatch-cars 1 [initCar xcor ycor :reach [nbEmployed] of myself]
  ]
end

to getHome
  if nbPeople < nbResidents [
    let carsAround cars in-radius 1.5
    ask carsAround [
      let :nbMissing [nbResidents - nbPeople] of myself
      ifelse nbPassengers <= :nbMissing [
        ask myself [set nbPeople nbPeople + [nbPassengers] of myself]
        die
      ][
        ask myself [set nbPeople nbResidents]
        set nbPassengers nbPassengers - :nbMissing
      ]
    ]
  ]
end

to goSleep
  set nbPeople nbResidents
  set nbEmployed 0
end

; Roaming Agents

to initRoamingAgent [x y :speed :reach]
  setxy x y
  set speed :speed
  set reach :reach

  face one-of patches in-radius 1 with [pcolor = roadColor]
end

to updateRoamingAgent
  ifelse reach > 0 [
    let :intersection one-of intersections in-radius (speed / 2)
    let :patchAhead patch-ahead 1
    if (:intersection != nobody) or ((:patchAhead != nobody) and ([pcolor] of :patchAhead != roadColor)) [
      let :directions []
      ifelse :intersection = nobody [
        set :directions patches in-radius 1 with [pcolor = roadColor]
      ][
        set :directions [directions] of :intersection
      ]
      let target one-of :directions
      if target != nobody [
        face target
      ]
    ]
    fd speed
    set reach reach - 1
    if distance patch-here < (speed / 2) [
      move-to patch-here
    ]
  ][
    die
  ]
end


; Offers

to initOffer [x y :reach :nbOpenJobs :group]
  initRoamingAgent x y offerSpeed :reach
  set nbOpenJobs :nbOpenJobs
  ifelse :group = -1 [
    set group who
  ][
    set group :group
  ]

  set size 1
  set label nbOpenJobs
end

to updateOffers
  updateRoamingAgent
  let :intersection one-of intersections in-radius (speed / 2)
  if :intersection != nobody [
    hatch-offers 1
  ]

  set label nbOpenJobs
end



; Cars

to initCar [x y :reach :nbPassengers]
  initRoamingAgent x y carSpeed :reach
  set nbPassengers :nbPassengers

  set size 1
  set label nbPassengers
end

to updateCars
  updateRoamingAgent
  set label nbPassengers
end
@#$#@#$#@
GRAPHICS-WINDOW
349
20
1430
685
-1
-1
16.015
1
20
1
1
1
0
0
0
1
-33
33
-20
20
1
1
1
ticks
30.0

BUTTON
7
10
70
43
NIL
reset
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
76
10
139
43
NIL
load
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
11
72
82
105
NIL
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

BUTTON
96
73
159
106
step
update
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

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

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

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

dot
false
0
Circle -7500403 true true 90 90 120

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

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

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

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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
