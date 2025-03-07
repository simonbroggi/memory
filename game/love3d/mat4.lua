local mat4 = {}

local function __construct(e1_1, e1_2, e1_3, e1_4,
                         e2_1, e2_2, e2_3, e2_4,
                         e3_1, e3_2, e3_3, e3_4,
                         e4_1, e4_2, e4_3, e4_4)
    local m = {}

    e1_1 = e1_1 or 0
    if not e1_2 then
        e1_2, e1_3, e1_4 = 0, 0, 0
        e2_1, e2_2, e2_3, e2_4 = 0, e1_1, 0, 0
        e3_1, e3_2, e3_3, e3_4 = 0, 0, e1_1, 0
        e4_1, e4_2, e4_3, e4_4 = 0, 0, 0, e1_1
    end

    m.e1_1, m.e1_2, m.e1_3, m.e1_4 = e1_1, e1_2, e1_3, e1_4
    m.e2_1, m.e2_2, m.e2_3, m.e2_4 = e2_1, e2_2, e2_3, e2_4
    m.e3_1, m.e3_2, m.e3_3, m.e3_4 = e3_1, e3_2, e3_3, e3_4
    m.e4_1, m.e4_2, m.e4_3, m.e4_4 = e4_1, e4_2, e4_3, e4_4

    return setmetatable(m, mat4)
end

-- https://github.com/Tachytaenius/mathsies/blob/master/mathsies.lua

function mat4.translation(x, y, z)
    return __construct(
        1, 0, 0, x,
        0, 1, 0, y,
        0, 0, 1, z,
        0, 0, 0, 1
    )
end

function mat4:setTranslation(x, y, z)
    self.e1_4 = x
    self.e2_4 = y
    self.e3_4 = z
    return self
end

-- ---rotation roder: y x z
-- ---@param x number
-- ---@param y number
-- ---@param z number
-- function mat4.rotation_euler(x, y, z)
--     return mat4.rotation_z(z):apply(mat4.rotation_x(x)):apply(mat4.rotation_y(y))
-- end

---mat4:apply(mat4.rotation_z(x)) is equivalent to transform:rotate(x)
---@param rad number angle in radians
---@return table mat4
function mat4.rotation_z(rad)
    local c, s = math.cos(rad), math.sin(rad)
    return __construct(
        c, -s, 0, 0,
        s, c, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    )
end

function mat4.rotation_x(rad)
    local c, s = math.cos(rad), math.sin(rad)
    return __construct(
        1, 0, 0, 0,
        0, c, -s, 0,
        0, s, c, 0,
        0, 0, 0, 1
    )
end

function mat4.rotation_y(rad)
    local c, s = math.cos(rad), math.sin(rad)
    return __construct(
        c, 0, s, 0,
        0, 1, 0, 0,
        -s, 0, c, 0,
        0, 0, 0, 1
    )
end

function mat4.scale(sx, sy, sz)
    return __construct(
        sx, 0, 0, 0,
        0, sy, 0, 0,
        0, 0, sz, 0,
        0, 0, 0, 1
    )
end

function mat4.ortho(left, right, bottom, top, near, far)
    return __construct(
        2/(right-left), 0, 0, -(right+left)/(right-left),
        0, 2/(top-bottom), 0, -(top+bottom)/(top-bottom),
        0, 0, -2/(far-near), -(far+near)/(far-near),
        0, 0, 0, 1
    )
end

---create right hand perspective projection matrix
---@param vert_fov any
---@param aspect number width / height
---@param near any
---@param far any
---@return table
function mat4.perspective_righthanded(vert_fov, aspect, near, far, shift_x, shift_y)
    local e3_3, e3_4 = -1, -2*near
    if far then
        e3_3 = (far+near)/(near-far)
        e3_4 = 2*far*near/(near-far)
    end
    local f = 1 / math.tan(vert_fov / 2)
    return __construct(
        f/aspect, 0, shift_x, 0,
        0, f, shift_y, 0,
        0, 0, e3_3, e3_4,
        0, 0, -1, 0
    )
end

function mat4.perspective_lefthanded(vert_fov, aspect, near, far, shift_x, shift_y, shear_x, shear_y)
    local e3_3, e3_4 = -1, -2*near
    shift_x, shift_y = shift_x or 0, shift_y or 0
    shear_x, shear_y = shear_x or 0, shear_y or 0

    -- shear around center, even if camera lens is shifted.
    shift_x = shift_x + shear_x * shift_y * -0.5
    shift_y = shift_y + shear_y * shift_x * -0.5

    if far then
        e3_3 = (far+near)/(far-near)
        e3_4 = 2*far*near/(far-near)
    end
    local f = 1 / math.tan(vert_fov / 2)
    return __construct(
        f/aspect, shear_x, shift_x, 0,
        0, -f, shift_y, 0,
        0, shear_y, e3_3, e3_4,
        0, 0, -1, 0
    )
end

function mat4.components(m)
    return m.e1_1, m.e1_2, m.e1_3, m.e1_4,
           m.e2_1, m.e2_2, m.e2_3, m.e2_4,
           m.e3_1, m.e3_2, m.e3_3, m.e3_4,
           m.e4_1, m.e4_2, m.e4_3, m.e4_4
end

function mat4:multiplyColumnVec4(x, y, z, w)
    local rx = self.e1_1 * x + self.e1_2 * y + self.e1_3 * z + self.e1_4 * w
    local ry = self.e2_1 * x + self.e2_2 * y + self.e2_3 * z + self.e2_4 * w
    local rz = self.e3_1 * x + self.e3_2 * y + self.e3_3 * z + self.e3_4 * w
    local rw = self.e4_1 * x + self.e4_2 * y + self.e4_3 * z + self.e4_4 * w
    return rx, ry, rz, rw
end

function mat4:apply(m)
    self.e1_1 = self.e1_1 * m.e1_1 + self.e1_2 * m.e2_1 + self.e1_3 * m.e3_1 + self.e1_4 * m.e4_1
    self.e1_2 = self.e1_1 * m.e1_2 + self.e1_2 * m.e2_2 + self.e1_3 * m.e3_2 + self.e1_4 * m.e4_2
    self.e1_3 = self.e1_1 * m.e1_3 + self.e1_2 * m.e2_3 + self.e1_3 * m.e3_3 + self.e1_4 * m.e4_3
    self.e1_4 = self.e1_1 * m.e1_4 + self.e1_2 * m.e2_4 + self.e1_3 * m.e3_4 + self.e1_4 * m.e4_4
    self.e2_1 = self.e2_1 * m.e1_1 + self.e2_2 * m.e2_1 + self.e2_3 * m.e3_1 + self.e2_4 * m.e4_1
    self.e2_2 = self.e2_1 * m.e1_2 + self.e2_2 * m.e2_2 + self.e2_3 * m.e3_2 + self.e2_4 * m.e4_2
    self.e2_3 = self.e2_1 * m.e1_3 + self.e2_2 * m.e2_3 + self.e2_3 * m.e3_3 + self.e2_4 * m.e4_3
    self.e2_4 = self.e2_1 * m.e1_4 + self.e2_2 * m.e2_4 + self.e2_3 * m.e3_4 + self.e2_4 * m.e4_4
    self.e3_1 = self.e3_1 * m.e1_1 + self.e3_2 * m.e2_1 + self.e3_3 * m.e3_1 + self.e3_4 * m.e4_1
    self.e3_2 = self.e3_1 * m.e1_2 + self.e3_2 * m.e2_2 + self.e3_3 * m.e3_2 + self.e3_4 * m.e4_2
    self.e3_3 = self.e3_1 * m.e1_3 + self.e3_2 * m.e2_3 + self.e3_3 * m.e3_3 + self.e3_4 * m.e4_3
    self.e3_4 = self.e3_1 * m.e1_4 + self.e3_2 * m.e2_4 + self.e3_3 * m.e3_4 + self.e3_4 * m.e4_4
    self.e4_1 = self.e4_1 * m.e1_1 + self.e4_2 * m.e2_1 + self.e4_3 * m.e3_1 + self.e4_4 * m.e4_1
    self.e4_2 = self.e4_1 * m.e1_2 + self.e4_2 * m.e2_2 + self.e4_3 * m.e3_2 + self.e4_4 * m.e4_2
    self.e4_3 = self.e4_1 * m.e1_3 + self.e4_2 * m.e2_3 + self.e4_3 * m.e3_3 + self.e4_4 * m.e4_3
    self.e4_4 = self.e4_1 * m.e1_4 + self.e4_2 * m.e2_4 + self.e4_3 * m.e3_4 + self.e4_4 * m.e4_4
    return self
end

-- function mat4:transform(x, y, z)
--     local x1 = self.e1_1 * x + self.e1_2 * y + self.e1_3 * z + self.e1_4
--     local y1 = self.e2_1 * x + self.e2_2 * y + self.e2_3 * z + self.e2_4
--     local z1 = self.e3_1 * x + self.e3_2 * y + self.e3_3 * z + self.e3_4

--     -- not quit sure if this is correct
--     local div = self.e4_1 * x + self.e4_2 * y + self.e4_3 * z + self.e4_4
--     if div ~= 1 then
--         print("div", div)
--         x1 = x1 / div
--         y1 = y1 / div
--         z1 = z1 / div
--     end

--     return x1, y1, z1
-- end

mat4.__index = mat4

setmetatable(
    mat4,
    {
        __call = function(_, e1_1, e1_2, e1_3, e1_4,  e2_1, e2_2, e2_3, e2_4,  e3_1, e3_2, e3_3, e3_4,  e4_1, e4_2, e4_3, e4_4)
            return __construct(e1_1, e1_2, e1_3, e1_4,  e2_1, e2_2, e2_3, e2_4,  e3_1, e3_2, e3_3, e3_4,  e4_1, e4_2, e4_3, e4_4)
        end
    }
)


return mat4