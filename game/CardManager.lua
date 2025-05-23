local core = require("core")
local PhysicsSystem = require("systems.PhysicsSystem")
local drawer = require("CardDrawer")
local ripple = require("ripple")

---@class CardManager creates new card sets, deals cards etc..
local manager = {}
local roomSounds = ripple.newTag()
love.audio.setEffect("roomReverb", {type="reverb"})
roomSounds:setEffect("roomReverb", true)
love.audio.setEffect("compressor", {type="compressor"})
roomSounds:setEffect("compressor", true)

local cardSounds = ripple.newTag()
local flipCardSound = ripple.newSound(love.audio.newSource("assets/sound_effects/flip_1.wav", "static"), {
    loop = false,
    tags = {roomSounds, cardSounds},
})

---A cardSet holds the sprites of all the set, including the card back.
---CardSprites are stored in an array.
---The index of pair cards is also stored in an array.
---Card just store refference to cardSet and index of card.
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
---@field inPlay boolean True if the card is not yet collected by player or computer.

---@class entity
---@field card? card

---check if two cards are a pair
---@param cardA card
---@param cardB card
---@return boolean true if cards are a pair.
function manager.isPair(cardA, cardB)
    -- if cards are from the same set and cardA pair index equals cardB pair index return true.
    if cardA.cardSet == cardB.cardSet and
        cardA.cardSet.pairIndices[cardA.index] == cardB.index then
        return true
    end
    return false
end

---Remove and return a random element from an array.
---@param array any[]
---@return any element
function manager.popRandomElementFromArray(array)
    local arraySize = #array
    local index = math.random(arraySize)
    local element = array[index]
    array[index] = array[arraySize]
    array[arraySize] = nil
    return element
end

---Remove the element with matching value from an an array.
---@param array any[]
---@param value any
---@return any value the removed value
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

manager.__cards_in_play = core.newList()

function manager:get_flipped_cards_in_play()
    local l = core.newList()
    for _, entity in ipairs(core.ecs_world.entities) do
        if entity.card then
            local card = entity.card
            if card.inPlay and card.facingUp then
                l:add(entity)
            end
        end
    end
    return l
end

---The card entities that are in play.
---@return List cardEntities a List of cards in play. 
function manager:get_cards_in_play()
    local l = core.newList()
    -- self.__cards_in_play:clear()
    for _, entity in ipairs(core.ecs_world.entities) do
        if entity.card then
            local card = entity.card
            if card.inPlay then
                -- self.__cards_in_play:add(entity)
                l:add(entity)
            end
        end
    end
    -- return self.__cards_in_play
    return l
end

function manager:get_defined_cards_in_play()
    local l = core.newList()
    for _, entity in ipairs(core.ecs_world.entities) do
        if entity.card then
            ---@type card
            local card = entity.card
            if card.inPlay and card.index ~= 0 then
                l:add(entity)
            end
        end
    end
    return l
end

function manager:get_undefined_cards_in_play()
    local l = core.newList()
    for _, entity in ipairs(core.ecs_world.entities) do
        if entity.card then
            ---@type card
            local card = entity.card
            if card.inPlay and card.index == 0 then
                l:add(entity)
            end
        end
    end
    return l
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

    -- first one is the wave
    cardSet.cardSprites[1] = drawer.cardWaveSprite()
    cardSet.pairIndices[1] = 1

    for i=2, cardSetSize do
        local div6 = math.floor((i-1)/6+1)
        local mod6 = ((i-1)%6)+1
        cardSet.cardSprites[i] = drawer.createCardDiceSprite(mod6, div6 > 1 and {1,0,0} or {0,1,0})
        cardSet.pairIndices[i] = i
    end
    return cardSet
end

function manager.initCardSet(n)
    math.randomseed(os.time())
    manager.cardSet = manager.createCardSet(n)
end

---@function
---@param e entity
local function cardFlipAnimUpdate(e, deltaT)
    local anim = e.anim
    ---@cast anim -nil
    anim.time = anim.time + deltaT
    local tt = anim.time * 6.4
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

        -- remove the animation first, then call onDone
        local onDone = e.anim.onDone
        e.anim = nil
        onDone(e)
    else
        e.tform.sx = 1 - math.sin(tt) * 0.1
        e.tform.sy = 1 - math.sin(tt) * .9
        e.tform.r = math.sin(tt) * math.rad(10)
        e.tform.kx = math.sin(tt) * 0.6
        e.tform.ky = math.sin(tt) * 0.8
    end
end

-- remove
manager.flippingCardEntities = setmetatable({}, {__mode="k"})

local function onFlipDone(e)
    -- Add or remove cards from revealedCardEntities depending on if they are facing up or down.
    -- Redundant data here, since the card.facingUp is already holding this value.
    manager.revealedCardEntities[e] = e.card.facingUp or nil
    manager.flippingCardEntities[e] = nil
    manager.do_transitions() -- gets called multiple times when multiple cards are flipped...
end

local function addFlipCardAnimation(cardEntity)
    
    --play sound with randomized pitch
    flipCardSound:play({pitch=1+math.random()*0.34-0.1})

    cardEntity.anim = {
        time = 0,
        update = cardFlipAnimUpdate,
        startRot = cardEntity.tform.r,
        flipped = false,
        -- add done callback function
        onDone = onFlipDone,
    }
    manager.flippingCardEntities[cardEntity] = true
end

function manager.revealCard(cardEntity)
    -- print("reveal card ")
    if cardEntity.anim then
        print("card already flipping")
    elseif cardEntity.card.facingUp then
        print("card is already facing up")
    else
        addFlipCardAnimation(cardEntity)
    end
end

function manager.concealCard(cardEntity)
    if cardEntity.anim then
        print("card already flipping")
    elseif not cardEntity.card.facingUp then
        print("card is already facing down")
    else
        addFlipCardAnimation(cardEntity)
    end
end

function manager.dontAllowFlipCard(cardEntity)
    print("not allowed to flip card now")
end

-- What happens when a card is clicked.
--manager.cardTapHandler = manager.revealCard
---called whenever a card is tapped
---@param cardEntity entity
local function onCardTapped(cardEntity)
    manager.cardTapHandler(cardEntity)
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
        inPlay = true,
    }
    cardEntity.tform = {x = x, y = y, r = math.pi/32 * math.random(-1.0,1.0)}
    cardEntity.sprite = cardSet.cardBackSprite
    cardEntity.body = love.physics.newBody(PhysicsSystem.world, x, y, "kinematic")
    cardEntity.body:setAngle(cardEntity.tform.r)
    love.physics.newRectangleShape(cardEntity.body, 0, 0, 256, 256)

    cardEntity.onPointerDown = onCardTapped

    return cardEntity
end

function manager.numRevealedCards()
    local nRevealedCards = 0
    for _ in pairs(manager.revealedCardEntities) do
        nRevealedCards = nRevealedCards + 1
    end
    return nRevealedCards
end

function manager.getRevealedPairCards()
    local pairEs = {}
    for e in pairs(manager.revealedCardEntities) do
        local addCard = true
        if #pairEs > 0 then
            if manager.isPair(pairEs[1].card, e.card) then
                addCard = true
            else
                addCard = false
            end
        end
        if addCard then
            pairEs[#pairEs+1] = e
        end
    end

    if #pairEs > 1 then
        return unpack(pairEs)
    else
        return nil
    end
end

function manager.update(dt)
    if manager.current_state.update then
        manager.current_state:update(dt)
    end
end

---update state transitions.
function manager.do_transitions()
    local state = manager.current_state
    -- print((state.name or " Unknown State"), "do transitions")
    for _, transfunc in ipairs(state.transitions) do
        if transfunc(state) then break end
    end
end

function manager.set_state(state)
    if manager.current_state and manager.current_state.exit then manager.current_state:exit() end
    manager.current_state = state
    if manager.current_state.enter then manager.current_state:enter() end
    return true
end

-- define states (need on enter / on exit functions?)
manager.playerTurn = require("State_PlayerTurn")
manager.playerCollect = require("State_PlayerCollect")
manager.computerTurn = require("State_ComputerTurn")
manager.computerCollect = require("State_ComputerCollect")

manager.playerTurn:init(manager)
manager.playerCollect:init(manager)
manager.computerTurn:init(manager)
manager.computerCollect:init(manager)

manager.num_cards_player_collected = 0
manager.num_player_turns = 0

---deals cards and starts the game.
---@param rows number
---@param columns number
function manager.dealCards(rows, columns)

    ---@type number[] a bag of card indices that are in play, but have not been revealed.
    manager.unrevealedCards = manager.createCardPairsBagFromSet(manager.cardSet, rows*columns)

    local spacing = 300
    local staratX, startY = - spacing * (rows-1) * 0.5, - spacing * (columns-1) * 0.5

    for y = 1, columns do
        local yy = (y-1) * spacing + startY
        for x = 1, rows do
            local xx = (x-1) * spacing + staratX
            local cardEntity = placeCard(xx, yy, manager.cardSet, manager.unrevealedCards) -- dont define the cards yet.
        end
    end

    manager.revealedCardEntities = setmetatable({}, {__mode="k"})

    manager.set_state(manager.playerTurn)

end

return manager
