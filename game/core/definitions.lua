---@class entity every entity is added to the world entities List.
---@field body? love.Body UserData of the body points to the entity.
---@field private __body? love.Body body is actually stored here.
---@field tform? tform
---@field transform? love.Transform
---@field sprite? sprite
---@field rectangle? rectangle
---@field material? material
---@field onPointerDown? function

---@class tform 2d transform component
---@field x number translation in x
---@field y number translation in y
---@field r? number rotation in radians
---@field sx? number scale factor in x
---@field sy? number scale factor in y
---@field kx? number skew factor in x
---@field ky? number skew factor in y

---@class sprite
---@field texture love.Texture
---@field quad love.Quad
---@field ox number origin offset in x (aka anchor point)
---@field oy number origin offset in y (aka anchor point)

---@class rectangle
---@field width number
---@field height number

---@class material
---@field shader? love.Shader
---@field properties? table -- https://love2d.org/wiki/Shader:send
---@field blendmode? love.BlendMode
---@field red? number
---@field green? number
---@field blue? number
---@field alpha? number
