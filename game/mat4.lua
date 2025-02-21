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

---rotation roder: y x z
---@param x number
---@param y number
---@param z number
function mat4.rotation_euler(x, y, z)
    return mat4.rotation_z(z):apply(mat4.rotation_x(x)):apply(mat4.rotation_y(y))
end

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

function mat4.ortho(left, right, bottom, top, near, far)
    return __construct(
        2/(right-left), 0, 0, -(right+left)/(right-left),
        0, 2/(top-bottom), 0, -(top+bottom)/(top-bottom),
        0, 0, -2/(far-near), -(far+near)/(far-near),
        0, 0, 0, 1
    )
end

---comment
---@param vert_fov any
---@param aspect number width / height
---@param near any
---@param far any
---@return table
function mat4.perspective(vert_fov, aspect, near, far)
    local f = 1 / math.tan(vert_fov / 2)
    return __construct(
        f/aspect, 0, 0, 0,
        0, f, 0, 0,
        0, 0, (far+near)/(near-far), 2*far*near/(near-far),
        0, 0, -1, 0
    )
end

function mat4.components(m)
    return m.e1_1, m.e1_2, m.e1_3, m.e1_4,
           m.e2_1, m.e2_2, m.e2_3, m.e2_4,
           m.e3_1, m.e3_2, m.e3_3, m.e3_4,
           m.e4_1, m.e4_2, m.e4_3, m.e4_4
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