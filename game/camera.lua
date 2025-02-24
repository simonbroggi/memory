local mat4 = require("love3d.mat4")

local camera = {}

local function __construct(l, r)
    local c = {}
    return setmetatable(c, camera)
end


camera.__index = camera
setmetatable(camera, {__call = function(_, ...) return __construct(...) end})

return camera