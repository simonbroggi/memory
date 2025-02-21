local core = require "core"
local mat4 = require("mat4")
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
                -- without projection transform function 
                -- local mx, my = self.mousePointer.x, self.mousePointer.y
                -- mx = self.mousePointer.x - DrawSystem.canvas_translate_x
                -- my = self.mousePointer.y - DrawSystem.canvas_translate_y
                -- mx = mx / DrawSystem.canvas_scale
                -- my = my / DrawSystem.canvas_scale
                -- mx = mx - DrawSystem.canvas_reference_width / 2
                -- my = my - DrawSystem.canvas_reference_height / 2

                -- normalize coordinates. center of the screen is 0,0
                local mx, my = self.mousePointer.x * 2 / love.graphics.getWidth() - 1, self.mousePointer.y * 2 / love.graphics.getHeight() - 1
                my = - my -- make y axis go up
                
                -- transform mouse coordinates to world coordinates
                -- mx, my = DrawSystem.projection:inverseTransformPoint(mx, my) -- just projection, without camera view transform taken into account
                local viewProjection = DrawSystem.projection:clone():apply(DrawSystem.cameraEntity.camera.view)
                
                mx, my = viewProjection:inverseTransformPoint(mx, my)
                
                mx, my = Hand.tform.x, Hand.tform.y

                -- this might not work when rotating the camera because theres no z?
                -- todo: check Matrix.h line 366, 341
                -- below i'm trying to do my own inverseTransformPoint

                -- local inverse = mat4(viewProjection:inverse():getMatrix())
                -- local cam = DrawSystem.cameraEntity.camera
                -- local distToOrigin = math.sqrt(cam.x * cam.x + cam.y * cam.y + cam.z * cam.z)
                -- local mz = -100
                
                -- mx, my, mz = inverse:transform(mx, my, mz)
                -- print("distToOrigin: " .. distToOrigin .. "   mz: " .. mz)

                -- print("mouse down at: " .. mx .. "," .. my .. "  -  " .. mxx .. "," .. myy)

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

                    if entity.onPointerDown then entity:onPointerDown() end
                    
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