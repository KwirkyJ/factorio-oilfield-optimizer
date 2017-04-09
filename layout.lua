---module documentation TODO as definition mutates quickly

local entities = require 'entities'



local layout = {}

local new, insert, tofile



-- ==== layout.new () ========================================================

---create a Layout object
new = function ()
    local t = {grid = {},
               entities = {},
               insert = insert, 
               tofile = tofile,
    }
    return t
end
layout.new = new



-- ==== layout.insert (Layout, typename, E, textgrid) ========================

---insert an entity `t` of type `typename` into grid object `G`
---can be called at module level `layout.insert (L, 'name', E)`
---or object-like `(Layout):insert ('name', E)`
---`if text` then insert tile characters at indices instead of entity
---return true if addition successful, else false (e.g., location clash)
insert = function (L, typename, E, text)
    local grid, foot_tiles, tile, x, y, c
    grid = L.grid
    
    -- TODO: error case of typename not recognized in entities
    
    foot_tiles = entities.get_tiles (typename, E)
    tiles_len = #foot_tiles
    
    -- check for collisions; do not add and signal failure if clash
    for i=1, tiles_len do
        tile = foot_tiles[i]
        x, y = tile.x, tile.y
        if grid[y] and grid[y][x] then 
            return false 
        end
    end
    
    -- no collision; insert
    for i=1, tiles_len do
        tile = foot_tiles[i]
        x, y, c = tile.x, tile.y, tile.repr
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



-- ==== layout.tofile (Layout, filehandle) ===================================

local get_text_grid

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



---return a Layout object where entity references have been replaced 
---with tile characters
get_text_grid = function (L) 
    local textgrid = new ()
    for typename, hashing in pairs (L.entities) do
        for entity, _ in pairs (hashing) do
            textgrid:insert (typename, entity, true)
        end
    end
    return textgrid
end



return layout

