local core = require "core"
local mat4 = require("love3d.mat4")
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

                local view = self.cameraEntity.transform:inverse()
                local projection = self.cameraEntity.camera.projection
                local viewProjection = projection:clone():apply(view)
                -- compute the inverse of the view_projection matrix
                local inv_vp = viewProjection:inverse()

                -- calculate the world coordinates of the near and far points
                local mat_inv_vp = mat4(inv_vp:getMatrix())
                local near_x, near_y, near_z, near_w = mat_inv_vp:multiplyColumnVec4(ndc_x, ndc_y, -1, 1)
                near_x, near_y, near_z = near_x / near_w, near_y / near_w, near_z / near_w -- homogeneous coordinates to 3D points
                local far_x, far_y, far_z, far_w = mat_inv_vp:multiplyColumnVec4(ndc_x, ndc_y, 1, 1)
                far_x, far_y, far_z = far_x / far_w, far_y / far_w, far_z / far_w -- homogeneous coordinates to 3D points

                -- calculate the ray direction
                local ray_dir_x, ray_dir_y, ray_dir_z = far_x - near_x, far_y - near_y, far_z - near_z
                if far_w == 0 then -- there's no far clip plane. cast ray from camera position to the near clip plane.
                    local _, _, _, view_x, _, _, _, view_y, _, _, _, view_z = self.cameraEntity.transform:getMatrix()
                    ray_dir_x, ray_dir_y, ray_dir_z = near_x - view_x, near_y - view_y, near_z - view_z
                end

                -- normalize the ray direction
                local ray_dir_len = math.sqrt(ray_dir_x * ray_dir_x + ray_dir_y * ray_dir_y + ray_dir_z * ray_dir_z)
                ray_dir_x, ray_dir_y, ray_dir_z = ray_dir_x / ray_dir_len, ray_dir_y / ray_dir_len, ray_dir_z / ray_dir_len

                -- find intersection with the z=0 plane
                local t = -near_z / ray_dir_z
                local intersection_x, intersection_y = near_x + t * ray_dir_x, near_y + t * ray_dir_y

                local mx, my = intersection_x, intersection_y
                
                -- transform mouse coordinates to world coordinates
                -- mx, my = DrawSystem.projection:inverseTransformPoint(mx, my) -- just projection, without camera view transform taken into account
                -- local viewProjection = DrawSystem.cameraEntity.camera.projection:clone():apply(DrawSystem.cameraEntity.transform:inverse())
                
                -- ndc_x, ndc_y = viewProjection:inverseTransformPoint(ndc_x, ndc_y)
                
                -- ndc_x, ndc_y = Hand.tform.x, Hand.tform.y

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

                local test_size = 0.000000001
                local topLeftX = mx - test_size
                local topLeftY = my - test_size
                local bottomRightX = mx + test_size
                local bottomRightY = my + test_size

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