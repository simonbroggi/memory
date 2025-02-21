local mat4 = require("mat4")

local camera = {}

local function __construct(x, y, z, rx, ry, rz)
    local c = {}
    c.x = x or 0
    c.y = y or 0
    c.z = z or 0

    -- rotations stored in euler angles for now
    c.rx = rx or 0
    c.ry = ry or 0
    c.rz = rz or 0

    c.viewMatrix = mat4.translation(-c.x, -c.y, -c.z)
    c.view = love.math.newTransform():setMatrix(c.viewMatrix:components())

    c.view_need_update = false
    return setmetatable(c, camera)
end

function camera:setPosition(x, y, z)
    self.x, self.y, self.z = x or 0, y or 0, z or 0
    self.viewMatrix:setTranslation(-self.x, -self.y, -self.z)
    self.view_need_update = true
end

function camera:setRotation(rx, ry, rz)
    self.rx, self.ry, self.rz = rx or 0, ry or 0, rz or 0
    -- probably going to be gimbal locked at some point, but for now it's fine.
    -- not 100% sure if the rotation should be inverted.
    -- https://www.reddit.com/r/opengl/comments/x656w/am_i_understanding_the_mvp_matrices_correctly/?rdt=42113
    
    -- construct rotation matrix, then set the translation components.
    self.viewMatrix = mat4.rotation_euler(self.rx, self.ry, self.rz)
    self.viewMatrix:setTranslation(-self.x, -self.y, -self.z)
    self.view_need_update = true
end

-- viewMatrix:setRotation

function camera:getView()
    if self.view_need_update then
        self.view:setMatrix(self.viewMatrix:components())
        self.view_need_update = false
    end
    return self.view
end

camera.__index = camera
setmetatable(camera, {__call = function(_, ...) return __construct(...) end})

return camera