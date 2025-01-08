local core = require("core")

local System = {
    animEntities = core.newList()
}

function System:init()
    self:filter()
end

function System:filter()
    self.animEntities:clear()
    for _, entity in ipairs(core.ecs_world.entities) do
        if entity.anim then
            self.animEntities:add(entity)
        end
    end
end

function System:update(dt)
    self:filter()
    for _, entity in ipairs(self.animEntities) do
        local anim = entity.anim
        anim.time = anim.time + dt
        anim.update(entity, dt)
    end
end

return System