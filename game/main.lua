require("batteries"):export()
local camera = require("camera")

local core = require("core")
local InputSystem = require("systems.InputSystem")
local PhysicsSystem = require("systems.PhysicsSystem")
local DrawSystem = require("systems.DrawSystem")
local AnimSystem = require("systems.AnimSystem")

local CardManager = require("CardManager")

local spline = require("spline")

require("love3d")

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
    Cam.transform = love.math.newTransform()
    Cam.transform:translate(0, 0, 1000)
    Cam.camera = camera()

    Oponent = core.newEntitytInWorld()
    Oponent.transform = love.math.newTransform()
    Oponent.transform:translate(0, 500)
    Oponent.material = {red=1, green=0, blue=0, alpha=1}
    Oponent.splines = {
        spline({vec2(29.00, 221.00), vec2(415.00, 68.00), vec2(306.00, 170.00), vec2(527.00, 221.00)}, {vec2(-44.00, 218.00), vec2(148.00, 0.00), vec2(291.00, 115.00), vec2(387.00, 225.00)}, {vec2(169.00, 140.00), vec2(327.00, 98.00), vec2(321.00, 225.00), vec2(667.00, 217.00)}, false),
    }

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
        Cam.transform:translate(-dist_step, 0)
    elseif key == "right" then
        Cam.transform:translate(dist_step, 0)
    elseif key == "up" then
        Cam.transform:translate(0, dist_step, 0)
    elseif key == "down" then
        Cam.transform:translate(0, -dist_step, 0)
    elseif key == "w" then
        Cam.transform:translate(0, 0, dist_step)
    elseif key == "s" then
        Cam.transform:translate(0, 0, -dist_step)
    elseif key == "a" then
        Cam.transform:rotate(angle_step)
    elseif key == "d" then
        Cam.transform:rotate(-angle_step)
    elseif key == "r" then
        Cam.transform:rotate(0, angle_step, 0)
    elseif key == "f" then
        Cam.transform:rotate(0, -angle_step, 0)
    elseif key == "q" then
        Cam.transform:rotate(0, 0, angle_step)
    elseif key == "e" then
        Cam.transform:rotate(0, 0, -angle_step)
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