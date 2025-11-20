local core = require("core")
local PhysicsSystem = require("systems.PhysicsSystem")

local System = {}

---@class pointer
---@field x number
---@field y number
---@field isDown boolean
---@field wasDown boolean


System.uiInteractableEntities = core.newList()

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

    self.uiInteractableEntities:clear()
    for _, entity in ipairs(core.ecs_world.entities) do
        if entity.ui and entity.rectangle and entity.onPointerDown then
            self.uiInteractableEntities:add(entity)
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
                local pointerUsed = false
                -- check if it's over an interactive UI element
                -- if so, do not send the pointer down to the physics system
                for _, entity in ipairs(self.uiInteractableEntities) do
                    local upperLeftX = entity.tform.x - entity.rectangle.width / 2
                    local upperLeftY = entity.tform.y - entity.rectangle.height / 2
                    local lowerRightX = entity.tform.x + entity.rectangle.width / 2
                    local lowerRightY = entity.tform.y + entity.rectangle.height / 2
                    if self.mousePointer.x >= upperLeftX and
                       self.mousePointer.x <= lowerRightX and
                       self.mousePointer.y >= upperLeftY and
                       self.mousePointer.y <= lowerRightY then
                        -- mouse is over this UI element, call its onPointerDown function
                        if entity.pointerDownHandler then
                            entity.onPointerDown(entity.pointerDownHandler, entity)
                        else
                            entity:onPointerDown()
                        end
                        pointerUsed = true -- stop processing pointer down for physics system
                    end
                end

                if not pointerUsed then
                    -- calculate Normalized Device Coordinates:
                    -- center of the screen is 0,0. top left is -1,-1. bottom right is 1,1.
                    local ndc_x = self.mousePointer.x * 2 / love.graphics.getWidth() - 1
                    local ndc_y = 1 - self.mousePointer.y * 2 / love.graphics.getHeight()

                    local mx, my = self.cameraEntity.camera:getXYPlaneIntersection(self.cameraEntity.transform, ndc_x, ndc_y)

                    PhysicsSystem:pointerDown(mx, my)
                end
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