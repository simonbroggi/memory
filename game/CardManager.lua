---@class CardManager
local manager = {}

-- Create a new cardSet creates the textures and all instantiates the card tables. After this, the card tables are only refferenced.
-- But what if a card is altered during a game (e.g. a mark is added)?
-- In that case, the card table must be copied! and then the pair value is no longer true.
-- Could have card just store refference to cardSet and index of card.
-- Or the card is a class and has metatable with the unique card in set, and when a card is altered its overwritten..
-- First option seems more like everything else in my ecs works: components dont have metatables. Also it's nicely serializable.
-- need an abstraction of value and display.
---@class cardSet a set of cards. Every card is unique, but has the same back sprite.
---@field cardBackSprite sprite the back of the card.
---@field cardSprites sprite[] the front of the card.
---@field pairIndices number[] the index to the other card that pairs with this one. Can point to self.

-- A card bag is a stack of cards. The same card can be in the stack multiple times. Its just an array of indices.
---Create a bag of cards with corresponding pairs from the given set.
---@param cardSet cardSet The set of cards to choose from.
---@param desiredBagSize number How big the returned card bag shoud be.
---@return number[] cardBagIndices An array of indices pointing to the cards in the cardSet describing the card bag.
function manager.createCardPairsBagFromSet(cardSet, desiredBagSize)
    assert(desiredBagSize%2==0, "desired bag size must be even.")

    -- create a set of all avilable card indices of the the card set. (simply a continuous list of numbers)
    local indexSet = {}
    for i=1, #cardSet.cardSprites do
        indexSet[i] = i
    end

    local cardPairsBag = {}
    local cardPairsBagSize = 0
    while cardPairsBagSize < desiredBagSize do
        if #indexSet <= 0 then
            error("Not enough cards in set")
        end
        cardPairsBagSize = cardPairsBagSize+1
        local cardIndex = manager.popRandomElementFromArray(indexSet)
        cardPairsBag[cardPairsBagSize] = cardIndex
        
        -- Put the corresponding pair card into the bag.
        -- If it's a different card index, remove it from the set first.        
        local pairIndex = cardSet.pairIndices[cardIndex]
        if not cardIndex == pairIndex then
            -- find the pairIndex in the indexBag and remove it
            manager.removeElementByValue(indexSet, pairIndex)
        end
        cardPairsBagSize = cardPairsBagSize + 1
        cardPairsBag[cardPairsBagSize] = pairIndex
    end
    return cardPairsBag
end

-- Set up a memory game from a cardSet:
-- - create a card bag with the correct cards called unseenCards.
-- - place sprite entities with the card back sprite on the board.
-- - when a card is clicked, if the frontSprite is not defined draw a random card from the stack and assign it to the front card.

---@class card
---@field cardSet cardSet a refference to the cardSet of this card.
---@field backSprite sprite the back of the card. get it from the cardSet, but possibly alter it during game.
---@field index number index of the card in the cardSet. can be 0 when it's not defined yet.
---@field frontSprite? sprite the front of the card. get it from the cardSet, but possibly alter it suring game. can be nil when card is not defined jet.

---@class entity
---@field card? card

---A card bag is just an array of cards.
---@param array card[]
---@return any element
function manager.popRandomElementFromArray(array)
    local cardsSize = #array
    local index = math.random(cardsSize)
    local element = array[index]
    array[index] = array[cardsSize]
    array[cardsSize] = nil
    return element
end

function manager.removeElementByValue(array, value)
    for i=1, #array do
        if array[i] == value then
            array[i] = array[#array]
            array[#array] = nil
            return value
        end
    end
    error("no element " .. value .. " in array")
end
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

function manager.createDiceCardTexture(n, color)
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

---create a card set with pairs pointing to its own index, so identical pairs.
---@param cardSetSize any
---@return cardSet
function manager.createCardSet(cardSetSize)
    ---@type cardSet
    local cardSet = {
        cardBackSprite = {
            texture = manager.createCardBackTexture(),
            ox = cardWidth / 2,
            oy = cardHeight / 2,
            quad = love.graphics.newQuad(0, 0, cardWidth, cardHeight, cardWidth, cardHeight)
        },
        cardSprites = {},
        pairIndices = {},
    }
    for i=1, cardSetSize do
        local div6 = math.floor((i-1)/6+1)
        local mod6 = ((i-1)%6)+1
        cardSet.cardSprites[i] = {
            texture = manager.createDiceCardTexture(mod6, div6 > 1 and {1,0,0} or {0,1,0}),
            ox = cardWidth / 2,
            oy = cardHeight / 2,
            quad = love.graphics.newQuad(0, 0, cardWidth, cardHeight, cardWidth, cardHeight)
        }
        cardSet.pairIndices[i] = i
    end
    return cardSet
end

return manager
