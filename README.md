# oilfield optimizer

script for the purpose of finding 'optimal' arrangement of pumps, pipes, 
power, and beacons in a factorio oil field

made available under the MIT license

## design overview

script takes an 'array' of locations, e.g. `{{x=1, y=5}, {x=-4, y=3}}` 
and supplies a table of different entities and their position/orientation

output can be rendered into an ascii text format, following conventions below

algorithm is brute-force, trying every permutation; expect to run SLOWLY

* For each oil field, place a pumpjack; for each pump, try each rotation.
* Create bounding region(s) for becaon placement and rectangular grid bounds 
  for everything else.
* Intersperse beacons, from one to `floor(beacon-bounds-area / beacon-area)`.
* For every pump/beacon layout, place power sources, pipes, 
  and pipe-to-ground pairs.
* For every generated layout, verify that all pumpjacks have an output path 
  exit beyond beacon bounds, and verify that all pumps and beacons receive 
  power, and the path of pole(s) extends beyond beacon bounds.

For all valid layouts, prioritize those with:
 
 1. more beacons
 2. fewer output trees (separate pipe groups)
 3. fewer total power entities
 3. fewer substations
 4. fewer big poles
 5. fewer small poles
 6. fewer medium poles
 7. fewer power trees
 8. fewer pipes
 9. fewer pipes-to-ground

If, after filtering the above, two layouts are equivalent, 
then the first is retained.

All positions are retained in tables,
`{x = <number>, y = <number> [, rot = '^' | '>' | 'v' | '<'] }`,
where `x` and `y` are the center, and `rot` denotes rotation if applicable.
For odd-dimension entities (pumps, pipes), center is an integer;
if even (substations), center is inter-plus-half, e.g., `-13.5`.



## generated output

Output is a table of entities with their position and rotation data. 

Below is a simple, sub-optimal example:

    layout = {
        pump = {{x=5, y=-2, rot='v'}},
        beacon = {{x=2, y=-2}},
        medium-pole = {}, -- {x=4, y=0},
        small-pole = {},
        big-pole = {},
        substation = {{x=4.5, y=0.5}}, -- (4,1)..(5,0)
        pipe = {},
        pipe-to-ground = {{x=4, y=-4, rot='v'}, {x=4, y=-9, rot='^'}},
    }



## ascii output

For visual aid, a utility is (TODO) provided to pretty-print the grid

#### standard pipes:

can connect in any orthagonal direction to pumpjack outlets and other pipes

    +

#### pipes-to-ground:

'arrow' points in direction pipe goes underground; 
opening is above-ground;

    ^  >  <  v

can only connect to pipes or outlets on 'open' adjacent location. 
`+>` and `<>` connect, whereas `>+` and `<^` do not.

example of connected pipes with stuff in between--note that the final 
pipe segment (`+`) is *not* connected to the underground line:
`+>BBBm<> P@PBBBs<+>+ <` 


other valid connections--try to identify the separate 'groups' of piping

    <+      v
     v     <++         +>
            ^+>       <+>
     ^      ++

hint: there are only two groups

#### pumpjacks

'arrow' points in direction of output

    PP^  PP>  PPP  PPP
    P@P  P@P  P@P  P@P
    PPP  PPP  vPP  <PP

#### power supplies: small, medium, big pole; substation

    s    m    TT    ##
              TT    ##

#### beacons

    BBB
    B@B
    BBB

### hand-crafted example:
    BBBBBBBBB          
    B*BB*BB*B          
    BBBBBBBBB          
    BBBm  BBBBBB       
    B*B   B*BB*B       
    BBBPPPBBBBBB     TT
    BBBP@P   mBBB    TT
    B*BPP>+<PPB*B      
    BBBm  +P@PBBB      
    BBBBBB+PPP         
    B*BB*B++++>      < 
    BBBBBB^PPvBBB      
      mBBBP@P B*B      
       B*BPPP BBB      
       BBBBBBm         
       BBBB*B^         
       B*BBBB++BBB     
       BBB PPP+B*B     
       BBB P@P+BBB     
       B*BmPP>+++BBB   
       BBBBBBPPP+B*B   
          B*BP@P+BBB   
          BBBPP>+BBB   
          BBB  m B*B   
          B*BBBB BBB   
          BBBB*B       
             BBB       

## extra information and notes

    entity      |supply | reach| foot
    ------------|-------|------|-----
    small pole  |  5x5  |  7.5 | 1 (x,y)
    medium pole |  7x7  |  9   | 1 (x,y)
    big pole    |  4x4  | 30   | 2 (x-0.5,y+0.5)..(x+0.5, y-0.5)
    substation  | 14x14 | 14   | 2 (x-0.5,y+0.5)..(x+0.5, y-0.5)

    pipe : 1 (x,y) omniattach
    pipe-to-ground : (a,b), (a,b +/ -1..10) | (a +/- 1..10, b) 
                     attach in-line

    beacon: 9x9 area, 3x3 foot

    pump : 3x3 foot - (x-1,y+1) .. (x+1,y-1), 
           outlets (1,2) | (2,1) | (-1,-2) | (-2,-1)

