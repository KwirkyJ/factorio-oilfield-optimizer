---module documentation TODO as definition mutates quickly

local entities = require 'entities'



local layout = {}

local insert, tofile

---create a Layout object
local new = function ()
    local t = {grid = {},
               entities = {},
               insert = insert, 
               tofile = tofile,
    }
    return t
end
layout.new = new



---insert an entity `t` of type `typename` into grid object `G`
---can be called at module level `layout.insert (L, 'name', E)`
---or object-like `(Layout):insert ('name', E)`
---`if text` then insert tile characters at indices instead of entity
---return true if addition successful, else false (e.g., location clash)
insert = function (L, typename, E, text)
    local grid = L.grid
--    if not entities[typename] then
--        error ("typename ".. typename.. "not found in entities index", 2)
--    end
    local tile_iter = entities[typename].get_tiles
    
    -- check for collisions; do not add and signal failure if clash
    for x, y, _ in tile_iter (E) do
        if grid[y] and grid[y][x] then 
            return false 
        end
    end
    
    -- no collision; insert
    for x, y, c in tile_iter (E) do
        if not grid[y] then
            grid[y] = {}
        end
        
        if text then 
            grid[y][x] = c
        else
            grid[y][x] = E
        end

        if L.entities[typename] == nil then
            L.entities[typename] = {}
        end
        L.entities[typename][E] = true

        if L.y_min == nil then 
            L.y_min = y
        elseif y < L.y_min then
            for n = y, L.y_min - 1 do
                grid[n] = grid[n] or {}
            end
            L.y_min = y
        end
        if L.y_max == nil then
            L.y_max = y
        elseif y > L.y_max then
            for n = L.y_max + 1, y do
                grid[n] = grid[n] or {}
            end
            L.y_max = y
        end
        
        if L.x_min == nil or x < L.x_min then
            L.x_min = x
        end
        if L.x_max == nil or x > L.x_max then
            L.x_max = x
        end
    end
    L.grid = grid
    return true
end
layout.insert = insert



---return a Layout object where entity references have been replaced 
---with tile characters
local function get_text_grid (L) 
    local textgrid = new ()
    for typename, hashing in pairs (L.entities) do
        for entity, _ in pairs (hashing) do
            textgrid:insert (typename, entity, true)
        end
    end
    return textgrid
end

---print a formatted string representation of grid G to a file
---file argument must be handle, e.g. `io.open (path, 'w')`
tofile = function (L, file)
    local g = get_text_grid (L)['grid']
    local buffer, bufflen, c
    for y = L.y_min, L.y_max do
        buffer, bufflen = {}, 0
        for x = L.x_min, L.x_max do
            c = g[y][x] or ' '
            bufflen = bufflen + 1
            buffer[bufflen] = c
        end
        file:write (string.format ("%s\n", table.concat (buffer)))
    end
    file:flush ()
end
layout.tofile = tofile



return layout

