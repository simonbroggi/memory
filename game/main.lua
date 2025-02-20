require("batteries"):export()

local core = require("core")
local InputSystem = require("systems.InputSystem")
local PhysicsSystem = require("systems.PhysicsSystem")
local DrawSystem = require("systems.DrawSystem")
local AnimSystem = require("systems.AnimSystem")

local CardManager = require("CardManager")

function love.load()
    InputSystem:init()
    PhysicsSystem:init()
    AnimSystem:init()

    Cam = core.newEntitytInWorld()
    Cam.camera = {}
    Cam.tform = {x = 0, y = 0, r = 0, sx = 1, sy = 1}
    --Cam.rectangle = {width = 40, height = 40}
    --Cam.material = {red=1, green=0, blue=1, alpha=1}

    --[[ coordinate system lines using rectangle components
    local ex = core.newEntitytInWorld()
    ex.tform = {x = 0, y = 0}
    ex.material = {red=1, green=0, blue=0, alpha=1}
    ex.rectangle = {width=1000, height=4}
    local ey = core.newEntitytInWorld()
    ey.tform = {x = 0, y = 0}
    ey.material = {red=0, green=1, blue=0, alpha=1}
    ey.rectangle = {width=4, height=1000}
    --]]

    local x, y = 4, 3
    -- make the set just big enough to make sure every card is dealed twice
    CardManager.initCardSet((x * y)/2)
    CardManager.dealCards(x, y)
    
    -- need to init the draw system after cardmanager calls carddrawer which probably resets projection.
    DrawSystem:init()
end

function love.update(dt)
    InputSystem:update(dt)
    PhysicsSystem:fixedUpdate(dt)

    CardManager.update(dt)

    AnimSystem:update(dt)
    DrawSystem:update(dt)
end

function love.draw()
    -- PhysicsSystem:debugDraw()
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