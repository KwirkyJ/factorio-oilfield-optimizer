local floor = math.floor



--[[
prototype tables must be of the following convention:

`prototype.foot = {x = number, y = number}`
    where number > 0
if no rotation (e.g., beacon) :
    `prototype.tiles = {{string, string, ...}, ...}`
    where #tiles == foot.y and for each row in tiles #tilex[y] == foot.x
else (e.g., pumpjack, pipe-to-ground) :
    `prototype.rotations = {[direction] = table}`
    where direction is any of '^', '>', '<', 'v'
    given rotation-dependent attributes override general attributes
    e.g., `prototype.rotations['v'].power` overrides `prototype.power`
if supplies power (e.g., medium pole, substation) :
    `prototype.power = {area = {x = number, y = number}, reach = number}`
    where numbers are all > 0
    `area` is tiles supplied with power 
            e.g., `area = {x=7, y=7}` 
            supplies x-3..x+3, y-3..x+3 from entity center
    `reach` is cartesian distance it will connect to other power entities
if provides bonus (e.g., beacon) :
    `prototype.bonus = { area = {x = number, y = number} }`
    where area is as in power
if moves oil (e.g., pipe, pipe_to_ground, pumpjack) :
    `prototype.piping = {attachments = {XY, ...}, 
            rule = RULE, source = SOURCE}`
    SOURCE e.g., pumpjack : `piping.source = true`; else = false|nil
    attachments lists valid tiles to connect to other piping entities
        XY : {x= number, y=number} giving offset from center
    RULE: how to handle attachments:
        rule = 'all' : use any and all of the attachment tiles as needed
        rule = 'first' : stop after finding the first valid attachment
                e.g. pipe-to-ground
--]]

local entities = {}



---enums of different categories

---all loaded types
entities.ALL = "ALL"

---types that provide power
entities.POWER = "power"

---types that support piping and pipe attachments
entities.PIPING = "piping"

---special piping types that produce stuff
entities.SOURCE = "is_source"

---types that boost entities (beacons)
entities.BONUS = "bonus"

---types that require power
entities.NEEDS_POWER = "requires_power"



-- hidden information; where loaded and preprocessed prototypes sit
local data

local function get_empty_data () 
    return {
        [entities.ALL]    = {},
        [entities.POWER]  = {},
        [entities.PIPING] = {},
        [entities.SOURCE] = {},
        [entities.BONUS]  = {},
        [entities.NEEDS_POWER] = {},
    }
end

data = get_empty_data ()



-- ==== entity.init (typename, prototype) ====================================

-- helper function declarations
local prepare_proto_rotations, populate_rotation, verify_uniform_attributes
local validate_rotation
      

---Load an entity prototype into memory
entities.init = function (typename, prototype)
    local rotations = prepare_proto_rotations (prototype)
    
    local valid, attributes = verify_uniform_attributes (rotations)
    if not valid then
        error (string.format(
                 "prototype %s has rotations with non-uniform attributes", 
                 typename))
    end
    
    -- go over each rotation and check that they are well-fromed
    for k, r in pairs (rotations) do
        local ok, err = pcall (validate_rotation, r)
        if not ok then
            error (string.format("%s\t%s", k, err))
        end
    end
    
    --TODO: preprocess values for proper offsets
    
    -- replace prototype module with mapping of rotkey to processed-rotation
    prototype = rotations 
    
    data [entities.ALL][typename] = prototype
    if attributes.power then 
        data [entities.POWER][typename] = prototype 
    end
    if attributes.requires_power then
        data[entities.NEEDS_POWER][typename] = prototype
    end
    if attributes.bonus then
        data[entities.BONUS][typename] = prototype
    end
    if attributes.pipe_rule then
        data[entities.PIPING][typename] = prototype
        --TODO: piping
        --piping.rule = string ('first' | 'all')
        --piping[1..n] = {x=n, y=n}
    end
    if attributes.is_source then
        data[entities.SOURCE][typename] = prototype
        -- TODO: is_source
    end
end



---populate a rotations table with default values when appropriate
---if prototype has no rotations, a new rotation [1] is introduced
prepare_proto_rotations = function (prototype)
    local attributes, rotations
    
    -- read default prototype attributes
    attributes = {}
    for k, v in pairs (prototype) do
        if k ~= 'rotations' then
            attributes[k] = v
        end
    end
    
    rotations = {}
    -- if no rotations given in prototype, place one {[1] = {...}}
    for key, rot in pairs (prototype.rotations or {{}}) do
        rotations[key] = populate_rotation (rot, attributes)
    end
    return rotations
end



---ensure that all rotations have the same attribute keys
---returns true and hash of attribute keys if all are uniform;
---else returns false
verify_uniform_attributes = function (rotations)
    local attributes
    for _, rotation in pairs (rotations) do
        if attributes == nil then 
            attributes = {}
            for rotkey, _ in pairs (rotation) do
                attributes[rotkey] = true
            end
        else 
            for rotkey, _ in pairs (rotation) do
                if not attributes[rotkey] then
                    return false
                end
            end
            for attrkey, _ in pairs (attributes) do
                if not rotation[attrkey] then
                    return false
                end
            end
        end
    end
    return true, attributes
end



---populate a rotation prototable, 
---prioritize rotation-specific values over defaults
populate_rotation = function (rot, defaults)
    local t = {}
    for k,v in pairs (defaults) do
        t[k] = v
    end
    for k,v in pairs (rot) do
        t[k] = v
    end
    return t
end



---check that a prototype rotation case is well-formed
---raises errors as appropriate
validate_rotation = function (rot)

    -- validate foot
    local foot = rot.foot
    assert (foot, 
            string.format("prototype must have a foot"))
    assert (type (foot) == 'table', 
            "foot must be a table")
    assert (foot.x and foot.y, "foot must have x- and y-keys")
    for k, v in pairs(foot) do
        assert ((k == 'x' or k == 'y'), "foot must have only x and y indices")
        assert (type (v) == 'number', "foot values must be numbers")
    end
    assert (foot.x > 0 and foot.y > 0, "foot must be >= 1 in each dimension")

    -- validate tiles
    assert (foot.y == #rot.tiles, "foot `y` must match tiles height")
    for y=1, foot.y do
        assert (foot.x == #rot.tiles[y], "foot `x` must match all tiles rows")
    end
    
    --TODO: validate power
    --TODO: validate bonus
    
    if rot.pipe_attachments or rot.pipe_rule then
        assert (rot.pipe_rule == 'first' or rot.pipe_rule == 'all',
                "pipe_rule must be 'first' or 'all'")
        local atts = rot.pipe_attachments
        for i = 1, #atts do
            local att = atts[i]
            assert (type (att.x) == 'number', 
                    string.format ("piping location %d has invalid x-coord",
                                    i))
            assert (type (att.y) == 'number', 
                    string.format ("piping location %d has invalid y-coord",
                                    i))
            if att.x == 0 and att.y == 0 then
                error ("0, 0 coordinates are forbidden")
            end
        end
    end
    --TODO: validate source
end



-- ==== entities.get_tiles (typename, E, tiletype) ===========================

local list_coords

---return a list of tiles of the specified type, for a given prototype,
---centered on an entity
---@param typename name of prototype
---@param E        entity instance table
---@param tiletype entity.ENUM 
---                (default: entities.ALL to denote foot representation)
---in the name of speed, failure to find a tiletype, typename, or rotation
---results in an ambiguous error or failure to return, rather than user-
---friendly breakdown; assumes proper function always
entities.get_tiles = function (typename, E, tiletype) 
    tiletype = tiletype or entities.ALL
    local proto, t
    proto = data[tiletype][typename]
    if not proto then 
        return {} 
    end
    proto, t = proto[E.rot or 1], {}
    if tiletype == entities.ALL then
        return list_coords (E.x, E.y, 
                            proto.foot.x, proto.foot.y, 
                            proto.tiles)
    elseif tiletype == entities.POWER then
        return list_coords (E.x, E.y, 
                            proto.power.area.x, proto.power.area.y)
    elseif tiletype == entities.PIPING then
        local atts = proto.pipe_attachments
        for i = 1, #atts do
            t[#t+1] = {x = atts[i].x + E.x,
                       y = atts[i].y + E.y}
        end
    --elseif tiletype == entities.SOURCE then
    elseif tiletype == entities.BONUS then
        return list_coords (E.x, E.y, 
                            proto.bonus.x, proto.bonus.y)
    end
    return t
end



---helper function gets list of coordinates, optinally with tiles repr
list_coords = function (center_x, center_y, area_x, area_y, tiles)
    local ulx = floor (center_x+0.5 - floor (area_x / 2))
    local uly = floor (center_y+0.5 - floor (area_y / 2))
    local t = {}
    for y=1, area_y do
        for x = 1, area_x do
            if tiles then
                t[#t+1] = {x    = x + ulx - 1, 
                           y    = y + uly - 1, 
                           repr = tiles[y][x]}
            else
                t[#t+1] = {x = x + ulx - 1, 
                           y = y + uly - 1}
            end
        end
    end
    return t
end



-- ==== entity.get_attachrule (typename) =====================================

---get the attachment rule of a prototype
---if not of the PIPING type, returns nil;
---else, returns string
entities.get_attachrule = function (typename)
    local proto, _
    proto = data[entities.PIPING][typename]
    if data[entities.PIPING][typename] then 
        _, proto = next (proto, nil)
        return proto.pipe_rule
    end
end



-- ==== entity.get_types (entity.ENUM) =======================================

---return hash of loaded prototypes of specified quality
---e.g. {['medium-pole'] = true, ['substation'] = true}
entities.get_types = function (enum)
    assert (data[enum])
    local t = {}
    for k, _ in pairs (data[enum]) do
        t[k] = true
    end
    return t
end



-- ==== entity.loaded () =====================================================

---return hash of prototypes loaded   
---e.g. {['pipe-to-ground'] = true, ['big-pole'] = true, ['pumpjack'] = true}
---alias for get_types (ALL)
entities.loaded = function ()
    return entities.get_types (entities.ALL)
end



-- ==== entity.clear () ======================================================

---reset, clearing loaded prototypes
entities.clear = function ()
    data = get_empty_data ()
end



return entities

