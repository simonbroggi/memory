local core = require("core")

local TextUISystem = {
}

function TextUISystem:init()
    
    -- add a choice button pool
    self.choiceButtonPool = {}
    self.visibleChoices = 0

    -- onChoiceChosen is executed when a choice button is clicked.
    -- the variable is set in InkReader, and the handler is the InkReader.
    self.onChoiceChosen = self.onChoiceChosen
    self.onChoiceChosenHandler = self.onChoiceChosenHandler

    self.font = love.graphics.newFont(20)

    self.dialogBubbles = {}
    self.nextBubbleY = 0
end

---todo: use this
---@param text string text displayed in the bubble
---@param area string where the bubble is shown
function TextUISystem:presentDialogBubble(text, area)
    local r, g, b, a = .5, .5, .5, .5
    local bubble = self:createDialogBubble(text, 200, self.nextBubbleY, 200, 60, r, g, b, a)
    self.nextBubbleY = self.nextBubbleY + 70
    self.dialogBubbles[#self.dialogBubbles+1] = bubble
end

function TextUISystem:layoutDialogBubbles()
    for i, bubble in ipairs(self.dialogBubbles) do

    end
end

function TextUISystem:presentChoices(choices)
    local visibleChoicesCount = 0
    for index, choice in ipairs(choices) do
        if self.debugLog then
            io.write(index .. ":\t" .. choice.text .. (#choice.tags > 0 and " # tags: " .. table.concat(choice.tags, ", ") or ""), "\n")
        end
        if #self.choiceButtonPool < index then
            -- create new choice button if there are not enough in the pool
            self:createChoiceButton()
        end

        local choiceButton = self.choiceButtonPool[index]
        choiceButton.textbox.text = choice.text

        visibleChoicesCount = index
        core.ecs_world.entities:add(choiceButton)
    end
    self.visibleChoices = visibleChoicesCount

    local width, height = love.graphics.getDimensions()
    self:layoutChoices(width, height)
end

function TextUISystem:hideChoices()
    -- hide all choice buttons
    for _, button in ipairs(self.choiceButtonPool) do
        core.ecs_world.entities:remove(button)
    end
    self.visibleChoices = 0
end

function TextUISystem:resize(width, height)
    self:layoutChoices(width, height)
end

function TextUISystem:onChoiceButtonPointerDown(buttonEntity)
    self.onChoiceChosen(self.onChoiceChosenHandler, buttonEntity.choiceIndex)
    TextUISystem:hideChoices()
end

function TextUISystem:layoutChoices(width, height)
    local visibleChoicesCount = self.visibleChoices
    if visibleChoicesCount == nil or visibleChoicesCount == 0 then return end

    local xStart = 0-- -width / 2
    local choiceSpace = width / visibleChoicesCount
    local inset = 12
    local choiceWidth = choiceSpace - 2*inset
    local halfWidth = choiceWidth / 2

    -- horizontal layout
    if width > height then
        for index = 1, visibleChoicesCount do
            local choiceButton = self.choiceButtonPool[index]

            choiceButton.tform.x = xStart + choiceSpace*index - choiceSpace/2
            choiceButton.tform.y = height - 60
            choiceButton.textbox.limit = choiceWidth
            choiceButton.textbox.ox = halfWidth
            choiceButton.rectangle.width = choiceWidth
        end
    else
        choiceSpace = width
        choiceWidth = choiceSpace - 2*inset
        halfWidth = choiceWidth / 2
        local ySpace = 60
        for index = 1, visibleChoicesCount do
            local choiceButton = self.choiceButtonPool[index]

            choiceButton.tform.x = xStart + choiceSpace/2
            choiceButton.tform.y = height - (60 + 2*ySpace) + (index-1)*ySpace

            choiceButton.textbox.limit = choiceWidth
            choiceButton.textbox.ox = halfWidth
            choiceButton.rectangle.width = choiceWidth 
        end
    end
end

function TextUISystem:createChoiceButton()
    local index = #self.choiceButtonPool + 1
    local button = core.newEntity() -- create the button entity, but don't add it to the world yet. It will be added to the world by showChoice.
    table.insert(self.choiceButtonPool, button) -- add to the pool

    button.tform = {x = 0, y = 600}
    button.ui = true
    button.rectangle = {width=260, height=50}
    button.material = {red=0, green=0, blue=1, alpha=0.7}
    button.textbox = {
        font = self.font,
        text = "choice " .. index .. " not set",
        limit = 200,
        ox = 100,
        oy = 25,
        align = "center",
    }
    button.choiceIndex = index
    button.onPointerDown = self.onChoiceButtonPointerDown
    button.pointerDownHandler = self
end

function TextUISystem:createDialogBubble(text, x, y, w, h, r, g, b, a)
    local bubble = core.newEntitytInWorld()
    bubble.tform = {x = x, y = y}
    bubble.ui = true
    bubble.rectangle = {width = w, height = h} -- todo: h is dynamic.
    bubble.material = {red=r, green=g, blue=b, alpha=a}
    local textWidth = w - 20
    bubble.textbox = {
        font = self.font,
        text = text,
        limit = textWidth,
        ox = textWidth/2,
        oy = h/2, -- todo: h is dynamic.
        align = "left",
    }
    return bubble
end

return TextUISystem