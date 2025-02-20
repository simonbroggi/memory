local core = require "core"

---@class PhysicsSystem : System
---@field meterScale number
---@field gravityX number
---@field gravityY number
local PhysicsSystem = {meterScale = 100, gravityX = 0, gravityY = 0}
-- local DamageSystem = require("src.DamageSystem")
local DrawSystem = require("systems.DrawSystem")

PhysicsSystem.bodyEntities = core.newList()

function PhysicsSystem:init()
    self.tick = 0 -- for debugging

    love.physics.setMeter(self.meterScale)
    self.world = love.physics.newWorld(self.gravityX * self.meterScale, self.gravityY * self.meterScale, true)

    local function beginContact(shapeA, shapeB, contact)
        self:beginContact(shapeA, shapeB, contact)
    end
    
    local function endContact(shapeA, shapeB, contact)
        self:endContact(shapeA, shapeB, contact)
    end
    
    -- local function preSolve(shapeA, shapeB, contact)
    --     self:preSolve(shapeA, shapeB, contact)
    -- end
    
    -- local function postSolve(shapeA, shapeB, contact, normalimpulse, tangentimpulse)
    --     self:postSolve(shapeA, shapeB, contact, normalimpulse, tangentimpulse)
    -- end

    -- self.world:setCallbacks(beginContact, endContact, preSolve, postSolve)
    self.world:setCallbacks(beginContact, endContact)
end

function PhysicsSystem:filter()
    self.bodyEntities:clear()
    for _, entity in ipairs(core.ecs_world.entities) do
        if entity.camera then
            self.cameraEntity = entity
        end
        if entity.body and entity.tform then -- filter
            self.bodyEntities:add(entity)
        end
    end
end

function PhysicsSystem:beginContact(shapeA, shapeB, contact)
    -- or get the bodies and check if they have onCollision
    -- actually here it's probabbly best not to go for ecs!
    -- just do what needs to be done here.

    if not contact:isTouching() then return end

    local bodyEntityA = shapeA:getBody():getUserData()
    local bodyEntityB = shapeB:getBody():getUserData()

    -- this might happen multiple times per colliding pairs of body entities,
    -- because it happens for each shape that collides.
    if bodyEntityA.damager and bodyEntityB.damageable then
        -- DamageSystem.damage(bodyEntityA.damager, bodyEntityB.damageable)
    end
    if bodyEntityB.damager and bodyEntityA.damageable then
        -- DamageSystem.damage(bodyEntityB.damager, bodyEntityA.damageable)
    end

    -- now if has doDamage and the other has health subtract doDamage from health.. ok?
    -- or just do damage according to impact https://love2d.org/wiki/Contact

    -- print(string.format("begin contact between bodie entities %s and %s", bodyEntityA, bodyEntityB))
end

function PhysicsSystem:endContact(shapeA, shapeB, contact)
    -- print("tick " .. self.tick .. " endContact " .. tostring(shapeA) .. " " .. tostring(shapeB))
end

-- function PhysicsSystem:preSolve(shapeA, shapeB, contact)
--     print("tick " .. self.tick .. " preSolve " .. tostring(shapeA) .. " " .. tostring(shapeB))
-- end

-- function PhysicsSystem:postSolve(shapeA, shapeB, contact, normalimpulse, tangentimpulse)
--     print("tick " .. self.tick .. " postSolve " .. tostring(shapeA) .. " " .. tostring(shapeB))
-- end

function PhysicsSystem:fixedUpdate(dt)

    -- pragmatic approach: clear the list and re-add all entities that have a body and a transform
    self:filter()

    self.tick = self.tick + 1

    self.world:update(dt)
    
    -- set tform position and rotation according to physics component
    -- could be optimized to not do static bodies.
    for _, entity in ipairs(self.bodyEntities) do
        ---@type love.Body
        local body = entity.body
        local tform = entity.tform
        
        tform.x, tform.y = body:getPosition()
        tform.r = body:getAngle()
    end
end

function PhysicsSystem:debugDraw()
    DrawSystem:pushCameraTransform()
    love.graphics.setColor(1,.2,.2,1)
    love.graphics.setBlendMode("alpha")
    local inactiveBodies = 0
    for _, body in ipairs(self.world:getBodies()) do
        if body:isActive() then
            local x,y = body:getPosition()
            love.graphics.push()
            love.graphics.translate(x,y)
            love.graphics.rotate(body:getAngle())
            --love.graphics.rectangle("line", -50,-30,100,60)
            for _, shape in ipairs(body:getShapes()) do
                if shape:isSensor() then
                    love.graphics.setColor(.2,.2,1,1)
                else
                    love.graphics.setColor(1,.2,.2,1)
                end
                local shapeType = shape:getType()
                if shapeType == "circle" then
                    local sx, sy = shape:getPoint()
                    love.graphics.circle("line", sx, sy, shape:getRadius())
                elseif shapeType == "polygon" then
                    local points = {shape:getPoints()}
                    local nPoints = #points
                    points[nPoints+1] = points[1]
                    points[nPoints+2] = points[2]
                    love.graphics.line(points)
                elseif shapeType == "edge" then
                    love.graphics.line(shape:getPoints())
                elseif shapeType == "chain" then
                    love.graphics.line(shape:getPoints())
                else
                    error("unknown physics shape type. cant debug draw")
                end
            end
            love.graphics.pop()
        else
            inactiveBodies = inactiveBodies + 1
        end
    end

    love.graphics.setColor(1,1,1,1)
    love.graphics.pop()
    if inactiveBodies > 0 then
        love.graphics.print("inactiveBodies: " .. inactiveBodies, 10, 70)
    end
end

return PhysicsSystem