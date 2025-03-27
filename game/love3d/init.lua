local modpath = (...)

local mat4 = require(modpath .. ".mat4")

local love3d = {mat4 = mat4}

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

-- dont do this!
function Set_right_handed()
    print("WARNING: Set_right_handed() is not recommended. It's a a hack.")
    error("Set_right_handed() is not recommended. It's a a hack.")
    local _draw = love.graphics.draw
    local _body_mt = getmetatable(love.physics.newBody(love.physics.newWorld()))
    local _body_set_angle = _body_mt.setAngle
    local _body_get_angle = _body_mt.getAngle

    love.graphics.draw = function(drawable, ...)
        if type(select(1, ...))=="number" then
            local x, y, r, sx, sy, ox, oy, kx, ky = ...
            _draw(drawable, x, y, -r, sx, -(sy or 1), ox, oy, kx, ky)
        elseif type(select(2, ...)) == "number" then
            local quad, x, y, r, sx, sy, ox, oy, kx, ky = ...
            _draw(drawable, quad, x, y, -r, sx, -(sy or 1), ox, oy, kx, ky)
        else
            _draw(drawable, ...)
        end
    end

    _body_mt.setAngle = function(body, angle)
        _body_set_angle(body, -angle)
    end
    _body_mt.getAngle = function(body)
        return -_body_get_angle(body)
    end
end

--Set_right_handed()

return love3d