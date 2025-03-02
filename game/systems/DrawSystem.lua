local core = require("core")
local mat4 = require("love3d.mat4")

local spline = require("spline")

---@class DrawSystem : System

local DrawSystem = {
    -- reference resolution where canvas scale is 1
    -- design for this resolution
    -- should stay constant!
    canvas_reference_width = 1920, canvas_reference_height = 1080,

    -- current translation and scale to make the reference resolution fit
    -- into the windows resolution (letterbox/pillarbox)
    -- calculated in resize function
    -- this is probably no longer needed since a projection matrix is used: self.projection
    canvas_translate_x = 0, canvas_translate_y = 0, canvas_scale = 1
}

-- lists of entities in main camera space
DrawSystem.spriteEntities = core.newList()
DrawSystem.rectangleEntities = core.newList()
DrawSystem.textboxEntities = core.newList()
DrawSystem.particleSystemEntities = core.newList()
DrawSystem.splinesEntities = core.newList()

DrawSystem.uiSpriteEntities = core.newList()
DrawSystem.uiRectangleEntities = core.newList()
DrawSystem.uiTextboxEntities = core.newList()
DrawSystem.uiSplinesEntities = core.newList()

function DrawSystem:init()
    --self.width, self.height = love.graphics.getDimensions()
    self.halfWidth, self.halfHeight = self.canvas_reference_width/2, self.canvas_reference_height/2

    local width, height = love.graphics.getDimensions()
    self:resize_canvas(width, height)
end


function DrawSystem:filter()
    self.spriteEntities:clear()
    self.uiSpriteEntities:clear()
    self.rectangleEntities:clear()
    self.uiRectangleEntities:clear()
    self.textboxEntities:clear()
    self.uiTextboxEntities:clear()
    self.splinesEntities:clear()
    self.uiSplinesEntities:clear()
    for _, entity in ipairs(core.ecs_world.entities) do
        if entity.camera then
            self.cameraEntity = entity
        end
        if entity.tform then
            if entity.ui then
                if entity.sprite then
                    self.uiSpriteEntities:add(entity)
                end
                if entity.rectangle then
                    self.uiRectangleEntities:add(entity)
                end
                if entity.textbox then
                    self.uiTextboxEntities:add(entity)
                end
            else
                if entity.sprite then
                    self.spriteEntities:add(entity)
                end
                if entity.rectangle then
                    self.rectangleEntities:add(entity)
                end
                if entity.textbox then
                    self.textboxEntities:add(entity)
                end
                if entity.splines then
                    self.splinesEntities:add(entity)
                end
            end
        end

        if entity.ui then
            if entity.splines then
                self.uiSplinesEntities:add(entity)
            end
        else
            if entity.splines then
                self.splinesEntities:add(entity)
            end
        end
    end
    self.particleSystemEntities:clear()
    for _, entity in ipairs(core.ecs_world.entities) do
        if entity.particleSystem then
            self.particleSystemEntities:add(entity)
        end
    end
end


function DrawSystem:update(dt)
    -- pragmatic approach: clear the list and re-add all entities that have a sprite and a transform
    self:filter()

    -- update particle systems
    for _, entity in ipairs(self.particleSystemEntities) do
        entity.particleSystem:update(dt)
    end
end

local function setMaterial(mat)
    mat = mat or {red=1, green=1, blue=1, alpha=1, blendmode="alpha"}

    love.graphics.setColor(mat.red or 1, mat.green or 1, mat.blue or 1, mat.alpha or 1)
    love.graphics.setBlendMode(mat.blendmode or "alpha")
    love.graphics.setShader(mat.shader)
    if mat.properties then
        for k,v in pairs(mat.properties) do
            mat.shader:send(k, v)
        end
    end
end

function DrawSystem:resize_canvas(w, h)
    local w1, h1 = self.canvas_reference_width, self.canvas_reference_height
    local scale = math.min(w/w1, h/h1)
    self.canvas_translate_x, self.canvas_translate_y = (w - w1*scale)/2, (h - h1*scale)/2
    self.canvas_scale = scale

    -- set projection
    
    -- top left corner is aproximatly 0, 0, y is down
    --local left, right, bottom, top = 0-self.canvas_translate_x/scale, w1+self.canvas_translate_x/scale, h1+self.canvas_translate_y/scale, 0-self.canvas_translate_y/scale

    -- center of the screen is 0, 0, y is down
    --local left, right, bottom, top = -w1/2-self.canvas_translate_x/scale, w1/2+self.canvas_translate_x/scale, h1/2+self.canvas_translate_y/scale, -h1/2-self.canvas_translate_y/scale

    -- center of the screen is 0, 0, y is up. Righthanded, like in Blender when looking downwards.
    local left, right, bottom, top = -w1/2-self.canvas_translate_x/scale, w1/2+self.canvas_translate_x/scale, -h1/2-self.canvas_translate_y/scale, h1/2+self.canvas_translate_y/scale

    --self.projection = orthographic_projection(left, right, bottom, top, 100, 2000)

    -- should probably be moved to camera.
    -- self.projection = love.math.newTransform():setMatrix(mat4.ortho(left, right, bottom, top, -10, 10):components())
    self.projection = love.math.newTransform():setMatrix(mat4.perspective_lefthanded(math.rad(50), w1/h1, 100):components())

    love.graphics.setProjection(self.projection)
end

function DrawSystem:drawScene()
    for _, entity in ipairs(self.splinesEntities) do
        if entity.transform then
            love.graphics.push()
            love.graphics.applyTransform(entity.transform)
        end
        local tform = entity.tform
        local splines = entity.splines
        setMaterial(entity.material)
        local w = love.graphics.getLineWidth()
        love.graphics.setLineWidth(6)
        for _, s in ipairs(splines) do
            local verts = s:render()
            -- This works as long as the curve is not self-intersecting (simple). Otherwise it crashes!
            -- https://stackoverflow.com/questions/4001745/testing-whether-a-polygon-is-simple-or-complex
            local triangles = love.math.triangulate(verts)
            love.graphics.setColor(1, 1, 0, 1)
            for i, triangle in ipairs(triangles) do
                love.graphics.polygon("fill", triangle)
            end
            love.graphics.setColor(1, 0, 0, 1)
            love.graphics.line(s:render())
        end
        love.graphics.setLineWidth(w)
        if entity.transform then
            love.graphics.pop()
        end
    end
    for _, entity in ipairs(self.spriteEntities) do
        local tform = entity.tform
        local sprite = entity.sprite
        local transform = entity.transform
        if transform then
            love.graphics.push()
            love.graphics.applyTransform(transform)
        end
        setMaterial(entity.material)
        love.graphics.draw(sprite.texture, sprite.quad, tform.x, tform.y, tform.r, tform.sx, tform.sy, sprite.ox, sprite.oy, tform.kx, tform.ky)
        if transform then
            love.graphics.pop()
        end
    end
    for _, entity in ipairs(self.rectangleEntities) do
        local tform = entity.tform
        local rect = entity.rectangle
        setMaterial(entity.material)
        local rWidth, rHeight = rect.width * (tform.sx or 1), rect.height * (tform.sy or tform.sx or 1)
        love.graphics.rectangle("fill", tform.x - rWidth/2, tform.y - rHeight/2, rWidth, rHeight)
    end

    -- todo: shader and/or blendmode per drawable component?
    --love.graphics.setBlendMode("add")
    for _, entity in ipairs(self.particleSystemEntities) do
        setMaterial(entity.material)
        love.graphics.draw(entity.particleSystem)
    end
    
    setMaterial() -- reset material
    -- debug draw rects
    for _, entity in ipairs(core.ecs_world.entities) do
        if entity.tform and entity.debugRect then
            love.graphics.rectangle("line", entity.tform.x + entity.debugRect.x, entity.tform.y + entity.debugRect.y, entity.debugRect.width, entity.debugRect.height)
        end
    end
end

function DrawSystem:draw()

    -- only support rendering the first camera
    local cameraEntity = self.cameraEntity

    if cameraEntity == nil then
        love.graphics.printf("No camera entity found!", self.halfWidth, self.halfHeight, self.canvas_reference_width, "center", 0, 4, 4, self.canvas_reference_width/2, 0)
    else
        self:pushCameraTransform()
        self:drawScene()
        
        -- end of camera transformations
        love.graphics.pop()
    end

    -- draw UI
    for _, entity in ipairs(self.uiSpriteEntities) do
        local tform = entity.tform
        local sprite = entity.sprite
        setMaterial(entity.material)
        love.graphics.draw(sprite.texture, sprite.quad, tform.x, tform.y, tform.r, tform.sx, tform.sy, sprite.ox, sprite.oy, tform.kx, tform.ky)
    end
    for _, entity in ipairs(self.uiRectangleEntities) do
        local tform = entity.tform
        local rect = entity.rectangle
        setMaterial(entity.material)
        local rWidth, rHeight = rect.width * (tform.sx or 1), rect.height * (tform.sy or tform.sx or 1)
        love.graphics.rectangle("fill", tform.x - rWidth/2, tform.y - rHeight/2, rWidth, rHeight)
    end
    for _, entity in ipairs(self.uiTextboxEntities) do
        local tform = entity.tform
        local textbox = entity.textbox
        setMaterial()
        love.graphics.setFont(textbox.font)
        love.graphics.printf(textbox.text, tform.x, tform.y, textbox.limit, textbox.align, tform.r, tform.sx, tform.sy, textbox.ox, textbox.oy, tform.kx, tform.ky)
    end

    setMaterial() -- reset material
end

-- probably pass camera component as an argument and do this for every camera entity
--- apply camera transformations
function DrawSystem:pushCameraTransform()
    local cameraEntity = self.cameraEntity

    love.graphics.push()
    love.graphics.applyTransform(cameraEntity.transform:inverse())
    --local camSX, camSY = cameraEntity.tform.sx or 1, cameraEntity.tform.sy or cameraEntity.tform.sx or 1
    --love.graphics.translate(self.halfWidth, self.halfHeight) -- not needed if projection 0,0 is set to center of the screen
    --love.graphics.scale(camSX, camSY)
    --love.graphics.rotate(cameraEntity.tform.r)
    --love.graphics.translate(-cameraEntity.tform.x, -cameraEntity.tform.y)
end

return DrawSystem