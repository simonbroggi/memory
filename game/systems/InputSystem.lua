local core = require "core"
local PhysicsSystem = require("systems.PhysicsSystem")
local DrawSystem = require("systems.DrawSystem")

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

function System:update(dt)
    if self.mousePointer then
        local m = love.mouse
        self.mousePointer.x = m.getX()
        self.mousePointer.y = m.getY()
        

        if self.mousePointer.isDown then
            if self.mousePointer.wasDown == false then
                -- mouse down this frame!

                -- transform mouse coordinates to world coordinates
                -- could definitely be done nicer! (learn to use transforms properly!)
                local mx, my = self.mousePointer.x, self.mousePointer.y
                mx = self.mousePointer.x - DrawSystem.canvas_translate_x
                my = self.mousePointer.y - DrawSystem.canvas_translate_y
                mx = mx / DrawSystem.canvas_scale
                my = my / DrawSystem.canvas_scale
                mx = mx - DrawSystem.canvas_reference_width / 2
                my = my - DrawSystem.canvas_reference_height / 2

                local topLeftX = mx - 1
                local topLeftY = my - 1
                local bottomRightX = mx + 1
                local bottomRightY = my + 1

                PhysicsSystem.world:queryShapesInArea(topLeftX, topLeftY, bottomRightX, bottomRightY, function(shape)
                    if not shape:testPoint(mx, my) then
                        -- continue testing for shapes
                        return true
                    end
                    
                    local body = shape:getBody()
                    local entity = body:getUserData()
                    if not entity.anim then
                        entity.anim = {
                            time = 0,
                            update = function(e, t)
                                local anim = e.anim
                                anim.time = anim.time + t
                                local tt = anim.time * 5
                                if tt >= math.pi then
                                    e.tform.sx = 1
                                    e.tform.sy = 1
                                    e.tform.kx = 0
                                    e.tform.ky = 0
                                    e.anim = nil
                                end
                                e.tform.sx = 1 - math.sin(tt) * 0.1
                                e.tform.sy = 1 - math.sin(tt) * .8
                                e.tform.kx = math.sin(tt) * 0.5
                                e.tform.ky = math.sin(tt) * -0.7
                            end
                        }
                    end
                    
                    -- continue testing for other shapes (could return false to stop testing and only handle the first shape collision)
                    return true
                end)
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