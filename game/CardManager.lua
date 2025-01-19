local core = require("core")
local PhysicsSystem = require("systems.PhysicsSystem")
local drawer = require("CardDrawer")

---@class CardManager creates new card sets, deals cards etc..
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
---@field index number index of the card in the cardSet. can be 0 when it's not defined yet.
---@field cardBag number[]
---@field facingUp boolean True if the card visible to the player.

---@class entity
---@field card? card

---A card bag is just an array of cards.
---@param array any[]
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

---create a card set with pairs pointing to its own index, so identical pairs.
---@param cardSetSize any
---@return cardSet
function manager.createCardSet(cardSetSize, cardWidth, cardHeight, cardBorder)
    cardWidth, cardHeight = cardWidth or 256, cardHeight or 256
    cardBorder = cardBorder or 2
    ---@type cardSet
    local cardSet = {
        cardBackSprite = drawer.createBackCardSprite(),
        cardSprites = {},
        pairIndices = {},
    }
    for i=1, cardSetSize do
        local div6 = math.floor((i-1)/6+1)
        local mod6 = ((i-1)%6)+1
        cardSet.cardSprites[i] = drawer.createCardDiceSprite(mod6, div6 > 1 and {1,0,0} or {0,1,0})
        cardSet.pairIndices[i] = i
    end
    return cardSet
end

function manager.initCardSet()
    math.randomseed(os.time())
    manager.cardSet = manager.createCardSet(12)
end

---@function
---@param e entity
local function cardFlipAnimUpdate(e, deltaT)
    local anim = e.anim
    ---@cast anim -nil
    anim.time = anim.time + deltaT
    local tt = anim.time * 5
    if tt >= math.pi/2 and not anim.flipped then
        anim.flipped = true
        e.card.facingUp = not e.card.facingUp
        if e.card.facingUp then
            -- if the front of the card is not yet defined, choose a random front sprite
            if e.card.index == 0 then
                e.card.index = manager.popRandomElementFromArray(e.card.cardBag)
                e.card.cardBag = nil -- this card is no longer part of the unseenCards bag.
            end
            e.sprite = e.card.cardSet.cardSprites[e.card.index]
        else
            e.sprite = e.card.cardSet.cardBackSprite
        end
    end
    if tt >= math.pi then
        e.tform.r = anim.startRot
        e.tform.sx = 1
        e.tform.sy = 1
        e.tform.kx = 0
        e.tform.ky = 0
        e.anim = nil -- remove the animation
    end
    e.tform.sx = 1 - math.sin(tt) * 0.1
    e.tform.sy = 1 - math.sin(tt) * .9
    e.tform.r = math.sin(tt) * math.rad(10)
    e.tform.kx = math.sin(tt) * 0.6
    e.tform.ky = math.sin(tt) * 0.8
end

---called whenever a card is tapped
---@param cardEntity entity
local function onCardTapped(cardEntity)
    if not manager.playerTurn then
        print("hey, it's computers turn!")
        return
    end

    -- todo: points and computer turn. manager.revealedCardEntities ...

    if not cardEntity.anim then
        cardEntity.anim = {
            time = 0,
            update = cardFlipAnimUpdate,
            startRot = cardEntity.tform.r,
            flipped = false,
        }
    end
end

---Create an unrevealed card entity from cardBag belonging to cardSet and place it at x/y.
---@param x number The x coordinate where card is placed.
---@param y number The y coordinate where card is placed.
---@param cardSet cardSet The cardSet this card belongs to.
---@param cardBag number[] The bag of cards this unrevealed card is part of.
---@return entity
local function placeCard(x, y, cardSet, cardBag)
    local cardEntity = core.newEntitytInWorld()

    -- card component could have a refference to a set, and an index if defined.

    cardEntity.card = {
        cardSet = cardSet,
        index = 0, -- unrevealed card
        cardBag = cardBag,
        facingUp = false,
    }
    cardEntity.tform = {x = x, y = y, r = math.pi/32 * math.random(-1.0,1.0)}
    cardEntity.sprite = cardSet.cardBackSprite
    cardEntity.body = love.physics.newBody(PhysicsSystem.world, x, y, "dynamic")
    cardEntity.body:setAngle(cardEntity.tform.r)
    love.physics.newRectangleShape(cardEntity.body, 0, 0, 256, 256)

    cardEntity.onPointerDown = onCardTapped

    return cardEntity
end

---deals cards and starts the game.
---@param rows number
---@param columns number
function manager.dealCards(rows, columns)

    -- a set of all card entities. weak refferenced..
    manager.dealedCardEntities = setmetatable({}, {__mode="k"})

    ---@type number[] a bag of card indices that are in play, but have not been revealed.
    manager.unrevealedCards = manager.createCardPairsBagFromSet(manager.cardSet, rows*columns)

    local spacing = 300
    local staratX, startY = - spacing * (rows-1) * 0.5, - spacing * (columns-1) * 0.5

    for y = 1, columns do
        local yy = (y-1) * spacing + startY
        for x = 1, rows do
            local xx = (x-1) * spacing + staratX
            local cardEntity = placeCard(xx, yy, manager.cardSet, manager.unrevealedCards) -- dont define the cards yet.
            manager.dealedCardEntities[cardEntity] = true
        end
    end

    manager.playerTurn = true
    manager.revealedCardEntities = setmetatable({}, {__mode="k"})

end

return manager
