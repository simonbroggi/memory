---@diagnostic disable: duplicate-set-field, duplicate-doc-field
-- todo: f-curve 'class' composed of multiple bezier curves and with functionality to sample y at given x
-- https://github.com/RNavega/CubicBezierEasing-Love/tree/main
-- functionality: add/remove/move points, scale, set handle types, save/load, sample, draw
-- split functionality between runtime and editor

local vector = vec2

---@class Spline
---@field keyPositions NVec[]
---@field rightHandles NVec[]
---@field leftHandles NVec[]
---@field segments love.BezierCurve[]
local Spline = {}

-- https://docs.blender.org/manual/en/latest/editors/graph_editor/fcurves/introduction.html
-- todo: controll points and handles and handle types

-- new fCurve with given control point coordinates
---construct an Spline
---@param keyPositions NVec[] control points
---@param leftHandles NVec[] left handles
---@param rightHandles NVec[] right handles
---@return Spline
local function __construct(keyPositions, leftHandles, rightHandles)
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
    local rightOffset = vector(30, 0)
    for i=1, nKeyPositions do
        local keyPoint = keyPositions[i]
        if constructRightHandles then
            rightHandles[i] = keyPoint + rightOffset
        end
        if constructLeftHandles then
            leftHandles[i] = keyPoint - rightOffset
        end
    end

    local instance = setmetatable({keyPositions = keyPositions, rightHandles = rightHandles, leftHandles = leftHandles}, Spline)
    instance.segments = {}
    instance:updateSegments()
    return instance
end

---create a new fcurve.
---@param keyPositions NVec[] control points
---@param leftHandles NVec[] left handles
---@param rightHandles NVec[] right handles
---@return Spline
function Spline.new(keyPositions, leftHandles, rightHandles)
    return __construct(keyPositions, leftHandles, rightHandles)
end

function Spline:copy()
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

---set a key point and keep the handles relatively constant
---@param i number
---@param vec NVec
function Spline:setKeyPosition(i, vec)
    local v = self.keyPositions[i]
    
    -- keep handles relatively constant
    local rightOffset = self.rightHandles[i] - v
    local leftOffset = self.leftHandles[i] - v

    v.x, v.y = vec.x, vec.y

    self.rightHandles[i] = v + rightOffset
    self.leftHandles[i] = v + leftOffset
end

function Spline:setLeftHandle(i, vec, mirror)
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

function Spline:setRightHandle(i, vec, mirror)
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

---Update the bezier segments of the Spline.
function Spline:updateSegments()
    local nControlPoints = #self.keyPositions
    for i = 2, nControlPoints do
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
end

function Spline:render(depth)
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

Spline.__index = Spline

setmetatable(Spline, {
    __call = function(_, keyPositions, leftHandles, rightHandles)
        return __construct(keyPositions, leftHandles, rightHandles)
    end
})

---@cast Spline +fun(...):Spline
return Spline
