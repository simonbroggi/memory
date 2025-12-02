local core = require("core")
local Story = require("tinta.love")
local TextUISystem = require("systems.TextUISystem")

local InkReader = {
}

function InkReader:init()
    self.debugLog = false -- print the story text to the console

    local story_definition = import("ink_story.story_main")
    self.story = Story(story_definition)
    self.cooldown = 0

    TextUISystem.onChoiceChosenHandler = self
    TextUISystem.onChoiceChosen = self.onChoiceChosen
end

function InkReader:onChoiceChosen(choiceIndex)
    self.story:ChooseChoiceIndex(choiceIndex)
end

function InkReader:setVariable(var_name, value)
    local var = self.story.state.variablesState.globalVariables[var_name]
    var.value = value
end

function InkReader:addToVariable(var_name, increment)
    increment = increment or 1
    local var = self.story.state.variablesState.globalVariables[var_name]
    var.value = var.value + increment
end

function InkReader:goto(path)
    TextUISystem:hideChoices()
    self.story:ChoosePathString(path)
end

-- function InkReader:turnCard()
--     --works!
--     self:addToVariable("cards_revealed")

--     -- local ct = self.story.state.variablesState.globalVariables["cards_turned"]
--     -- if ct then
--     --     ct.value = ct.value+1
--     -- end
-- end

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

        self:parseLine(line, tags)

        continued = true
    end
    if continued then
        local newChoices = self.story:currentChoices()
        TextUISystem:presentChoices(newChoices)
    end
end

function InkReader:parseLine(line, tags)
    if self.debugLog then
        io.write(line)
        if #tags > 0 then
            io.write("# tags: " .. table.concat(tags, ", ") .. "\n")
        end
    end

    if line:starts_with("NPC: ") then
        line = line:sub(6) -- remove "NPC: "
        local text = self.npcSpeech.textbox.text
        self.npcSpeech.textbox.text = text .. line
        self.playerSpeech.textbox.text = self.playerSpeech.textbox.text .. "\n"
        TextUISystem:presentDialogBubble(line, "left")
    else
        local text = self.playerSpeech.textbox.text
        self.playerSpeech.textbox.text = text .. line
        self.npcSpeech.textbox.text = self.npcSpeech.textbox.text .. "\n"
        TextUISystem:presentDialogBubble(line, "right")
    end
end

function InkReader:layout()
    local width = love.graphics.getWidth()
    local border = 40
    local colWidth = (width - border*2) / 3
    
    self.playerSpeech.tform.x = width - border - colWidth
    self.playerSpeech.textbox.ox = 0
    self.playerSpeech.textbox.limit = colWidth

    self.npcSpeech.tform.x = border
    self.npcSpeech.textbox.ox = 0
    self.npcSpeech.textbox.limit = colWidth
end

return InkReader