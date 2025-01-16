local core = require("core")
local InputSystem = require("systems.InputSystem")
local PhysicsSystem = require("systems.PhysicsSystem")
local DrawSystem = require("systems.DrawSystem")
local AnimSystem = require("systems.AnimSystem")

local CardManager = require("CardManager")

function love.load()
    DrawSystem:init()
    InputSystem:init()
    PhysicsSystem:init()
    AnimSystem:init()

    Cam = core.newEntitytInWorld()
    Cam.camera = {}
    Cam.tform = {x = 0, y = 0, r = 0, sx = 1, sy = 1}
    --Cam.rectangle = {width = 40, height = 40}
    --Cam.material = {red=1, green=0, blue=1, alpha=1}

    -- coordinate system lines using rectangle components
    local ex = core.newEntitytInWorld()
    ex.tform = {x = 0, y = 0}
    ex.material = {red=1, green=0, blue=0, alpha=1}
    ex.rectangle = {width=1000, height=4}
    local ey = core.newEntitytInWorld()
    ey.tform = {x = 0, y = 0}
    ey.material = {red=0, green=1, blue=0, alpha=1}
    ey.rectangle = {width=4, height=1000}

    math.randomseed(os.time())

    local cardSet = CardManager.createCardSet(12)
    local unseenCards = CardManager.createCardPairsBagFromSet(cardSet, 16)

    ---@function
    ---@param e entity
    local function cardFlipAnimUpdate(e, deltaT)
        local anim = e.anim
        ---@cast anim -nil
        anim.time = anim.time + deltaT
        local tt = anim.time * 5
        if tt >= math.pi/2 and not anim.flipped then
            anim.flipped = true
            if e.sprite == e.card.backSprite then
                -- if the front of the card is not yet defined, choose a random front sprite
                if e.card.frontSprite == nil then
                    local cardIndex = CardManager.popRandomElementFromArray(unseenCards)
                    e.card.frontSprite = cardSet.cardSprites[cardIndex]
                    --e.card.frontSprite = CardManager.cardSprites[math.random(8)]
                end
                e.sprite = e.card.frontSprite
            else
                e.sprite = e.card.backSprite
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

    local function placeCard(x, y)
        print("place card ")
        local cardEntity = core.newEntitytInWorld()
        cardEntity.card = {
            backSprite = cardSet.cardBackSprite,
        }
        cardEntity.tform = {x = x, y = y, r = math.pi/32 * math.random(-1.0,1.0)}
        cardEntity.sprite = cardEntity.card.backSprite
        cardEntity.body = love.physics.newBody(PhysicsSystem.world, x, y, "dynamic")
        cardEntity.body:setAngle(cardEntity.tform.r)
        love.physics.newRectangleShape(cardEntity.body, 0, 0, 256, 256)

        function cardEntity:onPointerDown()
            if not self.anim then
                self.anim = {
                    time = 0,
                    update = cardFlipAnimUpdate,
                    startRot = self.tform.r,
                    flipped = false,
                }
            end
        end
    end

    local spacing = 300
    local staratX, startY = - spacing * 1.5, - spacing * 1.5

    for y = 1, 4 do
        local yy = (y-1) * spacing + startY
        for x = 1, 4 do
            local xx = (x-1) * spacing + staratX
            placeCard(xx, yy) -- dont define the cards yet.
        end
    end
end

function love.update(dt)
    InputSystem:update(dt)
    PhysicsSystem:fixedUpdate(dt)

    AnimSystem:update(dt)
    DrawSystem:update(dt)
    
end

function love.draw()
    PhysicsSystem:debugDraw()
    DrawSystem:draw()
end

function love.keypressed(key)

    if key == "left" then
        Cam.tform.x = Cam.tform.x - 30
    elseif key == "right" then
        Cam.tform.x = Cam.tform.x + 30
    elseif key == "up" then
        Cam.tform.y = Cam.tform.y - 30
    elseif key == "down" then
        Cam.tform.y = Cam.tform.y + 30
    elseif key == "a" then
        Cam.tform.r = Cam.tform.r + math.pi/180
    elseif key == "d" then
        Cam.tform.r = Cam.tform.r - math.pi/180
    end
    if key == "escape" then
        love.event.quit()
        
        --test
        love.physics.newRectangleShape(love.physics.newBody(love.physics.newWorld(0, 0), 0, 0, "dynamic"), 10, 10)
    end
end

function love.resize(w, h)
    DrawSystem:resize_canvas(w, h)
end