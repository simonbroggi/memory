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

    -- todo: put this in a separate storry reader system..
    Story = require("tinta.love")
    local my_story = import("ink_story.story_main")
    local story = Story(my_story)
    print(story:Continue())

    -- Hand = core.newEntitytInWorld()
    -- Hand.tform = {x = 0, y = 0}
    -- Hand.material = {red=0, green=1, blue=1, alpha=1}
    -- Hand.rectangle = {width=20, height=20}

    -- love.mouse.setVisible(false)

    Cam = core.newEntitytInWorld()
    Cam.transform = love.math.newTransform()
    -- camera without rotation is looking upwards
    Cam.transform:translate(0, -1800, -1200)
    Cam.transform:rotate(0, math.rad(90))
    Cam.camera = camera(1920, 1080, true, math.rad(44), 100, 10000, 0, -1.2)

    local speachBubble = core.newEntitytInWorld()
    speachBubble.transform = love.math.newTransform()
    speachBubble.transform:translate(200, 500, -770)
    speachBubble.transform:rotate(0, math.rad(90))
    speachBubble.material = {red=1, green=1, blue=1, alpha=1}
    speachBubble.tform = {x = 0, y = 0, r = math.rad(0), sx = 2.1, sy = 2.1}
    speachBubble.splines = {
        -- todo: add stroke and fill colors, and maybe resolution. and make it animatable.
        spline({vec2(-11.07, -230.46), vec2(-47.03, -99.05), vec2(32.10, -66.74), vec2(8.18, -9.93), vec2(72.43, -62.19), vec2(294.75, -69.80), vec2(232.36, -206.21)}, {vec2(23.85, -265.95), vec2(-68.57, -117.36), vec2(-20.41, -60.20), vec2(22.87, -32.53), vec2(55.59, -65.99), vec2(272.26, -40.29), vec2(320.68, -154.70)}, {vec2(-45.98, -194.98), vec2(-25.48, -80.75), vec2(36.42, -39.62), vec2(81.76, -23.61), vec2(120.55, -52.09), vec2(317.23, -99.31), vec2(144.04, -257.73)}, true)
        ,
    }

    local oponent = core.newEntitytInWorld()
    oponent.transform = love.math.newTransform()
    oponent.transform:translate(0, 500)
    oponent.transform:rotate(0, math.rad(90))
    oponent.material = {red=1, green=1, blue=1, alpha=1}
    oponent.sprite = {texture = love.graphics.newImage("assets/charactere.png"), quad = love.graphics.newQuad(0, 0, 512, 512, 512, 512), ox=256, oy=480}
    oponent.tform = {x = 0, y = 0, r = math.rad(0), sx = 2.1, sy = 2.1}



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

    -- Hand.tform.x = love.mouse.getX()-love.graphics.getWidth()/2
    -- Hand.tform.y = -love.mouse.getY()+love.graphics.getHeight()/2
    -- local scale = 1/DrawSystem.cameraEntity.camera.canvas_scale
    -- Hand.tform.x, Hand.tform.y = Hand.tform.x * scale, Hand.tform.y * scale

    InputSystem:update(dt)
    PhysicsSystem:fixedUpdate(dt)

    CardManager.update(dt)

    AnimSystem:update(dt)
    DrawSystem:update(dt)
end

function love.draw()
    --PhysicsSystem:debugDraw()
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
    print("Resize Love", w, h)
    DrawSystem:resize_canvas(w, h)
end