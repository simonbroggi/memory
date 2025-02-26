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
    Cam.transform:translate(0, -1100, 800)
    Cam.transform:rotate(0, math.rad(60))
    Cam.camera = camera()

    local oponent = core.newEntitytInWorld()
    oponent.transform = love.math.newTransform()
    oponent.transform:translate(0, 500)
    oponent.transform:rotate(0, math.rad(90))
    oponent.material = {red=1, green=0, blue=0, alpha=1}
    oponent.splines = {
        -- todo: add stroke and fill colors, and maybe resolution. and make it animatable.
        spline({vec2(-322.00, -248.00), vec2(-108.00, -115.00), vec2(-242.00, -61.00), vec2(-295.00, 159.00), vec2(166.00, 288.00), vec2(239.00, 288.00), vec2(277.00, 268.00), vec2(309.00, 108.00), vec2(265.00, -79.00), vec2(130.00, -118.00), vec2(351.00, -267.00), vec2(-7.00, -265.00)}, {vec2(-313.00, -314.00), vec2(-110.00, -219.00), vec2(-302.00, -160.00), vec2(-304.00, -28.00), vec2(56.00, 222.00), vec2(189.00, 266.00), vec2(249.00, 248.00), vec2(303.00, 183.00), vec2(223.00, -8.00), vec2(130.00, -80.00), vec2(359.00, -215.00), vec2(111.00, -257.00)}, {vec2(-331.00, -182.00), vec2(-107.00, -74.00), vec2(-182.00, 38.00), vec2(-286.00, 346.00), vec2(159.00, 203.00), vec2(235.00, 228.00), vec2(278.00, 217.00), vec2(315.00, 33.00), vec2(307.00, -150.00), vec2(127.00, -223.00), vec2(343.00, -319.00), vec2(-125.00, -273.00)}, true),
        
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