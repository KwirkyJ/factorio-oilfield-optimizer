local floor = math.floor

-- ==== get_tiles iterator stuff =============================================

---variables for get_tiles iterators; nonreentrant
local _x, _y, _w, _h, _ulx, _uly

---set iterator variables with ulx, uly, and entity width/height
local function _prepare_iter (x0, y0, w, h)
    _x, _y, _w, _h, _ulx, _uly = 0, 0, w-1, h-1, x0, y0
end

---nonreentrant iterator/generator to get tiles for an entity
---tiles is a table of tables, e.g. for a big pole
---    {{'T', 'T'},
---     {'T', 'T'}}
---returns grid coordinates x, y, and character at that coordinate
local function _iter (tiles)
    if _y > _h then
        return nil
    end
    local x, y, char = _x + _ulx, _y + _uly, tiles[_y+1][_x+1]
    _x = _x + 1
    if _x > _w then
        _x, _y = 0, _y + 1
    end
    return x, y, char
end



-- ==== ENTITY STUFF =========================================================

local entities = {}

entities['pumpjack'] = {get_tiles = function (t)
                            _prepare_iter (floor(t.x)-1, floor(t.y)-1, 3, 3)
                            return _iter, entities['pumpjack'][t.rot]
                        end,
                        ['^'] = {{'P','P','^'},
                                 {'P','@','P'},
                                 {'P','P','P'}},
                        ['>'] = {{'P','P','>'},
                                 {'P','@','P'},
                                 {'P','P','P'}},
                        ['v'] = {{'P','P','P'},
                                 {'P','@','P'},
                                 {'v','P','P'}},
                        ['<'] = {{'P','P','P'},
                                 {'P','@','P'},
                                 {'<','P','P'}},
}

entities['beacon'] = {get_tiles = function (t)
                          _prepare_iter (floor (t.x)-1, floor (t.y)-1, 3, 3)
                          return _iter, entities['beacon'].tiles
                      end,
                      tiles = {{'B','B','B'},
                               {'B','*','B'},
                               {'B','B','B'}}
}

entities['small-pole'] = {get_tiles = function (t)
                            _prepare_iter (floor(t.x), floor(t.y), 1, 1)
                            return _iter, entities['small-pole'].tiles
                          end,
                          tiles = {{'s'},},
}

entities['medium-pole'] = {get_tiles = function (t)
                             _prepare_iter (floor(t.x), floor(t.y), 1, 1)
                             return _iter, entities['medium-pole'].tiles
                           end,
                           tiles = {{'m'},},
}

entities['big-pole'] = {get_tiles = function (t)
                            _prepare_iter (floor(t.x), floor(t.y), 2, 2)
                            return _iter, entities['big-pole'].tiles
                        end,
                        tiles = {{'T', 'T'},
                                 {'T', 'T'}},
}

entities['substation'] = {get_tiles = function (t)
                            _prepare_iter (floor(t.x), floor(t.y), 2, 2)
                            return _iter, entities['substation'].tiles
                          end,
                          tiles = {{'#', '#'},
                                   {'#', '#'}},
}

entities['pipe'] = {get_tiles = function (t)
                        _prepare_iter (floor(t.x), floor(t.y), 1, 1)
                        return _iter, entities['pipe'].tiles
                    end,
                    tiles = {{'+'},},
}

entities['pipe-to-ground'] = {get_tiles = function (t)
                                _prepare_iter (floor(t.x), floor(t.y), 1, 1)
                                return _iter, 
                                       entities['pipe-to-ground'][t.rot]
                              end,
                              ['^'] = {{'^'}},
                              ['>'] = {{'>'}},
                              ['v'] = {{'v'}},
                              ['<'] = {{'<'}},
}



return entities

