---@class CardManager
---@field cardBackSprite sprite
local manager = {}

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
    love.graphics.rectangle("fill", border, border, w-2*border, h-2*border, 20, 20)
    return texture
end

local function stopDrawingCardTexture()
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1,1,1,1)
    love.graphics.setCanvas()
end

function manager.createCardBackTexture()
    local texture = startDrawingCardTexture(cardWidth, cardHeight, 1, 1, 1)
    
    local r, g, b = 1, 0, 1
    love.graphics.setColor(r, g, b, 1)
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

function manager.createDiceCardTexture(n)
    local texture = startDrawingCardTexture(cardWidth, cardHeight, 1, 1, 1)
    local r, g, b = 1, 0, 1
    love.graphics.setColor(r, g, b, 1)
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

    stopDrawingCardTexture()
    return texture
end

local cardBackTexture = manager.createCardBackTexture()
local cardTexture = manager.createDiceCardTexture(6)

manager.cardBackSprite = {
    texture = cardTexture,
    ox = cardWidth/2,
    oy = cardHeight/2,
    quad = love.graphics.newQuad(0, 0, cardWidth, cardHeight, cardWidth, cardHeight)
}


return manager