local core = require("core")
local Story = require("tinta.love")

local InkReader = {
}

function InkReader:init()
    self.debugLog = true -- print the story text to the console

    local story_definition = import("ink_story.story_main")
    self.story = Story(story_definition)
    self.cooldown = 0

    -- add a choice button pool
    self.choiceButtonPool = {}
end

function InkReader:update(dt)
    self.cooldown = self.cooldown - dt
    if self.cooldown > 0 then
        return -- wait for the cooldown to finish
    end

    --- SIMPLE SYNC VERSION
    local continued = false
    --while self.story:canContinue() do -- do all the available lines in one frame.
    if self.story:canContinue() then -- only do one line per frame and wait for the cooldown.
        local line = self.story:Continue()
        local tags = self.story:currentTags()
        self.cooldown = 1

        self:presentLine(line, tags)

        continued = true
    end
    if continued then
        local newChoices = self.story:currentChoices()
        self:presentChoices(newChoices)
    end
end

function InkReader:presentLine(line, tags)
    if self.debugLog then
        io.write(line)
        if #tags > 0 then
            io.write("# tags: " .. table.concat(tags, ", ") .. "\n")
        end
    end

    if line:starts_with("NPC: ") then
        line = line:sub(6) -- remove "NPC: "
        local text = self.npcSpeach.textbox.text
        if text == "" then
            self.npcSpeach.textbox.text = line
        else
            self.npcSpeach.textbox.text = self.npcSpeach.textbox.text .. line
        end
    else
        local text = self.caption.textbox.text
        if text == "" then
            self.caption.textbox.text = line
        else
            -- append to the caption text
            self.caption.textbox.text = self.caption.textbox.text .. line
        end
    end
end

function InkReader:layoutChoices()
    local visibleChoicesCount = self.visibleChoices
    if not visibleChoicesCount then return end

    local width = love.graphics.getWidth()
    local xStart = 0-- -width / 2
    local choiceSpace = width / visibleChoicesCount
    local inset = 0
    local choiceWidth = choiceSpace - 2*inset
    local halfWidth = choiceWidth / 2
    for index = 1, visibleChoicesCount do
        local choiceButton = self.choiceButtonPool[index]

        choiceButton.tform.x = xStart + choiceSpace*index - choiceSpace/2
        choiceButton.textbox.limit = choiceWidth
        choiceButton.textbox.ox = halfWidth
    end
end

function InkReader:presentChoices(choices)
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

    self:layoutChoices()
end

function InkReader:hideChoices()
    -- hide all choice buttons
    for _, button in ipairs(self.choiceButtonPool) do
        core.ecs_world.entities:remove(button)
    end
    self.visibleChoices = 0
end

function InkReader:onChoiceButtonPointerDown(buttonEntity)
    print("Choice Button Down!")
    self.story:ChooseChoiceIndex(buttonEntity.choiceIndex)
    self:hideChoices()
end

function InkReader:createChoiceButton()
    local index = #self.choiceButtonPool + 1
    local button = core.newEntity() -- create the button entity, but don't add it to the world yet. It will be added to the world by showChoice.
    table.insert(self.choiceButtonPool, button) -- add to the pool

    button.tform = {x = 0, y = 600}
    button.ui = true
    button.rectangle = {width=200, height=50}
    button.material = {red=0, green=0, blue=1, alpha=0.7}
    button.textbox = {
        font = love.graphics.newFont(20),
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

return InkReader