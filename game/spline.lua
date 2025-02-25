---@diagnostic disable: duplicate-set-field, duplicate-doc-field
-- todo: f-curve 'class' composed of multiple bezier curves and with functionality to sample y at given x
-- https://github.com/RNavega/CubicBezierEasing-Love/tree/main
-- functionality: add/remove/move points, scale, set handle types, save/load, sample, draw
-- split functionality between runtime and editor

local vec2 = require("batteries.vec2")

---@class spline
---@field keyPositions vec2[]
---@field rightHandles vec2[]
---@field leftHandles vec2[]
---@field cyclic boolean
---@field segments love.BezierCurve[]
local spline = {}

-- https://docs.blender.org/manual/en/latest/editors/graph_editor/fcurves/introduction.html
-- todo: controll points and handles and handle types

-- new fCurve with given control point coordinates
---construct an FCurve
---@param keyPositions vec2[] control points
---@param leftHandles vec2[] left handles
---@param rightHandles vec2[] right handles
---@param cyclic boolean?
---@return spline
local function __construct(keyPositions, leftHandles, rightHandles, cyclic)
    local nKeyPositions = #keyPositions
    assert(nKeyPositions >= 2, "Number of control points must be at least 2")

    local constructLeftHandles = true
    local constructRightHandles = true
    if leftHandles then
        constructLeftHandles = false
        assert(nKeyPositions == #leftHandles, "Number of control points must be equal to number of left handles")
    else
        leftHandles = {}
    end
    if rightHandles then
        constructRightHandles = false
        assert(nKeyPositions == #rightHandles, "Number of control points must be equal to number of right handles")
    else
        rightHandles = {}
    end
    local rightOffset = vec2(30, 0)
    for i=1, nKeyPositions do
        local keyPoint = keyPositions[i]
        if constructRightHandles then
            rightHandles[i] = keyPoint + rightOffset
        end
        if constructLeftHandles then
            leftHandles[i] = keyPoint - rightOffset
        end
    end

    local instance = setmetatable({keyPositions = keyPositions, rightHandles = rightHandles, leftHandles = leftHandles, cyclic = cyclic}, spline)
    instance.segments = {}
    instance:updateSegments()
    return instance
end

function spline:copy()
    local keyPositions = {}
    local leftHandles = {}
    local rightHandles = {}
    for i=1, #self.keyPositions do
        keyPositions[i] = self.keyPositions[i]:copy()
        leftHandles[i] = self.leftHandles[i]:copy()
        rightHandles[i] = self.rightHandles[i]:copy()
    end
    return __construct(keyPositions, leftHandles, rightHandles)
end

---comment
---@param keyPositions vec2[] control points
---@param leftHandles vec2[] left handles
---@param rightHandles vec2[] right handles
---@param cyclic boolean?
---@return spline
function spline.new(keyPositions, leftHandles, rightHandles, cyclic)
    return __construct(keyPositions, leftHandles, rightHandles, cyclic)
end

---set a key point and keep the handles relatively constant
---@param i number
---@param vec vec2
function spline:setKeyPosition(i, vec)
    local v = self.keyPositions[i]
    
    -- keep handles relatively constant
    local rightOffset = self.rightHandles[i] - v
    local leftOffset = self.leftHandles[i] - v

    v.x, v.y = vec.x, vec.y

    self.rightHandles[i] = v + rightOffset
    self.leftHandles[i] = v + leftOffset
end

function spline:setLeftHandle(i, vec, mirror)
    local v = self.leftHandles[i]
    v.x, v.y = vec.x, vec.y
    if mirror then
        local key = self.keyPositions[i]
        local otherHandle = self.rightHandles[i]
        local offset = v - key
        local newOtherHandle = key - offset
        otherHandle.x, otherHandle.y = newOtherHandle.x, newOtherHandle.y
    end
end

function spline:setRightHandle(i, vec, mirror)
    local v = self.rightHandles[i]
    v.x, v.y = vec.x, vec.y
    if mirror then
        local key = self.keyPositions[i]
        local otherHandle = self.leftHandles[i]
        local offset = v - key
        local newOtherHandle = key - offset
        otherHandle.x, otherHandle.y = newOtherHandle.x, newOtherHandle.y
    end
end

function spline:insertKeyPosition(i, vec)
    -- find reasonable handle positions
    local previous_i = i - 1
    local next_i = i
    if previous_i == 0 then
        previous_i = #self.keyPositions
    end
    if next_i > #self.keyPositions then
        next_i = 1
    end
    local leftKey = self.keyPositions[previous_i]
    local rightKey = self.keyPositions[next_i]
    local newLeftHandle = (3 * vec + leftKey) / 4
    local newRightHandle = (3 * vec + rightKey) / 4

    -- insert key position and handles
    table.insert(self.keyPositions, i, vec:copy())
    table.insert(self.leftHandles, i, newLeftHandle)
    table.insert(self.rightHandles, i, newRightHandle)
    self:updateSegments()
end

function spline:removeKeyPosition(i)
    table.remove(self.keyPositions, i)
    table.remove(self.leftHandles, i)
    table.remove(self.rightHandles, i)
    if self.cyclic then
        table.remove(self.segments, #self.segments)
    end
    self:updateSegments()
end

---Return the control point at vec, re
---@param vec vec2 position
---@param d2 number distance squared
---@return integer? index, boolean left_handle, boolean right_handle
function spline:getCloseControlPointIndex(vec, d2)
    local nKeyPositions = #self.keyPositions
    for i=1, nKeyPositions do
        local cp = self.keyPositions[i]
        if cp:distance_squared(vec) < d2 then
            return i, false, false
        end
    end

    for i=1, nKeyPositions do
        local cp = self.leftHandles[i]
        if cp:distance_squared(vec) < d2 then
            return i, true, false
        end
    end

    for i=1, nKeyPositions do
        local cp = self.rightHandles[i]
        if cp:distance_squared(vec) < d2 then
            return i, false, true
        end
    end

    return nil, false, false
end

function spline:getCloseSegment(vec, d2)
    local nSegments = #self.segments
    for i=1, nSegments do
        local segment = self.segments[i]
        local coords = segment:render(5)
        for j=1, #coords, 2 do
            local p = vec2(coords[j], coords[j+1])
            if p:distance_squared(vec) < d2 then
                return i
            end
        end
    end
    return nil
end

---Update the bezier segments of the FCurve.
function spline:updateSegments()
    local nKeys = #self.keyPositions
    for i = 2, nKeys do
        local cpA = self.keyPositions[i-1]
        local rightHandleA = self.rightHandles[i-1]
        local cpB = self.keyPositions[i]
        local leftHandleB = self.leftHandles[i]

        local w = 20

        if self.segments[i-1] then
            self.segments[i-1]:setControlPoint(1, cpA.x, cpA.y)
            self.segments[i-1]:setControlPoint(2, rightHandleA.x, rightHandleA.y)
            self.segments[i-1]:setControlPoint(3, leftHandleB.x, leftHandleB.y)
            self.segments[i-1]:setControlPoint(4, cpB.x, cpB.y)
        else
            self.segments[i-1] = love.math.newBezierCurve({cpA.x, cpA.y, rightHandleA.x, rightHandleA.y, leftHandleB.x, leftHandleB.y, cpB.x, cpB.y})
        end
    end

    if self.cyclic then
        local cpA = self.keyPositions[nKeys]
        local rightHandleA = self.rightHandles[nKeys]
        local cpB = self.keyPositions[1]
        local leftHandleB = self.leftHandles[1]

        if self.segments[nKeys] then
            self.segments[nKeys]:setControlPoint(1, cpA.x, cpA.y)
            self.segments[nKeys]:setControlPoint(2, rightHandleA.x, rightHandleA.y)
            self.segments[nKeys]:setControlPoint(3, leftHandleB.x, leftHandleB.y)
            self.segments[nKeys]:setControlPoint(4, cpB.x, cpB.y)
        else
            self.segments[nKeys] = love.math.newBezierCurve({cpA.x, cpA.y, rightHandleA.x, rightHandleA.y, leftHandleB.x, leftHandleB.y, cpB.x, cpB.y})
        end
    else
        if self.segments[nKeys] then
            self.segments[nKeys] = nil
        end
    end
end

function spline:render(depth)
    local nSegments = #self.segments
    if nSegments < 1 then
        return {}
    end
    depth = depth or 5
    local renderedLines = self.segments[1]:render(depth)
    for i=2, nSegments do
        local renderedSegment = self.segments[i]:render(depth)
        local nLines = #renderedSegment
        -- skip the first two coordinates since the lines are connected
        for j=3, nLines do
            table.insert(renderedLines, renderedSegment[j])
        end
    end
    return renderedLines
end

spline.__index = spline

setmetatable(spline, {
    __call = function(_, keyPositions, leftHandles, rightHandles, cyclic)
        return __construct(keyPositions, leftHandles, rightHandles, cyclic)
    end
})

---@cast spline +fun(...)spline
return spline
