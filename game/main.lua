require("batteries"):export()
local camera = require("camera")

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
    Cam.camera = camera()

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
    PhysicsSystem:debugDraw()
    DrawSystem:draw()
end

function love.keypressed(key)

    if key == "left" then
        Cam.camera:setPosition(Cam.camera.x - 30, Cam.camera.y, Cam.camera.z)
    elseif key == "right" then
        Cam.camera:setPosition(Cam.camera.x + 30, Cam.camera.y, Cam.camera.z)
    elseif key == "up" then
        Cam.camera:setPosition(Cam.camera.x, Cam.camera.y + 30, Cam.camera.z)
    elseif key == "down" then
        Cam.camera:setPosition(Cam.camera.x, Cam.camera.y - 30, Cam.camera.z)
    elseif key == "w" then
        Cam.camera:setPosition(Cam.camera.x, Cam.camera.y, Cam.camera.z + 3)
    elseif key == "s" then
        Cam.camera:setPosition(Cam.camera.x, Cam.camera.y, Cam.camera.z - 3)
    elseif key == "a" then
        Cam.camera:setRotation(Cam.camera.rx, Cam.camera.ry, Cam.camera.rz + math.pi/180)
    elseif key == "d" then
        Cam.camera:setRotation(Cam.camera.rx, Cam.camera.ry, Cam.camera.rz - math.pi/180)
    elseif key == "r" then
        Cam.camera:setRotation(Cam.camera.rx + math.pi/180, Cam.camera.ry, Cam.camera.rz)
    elseif key == "f" then
        Cam.camera:setRotation(Cam.camera.rx - math.pi/180, Cam.camera.ry, Cam.camera.rz)
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