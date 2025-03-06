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

camera.__index = camera
setmetatable(camera, {__call = function(_, ...) return __construct(...) end})

return camera