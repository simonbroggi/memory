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

    Hand = core.newEntitytInWorld()
    Hand.tform = {x = 0, y = 0}
    Hand.material = {red=0, green=1, blue=1, alpha=1}
    Hand.rectangle = {width=20, height=20}

    love.mouse.setVisible(false)

    Cam = core.newEntitytInWorld()
    Cam.camera = camera(0, 0, 1000)

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

    Hand.tform.x = love.mouse.getX()-love.graphics.getWidth()/2
    Hand.tform.y = -love.mouse.getY()+love.graphics.getHeight()/2
    local scale = 1/DrawSystem.canvas_scale
    Hand.tform.x, Hand.tform.y = Hand.tform.x * scale, Hand.tform.y * scale

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

    local dist_step = 100
    local angle_step = math.rad(15)
    if key == "left" then
        Cam.camera:setPosition(Cam.camera.x - dist_step, Cam.camera.y, Cam.camera.z)
    elseif key == "right" then
        Cam.camera:setPosition(Cam.camera.x + dist_step, Cam.camera.y, Cam.camera.z)
    elseif key == "up" then
        Cam.camera:setPosition(Cam.camera.x, Cam.camera.y + dist_step, Cam.camera.z)
    elseif key == "down" then
        Cam.camera:setPosition(Cam.camera.x, Cam.camera.y - dist_step, Cam.camera.z)
    elseif key == "w" then
        Cam.camera:setPosition(Cam.camera.x, Cam.camera.y, Cam.camera.z + dist_step)
    elseif key == "s" then
        Cam.camera:setPosition(Cam.camera.x, Cam.camera.y, Cam.camera.z - dist_step)
    elseif key == "a" then
        Cam.camera:setRotation(Cam.camera.rx, Cam.camera.ry, Cam.camera.rz + angle_step)
    elseif key == "d" then
        Cam.camera:setRotation(Cam.camera.rx, Cam.camera.ry, Cam.camera.rz - angle_step)
    elseif key == "r" then
        Cam.camera:setRotation(Cam.camera.rx - angle_step, Cam.camera.ry, Cam.camera.rz)
    elseif key == "f" then
        Cam.camera:setRotation(Cam.camera.rx + angle_step, Cam.camera.ry, Cam.camera.rz)
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