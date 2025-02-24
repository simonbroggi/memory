local modpath = (...)

local mat4 = require(modpath .. ".mat4")

require(modpath .. ".definitions")

-- extend love transform to 3d

love.math.newTransform3D = function(m)
    return love.math.newTransform():setMatrix(m:components())
end
local t3d = love.math.newTransform3D

local transform_mt = getmetatable(love.math.newTransform())

local _translate = transform_mt.translate
---comment
---@param x any
---@param y any
---@param z any
---@return unknown
function transform_mt:translate(x, y, z)
    if z then
        local t = t3d(mat4.translation(x, y, z))
        return self:apply(t)
    else
        return _translate(self, x, y)
    end
end

local _rotate = transform_mt.rotate
function transform_mt:rotate(z, x, y)
    _rotate(self, z)
    if x and x ~= 0 then
        self:apply(t3d(mat4.rotation_x(x)))
    end
    if y and y ~= 0 then
        self:apply(t3d(mat4.rotation_y(y)))
    end
end

