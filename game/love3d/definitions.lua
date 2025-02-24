---@meta

---@class love.Transform
local Transform = {}

---
---Applies a translation to the Transform's coordinate system. This method does not reset any previously applied transformations.
---
---
---[Open in Browser](https://love2d.org/wiki/Transform:translate)
---
---@param dx number # The relative translation along the x-axis.
---@param dy number # The relative translation along the y-axis.
---@param dz number # The relative translation along the z-axis.
---@return love.Transform transform # The Transform object the method was called on. Allows easily chaining Transform methods.
function Transform:translate(dx, dy, dz) end

---
---Applies a rotation to the Transform's coordinate system. This method does not reset any previously applied transformations.
---
---
---[Open in Browser](https://love2d.org/wiki/Transform:rotate)
---
---@param z number # The relative angle in radians to rotate this Transform by around the z axis.
---@param x number # The relative angle in radians to rotate this Transform by around the x axis.
---@param y number # The relative angle in radians to rotate this Transform by around the y axis.
---@return love.Transform transform # The Transform object the method was called on. Allows easily chaining Transform methods.
function Transform:rotate(z, x, y) end
