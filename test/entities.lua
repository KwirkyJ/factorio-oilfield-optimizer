local assertive = require 'lib.assertive'
local entities  = require 'entities'

local assertEq       = assertive.assertEquals
--local assertAlmostEq = assertive.assertAlmostEquals
local assertError    = assertive.assertError

local expected



-- ==== TEST LOADING AND VALIDATION ==========================================

---- tile and foot checking --------------------------------------------------

local medium_pole_proto = {foot = {x=1, y=1}, tiles = {{'m'}}}
entities.init ("medium-pole", medium_pole_proto)
assertEq (entities.loaded (), {['medium-pole'] = true})

assertError ("not enough information", nil, 
             entities.init, "small-pole", {})
assertError ("foot must match tiles size", nil, 
             entities.init, "small-pole", 
             {foot = {x=2, y=1}, tiles = {{'s'}}})
assertError ("foot must match tiles size", nil, 
             entities.init, "small-pole", 
             {foot = {x=1, y=2}, tiles = {{'s'}}})
assertError ("foot cannot have gaps", nil, 
             entities.init,  "small-pole", 
             {foot = {x=2, y=2}, tiles = {{'s'}, {'t', 'l'}}})
assertError ("foot must be {x=n, y=n} table", nil, 
             entities.init, "small-pole", 
             {foot = {1, 1}, tiles = {{'s'}}})
assertError ("foot must be {x=n, y=n} table", nil, 
             entities.init, "small-pole", 
             {foot = {y=1, m=1}, tiles = {{'s'}}})
assertError ("foot must be {x=n, y=n} table", nil, 
             entities.init, "small-pole", 
             {foot = {x=1, t=1}, tiles = {{'s'}}})
assertError ("foot must be {x=n, y=n} table", nil, 
             entities.init, "small-pole", 
             {foot = 7, tiles = {{'s'}}})
assertError ("foot must be {x=n, y=n} table", nil, 
             entities.init, "small-pole", 
             {foot = {x=1, y=1, z=5}, tiles = {{'s'}}})
assertError ("foot must be {x=n, y=n} table", nil, 
             entities.init, "small-pole", 
             {foot = {x=1, y="blue"}, tiles = {{'s'}}})
assertError ("numbers must be greater than zero", nil, 
             entities.init, "small-pole", 
             {foot = {x=1, y=0}, tiles = {{'s'}}})
assertError ("numbers must be greater than zero", nil, 
             entities.init, "small-pole", 
             {foot = {x=-61, y=3}, tiles = {{'s'}}})
assertError ("numbers must be greater than zero", nil, 
             entities.init, "small-pole", 
             {foot = {x=0, y=0}, tiles = {}})

assertEq (entities.loaded (), {['medium-pole'] = true},
          "errors above do not add anything")



---- entity with rotations ---------------------------------------------------

local rotEnt = {foot = {x=2, y=2}, 
                rotations = {['^'] = {tiles = {{'@', '^'}, 
                                               {'@', '@'}}},
                             ['v'] = {tiles = {{'@', '@'}, 
                                               {'@', 'v'}}},
                            }}
entities.init ("rot-thing", rotEnt)

rotEnt = {foot = {x=2, y=2}, 
          rotations = {['^'] = {tiles = {{'@', '^'}, 
                                         {'@', '@'}}},
                       ['v'] = {tiles = {{'@'}, 
                                         {'@', 'v'}}},
                      }}
assertError ("missing column in a tile row", nil, 
             entities.init, "bad_rot", rotEnt)

rotEnt = {foot = {x=2, y=2}, 
          rotations = {['^'] = {tiles = {{'@', '^'}, 
                                         {'@', '@'}}},
                       ['v'] = {tiles = {{'@', '@', '@'}, 
                                         {'@', 'v'}}},
                      }}
assertError ("extra element(s) in tile row", nil, 
             entities.init, "bad_rot", rotEnt)

rotEnt = {foot = {x=2, y=2}, 
          rotations = {['^'] = {tiles = {{'@', '^'}}},
                       ['v'] = {tiles = {{'@', '@'}, 
                                         {'@', 'v'}}},
                      }}
assertError ("tile missing a row", nil, 
             entities.init, "bad_rot", rotEnt)

rotEnt = {foot = {x=2, y=2}, 
          rotations = {['^'] = {}},
         }
assertError ("rotation missing important field", nil, 
             entities.init, "bad_rot", rotEnt)

rotEnt = {foot = {x=2, y=2}, 
          rotations = {['v'] = {tiles = {{'@', '@'}, 
                                         {'@', 'v'}}},
                      }}
entities.init ("rot2", rotEnt)



---- see what has been loaded ------------------------------------------------

assertEq (entities.loaded (), 
          {['medium-pole'] = true, ['rot-thing']=true, ['rot2']=true})
assertEq (entities.get_types (entities.ALL), 
          {['medium-pole'] = true, ['rot-thing']=true, ['rot2']=true})
assertEq (entities.get_types (entities.POWER), {}, 'proto has not power')
assertEq (entities.get_types (entities.BONUS), {})
assertEq (entities.get_types (entities.PIPING), {})
assertEq (entities.get_types (entities.SOURCE), {})



---- can reset entities ------------------------------------------------------

entities.clear ()
assertEq (entities.loaded (), {})
assertEq (entities.get_types (entities.ALL), {})
assertEq (entities.get_types (entities.POWER), {})
assertEq (entities.get_types (entities.BONUS), {})
assertEq (entities.get_types (entities.PIPING), {})
assertEq (entities.get_types (entities.SOURCE), {})



---- power entities ----------------------------------------------------------

medium_pole_proto = {foot = {x=1, y=1},
                     tiles = {{'m'}},
                     power = {area = {x=7, y=7},
                              reach = 9}}
entities.init ("medium-pole", medium_pole_proto)
assertEq (entities.loaded (), {['medium-pole'] = true})
assertEq (entities.get_types (entities.ALL), {['medium-pole'] = true})
assertEq (entities.get_types (entities.POWER), {['medium-pole'] = true})
assertEq (entities.get_types (entities.BONUS), {})
assertEq (entities.get_types (entities.PIPING), {})
assertEq (entities.get_types (entities.SOURCE), {})

local E = {x=4, y=-3}
assertEq (entities.get_tiles ("medium-pole", E), 
          {{x=4, y=-3, repr='m'}},
          "called without tiletype, returns foot repr")

expected = {}
for y=-6, 0 do
    for x = 1, 7 do
        expected[#expected+1] = {x=x, y=y}
    end
end
assertEq (entities.get_tiles ("medium-pole", E, entities.POWER), 
          expected,
          "called with POWER tiletype, returns row-first listing of tiles")

assertEq (entities.get_tiles ("medium-pole", E, entities.SOURCE),
          {},
          "called with unsupported attribute, nothing is returned")



---- power with rectangular foot and area ------------------------------------

local widepole = {
    rotations = {
        ['^'] = {foot = {x=1, y=3},
                 tiles = {{'$'}, {'$'}, {'$'}},
                 power = {area = {x=5, y=9},
                          reach = 11}},
        ['>'] = {foot = {x=3, y=1},
                 tiles = {{'$', '$', '$'}},
                 power = {area = {x=9, y=5},
                          reach = 11}},
    }
}
entities.init ("widepole", widepole)
assertEq (entities.get_types (entities.POWER), 
          {['medium-pole'] = true, ['widepole'] = true},
          "rotation differences hidden under prototype name")
expected = {{x=3, y=9, repr = '$'}, 
            {x=4, y=9, repr = '$'}, 
            {x=5, y=9, repr = '$'}}
assertEq (entities.get_tiles ('widepole', {x=4, y=9, rot='>'}), expected,
          "foot area/repr of horizontal orientation")

expected = {}
for y = 7, 11 do
    for x = 0, 8 do
        expected[#expected+1] = {x=x, y=y}
    end
end
assertEq (entities.get_tiles ('widepole', 
                              {x=4, y=9, rot='>'},
                              entities.POWER),
          expected,
          "power area from horizontal rotation")

expected = {}
for y = -16, -8 do
    for x = 4, 8 do
        expected[#expected+1] = {x=x, y=y}
    end
end
assertEq (entities.get_tiles ('widepole', 
                              {x=6, y=-12, rot='^'},
                              entities.POWER),
          expected,
          "vertical orientation")
assertEq (entities.get_tiles ('widepole',
                              {x=6, y=-12, rot='^'},
                              entities.BONUS),
          {},
          "entity has no bonus attribute; no bonus tiles")

assertError ("somehow got a bad rotaton key", nil,
             entities.get_tiles, 'widepole', {x=6, y=0, rot='<'})



---- beacon-like entity ------------------------------------------------------

local bacon = {foot = {x=4, y=4},
               requires_power = true,
               bonus = {x=12, y=12},
               tiles = {{'M', 'M', 'M', 'M'}, 
                        {'M', 'M', 'M', 'M'}, 
                        {'M', 'M', 'M', 'M'}, 
                        {'M', 'M', 'M', 'M'}},
}

entities.init ("bacon", bacon)

assertEq (entities.get_types (entities.NEEDS_POWER), {bacon = true})

expected = {}
for y = 7, 10 do
    for x = -5, -2 do
        expected[#expected+1] = {x=x, y=y, repr= 'M'}
    end
end
assertEq (entities.get_tiles ("bacon", {x=-3.5, y=8.5}), 
          expected)
          
expected = {}
for y = 3, 14 do
    for x = -9, 2 do
        expected[#expected+1] = {x=x, y=y}
    end
end
assertEq (entities.get_tiles ("bacon", {x=-3.5, y=8.5}, entities.BONUS), 
          expected)

assertEq (entities.get_tiles ("bacon", {x=-3.5, y=8.5}, entities.POWER), 
          {})



---- basic omni pipe ---------------------------------------------------------

local pipe = {
    foot = {x=1, y=1},
    tiles = {{'+'}},
    pipe_rule = 'all',
    pipe_attachments = {
        {x= 0, y=-1},
        {x= 0, y= 1},
        {x= 1, y= 0},
        {x=-1, y= 0}
    },
}
entities.init ("omni-pipe", pipe)

assert (entities.loaded ()['omni-pipe'])

assertEq (entities.get_tiles ("omni-pipe", {x=4, y=-8}),
          {{x=4, y=-8, repr = "+"}})
assertEq (entities.get_tiles ("omni-pipe", {x=-4, y=8}, entities.PIPING),
          {{x=-4, y=7}, {x=-4, y=9}, {x=-3, y=8}, {x=-5, y=8}},
          "ordering as defined in prototype")
assertEq (entities.get_attachrule ("omni-pipe"), 'all')



assert (entities.loaded ()["medium-pole"],
        "verify that this entity is accessible") 
assert (entities.get_types (entities.PIPING)['medium-pole'] == nil,
        "verify that pole is not pipe")
assert (entities.get_attachrule ("medium-pole") == nil,
        "non-pipe does not have attachment rule")



assertError ("pipe_rule requires pipe_attachments", nil,
             entities.init, "badpipe", 
                 {foot = {x=1, y=1}, tiles = {{'+'}}, pipe_rule = 'all'})
assertError ("pipe_attachments requires pipe_rule", nil,
             entities.init, "badpipe", 
                 {foot = {x=1, y=1}, tiles = {{'+'}}, pipe_attachments = {{x=1, y=0}}})
assertError ("0, 0 coordinates are forbidden", nil,
             entities.init, "badpipe", 
                 {foot = {x=1, y=1}, tiles = {{'+'}}, pipe_rule = 'all', 
                  pipe_attachments = {{x=0, y=0}}})
assertError ("pipe_rule must be 'first' or 'all'", nil,
             entities.init, "badpipe", 
                 {foot = {x=1, y=1}, tiles = {{'+'}}, pipe_rule = 'blue', 
                  pipe_attachments = {{x=0, y=1}}})
assertError ("pipe_rule must be 'first' or 'all'", nil,
             entities.init, "badpipe", 
                 {foot = {x=1, y=1}, tiles = {{'+'}}, pipe_rule = 5, 
                  pipe_attachments = {{x=0, y=1}}})



---- pipe-to-ground ----------------------------------------------------------

pipe = {
    foot = {x=1, y=1},
    pipe_rule = 'first',
    rotations = {
        ['^'] = {tiles = {{'('}},
                 pipe_attachments = {
                 {x=0, y=1},
                 {x=0, y=2},
                 {x=0, y=3},
                 {x=0, y=4},
                 {x=0, y=5}}
        },
        ['v'] = {tiles = {{'9'}},
                 pipe_attachments = {
                 {x=0, y=-1},
                 {x=0, y=-2},
                 {x=0, y=-3},
                 {x=0, y=-4},
                 {x=0, y=-5}}
        },
    },
}
entities.init ("groundpipe", pipe)

assertEq (entities.get_types (entities.PIPING), 
          {['groundpipe'] = true, ['omni-pipe'] = true})
assertEq (entities.get_tiles ("groundpipe", {x=5, y=0, rot = 'v'}),
          {{x=5, y=0, repr = '9'}})
assertEq (entities.get_tiles ("groundpipe", {x=5, y=0, rot = '^'}, 
                              entities.PIPING),
          {{x=5, y=1}, {x=5, y=2}, {x=5, y=3}, {x=5, y=4}, {x=5, y=5}})
assertEq (entities.get_attachrule ("groundpipe"), 'first')



---- pumpjack requires power and is source -----------------------------------

local pump = {
    foot           = {x=3, y=3},
    requries_power = true,
    is_source      = true,
    pipe_rule      = 'first',
    rotations = {
        ['^'] = {
            tiles = {{'P', 'P', '^'},
                     {'P', '@', 'P'},
                     {'P', 'P', 'P'}},
            pipe_attachments = {{x=1, y=-2}}
        },
        ['>'] = {
            tiles = {{'P', 'P', '>'},
                     {'P', '@', 'P'},
                     {'P', 'P', 'P'}},
            pipe_attachments = {{x=2, y=-1}}
        },
        ['v'] = {
            tiles = {{'P', 'P', 'P'},
                     {'P', '@', 'P'},
                     {'v', 'P', 'P'}},
            pipe_attachments = {{x=-1, y=2}}
        },
        ['<'] = {
            tiles = {{'P', 'P', 'P'},
                     {'P', '@', 'P'},
                     {'<', 'P', 'P'}},
            pipe_attachments = {{x=-2, y=1}}
        }
    }
}
entities.init ("pump", pump)

expected = {
    {x=-2, y=7, repr = 'P'},
    {x=-1, y=7, repr = 'P'},
    {x= 0, y=7, repr = 'P'},
    {x=-2, y=8, repr = 'P'},
    {x=-1, y=8, repr = '@'},
    {x= 0, y=8, repr = 'P'},
    {x=-2, y=9, repr = 'v'},
    {x=-1, y=9, repr = 'P'},
    {x= 0, y=9, repr = 'P'},
}
assertEq (entities.get_tiles ('pump', {x=-1, y=8, rot='v'}),
          expected)
assertEq (entities.get_tiles ('pump', {x=-1, y=8, rot='v'}, entities.PIPING),
          {{x=-2, y=10}})



---- see what has all been loaded where --------------------------------------

expected = {
    ['medium-pole'] = true,
    ['bacon'] = true,
    ['pump'] = true,
    ['omni-pipe'] = true,
    ['groundpipe'] = true,
    ['widepole'] = true,
}
assertEq (entities.loaded (), expected)
assertEq (entities.get_types (entities.ALL), expected)
assertEq (entities.get_types (entities.POWER), 
         {['medium-pole'] = true, ['widepole'] = true})
assertEq (entities.get_types (entities.BONUS), 
          {bacon = true})
assertEq (entities.get_types (entities.PIPING), 
          {pump = true, groundpipe = true, ['omni-pipe'] = true})
assertEq (entities.get_types (entities.SOURCE), 
          {pump = true})



print ("==== ENTITIES TESTS PASSED ====")

