;=========================================================================================================
; Most of the initialization are random
; In future, will try to remove hard coding with configurable variables
; 
; The code is flat. Not much of modularity.
; The model is written by a beginner in NetLogo, not all features of NetLogo used, but seems to work :-)
; It is just a model, results are only to demonstrate the model and do not serve any other purpose
;
; Contact: dibakard@ieee.org
;
; how to cite: TO BE DONE
;=========================================================================================================

;---------------------------------------------------------------------------------------------------------
globals
[
  ; radius of the location i.e. white circle
  radius_per_cluster 
  
  ; holds x value the cluster centre of the white location circle agents
  cluster_centre_x 
  
  ; holds y value the cluster centre of the white location circle agents
  cluster_centre_y 
  
  ; holds the percentage of infected agents
  percent_infected 
  
  ; holds the percentage of agents taking precautions
  percent_precautioned 
  
  ; holds the percentage of recovered agents
  percent_recovered 
  
  ; flag to indicate the mobility across enabled routes have started
  start-mobility 
  
  cyan_low_thres_x 
  cyan_high_thres_x 
  
  cyan_low_thres_y 
  cyan_high_thres_y 
  
  yellow_low_thres_x
  yellow_high_thres_x
  
  yellow_low_thres_y
  yellow_high_thres_y
  
  ; set to TRUE when turtles moves to and fro, blue (bottom-left) and red (centre)
  mobility-blue-red? 
  
  ; set to TRUE when turtles moves to and fro, blue (bottom-left) and yellow (top-left)
  mobility-blue-yellow? 
  
  ; set to TRUE when turtles moves to and fro, blue (bottom-left) and pink (bottom-right)
  mobility-blue-pink?
  
  ; set to TRUE when turtles moves to and fro, pink (bottom-right) and red (centre)
  mobility-pink-red?
  
  ; set to TRUE when turtles moves to and fro, cyan (top-right) and pink (bottom-right)
  mobility-cyan-pink?
  
  ; set to TRUE when turtles moves to and fro, cyan (top-right) and red (centre)
  mobility-cyan-red?
  
  ; set to TRUE when turtles moves to and fro, cyan (top-right) and yellow (top-left)
  mobility-cyan-yellow?
  
  ; set to TRUE when turtles moves to and fro, red (centre) and yellow (top-left)
  mobility-yellow-red?
  
  ; set to TRUE when red turtles are infected
  red-infected?
  
  ; set to TRUE when blue turtles are infected
  blue-infected?
  
  ; set to TRUE when pink turtles are infected
  pink-infected?
  
  ; set to TRUE when cyan turtles are infected
  cyan-infected?
  
  ; set to TRUE when cyan turtles are infected
  yellow-infected?
  
  ; this variable limits the mobility till they reach white circles
  lock_radius 
]
;-----------------------------------------------------------------------------------------------------------
turtles-own
[
  ;my-id ;remove the node for this variable not required TBD
  ;my-group ;remove the node for this variable not required TBD
  
  ; hold the initial x coordinate value of created turtle
  my-x
  
  ; hold the initial y coordinate value of created turtle
  my-y
  
  ; turtle's cluster centre  x coordinate
  my-cluster-center-x
  
  ; turtle's cluster centre  y coordinate
  my-cluster-center-y
  my-colour;remove the node for this variable not required TBD
  
  ; turtles immunity 1-9
  my-immunity
  
  ; turtles movement along the eight interfaces 0-8
  my-heading
  
  ; turtles home after mobility red, blue, yellow, pink, cyan
  my-new-home
  
  ; whether turtle takes precautions
  my-precautions?
  
  ; whether a turtle is infected
  my-infection?
]
;-----------------------------------------------------------------------------------------------------------
; setup procedure
to setup
  
  clear-all
  
  reset-ticks
  
  ; initially there is no inter location mobility
  set start-mobility 0
  
  ; the setup procedure
  static-setup
  
  ; set the background  
  setup-patches
  
end
;-----------------------------------------------------------------------------------------------------------
; sets back ground
to setup-patches
  
  ; colour background with black
  ask patches
  [
    set pcolor black
    
  ]
  
end 
;-----------------------------------------------------------------------------------------------------------
; go procedure
to go
  
  static-go
  
  ; lockdown an interface
  static-lockdown-interface
  
  ; locdown a location
  static-lockdown
  
  ; start turtle infection
  start-infection
  
  ; start turtle recovery
  do-recovery
  
  ; turtles take precautions
  do-precautions
 
  tick
  
end
;-----------------------------------------------------------------------------------------------------------
; this function is invoked by setup
to static-setup
  
  set cyan_low_thres_x 28
  set cyan_high_thres_x 32 
  
  set cyan_low_thres_y 28
  set cyan_high_thres_y 32
  
  set yellow_low_thres_x 8
  set yellow_high_thres_x 12
  
  set yellow_low_thres_y 28
  set yellow_high_thres_y 32
  
  ; centres for the 5 location white circles
  let cluster-x  [[20 20] [10 30] [30 30] [10 10] [30 10]]
   
  
  ; create the 5 locations with big  white circles
  let i 0 
  foreach  cluster-x
  [
    create-turtles 1 
    [
      set shape "circle 2" 
      set size 12 
      
      ; store the radius of the big circles
      set radius_per_cluster size
      
      setxy (item 0 item i cluster-x)  (item 1 item i cluster-x) 
      
      ; store cluster x-coordinate
      set cluster_centre_x (item 0 item i cluster-x)
      
      ; store cluster y-coordinate
      set cluster_centre_y (item 1 item i cluster-x)
      
      set color white 
    ]
     set i (i + 1)
  ]
  
  ; create 100 turtles with 5 colours 
  set i 0
  let cluster-color 15
  foreach  cluster-x ;create turtles for each location 
  [
    create-turtles 100 
    [
      
      set cluster_centre_x (item 0 item i cluster-x)
      
      set cluster_centre_y (item 1 item i cluster-x)
      
      set shape "circle" 
      
      set size 0.25 
      
      ; position the respective coloured turtles within the white circle locations
      setxy (cluster_centre_x + ((-2) + random (4)))  cluster_centre_y + (((-2) + random (4))) 
       
      set color cluster-color
      
      ; store values in the private variables of turtles
      set my-cluster-center-x cluster_centre_x
      
      set my-cluster-center-y cluster_centre_y
      
      set my-x (cluster_centre_x + ((-2) + random (4)))
      
      set my-y (cluster_centre_y + ((-2) + random (4)))
      
      set my-colour cluster-color
      
      ; initialize immunity value randomly between 1-9
      set my-immunity (1 + random (9 - 1 )) 
      
      ; initialize the direction of movement from the turtles along the 8 routes
      set my-heading mobility-direction
      
      ; all turtles are initialized to taking no precautions
      set my-precautions? FALSE
      
      ; all turtles are initialized to not infected
      set my-infection? FALSE
    ]
    set i (i + 1)
    
    set cluster-color cluster-color + 30
  ]
  
  ; initially turtle mobility among all location (5 white cirles) set to FALSE
  set mobility-blue-red? FALSE
  set mobility-blue-yellow? FALSE
  set mobility-blue-pink? FALSE
  set mobility-pink-red? FALSE
  set mobility-cyan-pink? FALSE
  set mobility-cyan-red? FALSE
  set mobility-cyan-yellow? FALSE
  set mobility-yellow-red? FALSE
  
  ; initially routes among all location (5 white cirles) are disabled, can be enabled from GUI
  set route-blue-red-enable? FALSE
  set route-blue-yellow-enable? FALSE
  set route-blue-pink-enable? FALSE
  set route-pink-red-enable? FALSE
  set route-cyan-pink-enable? FALSE
  set route-cyan-red-enable? FALSE
  set route-cyan-yellow-enable? FALSE
  set route-yellow-red-enable? FALSE
  
  ; initially none of the routes (5 white cirles) are in locked down state, can be enabled from GUI
  set lockdown-blue-red? FALSE
  set lockdown-blue-yellow? FALSE
  set lockdown-blue-pink? FALSE
  set lockdown-pink-red? FALSE
  set lockdown-cyan-pink? FALSE
  set lockdown-cyan-red? FALSE
  set lockdown-cyan-yellow? FALSE
  set lockdown-yellow-red? FALSE
  
  ; initially none of the locations (5 white cirles) are in locked down state, can be enabled from GUI
  set lockdown-blue? FALSE
  set lockdown-pink? FALSE
  set lockdown-red? FALSE
  set lockdown-cyan? FALSE
  set lockdown-yellow? FALSE
   
  ; initially all turtles are not infected in all location (5 white cirles) set to FALSE
  set red-infected? FALSE
  set blue-infected? FALSE
  set pink-infected? FALSE  
  set cyan-infected? FALSE
  set yellow-infected? FALSE
  
  ; initially all turtles are not infected in all location (5 white cirles) and set to FALSE
  set infect-red? FALSE
  set infect-blue? FALSE
  set infect-pink? FALSE
  set infect-yellow? FALSE
  set infect-cyan? FALSE
  
  ; initially local mobility of turtles  in all location (5 white cirles) and set to TRUE
  set local-mobility-red-allow? TRUE
  set local-mobility-yellow-allow? TRUE
  set local-mobility-pink-allow? TRUE
  set local-mobility-cyan-allow? TRUE
  set local-mobility-blue-allow? TRUE
  
  ; one turtle infecting other is initialized to FALSE, can be enabled from GUI
  set propagate-infection? FALSE
  
  ; initially recovery of turtles is set to FALSE, can be enabled from GUI
  set start-recovery? FALSE
  
  ; initially turtles dont take precuations against infection
  set take-precautions? FALSE
  
  ; this set value 
  set lock_radius 4
end
;-----------------------------------------------------------------------------------------------------------
; this is the main function invoked by "go" procedure
to static-go
  
  ; keep the turtles moving till local mobility is allowed
  ask turtles with [color != white]
  [
    
    let new_x my-x + (-2) + random (4)
    
    let new_y my-y + (-2) + random (4)
    
    ; when there is no route inter-location mobility enabled
    ifelse (start-mobility = 0)
    [
      ; move the turtles in their respective location 
      if (sqrt((new_x - my-cluster-center-x)*(new_x - my-cluster-center-x) + (new_y - my-cluster-center-y)*(new_y - my-cluster-center-y)) < 2.5)
      [
        facexy new_x new_y
        forward 2
      ]
    ]
    ; when there are routes enabled, i.e., start-mobility = 1, at least one of the routes are enabled.
    [
      
      ; if none of the routes of red turtles (centre) location are not enabled, always allow local mobility if set by user
      if (not route-blue-red-enable?) and (not route-pink-red-enable?) and (not route-yellow-red-enable?) and (not route-cyan-red-enable?) and (local-mobility-red-allow?)
      [
          ask turtles with [color = red]
          [
            facexy (15 + random(25 - 15)) (15 + random(25 - 15))
            forward 1
            set my-new-home red
          ]
      ]
      
      ; if none of the routes of blue turtles (bottom-left) location are not enabled, always allow local mobility if set by user
      if (not route-blue-red-enable?) and (not route-blue-yellow-enable?) and (not route-blue-pink-enable?) and (local-mobility-blue-allow?)
      [
          ask turtles with [color = blue]
          [
            facexy (7 + random(12 - 7)) (7 + random(12 - 7)) 
            forward 1
            set my-new-home blue
         ]
      ]
      
      ; if none of the routes of yellow turtles (top-left) location are not enabled, always allow local mobility if set by user
      if (not route-blue-yellow-enable?) and (not route-cyan-yellow-enable?) and (not route-yellow-red-enable?) and (local-mobility-yellow-allow?)
      [
        ask turtles with [color = yellow]
        [
            facexy (7 + random(12 - 7)) (25 + random(35 - 25))
            forward 1
            set my-new-home yellow
        ]
      ]
      
      ; if none of the routes of pink turtles (right-bottom) location are not enabled, always allow local mobility if set by user
      if (not route-blue-pink-enable?) and (not route-cyan-pink-enable?) and (not route-pink-red-enable?) and (local-mobility-pink-allow?)
      [
        ask turtles with [color = pink]
        [
            facexy (25 + random(35 - 25)) (7 + random(12 - 7))  
            forward 1
            set my-new-home pink
        ]
      ]
      
      ; if none of the routes of cyan turtles (right-top) location are not enabled, always allow local mobility if set by user
      if (not route-cyan-pink-enable?) and (not route-cyan-yellow-enable?) and (not route-cyan-red-enable?) and (local-mobility-cyan-allow?)
      [
        ask turtles with [color = 75]
        [
            facexy (25 + random(35 - 25)) (25 + random(35 - 25))  
            forward 1
            set my-new-home 75
        ]
      ]
      
    ]
    
    ; if the route blue<->red is not locked down
    if (not lockdown-blue-red?)
    [
    
      ; if route blue<->red is configured
      ifelse (route-blue-red-enable?)
      [
        ; some routes are enabled, then turtles are moving across locations
        set start-mobility 1
        
        ; set mobility blue<->red TRUE
        set mobility-blue-red? TRUE
        
        ; allow local mobility in red circle (centre)
        set local-mobility-red-allow? TRUE
        
        ; allow local mobility in blue circle (bottom-left)
        set local-mobility-blue-allow? TRUE
        
        ; turtles are divided in to 9 groups by mobility by function mobility-direction 0-8 denoted by my-headling
        ; turtles in group 0 always stay at home location
        ; turtles in group 1 move along blue <-> yellow
        ; turtles in group 2 move along blue <-> pink
        ; turtles in group 3 move along pink <-> cyan
        ; turtles in group 4 move along cyan <-> yellow
        ; turtles in group 5 move along blue <-> red
        ; turtles in group 6 move along pink <-> red
        ; turtles in group 7 move along cyan <-> red
        ; turtles in group 8 move along yellow <-> red   
        
        ; note red turtles will move along routes 5,6,7,8 provided their mobility along routes are allowed         
        ask turtles with [color = red]
        [
          ; hence group of red turtles 0-4 remain at home (centre)
          ; in this part of the code route 5 is considered, hence other routes 6,7,8 will have their 
          ; red turtles at home if mobility along those routes are not enabled
          if (my-heading = 0)  
          or ((my-heading = 1))
          or ((my-heading = 2)) 
          or ((my-heading = 3)) 
          or ((my-heading = 4))
          or ((not mobility-pink-red?) and (my-heading = 6))
          or ((not mobility-cyan-red?) and (my-heading = 7))
          or ((not mobility-yellow-red?) and (my-heading = 8))
          [
            facexy (15 + random(25 - 15)) (15 + random(25 - 15))
            forward 1
            set my-new-home red
          ] 
        ]
      
        ; note blue turtles will move along routes 1,2,5 provided their mobility along routes are allowed 
        ask turtles with [color = blue]
        [
        
          ; hence group of blue turtles 0,3,4,6,7,8 remain at home (bottom-left)
          ; in this part of the code route 5 is considered, hence other routes 1,2 will have their 
          ; blue turtles at home if mobility along those routes are not enabled
          if (my-heading = 0)  
          or ((my-heading = 3)) 
          or ((my-heading = 4)) 
          or ((my-heading = 6))
          or ((my-heading = 7))
          or ((my-heading = 8))
          or ((not mobility-blue-yellow?) and (my-heading = 1))
          or ((not mobility-blue-pink?) and (my-heading = 2))
          [
            facexy (7 + random(12 - 7)) (7 + random(12 - 7)) 
            forward 1
            set my-new-home blue
          ]
        ] 
          
        ; some of the blue turtles in group 5 move from blue (bottom-left) to red (centre)
        ask n-of (5 + random (10 - 5)) turtles with [color = blue]
        [
          if (my-heading = 5)
          [
            facexy (18 + random(22 - 18)) (18 + random(22 - 18))
            forward 2
            set my-new-home red
          ]
        ]
          
        ; some of the blue turtles in group 5 who moved from blue (bottom-left) to red (centre) 
        ; return to blue (bottom-left)
        ask n-of (5 + random (10 - 5)) turtles with [color = blue]
        [
          if (my-heading = 5) and (my-new-home = red)
          [
            facexy (8 + random(12 - 8)) (8 + random(12 - 8))
            forward 2
          ]
        ]
          
        ;some of the red turtles in group 5 move from    
        ask n-of (5 + random (10 - 5)) turtles with [color = red]
        [
          if (my-heading = 5)
          [
            facexy (8 + random(12 - 8)) (8 + random(12 - 8))
            forward 2
            set my-new-home blue
          ]
        ]
          
        ; some of the red turtles in group 5 who moved from red (centre) to blue (bottom-left) 
        ; return to red (centre)
        ask n-of (5 + random (10 - 5)) turtles with [color = red]
        [
          if (my-heading = 5) and (my-new-home = blue)
          [
            facexy (18 + random(22 - 18)) (18 + random(22 - 18))
            forward 2
          ]
        ]  
       
      ]
      [
        ; once route blue<->red is configured it cannot be disabled from GUI during simulation
        ; however can be locked and unlocked
        if (mobility-blue-red?)
        [
          set route-blue-red-enable? TRUE
        ]
      ]
    ]
    
    ; if the route blue<->yellow is not locked down
    if (not lockdown-blue-yellow?)
    [
      ; if route blue<->yellow is configured
      ifelse (route-blue-yellow-enable?)
      [
        ; some routes are enabled, then turtles are moving across locations
        set start-mobility 1
        
        ; set mobility blue<->red TRUE
        set mobility-blue-yellow? TRUE
        
        ; allow local mobility in yellow circle (top-left)
        set local-mobility-yellow-allow? TRUE
        
        ; allow local mobility in blue circle (bottom-left)
        set local-mobility-blue-allow? TRUE 
        
        ; note yellow turtles will move along routes 1,4,8 provided their mobility along routes are allowed    
        ask turtles with [color = yellow]
        [
          ; hence group of yellow turtles 0,2,3,5,6,7 remain at home (top-left)
          ; in this part of the code route 1 is considered, hence other routes 4,8 will have their 
          ; yellow turtles at home if mobility along those routes are not enabled
          if (my-heading = 0)  
          or ((my-heading = 2))
          or ((my-heading = 3)) 
          or ((my-heading = 5)) 
          or ((my-heading = 6))
          or ((my-heading = 7))
          or ((not mobility-cyan-yellow?) and (my-heading = 4))
          or ((not mobility-yellow-red?) and (my-heading = 8))
          [
            facexy (7 + random(12 - 7)) (25 + random(35 - 25)) 
            forward 1
            set my-new-home yellow
          ]
        ]
      
        ; note blue turtles will move along routes 1,2,5 provided their mobility along routes are allowed
        ask turtles with [color = blue]
        [
          ; hence group of blue turtles 0,3,4,6,7,8 remain at home (bottom-left)
          ; in this part of the code route 1 is considered, hence other routes 2,5 will have their 
          ; yellow turtles at home if mobility along those routes are not enabled
          if (my-heading = 0)  
          or ((my-heading = 3)) 
          or ((my-heading = 4)) 
          or ((my-heading = 6))
          or ((my-heading = 7))
          or ((my-heading = 8))
          or ((not mobility-blue-pink?) and (my-heading = 2))
          or ((not mobility-blue-red?) and (my-heading = 5))
          [
            facexy (7 + random(12 - 7)) (7 + random(12 - 7))
            forward 1
            set my-new-home blue
          ]
        ]
        
        ; some of the yellow turtles in group 1 move from yellow (top-left) to blue (bottom-left)
        ask n-of (5 + random (10 - 5)) turtles with [color = yellow]
        [
          if (my-heading = 1)
          [
            facexy (8 + random(12 - 8)) (8 + random(12 - 8)) 
            forward 2 
            set my-new-home blue
          ]   
        ]
        
        ; some of the yellow turtles in group 1 who moved from yellow (top-left) to blue (bottom-left) 
        ; return to yellow (top-left)
        ask n-of (5 + random (10 - 5)) turtles with [color = yellow]
        [
          if (my-heading = 1) and (my-new-home = blue)
          [
             facexy (8 + random(12 - 8)) (28 + random(32 - 28)) 
             forward 2 
          ]        
        ]
          
        ; some of the blue turtles in group 1 move from blue (bottom-left) to yellow (top-left)
        ask n-of (5 + random (10 - 5)) turtles with [color = blue]
        [
           if (my-heading = 1)
           [
              facexy (8 + random(12 - 8)) (28 + random(32 - 28)) 
              forward 2
              set my-new-home yellow
           ]  
        ]   
         
        ; some of the blue turtles in group 1 who moved from blue (bottom-left) to yellow (top-left) 
        ; return to blue (bottom-left)
        ask n-of (5 + random (10 - 5)) turtles with [color = blue]
        [
          if (my-heading = 1) and (my-new-home = yellow)
          [
             facexy (8 + random(12 - 8)) (8 + random(12 - 8))
             forward 2 
          ]
        ]   
       
      ]
      [
        ; once route blue<->yellow is configured it cannot be disabled from GUI during simulation
        ; however can be locked and unlocked
        if (mobility-blue-yellow?)
        [
          set route-blue-yellow-enable? TRUE
        ]
      ]
    ]
    
    ; if the route blue<->pink is not locked down
    if (not lockdown-blue-pink?)
    [
    
      ; if route blue<->pink is configured
      ifelse (route-blue-pink-enable?)
      [
        ; some routes are enabled, then turtles are moving across locations
        set start-mobility 1  
        
        ; set mobility blue<->red TRUE
        set mobility-blue-pink? TRUE
        
        ; allow local mobility in pink circle (bottom-right)
        set local-mobility-pink-allow? TRUE
        
        ; allow local mobility in blue circle (bottom-left)
        set local-mobility-blue-allow? TRUE
        
        ; note blue turtles will move along routes 1,2,5 provided their mobility along routes are allowed  
        ask turtles with [color = blue]
        [
          ; hence group of blue turtles 0,3,4,6,7,8 remain at home (bottom-left)
          ; in this part of the code route 2 is considered, hence other routes 1,5 will have their 
          ; yellow turtles at home if mobility along those routes are not enabled
          if (my-heading = 0)  
          or ((my-heading = 3)) 
          or ((my-heading = 4))
          or ((my-heading = 6))
          or ((my-heading = 7))
          or ((my-heading = 8))
          or ((not mobility-blue-yellow?) and (my-heading = 1))
          or ((not mobility-blue-yellow?) and (my-heading = 5))
          [
            facexy (7 + random(12 - 7)) (7 + random(12 - 7))
            forward 1
          ]
        ]
        
        ; note pink turtles will move along routes 2,3,6 provided their mobility along routes are allowed  
        ask turtles with [color = pink]
        [
          ; hence group of pink turtles 0,1,4,5,7,8 remain at home (bottom-right)
          ; in this part of the code route 2 is considered, hence other routes 3,6 will have their 
          ; pink turtles at home if mobility along those routes are not enabled
          if (my-heading = 0)  
          or ((my-heading = 1))
          or ((my-heading = 4))
          or ((my-heading = 5))
          or ((my-heading = 7))
          or ((my-heading = 8))
          or ((not mobility-cyan-pink?) and (my-heading = 3))
          or ((not mobility-pink-red?) and (my-heading = 6))
          [
            facexy (25 + random(35 - 25)) (7 + random(12 - 7))  
            forward 1
          ]
        ]
        
        ; some of the pink turtles in group 2 move from pink (bottom-right) to blue (bottom-left)
        ask  n-of (5 + random (10 - 5)) turtles with [color = pink] 
        [
            
          if (my-heading = 2)
          [
            facexy (8 + random(12 - 8)) (8 + random(12 - 8)) 
            forward 2   
            set my-new-home blue
          ] 
        ]
          
          
        ; some of the pink turtles in group 2 who moved from pink (bottom-right) to blue (bottom-left)
        ; return to pink (bottom-right)
        ask n-of (5 + random (10 - 5)) turtles with [color = pink]
        [
          if (my-heading = 2) and (my-new-home = blue)
          [
            facexy (28 + random(32 - 28)) (8 + random(12 - 8)) 
            forward 2  
              
          ]       
        ]
        
        ; some of the  blue turtles in group 2 move from blue (bottom-left) to pink (bottom-right) 
        ask n-of (5 + random (10 - 5)) turtles with [color = blue] 
        [
          if (my-heading = 2)
          [
            facexy (28 + random(32 - 28)) (8 + random(12 - 8)) 
            forward 2 
            set my-new-home pink
          ]
        ]        
         
        ; some of the blue turtles in group 2 who moved from blue (bottom-left) to pink (bottom-right)
        ; return to blue (bottom-left)
        ask n-of (5 + random (10 - 5)) turtles with [color = blue]
        [
          if (my-heading = 2) and (my-new-home = pink)
          [  
            facexy (8 + random(12 - 8)) (8 + random(12 - 8)) 
            forward 2  
          ]
        ]    
        
      ]
      [
        ; once route blue<->pink is configured it cannot be disabled from GUI during simulation
        ; however can be locked and unlocked
        if (mobility-blue-pink?)
        [
          set route-blue-pink-enable? TRUE
        ]  
      ]
    ]
    
    ; if the route pink<->red is not locked down
    if (not lockdown-pink-red?)
    [
    
      ; if route pink<->red is configured
      ifelse (route-pink-red-enable?)
      [
      
        ; some routes are enabled, then turtles are moving across locations
        set start-mobility 1
        
        ; set mobility pink<->red TRUE
        set mobility-pink-red? TRUE
        
        ; allow local mobility in red circle (centre)
        set local-mobility-red-allow? TRUE
        
        ; allow local mobility in pink circle (bottom-right)
        set local-mobility-pink-allow? TRUE
      
        ; note red turtles will move along routes 5,6,7,8 provided their mobility along routes are allowed
        ask turtles with [color = red]
        [
          ; hence group of red turtles 0,1,2,3,4 remain at home (centre)
          ; in this part of the code route 6 is considered, hence other routes 5,7,8 will have their 
          ; pink turtles at home if mobility along those routes are not enabled
          if (my-heading = 0)  
          or ((my-heading = 1))
          or ((my-heading = 2)) 
          or ((my-heading = 3)) 
          or ((my-heading = 4)) 
          or ((not mobility-blue-red?) and (my-heading = 5))
          or ((not mobility-cyan-red?) and (my-heading = 7))
          or ((not mobility-yellow-red?) and (my-heading = 8))
          [
            facexy (15 + random(25 - 15)) (15 + random(25 - 15))
            forward 1
            set my-new-home red
          ]
        ; if not moving to any nodes move the rest  
        ]
      
        ; note pink turtles will move along routes 2,3,6 provided their mobility along routes are allowed
        ask turtles with [color = pink]
        [
          ; hence group of pink turtles 0,1,4,5,7,8 remain at home (bottom-right)
          ; in this part of the code route 6 is considered, hence other routes 2,3 will have their 
          ; pink turtles at home if mobility along those routes are not enabled
          if (my-heading = 0)  
          or ((my-heading = 1))
          or ((my-heading = 4)) 
          or ((my-heading = 5))
          or ((my-heading = 7))
          or ((my-heading = 8))
          or ((not mobility-blue-pink?) and (my-heading = 2))
          or ((not mobility-cyan-pink?) and (my-heading = 3)) 
          [
            facexy (25 + random(35 - 25)) (7 + random(12 - 7))  
            forward 1
            set my-new-home pink
          ]
        ]
      
        ; some of the red turtles in group 6 move from red (centre) to pink (bottom-right)
        ask n-of (5 + random (10 - 5)) turtles with [color = red ] 
        [
          if (my-heading = 6)
          [
            facexy (28 + random(32 - 28)) (8 + random(12 - 8)) 
            forward 2 
            set my-new-home pink
          ]
        ]
      
        ; some of the red turtles in group 6 who moved from red (centre) to pink (bottom-right)
        ; return to red (centre)
        ask n-of (5 + random (10 - 5)) turtles with [color = red ] 
        [
          if (my-heading = 6) and (my-new-home = pink)
          [
            facexy (18 + random(22 - 18)) (18 + random(22 - 18))
            forward 2 
          ]
        ]
      
        ; some of the pink turtles in group 6 move from pink (bottom-right) to red (centre) 
        ask n-of (5 + random (10 - 5)) turtles with [color = pink] 
        [
          if (my-heading = 6)
          [
            facexy (18 + random(22 - 18)) (18 + random(22 - 18))
            forward 2   
            set my-new-home red
          ] 
        ]
      
        ; some of the pink turtles in group 6 who moved from pink (bottom-right) to red (centre) 
        ; return to pink (bottom-right)
        ask n-of (5 + random (10 - 5)) turtles with [color = pink] 
        [
          if (my-heading = 6) and (my-new-home = red)
          [
            facexy (28 + random(32 - 28)) (6 + random(12 - 8))  
            forward 2
          ]
        ]  
      ]
      [
        ; once route pink<->red is configured it cannot be disabled from GUI during simulation
        ; however can be locked and unlocked
        if (mobility-pink-red?)
        [
          set route-pink-red-enable? TRUE
        ]
          
      ]
    ]
    ; if the route cyan<->pink is not locked down
    if (not lockdown-cyan-pink?)
    [
      
      ; if route cyan<->pink is configured
      ifelse (route-cyan-pink-enable?)
      [
        ; some routes are enabled, then turtles are moving across locations
        set start-mobility 1 
        
        ; set mobility cyan<->pink TRUE 
        set mobility-cyan-pink? TRUE 
        
        ; allow local mobility in cyan (top-right)
        set local-mobility-cyan-allow? TRUE
        
        ; allow local mobility in pink circle (bottom-right)
        set local-mobility-pink-allow? TRUE
        
        ; note cyan (75 colour code) turtles will move along routes 3,4,7 provided their mobility along routes are allowed  
        ask turtles with [color = 75]
        [
          ; hence group of cyan turtles 0,1,2,5,6,8 remain at home (top-right)
          ; in this part of the code route 3 is considered, hence other routes 4,7 will have their 
          ; cyan  turtles at home if mobility along those routes are not enabled
          if (my-heading = 0)  
          or (my-heading = 1) 
          or (my-heading = 2) 
          or (my-heading = 5) 
          or (my-heading = 6)  
          or (my-heading = 8)
          or ((not mobility-cyan-red?) and (my-heading = 7))
          or ((not mobility-cyan-yellow?) and (my-heading = 4))
          [
            facexy (25 + random(35 - 25)) (25 + random(35 - 25))
            forward 1
          ]
        ]
        ; note pink turtles will move along routes 2,3,6 provided their mobility along routes are allowed  
        ask turtles with [color = pink]
        [
          ; hence group of pink turtles 0,1,4,5,7,8 remain at home (bottom-right)
          ; in this part of the code route 3 is considered, hence other routes 2,6 will have their 
          ; pink turtles at home if mobility along those routes are not enabled
          if (my-heading = 0)  
          or (my-heading = 1) 
          or (my-heading = 4) 
          or (my-heading = 5) 
          or (my-heading = 7) 
          or (my-heading = 8) 
          or ((not mobility-blue-pink?) and (my-heading = 2))
          or ((not mobility-pink-red?) and (my-heading = 6))
          [
            facexy (25 + random(35 - 25)) (7 + random(12 - 7))  
            forward 1
          ]
        ]
        
        ; some of the pink turtles in group 3 move from pink (bottom-right) to cyan (top-right)
        ask n-of (5 + random (10 - 5)) turtles with [color = pink] 
        [
            
          if (my-heading = 3)
          [
            facexy (28 + random(32 - 28)) (28 + random(32 - 28)) 
            forward 2  
            set my-new-home 75 
          ] 
        ]
        
        ; some of the pink turtles in group 3 who moved from pink (bottom-right) to cyan (top-right)
        ; return to pink (bottom-right)
        ask n-of (5 + random (10 - 5)) turtles with [color = pink] 
        [
          if (my-heading = 3) and (my-new-home = 75)
          [
             facexy (28 + random(32 - 28)) (8 + random(12 - 8)) 
             forward 2 
          ]
        ]
          
        ; some of the cyan turtles in group 3 move from cyan (top-right) to pink (bottom-right) 
        ask n-of (5 + random (10 - 5)) turtles with [color = 75]
        [
          if (my-heading = 3)
          [
            facexy (28 + random(32 - 28)) (8 + random(12 - 8)) 
            forward 2 
            set my-new-home pink 
          ]       
        ]
          
        ; some of the cyan turtles in group 3 who moved from cyan (top-right) to pink (bottom-right)
        ; return to pink (bottom-right)
        ask n-of (5 + random (10 - 5)) turtles with [color = 75]
        [
          if (my-heading = 3) and (my-new-home = pink)
          [
            facexy (28 + random(32 - 28)) (28 + random(32 - 28)) 
            forward 2
          ]
        ]    
      ]
      [
        ; once route cyan<->pink is configured it cannot be disabled from GUI during simulation
        ; however can be locked and unlocked
        if (mobility-cyan-pink?)
        [
          set route-cyan-pink-enable? TRUE
        ] 
      ]
    ]
    
    ; if the route cyan<->red is not locked down
    if (not lockdown-cyan-red?)
    [
    
      ; if route cyan<->red is configured
      ifelse (route-cyan-red-enable?)
      [
        ; some routes are enabled, then turtles are moving across locations
        set start-mobility 1
        
        ; set mobility cyan<->red TRUE
        set mobility-cyan-red? TRUE
        
        ; allow local mobility in cyan (top-right)
        set local-mobility-cyan-allow? TRUE
        
        ; allow local mobility in red (centre)
        set local-mobility-red-allow? TRUE
      
        ; note red turtles will move along routes 5,6,7,8 provided their mobility along routes are allowed
        ask turtles with [color = red]
        [
          ; hence group of red turtles 0,1,2,3,4 remain at home (top-right)
          ; in this part of the code route 7 is considered, hence other routes 5,6,8 will have their 
          ; red turtles at home if mobility along those routes are not enabled
          if (my-heading = 0)  
          or ((my-heading = 1))
          or ((my-heading = 2))
          or ((my-heading = 3)) 
          or ((my-heading = 4)) 
          or ((not mobility-blue-red?) and (my-heading = 5))
          or ((not mobility-pink-red?) and (my-heading = 6))
          or ((not mobility-yellow-red?) and (my-heading = 8))
          [
            facexy (15 + random(25 - 15)) (15 + random(25 - 15))
            forward 1
          ]
        ]
        
        ; note cyan (colour code 75) turtles will move along routes 3,4,7 provided their mobility along routes are allowed
        ask turtles with [color = 75]
        [
          ; hence group of red turtles 0,1,2,5,6,8 remain at home (top-right)
          ; in this part of the code route 7 is considered, hence other routes 3,4 will have their 
          ; cyan turtles at home if mobility along those routes are not enabled
          if (my-heading = 0)  
          or ((my-heading = 1))
          or ((my-heading = 2))
          or ((my-heading = 5))
          or ((my-heading = 6))
          or ((my-heading = 8))
          or ((not mobility-cyan-pink?) and (my-heading = 3)) 
          or ((not mobility-cyan-yellow?) and (my-heading = 4)) 
          [
            facexy (25 + random(35 - 25)) (25 + random(35 - 25))
            forward 1
          ]
        ]
        
        ; some of the red turtles in group 7 move from red (centre) to cyan (top-right)  
        ask n-of (5 + random (10 - 5)) turtles with [color = red]
        [  
          if (my-heading = 7)  
          [
            facexy (28 + random(32 - 28)) (28 + random(32 - 28))
            forward 2
            set my-new-home 75
          ]
        ] 
        
        ; some of the red turtles in group 7 who moved from red (centre) to cyan (top-right)
        ; return to red (centre) 
        ask n-of (5 + random (10 - 5)) turtles with [color = red]
        [  
          if (my-heading = 7) and (my-new-home = 75)
          [
            facexy (18 + random(22 - 18)) (18 + random(22 - 18))
            forward 2
          ]
        ]
       
        ; some of the cyan turtles in group 7 move from cyan (top-right) to red (centre)
        ask n-of (5 + random (10 - 5)) turtles with [color = 75]
        [  
          if (my-heading = 7)  
          [
            facexy (18 + random(22 - 18)) (18 + random(22 - 18))
            forward 2
            set my-new-home red
          ]
        ] 
      
        ; some of the cyan turtles in group 7 who moved from cyan (top-right) to red (centre)
        ; return to cyan (top-right)
        ask n-of (5 + random (10 - 5)) turtles with [color = 75]
        [  
          if (my-heading = 7)  and (my-new-home = red)
          [
            facexy (28 + random(32 - 28)) (28 + random(32 - 28))
            forward 2
          ]
        ] 
       
      ]
      [
        ; once route cyan<->red is configured it cannot be disabled from GUI during simulation
        ; however can be locked and unlocked
        if (mobility-cyan-red?)
        [
            set route-cyan-red-enable? TRUE
        ]
      ]
    ]
    
    ; if the route cyan<->yellow is not locked down
    if (not lockdown-cyan-yellow?)
    [
      ; if route cyan<->yellow is configured
      ifelse (route-cyan-yellow-enable?)
      [
        ; some routes are enabled, then turtles are moving across locations
        set start-mobility 1
        
        ; set mobility cyan<->yellow TRUE
        set mobility-cyan-yellow? TRUE
        
        ; allow local mobility in cyan (top-right)
        set local-mobility-cyan-allow? TRUE
        
        ; allow local mobility in yellow (top-left)
        set local-mobility-yellow-allow? TRUE
          
        ; note cyan turtles (colour code 75) will move along routes 3,4,7 provided their mobility along routes are allowed
        ask turtles with [color = 75]
        [
          ; hence group of cyan turtles 0,1,2,5,6,8 remain at home red (centre)
          ; in this part of the code route 4 is considered, hence other routes 3,7 will have their 
          ; cyan turtles at home if mobility along those routes are not enabled
          if (my-heading = 0)  
          or (my-heading = 1) 
          or (my-heading = 2) 
          or (my-heading = 5) 
          or (my-heading = 6)  
          or (my-heading = 8)
          or ((not mobility-cyan-red?) and (my-heading = 7))
          or ((not mobility-cyan-pink?) and (my-heading = 3))
          [
            facexy (25 + random(35 - 25)) (25 + random(35 - 25))
            forward 1
          ]
        ]
        
        ; note yellow turtles will move along routes 1,4,8 provided their mobility along routes are allowed  
        ask turtles with [color = yellow]
        [
          ; hence group of yellow turtles 0,2,3,5,6,7 remain at home (top-left)
          ; in this part of the code route 7 is considered, hence other routes 1,8 will have their 
          ; yellow turtles at home if mobility along those routes are not enabled
          if (my-heading = 0)  
          or (my-heading = 2) 
          or (my-heading = 3) 
          or (my-heading = 5) 
          or (my-heading = 6) 
          or (my-heading = 7) 
          or ((not mobility-yellow-red?) and (my-heading = 8))
          or ((not mobility-blue-yellow?) and (my-heading = 1))
          [
            facexy (7 + random(12 - 7)) (25 + random(35 - 25))   
            forward 1
          ]
        ]
          
        ; some of the cyan turtles in group 4 move from  cyan (top-right)  to yellow (top-left)
        ask n-of (5 + random (10 - 5)) turtles with [color = 75] 
        [
          if (my-heading = 4)
          [
            facexy (8 + random(12 - 8)) (28 + random(32 - 28))
            forward 2 
            set my-new-home yellow
          ]
        ]
          
        ; some of the cyan turtles in group 4 who moved from cyan (top-right) to yellow (top-left)  
        ; return to cyan (top-right) 
        ask n-of (5 + random (10 - 5)) turtles with [color = 75] 
        [  
          if (my-heading = 4) and (my-new-home = yellow)
          [
            facexy (28 + random(32 - 28)) (28 + random(32 - 28))
            forward 2   
          ] 
        ]
          
        ; some of the yellow turtles in group 4 move from  yellow (top-left) to cyan (top-right) 
        ask n-of (5 + random (10 - 5)) turtles with [color = yellow]
        [
          if (my-heading = 4)
          [
            facexy (28 + random(32 - 28)) (28 + random(32 - 28))
            forward 2
            set my-new-home 75
          ] 
        ] 
          
        ; some of the yellow turtles in group 4 who moved from yellow (top-left) to cyan (top-right) 
        ; return to  yellow (top-left) 
        ask n-of (5 + random (10 - 5)) turtles with [color = yellow]
        [
          if (my-heading = 4) and (my-new-home = 75)
          [
            facexy (8 + random(12 - 8)) (28 + random(32 - 28)) 
            forward 2  
          ]       
        ]  
      ]
      [
        ; once route cyan<->yellow is configured it cannot be disabled from GUI during simulation
        ; however can be locked and unlocked
        if (mobility-cyan-yellow?)
        [
          set route-cyan-yellow-enable? TRUE
        ]
      ]
    ]
    
    ; if the route yellow<->red is not locked down
    if (not lockdown-yellow-red?)
    [
      ; if route yellow<->red is configured
      ifelse (route-yellow-red-enable?)
      [
        ; some routes are enabled, then turtles are moving across locations
        set start-mobility 1
        
        ; set mobility yellow<->red TRUE
        set mobility-yellow-red? TRUE
        
        ; allow local mobility in red (centre)
        set local-mobility-red-allow? TRUE
        
        ; allow local mobility in yellow (top-left)
        set local-mobility-yellow-allow? TRUE
      
        ; note red turtles will move along routes 5,6,7,8 provided their mobility along routes are allowed
        ask turtles with [color = red]
        [
          ; hence group of yellow turtles 0,1,2,3,4 remain at home red (centre)
          ; in this part of the code route 8 is considered, hence other routes 5,6,7 will have their 
          ; yellow turtles at home if mobility along those routes are not enabled
          if (my-heading = 0)  
          or ((my-heading = 1))
          or ((my-heading = 2))
          or ((my-heading = 3)) 
          or ((my-heading = 4)) 
          or ((not mobility-blue-red?) and (my-heading = 5))
          or ((not mobility-pink-red?) and (my-heading = 6))
          or ((not mobility-cyan-red?) and (my-heading = 7))
          [
            facexy (15 + random(25 - 15)) (15 + random(25 - 15))
            forward 1
          ]
        ]
        
        ; note yellow turtles will move along routes 1,4,8 provided their mobility along routes are allowed
        ask turtles with [color = yellow]
        [
          ; hence group of yellow turtles 0,2,3,5,6,7 remain at home yellow (top-left)
          ; in this part of the code route 8 is considered, hence other routes 1,4 will have their 
          ; yellow turtles at home if mobility along those routes are not enabled
          if (my-heading = 0)  
          or ((my-heading = 2))
          or ((my-heading = 3)) 
          or ((my-heading = 5)) 
          or ((my-heading = 6))
          or ((my-heading = 7))
          or ((not mobility-blue-yellow?) and (my-heading = 1))
          or ((not mobility-cyan-yellow?) and (my-heading = 4)) 
          [
            facexy (7 + random(13 - 7)) (25 + random(35 - 25)) 
            forward 1
          ]
        ]
        
        ; some of the yellow turtles in group 8 move from  yellow (top-left) to red (centre) 
        ask n-of (5 + random (10 - 5)) turtles with [color = yellow]
        [ 
          if (my-heading = 8)
          [
            facexy (18 + random(22 - 18)) (18 + random(22 - 18))
            forward 2
            set my-new-home red
          ]  
        ]
        
        ; some of the yellow turtles in group 8 who moved from yellow (top-left) to red (centre)  
        ; return to yellow (top-left) 
        ask n-of (5 + random (10 - 5)) turtles with [color = yellow]
        [ 
          if (my-heading = 8) and (my-new-home = red)
          [
            facexy (8 + random(12 - 8)) (28 + random(32 - 28))
            forward 2
          ]  
        ]
        
        ; some of the red turtles in group 8 move from  red (centre) to yellow (top-left)
        ask n-of (5 + random (10 - 5)) turtles with [color = red]
        [ 
          if (my-heading = 8)
          [
            facexy (8 + random(12 - 8)) (28 + random(32 - 28))
            forward 2
            set my-new-home yellow
          ]  
        ]
      
        ; some of the red turtles in group 8 who moved from red (centre) to yellow (top-left)  
        ; return to red (centre)
        ask n-of (5 + random (10 - 5)) turtles with [color = red]
        [ 
          if (my-heading = 8) and (my-new-home = yellow)
          [
            facexy (18 + random(22 - 18)) (18 + random(22 - 18))
            forward 2
          ]  
        ]
      ]
      [
        ; once route yellow<->red is configured it cannot be disabled from GUI during simulation
        ; however can be locked and unlocked
        if (mobility-yellow-red?)
        [
            set route-yellow-red-enable? TRUE
        ]  
      ]
    ]
    
    ; calculate the percentage of infected turtles
    set percent_infected (((count turtles with [(shape = "triangle")]) * 100))/(count turtles  with [color != white])
  ]
end
;-----------------------------------------------------------------------------------------------------------
; this functions allows turtles to recover
to do-recovery
  if (start-recovery?)
  [
    ; count number infected turtles
    let infected_turtles (count turtles with [(shape = "triangle")])
    
    ; calculate percentage of turtles to be moved to recovered state
    let recovered_turtles round(infected_turtles * 0.05)
    
    ask n-of recovered_turtles turtles with [shape = "triangle"]
    [
      set shape "star"
      set size 1
      set my-infection? FALSE
    ]
    ifelse (recovered_turtles < 1) ;compensate for left recovered_turtles round(infected_turtles * 0.1) when less than 1
    [
      ask turtles with [shape = "triangle"]
      [
        ; convert their sape to star
        set shape "star"
        
        set size 1
        
        ; set infection state for false
        set my-infection? FALSE
        
        ; all infected turtles have recovered
        show "NO TURTLES INFECTED!!!"
      ]
    ]
    ; recovered_turtles >= 1
    [
      ; move some of the infected turtles to 
      ask n-of recovered_turtles turtles with [shape = "triangle"]
      [
        ; convert their sape to star
        set shape "star"
        
        set size 1
        
        ; set infection state for false
        set my-infection? FALSE
      ]
    ]
  ]
  
  ; calculate percentage of recovered tutles
  let percent_recovered_turtles count turtles with [shape = "star"]
  
  set percent_recovered (percent_recovered_turtles * 100)/(count turtles  with [color != white])
  
end
;-----------------------------------------------------------------------------------------------------------
; this function allows turtles to take precautions
to do-precautions
  
  ; if agents take precaution, set in GUI 
  ifelse (take-precautions?)
  [
    
    ; count turtles which who are not taking precautions and also ignore the white location circles
    let total_turtles (count turtles with [(shape != "circle 2") and (shape != "square")])
    
    ; assumed each iteration max. of 5 percent of the turtles take precuations
    let carefull_turtles round(total_turtles * 0.05)
    
    ; ask some of the 10% turtles to take precautions
    ask n-of carefull_turtles turtles with [(shape != "circle 2") and (shape != "square")]
    [ 
      ; change the shape from circle to square
      if (shape = "circle")
      [
        ; set the attribute of precautions for the turtle to TRUE
        set my-precautions? TRUE
        
        set shape "square"
        set size 1
      ]
    ]
  ]
  [
    let current_carefull_turtles count turtles with [shape = "square"]
    ; when precautions is disabled, set in GUI, change the shape back to circle
    ask n-of random(round(current_carefull_turtles * 0.1)) turtles with [shape = "square"]
    [
      set shape "circle"
      set size 0.25
      set my-precautions? FALSE
    ]
  ]
  
  ; calculate the percentage of turtles taking precaution to be displayed in the plot
  let precautioned_turtles count turtles with [(shape = "square")]
  set percent_precautioned (precautioned_turtles * 100)/(count turtles with [(shape != "circle 2")])
  
end
;-----------------------------------------------------------------------------------------------------------
; function to start infection in all the 5 locations
to start-infection
  
  ; check if red turtles (centre) are configured to be infected
  ifelse (infect-red? = TRUE) and (red-infected? = FALSE)
  [
    ; the red turtles infected to TRUE to indicated red turtles as infected
    set red-infected? TRUE
    
    ; infect 5 random turtles, can be changed
    ask n-of random(5) turtles  with [color = red] 
    [
      ; set infected turtle as triangle
      set shape "triangle" 
      
      set size 1 
      
      ; set its attributed to infected
      set my-infection? TRUE
    ]
  ]
  [
    ; once set by the GUI, infect-red remains TRUE
    if (red-infected?)
    [
      set infect-red? TRUE
    ]
  ]
  
  ; check if blue turtles (bottom-left) are configured to be infected
  ifelse (infect-blue? = TRUE) and (blue-infected? = FALSE)
  [
    ; the blue turtles infected to TRUE to indicated red turtles as infected
    set blue-infected? TRUE
    
    ; infect 5 random turtles, can be changed
    ask n-of random(5) turtles  with [color = blue] 
    [
      ; set infected turtle as triangle
      set shape "triangle" 
      set size 1 
      
      ; set its attributed to infected
      set my-infection? TRUE
    ]
  ]
  [
    ; once set by the GUI, infect-blue remains TRUE
    if (blue-infected?)
    [
      set infect-blue? TRUE
    ]
  ]
  
  ; check if pink turtles (bottom-right) are configured to be infected
  ifelse (infect-pink? = TRUE) and (pink-infected? = FALSE)
  [
    ; the pink turtles infected to TRUE to indicated red turtles as infected
    set pink-infected? TRUE
    
    ; infect 5 random turtles, can be changed
    ask n-of random(5) turtles  with [color = pink] 
    [
      ; set infected turtle as triangle
      set shape "triangle" 
      set size 1 
      
      ; set its attributed to infected
      set my-infection? TRUE
    ]
  ]
  [
    ; once set by the GUI, infect-pink remains TRUE
    if (pink-infected?)
    [
      set infect-pink? TRUE
    ]
  ]
  
  ; check if cyan (colour code 75) turtles (top-right) are configured to be infected
  ifelse (infect-cyan? = TRUE) and (cyan-infected? = FALSE)
  [
    ; the cyan turtles infected to TRUE to indicated red turtles as infected
    set cyan-infected? TRUE
    
    ; infect 5 random turtles, can be changed
    ask n-of random(5) turtles  with [color = 75] 
    [
      ; set infected turtle as triangle
      set shape "triangle" 
      set size 1 
      
      ; set its attributed to infected
      set my-infection? TRUE
    ]
  ]
  [
    ; once set by the GUI, infect-cyan remains TRUE
    if (cyan-infected?)
    [
      set infect-cyan? TRUE
    ]
  ]
  
  ; check if yellow turtles (top-right) are configured to be infected
  ifelse (infect-yellow? = TRUE) and (yellow-infected? = FALSE)
  [
    ; the yellow turtles infected to TRUE to indicated red turtles as infected
    set yellow-infected? TRUE
    
    ; infect 5 random turtles, can be changed
    ask n-of random(5) turtles  with [color = yellow] 
    [
      ; set infected turtle as triangle
      set shape "triangle" 
      set size 1 
      
      ; set its attributed to infected
      set my-infection? TRUE
    ]
  ]
  [
    ; once set by the GUI, infect-yellow remains TRUE
    if (yellow-infected?)
    [
      set infect-yellow? TRUE
    ]
  ]
  
  ; check if propagate infection is set in GUI
  if (propagate-infection?)
  [
    ; ask each infected turtles to propagate to others
    ask turtles with [(shape = "triangle") and ( size = 1)]
    [
      ask neighbors 
      [
        ; if any other turtle 
        ask turtles-here with [(shape != "triangle") and (shape != "circle 2")]
        [
          ; with immunity less than 3 and certain probability of getting infection and not taking precautions gets infected
          if ((my-immunity < 3) and toss-a-coin? and (not my-precautions?)) 
          [
            ; set infected turtle as triangle
            set shape "triangle" 
            set size 1 
            
            ; set its attributed to infected
            set my-infection? TRUE
          ]
        ]
      ]
    ]
  ]
  
end
;-----------------------------------------------------------------------------------------------------------
; function to lock down an interface
to static-lockdown-interface
  
  ; check if the interface blue<->red is configured
  ifelse (route-blue-red-enable?) 
  [
    ; if interface blue<->red is locked down
    if (lockdown-blue-red?)
    [
      ;show "lockdown-blue-red"    
      ask turtles with [color = red]
      [
        ; as explained above some red turtles stay in red location (centre)
        if (my-heading = 0)  
        or ((my-heading = 1))
        or ((my-heading = 2)) 
        or ((my-heading = 3)) 
        or ((my-heading = 4))
        or ((not mobility-pink-red?) and (my-heading = 6))
        or ((not mobility-cyan-red?) and (my-heading = 7))
        or ((not mobility-yellow-red?) and (my-heading = 8))
        [
          
          set my-new-home red
        
          ; if local mobility is allowed, then red turtles keep moving locally 
          if (local-mobility-red-allow?)
          [
            facexy (15 + random(25 - 15)) (15 + random(25 - 15))
            forward 2
          ]
        ]  
      ]
      
      ; as explained above some blue turtles stay in blue location (bottom-left)
      ask turtles with [color = blue]
      [
        if (my-heading = 0)  
        or ((not mobility-blue-yellow?) and (my-heading = 1))
        or ((not mobility-blue-pink?) and (my-heading = 2))
        or ((my-heading = 3)) 
        or ((my-heading = 4)) 
        or ((my-heading = 6))
        or ((my-heading = 7))
        or ((my-heading = 8))
        [
          set my-new-home blue
          
          ; if local mobility is allowed, then blue turtles keep moving locally      
          if (local-mobility-blue-allow?)
          [
              facexy (7 + random(13 - 7)) (7 + random(13 - 7)) 
              forward 2
          ]
        ]
      ] 
      
      ; red turtles move from blue to red  
      ask turtles with [color = red]
      [
        ; blue <-> red interface
        if ((my-heading = 5))
        [
          set my-new-home blue
        
          ; red turtles along blue <-> red interface keep moving till they reach blue (bottom-left)
          ifelse (sqrt((xcor - 10)*(xcor - 10) + (ycor - 10)*(ycor - 10)) > lock_radius)
          [
            facexy (8 + random(12 - 8)) (8 + random(12 - 8)) 
            forward 2
          ]
          [
            ; if local mobility in blue (bottom-left) is allowed, red turtles move locally 
            if (local-mobility-blue-allow?)
            [
              facexy (7 + random(13 - 7)) (7 + random(13 - 7)) 
              forward 2
            ]
          ]
        ]   
      ]
     
      ; blue turtles move from blue to red 
      ask turtles with [color = blue]
      [
        ; blue <-> red interface
        if ((my-heading = 5))
        [
          set my-new-home red
        
          ; blue turtles along blue <-> red interface keep moving till they reach red (centre)
          ifelse (sqrt((xcor - 20)*(xcor - 20) + (ycor - 20)*(ycor - 20)) > lock_radius)
          [
            facexy (18 + random(22 - 18)) (18 + random(22 - 18))
            forward 2
          ]
          [
            ; if local mobility in  red (centre) is allowed, blue turtles move locally
            if (local-mobility-red-allow?)
            [
              facexy (18 + random(22 - 18)) (18 + random(22 - 18))
              forward 2
            ]
          ]
        ]   
      ]
    ]
  ]
  [
    ; blue <-> red interface is not configured then it cannot be locked down
    set lockdown-blue-red? FALSE
  ]
  
  ; check if the interface blue<->yellow is configured
  ifelse (route-blue-yellow-enable?) 
  [
    ; if interface blue<->yellow is locked down
    if (lockdown-blue-yellow?)
    [
    
      ;show "lockdown-blue-yellow" 
      ; as explained above some yellow turtles stay in yellow location (top-left)
      ask turtles with [color = yellow]
      [
        if (my-heading = 0)  
        or (my-heading = 2)
        or (my-heading = 3)
        or (my-heading = 5)
        or (my-heading = 6)
        or (my-heading = 7)
        or ((not mobility-blue-pink?) and (my-heading = 4))
        or ((not mobility-blue-red?) and (my-heading = 8))
        [
          set my-new-home yellow
          
          ; if local mobility is allowed, then yellow turtles keep moving locally
          if (local-mobility-yellow-allow?)
          [
            facexy (8 + random(12 - 8)) (28 + random(32 - 28)) 
            forward 1
          ]
        ]
      ] 
    
      ; as explained above some blue turtles stay in blue location (bottom-left)
      ask turtles with [color = blue]
      [
        if (my-heading = 0)  
        or (my-heading = 3)
        or (my-heading = 4)
        or (my-heading = 6)
        or (my-heading = 7)
        or (my-heading = 8)
        or ((not mobility-blue-pink?) and (my-heading = 2))
        or ((not mobility-blue-red?) and (my-heading = 5))
        [
          set my-new-home blue
        
          ; if local mobility is allowed, then blue turtles keep moving locally
          if (local-mobility-blue-allow?)
          [
              facexy (8 + random(12 - 8)) (8 + random(12 - 8))
              forward 1
          ]
        ]
      ]
      
      
      ; yellow turtles move from yellow to blue
      ask turtles with [color = yellow]
      [
        ; blue <-> yellow interface
        if (my-heading = 1)
        [
          set my-new-home blue
        
          ; yellow turtles along blue <-> yellow interface keep moving till they reach blue (bottom-left)
          ifelse (sqrt((xcor - 10)*(xcor - 10) + (ycor - 10)*(ycor - 10)) > lock_radius)
          [
            facexy (8 + random(12 - 8)) (8 + random(12 - 8)) 
            forward 2
          ]
          [
            ; if local mobility in  blue (bottom-left) is allowed, yellow turtles move locally
            if (local-mobility-blue-allow?)
            [
              facexy (8 + random(12 - 8)) (8 + random(12 - 8)) 
              forward 1
            ]
          ]
        ]   
      ]
          
      ; blue turtles move from blue to yellow
      ask turtles with [color = blue]
      [
        ; blue <-> yellow interface
        if (my-heading = 1)
        [
          set my-new-home yellow
        
          ; blue turtles along blue <-> yellow interface keep moving till they reach yellow (top-left)
          ifelse (sqrt((xcor - 10)*(xcor - 10) + (ycor - 30)*(ycor - 30)) > lock_radius)
          [
            facexy (8 + random(12 - 8)) (28 + random(32 - 28)) 
            forward 1 
          ]
          [
            ; if local mobility in  yellow (top-left) is allowed, blue turtles move locally
            if (local-mobility-yellow-allow?)
            [
              facexy (8 + random(12 - 8)) (28 + random(32 - 28)) 
              forward 2
            ]
          ]
        ]  
      ]
    ]
  ]
  [
    ; blue <-> yellow interface is not configured then it cannot be locked down
    set lockdown-blue-yellow? FALSE
  ]
  
  ; check if the interface blue<->pink is configured
  ifelse (route-blue-pink-enable?) 
  [
    ; if interface blue<->pink is locked down
    if (lockdown-blue-pink?)
    [
  
      ; as explained above some blue turtles stay in blue location (bottom-left)
      ask turtles with [color = blue]
      [
        if (my-heading = 0)  
        or (my-heading = 3) 
        or (my-heading = 4) 
        or (my-heading = 6) 
        or (my-heading = 7)  
        or (my-heading = 8)
        or ((not mobility-blue-red?) and (my-heading = 5))
        or ((not mobility-blue-yellow?) and (my-heading = 1))
        [
          set my-new-home blue
           
          ; if local mobility is allowed, then blue turtles keep moving locally   
          if (local-mobility-blue-allow?)
          [
            facexy (8 + random(12 - 8)) (8 + random(12 - 8))        
            forward 1
          ]
        ]
      ]
      
      ; as explained above some pink turtles stay in pink location (bottom-right)    
      ask turtles with [color = pink]
      [
        if (my-heading = 0)  
        or (my-heading = 1) 
        or (my-heading = 4) 
        or (my-heading = 5) 
        or (my-heading = 7) 
        or (my-heading = 8) 
        or ((not mobility-cyan-pink?) and (my-heading = 3))
        or ((not mobility-pink-red?) and (my-heading = 6))
        [
          set my-new-home pink
          
          ; if local mobility is allowed, then pink turtles keep moving locally     
          if (local-mobility-pink-allow?)
          [
            facexy (28 + random(32 - 28)) (8 + random(12 - 8))  
            forward 1
          ]
        ]
      ]
    
      ; pink turtles move from pink to blue
      ask turtles with [color = pink] 
      [            
        ; blue <-> pink interface
        if (my-heading = 2)
        [
        
          set my-new-home blue
        
          ; pink turtles along blue <-> pink interface keep moving till they reach blue (bottom-left)
          ifelse (sqrt((xcor - 10)*(xcor - 10) + (ycor - 10)*(ycor - 10)) > lock_radius)
          [
            facexy (8 + random(12 - 8)) (8 + random(12 - 8)) 
            forward 2 
          ]
          [
            ; if local mobility is allowed, then pink turtles keep moving locally 
            if (local-mobility-blue-allow?)
            [
              facexy (8 + random(12 - 8)) (8 + random(12 - 8))        
              forward 1
            ]
          ]     
        ] 
      ]
    
      ; blue turtles move from blue to pink
      ask turtles with [color = blue] 
      [
        ; blue <-> pink interface
        if (my-heading = 2)
        [
          set my-new-home pink
        
          ; blue turtles along blue <-> pink interface keep moving till they reach pink (bottom-right)
          ifelse (sqrt((xcor - 30)*(xcor - 30) + (ycor - 10)*(ycor - 10)) > lock_radius)
          [
            facexy (28 + random(32 - 28)) (8 + random(12 - 8)) 
            forward 2 
          
          ]
          [
            ; if local mobility is allowed, then blue turtles keep moving locally
            if (local-mobility-pink-allow?)
            [
              facexy (28 + random(32 - 28)) (8 + random(12 - 8)) 
              forward 2
            ]
          ]  
        ]
      ]
    ]
  ]
  [
    ; blue <-> pink interface is not configured then it cannot be locked down
    set lockdown-blue-pink? FALSE
  ]
  
  
  ; check if the interface pink<->red is configured
  ifelse (route-pink-red-enable?)
  [ 
    ; if interface pink<->red is locked down
    if (lockdown-pink-red?)
    [
      
      ; as explained above some red turtles stay in red location (centre) 
      ask turtles with [color = red]
      [
        if (my-heading = 0)  
        or ((my-heading = 1))
        or ((my-heading = 2)) 
        or ((my-heading = 3)) 
        or ((my-heading = 4)) 
        or ((not mobility-blue-red?) and (my-heading = 5))
        or ((not mobility-cyan-red?) and (my-heading = 7))
        or ((not mobility-yellow-red?) and (my-heading = 8))
        [
          set my-new-home red
          
          ; if local mobility is allowed, then red turtles keep moving locally
          if (local-mobility-red-allow?)
          [
            facexy (15 + random(25 - 15)) (15 + random(25 - 15))
            forward 1
          ]   
        ]
      ]
      
      ; as explained above some pink turtles stay in pink location (bottom-right) 
      ask turtles with [color = pink]
      [
         if (my-heading = 0)  
         or ((my-heading = 1))
         or ((my-heading = 4)) 
         or ((my-heading = 5))
         or ((my-heading = 7))
         or ((my-heading = 8))
         or ((not mobility-blue-pink?) and (my-heading = 2))
         or ((not mobility-cyan-pink?) and (my-heading = 3)) 
         [
           set my-new-home pink
           
           ; if local mobility is allowed, then pink turtles keep moving locally
           if (local-mobility-pink-allow?)
           [
             facexy (25 + random(35 - 25)) (7 + random(13 - 7))  
             forward 1
           ]
         ]
      ]
      
      ; red turtles move from red to pink
      ask turtles with [color = red] 
      [    
        ; pink <-> red interface
        if (my-heading = 6)
        [             
          set my-new-home pink
          
          ; red turtles along pink <-> red interface keep moving till they reach pink (bottom-right)    
          ifelse (sqrt((xcor - 30)*(xcor - 30) + (ycor - 10)*(ycor - 10)) > lock_radius)
          [
            facexy (28 + random(32 - 28)) (6 + random(12 - 8)) 
            forward 2
          ]
          [
            ; if local mobility is allowed, then red turtles keep moving locally
            if (local-mobility-pink-allow?)
            [
              facexy (28 + random(32 - 28)) (6 + random(12 - 8)) 
              forward 2
            ]
          ]  
        ]
      ]
      
      ; pink turtles move from pink to red
      ask turtles with [color = pink] 
      [
        ; pink <-> red interface
        if (my-heading = 6)
        [  
          set my-new-home red
          
          ; pink turtles along pink <-> red interface keep moving till they reach red (centre)
          ifelse (sqrt((xcor - 20)*(xcor - 20) + (ycor - 20)*(ycor - 20)) > lock_radius)
          [
            facexy (18 + random(22 - 18)) (18 + random(22 - 18))
            forward 2   
          ]
          [
            ; if local mobility is allowed, then red turtles keep moving locally
            if (local-mobility-red-allow?)
            [
              facexy (18 + random(22 - 18)) (18 + random(22 - 18))
              forward 2   
            ]
          ] 
        ]
      ]
    ]
  ]
  [
    ; pink <-> red interface is not configured then it cannot be locked down
    set lockdown-pink-red? FALSE
  ] 
  
  ; check if the interface cyan<->pink is configured
  ifelse (route-cyan-pink-enable?) 
  [
    ; if interface cyan<->pink is locked down
    if (lockdown-cyan-pink?)
    [    
      ; as explained above some cyan turtles (colour code 75) stay in pink location (top-right) 
      ask turtles with [color = 75]
      [
        if (my-heading = 0)  
        or (my-heading = 1) 
        or (my-heading = 2) 
        or (my-heading = 5) 
        or (my-heading = 6)  
        or (my-heading = 8)
        or ((not mobility-cyan-red?) and (my-heading = 7))
        or ((not mobility-cyan-yellow?) and (my-heading = 4))
        [
          set my-new-home 75
              
          ; if local mobility is allowed, then cyan turtles keep moving locally
          if (local-mobility-cyan-allow?)
          [
            facexy (25 + random(35 - 25)) (25 + random(35 - 25))  
            forward 1
          ]
        ]
      ]
      
      ; as explained above some pink turtles stay in pink location (bottom-right)    
      ask turtles with [color = pink]
      [
        if (my-heading = 0)  
        or (my-heading = 1) 
        or (my-heading = 4) 
        or (my-heading = 5) 
        or (my-heading = 7) 
        or (my-heading = 8) 
        or ((not mobility-blue-pink?) and (my-heading = 2))
        or ((not mobility-pink-red?) and (my-heading = 6))
        [
          set my-new-home pink
          
          ; if local mobility is allowed, then pink turtles keep moving locally    
          if (local-mobility-pink-allow?)
          [
            facexy (25 + random(35 - 25)) (7 + random(13 - 7))  
            forward 1
          ]
        ]
      ]
      
      ; pink turtles move from pink to cyan
      ask turtles with [color = pink] 
      [      
        ; cyan <-> pink interface
        if (my-heading = 3)
        [
          set my-new-home 75
           
          ; pink turtles along pink <-> cyan interface keep moving till they reach cyan (top-right)   
          ifelse (sqrt((xcor - 30)*(xcor - 30) + (ycor - 30)*(ycor - 30)) > lock_radius)
          [
            facexy (28 + random(32 - 28)) (28 + random(32 - 28)) 
            forward 2
                
          ]
          [
            ; if local mobility is allowed, then cyan turtles keep moving locally
            if (local-mobility-cyan-allow?)
            [
              facexy (28 + random(32 - 28)) (28 + random(32 - 28)) 
              forward 2
            ]
          ]  
        ] 
      ]
          
          
      ; cyan turtles move from cyan to pink
      ask turtles with [color = 75]
      [
        ; cyan <-> pink interface
        if (my-heading = 3)
        [
          set my-new-home pink
          
          ; cyan turtles along pink <-> cyan interface keep moving till they reach pink (top-right)    
          ifelse (sqrt((xcor - 30)*(xcor - 30) + (ycor - 10)*(ycor - 10)) > lock_radius)
          [
            facexy (28 + random(32 - 28)) (8 + random(12 - 8)) 
            forward 2      
          ]
          [
            ; if local mobility is allowed, then pink turtles keep moving locally
            if (local-mobility-pink-allow?)
            [
              facexy (28 + random(32 - 28)) (8 + random(12 - 8)) 
              forward 2
            ]
          ]  
        ]       
      ]  
    ]
  ]
  [
    ; cyan <-> pink interface is not configured then it cannot be locked down
    set lockdown-cyan-pink? FALSE
  ]
   
  ; check if the interface cyan<->red is configured 
  ifelse (route-cyan-red-enable?) 
  [
    
    ; if interface cyan<->red is locked down
    if (lockdown-cyan-red?)
    [
      
      ; as explained above some red turtles stay in red location (centre) 
      ask turtles with [color = red]
      [
        if (my-heading = 0)  
        or ((my-heading = 1))
        or ((my-heading = 2))
        or ((my-heading = 3)) 
        or ((my-heading = 4)) 
        or ((not mobility-blue-red?) and (my-heading = 5))
        or ((not mobility-pink-red?) and (my-heading = 6))
        or ((not mobility-yellow-red?) and (my-heading = 8))
        [
          set my-new-home red
         
          ; if local mobility is allowed, then red turtles keep moving locally
          if (local-mobility-red-allow?)
          [
            facexy (15 + random(25 - 15)) (15 + random(25 - 15))
            forward 1
          ] 
        ]
      ]
      
      ; as explained above some cyan turtles stay in cyan location (top-right)
      ask turtles with [color = 75]
      [
        if (my-heading = 0)  
        or ((my-heading = 1))
        or ((my-heading = 2))
        or ((my-heading = 5))
        or ((my-heading = 6))
        or ((my-heading = 8))
        or ((not mobility-cyan-pink?) and (my-heading = 3)) 
        or ((not mobility-cyan-yellow?) and (my-heading = 4)) 
        [
          
          set my-new-home 75
          
          ; if local mobility is allowed, then cyan turtles keep moving locally
          if (local-mobility-cyan-allow?)
          [
            facexy (25 + random(35 - 25)) (25 + random(35 - 25))
            forward 1
          ]
        ]
      ]
      
      
      ; red turtles move from red to cyan  
      ask turtles with [color = red]
      [  
        
        ; cyan <-> red interface
        if (my-heading = 7)  
        [ 
          set my-new-home 75
          
          ; red turtles along cyan <-> red interface keep moving till they reach cyan (top-right)
          ifelse (sqrt((xcor - 30)*(xcor - 30) + (ycor - 30)*(ycor - 30)) > lock_radius)
          [
            facexy (28 + random(32 - 28)) (28 + random(32 - 28))
            forward 2
          ]
          [
            ; if local mobility is allowed, then red turtles keep moving locally
            if (local-mobility-cyan-allow?)
            [
              facexy (28 + random(32 - 28)) (28 + random(32 - 28))
              forward 2
            ]
          ]
        ]
      ] 
      
       
      ; cyan turtles move from cyan to red 
      ask turtles with [color = 75]
      [  
        set my-new-home red
        
        if (my-heading = 7)  
        [
          
          ; cyan turtles along cyan <-> red interface keep moving till they reach red (centre)
          ifelse (sqrt((xcor - 20)*(xcor - 20) + (ycor - 20)*(ycor - 20)) > lock_radius)
          [
            facexy (18 + random(22 - 18)) (18 + random(22 - 18))
            forward 2
            
          ]
          [
            ; if local mobility is allowed, then red turtles keep moving locally
            if (local-mobility-red-allow?)
            [
              facexy (18 + random(22 - 18)) (18 + random(22 - 18))
              forward 2
            ]
          ]
        ]
      ]  
    ]
  ]
  [
    ; cyan <-> red interface is not configured then it cannot be locked down
    set lockdown-cyan-red? FALSE
  ]
    
  ; check if the interface cyan<->yellow is configured
  ifelse (route-cyan-yellow-enable?)
  [
    ; if interface cyan<->yellow is locked down
    if (lockdown-cyan-yellow?)
    [
      ; as explained above some cyan turtles stay in cyan location (top-right)
      ask turtles with [color = 75]
      [
        if (my-heading = 0)  
        or (my-heading = 1) 
        or (my-heading = 2) 
        or (my-heading = 5) 
        or (my-heading = 6)  
        or (my-heading = 8)
        or ((not mobility-cyan-red?) and (my-heading = 7))
        or ((not mobility-cyan-pink?) and (my-heading = 3))
        [
          
          set my-new-home 75
          
          ; if local mobility is allowed, then cyan turtles keep moving locally    
          if (local-mobility-cyan-allow?)
          [
            facexy (28 + random(32 - 28)) (28 + random(32 - 28))
            forward 2
          ]
        ]
      ]
       
      ; as explained above some yellow turtles stay in cyan location (top-left)   
      ask turtles with [color = yellow]
      [
        if (my-heading = 0)  
        or (my-heading = 2) 
        or (my-heading = 3) 
        or (my-heading = 5) 
        or (my-heading = 6) 
        or (my-heading = 7) 
        or ((not mobility-yellow-red?) and (my-heading = 8))
        or ((not mobility-blue-yellow?) and (my-heading = 1))
        [  
          set my-new-home yellow
              
          ; if local mobility is allowed, then yellow turtles keep moving locally
          if (local-mobility-yellow-allow?)
          [
            facexy (8 + random(12 - 8)) (28 + random(32 - 28))   
            forward 2
          ]
        ]
      ]
          
      ; cyan turtles move from cyan to yellow
      ask turtles with [color = 75] 
      [
        if (my-heading = 4)
        [
          set my-new-home yellow
          
          ; cyan turtles along cyan <-> yellow interface keep moving till they reach yellow (top-left)    
          ifelse (sqrt((xcor - 10)*(xcor - 10) + (ycor - 30)*(ycor - 30)) > lock_radius)
          [
            facexy (8 + random(12 - 8)) (28 + random(32 - 28)) 
            forward 2
          ]
          [
            ; if local mobility is allowed, then cyan turtles keep moving locally
            if (local-mobility-yellow-allow?)
            [
              facexy (8 + random(12 - 8)) (28 + random(32 - 28)) 
              forward 2
            ]
          ]
        ]
      ]
          
      ; yellow turtles move from yellow to cyan
      ask turtles with [color = yellow]
      [
        if (my-heading = 4)
        [
          set my-new-home 75
              
          ; yellow turtles along cyan <-> yellow interface keep moving till they reach cyan (top-right)
          ifelse (sqrt((xcor - 30)*(xcor - 30) + (ycor - 30)*(ycor - 30)) > lock_radius)
          [
            facexy (8 + random(12 - 8)) (28 + random(32 - 28))
            forward 2
          ]
          [
            ; if local mobility is allowed, then yellow turtles keep moving locally
            if (local-mobility-cyan-allow?)
            [
              facexy (8 + random(12 - 8)) (28 + random(32 - 28))
              forward 2
            ]
          ]  
        ]
      ] 
    ]
  ]
  [
    ; cyan <-> yellow interface is not configured then it cannot be locked down
    set lockdown-cyan-yellow? FALSE
  ]
    
  ; check if the interface cyan<->red is configured
  ifelse (route-yellow-red-enable?) 
  [
    ; if interface cyan<->red is locked down
    if (lockdown-yellow-red?)
    [      
      ; as explained above some red turtles stay in red location (centre)
      ask turtles with [color = red]
      [
        if (my-heading = 0)  
        or ((my-heading = 1))
        or ((my-heading = 2))
        or ((my-heading = 3)) 
        or ((my-heading = 4)) 
        or ((not mobility-blue-red?) and (my-heading = 5))
        or ((not mobility-pink-red?) and (my-heading = 6))
        or ((not mobility-cyan-red?) and (my-heading = 7))
        [
          
          set my-new-home red
          
          ; if local mobility is allowed, then red turtles keep moving locally
          if (local-mobility-red-allow?)
          [
            facexy (15 + random(25 - 15)) (15 + random(25 - 15))
            forward 1
          ]
        ]
      ]
      
      ; as explained above some red turtles stay in red location (top-left)
      ask turtles with [color = yellow]
      [
        if (my-heading = 0)  
        or ((my-heading = 2))
        or ((my-heading = 3)) 
        or ((my-heading = 5)) 
        or ((my-heading = 6))
        or ((my-heading = 7))
        or ((not mobility-blue-yellow?) and (my-heading = 1))
        or ((not mobility-cyan-yellow?) and (my-heading = 4)) 
        [
          
          set my-new-home yellow
         
          ; if local mobility is allowed, then red turtles keep moving locally
          if (local-mobility-yellow-allow?)
          [
              facexy (7 + random(13 - 7)) (25 + random(35 - 25)) 
              forward 1
          ]
        ]
      ]
      
      ; yellow turtles move from yellow to red
      ask turtles with [color = yellow]
      [
        if (my-heading = 8)
        [
          
          set my-new-home red
          
          ; yellow turtles along yellow <-> red interface keep moving till they reach red (centre)
          ifelse (sqrt((xcor - 20)*(xcor - 20) + (ycor - 20)*(ycor - 20)) > lock_radius)
          [
            facexy (18 + random(22 - 18)) (18 + random(22 - 18))
            forward 2
          ]
          [
            ; if local mobility is allowed, then yellow turtles keep moving locally
            if (local-mobility-red-allow?)
            [
              facexy (18 + random(22 - 18)) (18 + random(22 - 18))
              forward 2
            ]
          ]
        ]  
      ]
      
      ; red turtles move from red to yellow
      ask turtles with [color = red]
      [ 
        if (my-heading = 8)
        [
          
          set my-new-home yellow
          
          ; red turtles along yellow <-> red interface keep moving till they reach yellow (top-left)
          ifelse (sqrt((xcor - 10)*(xcor - 10) + (ycor - 30)*(ycor - 30)) > lock_radius)
          [
            facexy (8 + random(12 - 8)) (28 + random(32 - 28)) 
            forward 2
          ]
          [
            ; if local mobility is allowed, then red turtles keep moving locally
            if (local-mobility-yellow-allow?)
            [
              facexy (8 + random(12 - 8)) (28 + random(32 - 28)) 
              forward 2
            ]
          ]
          
        ]  
      ]
    ]
  ]
  [
    ; yellow <-> red interface is not configured then it cannot be locked down
    set lockdown-yellow-red? FALSE
  ]
               
end
;-----------------------------------------------------------------------------------------------------------
; function to lockdown a location red, blue, pink, cyan, yellow
to static-lockdown
  
  ; to lockdown blue location (bottom-left) check if any of its interfaces are configured 
  ifelse (route-blue-pink-enable?) or (route-blue-yellow-enable?) or (route-blue-red-enable?)
  [
    ; if lockdown blue  is set in the GUI, all its 3 interfaces are locked down
    if (lockdown-blue?)
    [
      set lockdown-blue-pink? TRUE
      set lockdown-blue-yellow? TRUE
      set lockdown-blue-red? TRUE  
    ]
  ]
  ; if none of the interaces of blue location (bottom-left) is configured, then lockdown can't be done
  [
    set lockdown-blue? FALSE
  ]
  
  ; to lockdown pink location (bottom-right) check if any of its interfaces are configured 
  ifelse (route-blue-pink-enable?) or (route-cyan-pink-enable?) or (route-pink-red-enable?)
  [
    ; if lockdown pink  is set in the GUI, all its 3 interfaces are locked down
    if (lockdown-pink?)
    [
      set lockdown-blue-pink? TRUE
      set lockdown-cyan-pink? TRUE
      set lockdown-pink-red? TRUE 
    ]
  ]
  ; if none of the interaces of pink location (bottom-right) is configured, then lockdown can't be done
  [
    set lockdown-pink? FALSE
  ]
  
  ; to lockdown cyan (colour code 75) location (top-right) check if any of its interfaces are configured 
  ifelse (route-cyan-pink-enable?) or (route-cyan-red-enable?) or (route-cyan-yellow-enable?)
  [
    ; if lockdown cyan is set in the GUI, all its 3 interfaces are locked down
    if (lockdown-cyan?)
    [ 
      set lockdown-cyan-pink? TRUE
      set lockdown-cyan-red? TRUE
      set lockdown-cyan-yellow? TRUE
    ]
  ]
  ; if none of the interaces of cyan location (top-right) is configured, then lockdown can't be done
  [
    set lockdown-cyan? FALSE
  ] 
  
  ; to lockdown yellow location (top-left) check if any of its interfaces are configured
  ifelse (route-cyan-yellow-enable?) or (route-blue-yellow-enable?) or (route-yellow-red-enable?)
  [
    ; if lockdown yellow is set in the GUI, all its 3 interfaces are locked down
    if (lockdown-yellow?)
    [
      set lockdown-cyan-yellow? TRUE
      set lockdown-blue-yellow? TRUE
      set lockdown-yellow-red? TRUE
    ]
  ]
  ; if none of the interaces of yellow location (top-left) is configured, then lockdown can't be done
  [
    set lockdown-yellow? FALSE
  ]
  
  ; to lockdown red location (centre) check if any of its interfaces are configured
  ifelse (route-cyan-red-enable?) or (route-blue-red-enable?) or (route-yellow-red-enable?) or (route-pink-red-enable?)
  [
    ; if lockdown red is set in the GUI, all its 4 interfaces are locked down
    if (lockdown-red?)
    [
      set lockdown-cyan-red? TRUE
      set lockdown-blue-red? TRUE
      set lockdown-yellow-red? TRUE
      set lockdown-pink-red? TRUE
    ]
  ]
  ; if none of the interaces of red location (centre) is configured, then lockdown can't be done
  [
    set lockdown-red? FALSE
  ]
    
end
;-----------------------------------------------------------------------------------------------------------
; this is just a function to generate some randomness for infection
to-report toss-a-coin?
  report (random 200) mod 199 = 0
end 
;-----------------------------------------------------------------------------------------------------------
; this function randomly alocates mobility direction for the turtles
to-report mobility-direction
  report random 9
end 
@#$#@#$#@
GRAPHICS-WINDOW
204
10
721
548
-1
-1
12.37
1
10
1
1
1
0
0
0
1
0
40
0
40
0
0
1
ticks
30.0

BUTTON
12
38
67
71
NIL
setup
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
125
36
180
69
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
47
8
197
26
NIL
11
0.0
1

TEXTBOX
22
10
172
28
NIL
11
0.0
1

PLOT
12
402
190
522
%  infected agents
time
%
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot percent_infected"

SWITCH
727
94
876
127
propagate-infection?
propagate-infection?
0
1
-1000

SWITCH
9
176
188
209
route-blue-red-enable?
route-blue-red-enable?
0
1
-1000

SWITCH
9
328
190
361
route-cyan-red-enable?
route-cyan-red-enable?
0
1
-1000

SWITCH
8
365
191
398
route-yellow-red-enable?
route-yellow-red-enable?
0
1
-1000

SWITCH
9
100
187
133
route-blue-yellow-enable?
route-blue-yellow-enable?
0
1
-1000

SWITCH
9
138
187
171
route-blue-pink-enable?
route-blue-pink-enable?
0
1
-1000

SWITCH
8
212
189
245
route-pink-red-enable?
route-pink-red-enable?
0
1
-1000

SWITCH
8
289
188
322
route-cyan-pink-enable?
route-cyan-pink-enable?
0
1
-1000

SWITCH
9
251
189
284
route-cyan-yellow-enable?
route-cyan-yellow-enable?
0
1
-1000

SWITCH
728
190
859
223
lockdown-blue?
lockdown-blue?
1
1
-1000

SWITCH
726
266
859
299
lockdown-pink?
lockdown-pink?
1
1
-1000

SWITCH
727
228
859
261
lockdown-yellow?
lockdown-yellow?
1
1
-1000

SWITCH
726
304
859
337
lockdown-cyan?
lockdown-cyan?
1
1
-1000

SWITCH
729
151
859
184
lockdown-red?
lockdown-red?
1
1
-1000

SWITCH
725
449
878
482
lockdown-blue-red?
lockdown-blue-red?
1
1
-1000

SWITCH
724
409
879
442
lockdown-blue-yellow?
lockdown-blue-yellow?
1
1
-1000

SWITCH
723
488
878
521
lockdown-blue-pink?
lockdown-blue-pink?
1
1
-1000

SWITCH
726
371
879
404
lockdown-pink-red?
lockdown-pink-red?
1
1
-1000

SWITCH
893
373
1052
406
lockdown-cyan-yellow?
lockdown-cyan-yellow?
1
1
-1000

SWITCH
893
410
1053
443
lockdown-cyan-pink?
lockdown-cyan-pink?
1
1
-1000

SWITCH
893
449
1053
482
lockdown-cyan-red?
lockdown-cyan-red?
1
1
-1000

SWITCH
891
489
1054
522
lockdown-yellow-red?
lockdown-yellow-red?
1
1
-1000

SWITCH
728
26
830
59
infect-red?
infect-red?
0
1
-1000

SWITCH
834
26
939
59
infect-blue?
infect-blue?
0
1
-1000

SWITCH
942
27
1044
60
infect-pink?
infect-pink?
0
1
-1000

SWITCH
1047
27
1161
60
infect-yellow?
infect-yellow?
0
1
-1000

SWITCH
1164
27
1271
60
infect-cyan?
infect-cyan?
0
1
-1000

SWITCH
880
152
1056
185
local-mobility-red-allow?
local-mobility-red-allow?
0
1
-1000

SWITCH
882
229
1057
262
local-mobility-yellow-allow?
local-mobility-yellow-allow?
0
1
-1000

SWITCH
881
267
1057
300
local-mobility-pink-allow?
local-mobility-pink-allow?
0
1
-1000

SWITCH
882
306
1058
339
local-mobility-cyan-allow?
local-mobility-cyan-allow?
0
1
-1000

SWITCH
881
190
1057
223
local-mobility-blue-allow?
local-mobility-blue-allow?
0
1
-1000

SWITCH
1026
95
1152
128
start-recovery?
start-recovery?
0
1
-1000

SWITCH
880
94
1020
127
take-precautions?
take-precautions?
0
1
-1000

TEXTBOX
13
76
193
101
Initialize mobility routes after \"setup\" and \"go\". Once enabled, can't be disabled!
9
15.0
1

TEXTBOX
13
7
185
40
Since there are many parameters, they are hard coded. Feel free to change!
9
15.0
1

TEXTBOX
729
15
1264
33
Infect turtles, centre: red, bottom-left: blue, bottom-right: pink, top-left: yellow, top-right: cyan
9
15.0
1

TEXTBOX
729
138
879
156
lockdown a location (white circle)
9
15.0
1

TEXTBOX
879
138
1082
160
allow local mobility in a location (white circle)
9
15.0
1

TEXTBOX
730
352
948
374
lockdown a route between two locations
9
15.0
1

TEXTBOX
728
79
878
97
propagate infection turtle to turtle
9
15.0
1

TEXTBOX
882
70
1032
92
turtles take precuations to avoid infection
9
15.0
1

TEXTBOX
1026
81
1176
99
turtles recover
9
15.0
1

PLOT
1083
152
1283
302
% agents takes percautions
time
%
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -13345367 true "" "plot percent_precautioned"

PLOT
1103
358
1303
508
% agents recovered
time
%
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -13840069 true "" "plot percent_recovered"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)
my-heading = 0, stay home, all nodes
my-heading = 1, yellow <-> blue
my-heading = 2, blue <-> pink
my-heading = 3, pink <-> cyan
my-heading = 4, cyan <-> yellow
my-heading = 5, any <-> red

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

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

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
NetLogo 5.2.0
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
