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

function mat4.orthogonal(left, right, bottom, top, near, far)
    return __construct(
        2/(right-left), 0, 0, -(right+left)/(right-left),
        0, 2/(top-bottom), 0, -(top+bottom)/(top-bottom),
        0, 0, -2/(far-near), -(far+near)/(far-near),
        0, 0, 0, 1
    )
end

function mat4.components(m)
    return m.e1_1, m.e1_2, m.e1_3, m.e1_4,
           m.e2_1, m.e2_2, m.e2_3, m.e2_4,
           m.e3_1, m.e3_2, m.e3_3, m.e3_4,
           m.e4_1, m.e4_2, m.e4_3, m.e4_4
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