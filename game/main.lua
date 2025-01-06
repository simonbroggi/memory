local core = require("core")

local DrawSystem = require("systems.DrawSystem")

function love.load()
    DrawSystem:init()

    Cam = core.newEntitytInWorld()
    Cam.camera = {}
    Cam.tform = {x = 0, y = 0, r = 0, sx = 1, sy = 1}
    Cam.rectangle = {width = 40, height = 40}
    Cam.material = {red=1, green=0, blue=1, alpha=1}

    -- coordinate system lines using rectangle components
    local ex = core.newEntitytInWorld()
    ex.tform = {x = 0, y = 0}
    ex.material = {red=1, green=0, blue=0, alpha=1}
    ex.rectangle = {width=1000, height=4}
    local ey = core.newEntitytInWorld()
    ey.tform = {x = 0, y = 0}
    ey.material = {red=0, green=1, blue=0, alpha=1}
    ey.rectangle = {width=4, height=1000}

    -- cards using sprite components
    local card_backs_texture =  love.graphics.newImage("assets/card_backs.png")
    local card_backs_w, card_backs_h = 1024, 1024
    local card_w, card_h = 346, 476
    local card1_quad = love.graphics.newQuad(122, 19, card_w, card_h, card_backs_w, card_backs_h)
    local card2_quad = love.graphics.newQuad(556, 19, card_w, card_h, card_backs_w, card_backs_h)
    local card3_quad = love.graphics.newQuad(122, 530, card_w, card_h, card_backs_w, card_backs_h)
    local card4_quad = love.graphics.newQuad(556, 530, card_w, card_h, card_backs_w, card_backs_h)

    math.randomseed(os.time())

    local card1 = core.newEntitytInWorld()
    card1.tform = {x = 250, y = 250, r=math.pi/32 * math.random(-1.0,1.0)}
    card1.sprite = {texture = card_backs_texture, quad = card1_quad, ox = card_w*0.5, oy = card_h*0.5}

    local card2 = core.newEntitytInWorld()
    card2.tform = {x = 250, y = -250, r=math.pi/32 * math.random(-1.0,1.0)}
    card2.sprite = {texture = card_backs_texture, quad = card2_quad, ox = card_w*0.5, oy = card_h*0.5}

    local card3 = core.newEntitytInWorld()
    card3.tform = {x = -250, y = -250, r=math.pi/32 * math.random(-1.0,1.0)}
    card3.sprite = {texture = card_backs_texture, quad = card3_quad, ox = card_w*0.5, oy = card_h*0.5}

    local card4 = core.newEntitytInWorld()
    card4.tform = {x = -250, y = 250, r=math.pi/32 * math.random(-1.0,1.0)}
    card4.sprite = {texture = card_backs_texture, quad = card4_quad, ox = card_w*0.5, oy = card_h*0.5}
end

function love.update(dt)
    
    DrawSystem:update(dt)
    
end

function love.draw()
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