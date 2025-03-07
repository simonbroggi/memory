local core = require("core")
local PhysicsSystem = require("systems.PhysicsSystem")

local System = {}

---@class pointer
---@field x number
---@field y number
---@field isDown boolean
---@field wasDown boolean

function System:init()
    if love.mouse.isCursorSupported() then
        local m = love.mouse

        ---@type pointer
        self.mousePointer = {x = m.getX(), y = m.getY(), isDown = m.isDown(1), wasDown = false}

        function love.mousepressed( x, y, button, istouch, presses )
            if istouch then return end
            if button == 1 then
                self.mousePointer.isDown = true
            end
        end

        function love.mousereleased( x, y, button, istouch, presses)
            if istouch then return end
            if button == 1 then
                self.mousePointer.isDown = false
            end
        end

    end
end

function System:filter()
    self.cameraEntity = nil
    for _, entity in ipairs(core.ecs_world.entities) do
        if entity.camera then
            self.cameraEntity = entity
        end
    end
end

function System:update(dt)
    self:filter()
    if self.mousePointer then
        local m = love.mouse
        self.mousePointer.x = m.getX()
        self.mousePointer.y = m.getY()
        

        if self.mousePointer.isDown then
            if self.mousePointer.wasDown == false then
                -- mouse down this frame!

                -- calculate Normalized Device Coordinates:
                -- center of the screen is 0,0. top left is -1,-1. bottom right is 1,1.
                local ndc_x = self.mousePointer.x * 2 / love.graphics.getWidth() - 1
                local ndc_y = 1 - self.mousePointer.y * 2 / love.graphics.getHeight()

                local mx, my = self.cameraEntity.camera:getXYPlaneIntersection(self.cameraEntity.transform, ndc_x, ndc_y)

                PhysicsSystem:pointerDown(mx, my)
            end
        else
            if self.mousePointer.wasDown == true then
                -- mouse up this frame!
            end
        end
        self.mousePointer.wasDown = self.mousePointer.isDown
    end
end

return System