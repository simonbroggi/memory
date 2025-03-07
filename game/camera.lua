local love3d = require("love3d")

local camera = {}

local function __construct(canvas_reference_width, canvas_reference_height, perspective, fov, near, far, shift_x, shift_y, shear_x, shear_y)
    local c = {}

    -- reference resolution where canvas scale is 1
    -- design for this resolution
    -- should stay constant!
    c.canvas_reference_width = canvas_reference_width
    c.canvas_reference_height = canvas_reference_height

    c.canvas_scale = 1

    c.perspective = perspective
    c.fov = fov
    c.near = near
    c.far = far
    c.shift_x = shift_x
    c.shift_y = shift_y
    c.shear_x = shear_x
    c.shear_y = shear_y

    c.projection = love.math.newTransform()

    setmetatable(c, camera)

    --c:updateProjection()

    return c
end

function camera:updateProjection(width, height)
    self.canvas_scale = math.min(width/self.canvas_reference_width, height/self.canvas_reference_height)
    local matrix
    if self.perspective then
        matrix = love3d.mat4.perspective_lefthanded(self.fov, self.canvas_reference_width/self.canvas_reference_height, self.near, self.far, self.shift_x, self.shift_y, self.shear_x, self.shear_y)
    else
        matrix = love3d.mat4.ortho(-self.canvas_reference_width/2, self.canvas_reference_width/2, -self.canvas_reference_height/2, self.canvas_reference_height/2, self.near, self.far)
    end
    self.projection:setMatrix(matrix:components())
end

---Raycast from a ndc position on the camera near to far clip plane onto the world X/Y plane (Z=0).
---Returning world position where Z is 0.
---If the camera has no far clip plane, the ray is cast from the camera position to the near clip plane.
---@param transform love.Transform camera transform
---@param ndc_x number normalized device coordinate X component
---@param ndc_y number normalized device coordinate Y component
---@return number world coordinate on the X axis
---@return number world coordinate on the Y axis
function camera:getXYPlaneIntersection(transform, ndc_x, ndc_y)
    local view = transform:inverse()
    local viewProjection = self.projection:clone():apply(view)
    -- compute the inverse of the view_projection matrix
    local inv_vp = viewProjection:inverse()

    -- calculate the world coordinates of the near and far points
    local mat_inv_vp = love3d.mat4(inv_vp:getMatrix())
    local near_x, near_y, near_z, near_w = mat_inv_vp:multiplyColumnVec4(ndc_x, ndc_y, -1, 1)
    near_x, near_y, near_z = near_x / near_w, near_y / near_w, near_z / near_w -- homogeneous coordinates to 3D points
    local far_x, far_y, far_z, far_w = mat_inv_vp:multiplyColumnVec4(ndc_x, ndc_y, 1, 1)
    if far_w == 0 then
        -- there's no far clip plane. cast ray from camera position to the near clip plane.
        if not self.perspective then
            love.errorhandler("Camera has no far clip plane and is not in perspective mode./nCant cast ray to the far clip plane.")
            -- todo: just cast the ray in the direction of the camera transform
        end
        far_x, far_y, far_z = near_x, near_y, near_z
        _, _, _, near_x, _, _, _, near_y, _, _, _, near_z = transform:getMatrix()
    else
        far_x, far_y, far_z = far_x / far_w, far_y / far_w, far_z / far_w -- homogeneous coordinates to 3D points
    end

    -- calculate the ray direction
    local ray_dir_x, ray_dir_y, ray_dir_z = far_x - near_x, far_y - near_y, far_z - near_z

    -- normalize the ray direction
    local ray_dir_len = math.sqrt(ray_dir_x * ray_dir_x + ray_dir_y * ray_dir_y + ray_dir_z * ray_dir_z)
    ray_dir_x, ray_dir_y, ray_dir_z = ray_dir_x / ray_dir_len, ray_dir_y / ray_dir_len, ray_dir_z / ray_dir_len

    -- find intersection with the z=0 plane
    local t = -near_z / ray_dir_z
    local intersection_x, intersection_y = near_x + t * ray_dir_x, near_y + t * ray_dir_y

    return intersection_x, intersection_y
end

camera.__index = camera
setmetatable(camera, {__call = function(_, ...) return __construct(...) end})

return camera