local drawer = {}

local spline = require("spline")

local cardWidth, cardHeight, cardBorder = 256, 256, 2

local function startDrawingCardTexture(w, h, r, g, b)
    local canvasSettings = {
        type = "2d",
        format = "normal",
        readable = true,
        msaa = 8,
        dpiscale = love.graphics.getDPIScale(),
        mipmaps = "none"
    }
    local texture = love.graphics.newCanvas(w, h, canvasSettings)
    love.graphics.setCanvas(texture)
    r, g, b = r or 1, g or 1, b or 1
    
    love.graphics.clear(r, g, b, 0)
    love.graphics.setColor(r, g, b, 1)
    local border = cardBorder

    -- rounded rectangle
    love.graphics.rectangle("fill", border, border, w-2*border, h-2*border, 20, 20)
    return texture
end

local function stopDrawingCardTexture()
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1,1,1,1)
    love.graphics.setCanvas()
end

local function createCardBackTexture()
    local texture = startDrawingCardTexture(cardWidth, cardHeight, 1, 1, 1)
    
    local color = {1, 0, 1}
    love.graphics.setColor(color)
    local inset = 10
    local lineWidth = love.graphics.getLineWidth()
    love.graphics.setLineWidth(4)
    local bi = cardBorder + inset
    love.graphics.rectangle("line", bi, bi, cardWidth-2*bi, cardHeight-2*bi, 16, 16)
    love.graphics.push()
    love.graphics.translate(cardWidth/2, cardHeight/2)
    love.graphics.rotate(math.rad(45))
    love.graphics.rectangle("fill", -40, -40, 80, 80)
    love.graphics.pop()

    stopDrawingCardTexture()
    return texture
end

local function createDiceCardTexture(n, color)
    local texture = startDrawingCardTexture(cardWidth, cardHeight, 1, 1, 1)
    love.graphics.setColor(color)
    love.graphics.push()
    love.graphics.translate(cardWidth/2, cardHeight/2)
    local radius = 20
    local spacing = cardWidth/4

    if n % 2 == 1 then
        love.graphics.circle("fill", 0, 0, radius)
    end
    if n >= 2 then
        love.graphics.push()
        love.graphics.translate(spacing, spacing)
        love.graphics.circle("fill", 0, 0, radius)
        love.graphics.pop()
        love.graphics.push()
        love.graphics.translate(-spacing, -spacing)
        love.graphics.circle("fill", 0, 0, radius)
        love.graphics.pop()
    end
    if n >= 4 then
        love.graphics.push()
        love.graphics.translate(spacing, -spacing)
        love.graphics.circle("fill", 0, 0, radius)
        love.graphics.pop()
        love.graphics.push()
        love.graphics.translate(-spacing, spacing)
        love.graphics.circle("fill", 0, 0, radius)
        love.graphics.pop()
    end
    if n == 6 then
        love.graphics.push()
        love.graphics.translate(spacing, 0)
        love.graphics.circle("fill", 0, 0, radius)
        love.graphics.pop()
        love.graphics.push()
        love.graphics.translate(-spacing, 0)
        love.graphics.circle("fill", 0, 0, radius)
        love.graphics.pop()
    end
    love.graphics.pop()

    stopDrawingCardTexture()
    return texture
end

local function createWaveTexture()
    print("create wave")
    local texture = startDrawingCardTexture(cardWidth, cardHeight, 1, 1, 1)
    local vector = vec2
    
    local s1 = spline({vector(14,100), vector(126,123), vector(243,43), vector(346,122)}, {vector(14,110), vector(76,124), vector(168,44), vector(346,132)}, {vector(90,92), vector(176,122), vector(318,42), vector(376,122)})
    local s2 = spline({vector(16,173), vector(166,83), vector(265,189), vector(347,161)}, {vector(16,183), vector(64,83), vector(190,190), vector(347,171)}, {vector(92,165), vector(268,83), vector(340,188), vector(377,161)})

    love.graphics.setColor(1,0,0,1)
    love.graphics.line(s1:render())

    -- interpolate between the two splines
    local steps = 10
    for i=1, steps do
        local s1_factor = 1 / (steps+1) * i
        local s2_factor = 1 - s1_factor
        local si = s1:copy()

        for ii = 1, #si.keyPositions do
            local ipos = s1.keyPositions[ii] * s1_factor + s2.keyPositions[ii] * s2_factor
            local lHandle = s1.leftHandles[ii] * s1_factor + s2.leftHandles[ii] * s2_factor
            local rHandle = s1.rightHandles[ii] * s1_factor + s2.rightHandles[ii] * s2_factor
            si:setKeyPosition(ii, ipos)
            si:setLeftHandle(ii, lHandle)
            si:setRightHandle(ii, rHandle)
        end
        si:updateSegments()
        love.graphics.setColor(0,1,0,1)
        love.graphics.line(si:render())
    end

    love.graphics.setColor(0,0,1,1)
    love.graphics.line(s2:render())
    
    stopDrawingCardTexture()
    return texture
end

function drawer.createBackCardSprite()
    local sprite = {
        texture = createCardBackTexture(),
        ox = cardWidth / 2,
        oy = cardHeight / 2,
        quad = love.graphics.newQuad(0, 0, cardWidth, cardHeight, cardWidth, cardHeight)
    }
    return sprite
end

function drawer.createCardDiceSprite(n, color)
    local sprite = {
        texture = createDiceCardTexture(n, color),
        ox = cardWidth / 2,
        oy = cardHeight / 2,
        quad = love.graphics.newQuad(0, 0, cardWidth, cardHeight, cardWidth, cardHeight)
    }
    return sprite
end

function drawer.cardWaveSprite()
    local sprite = {
        texture = createWaveTexture(),
        ox = cardWidth / 2,
        oy = cardHeight / 2,
        quad = love.graphics.newQuad(0, 0, cardWidth, cardHeight, cardWidth, cardHeight)
    }
    return sprite
end

return drawer