local core = {}

local modpath = (...)
local entity_mt = require(modpath .. ".Entity_mt")
local list_mt = require(modpath .. ".List_mt")

require(modpath .. ".definitions")

---Create a new entity.
---@return entity
function core.newEntity()
    return setmetatable({}, entity_mt)
end

---Create a new list.
---@return List
function core.newList()
    return setmetatable({size = 0}, list_mt)
end

core.ecs_world = {entities = core.newList()}

---Create a new entity and add it to the world.
---@return entity
function core.newEntitytInWorld()
    local e = core.newEntity()
    core.ecs_world.entities:add(e)
    return e
end

return core