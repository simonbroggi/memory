local core = require("core")
local Story = require("tinta.love")

local InkReader = {
}

function InkReader:init()
    self.debugLog = true -- print the story text to the console

    local story_definition = import("ink_story.story_main")
    self.story = Story(story_definition)

    -- add a choice button pool
    self.choiceButtonPool = {}
end

function InkReader:update(dt)
    --- SIMPLE SYNC VERSION
    local continued = false
    while self.story:canContinue() do
        local line = self.story:Continue()
        local tags = self.story:currentTags()

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

    if line:starts_with("RILEY: ") then
        line = line:sub(8) -- remove "RILEY: "
        local text = self.rileySpeach.textbox.text
        if text == "" then
            self.rileySpeach.textbox.text = line
        else
            self.rileySpeach.textbox.text = self.rileySpeach.textbox.text .. line
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

function InkReader:presentChoices(choices)
    for i,c in ipairs(choices) do
        if self.debugLog then
            io.write(i .. ":\t" .. c.text .. (#c.tags > 0 and " # tags: " .. table.concat(c.tags, ", ") or ""), "\n")
        end
        self:showChoice(c, i)
    end
end

function InkReader:hideChoices()
    -- hide all choice buttons
    for _, button in ipairs(self.choiceButtonPool) do
        core.ecs_world.entities:remove(button)
    end
end


function InkReader:showChoice(choice, index)
    local button
    if #self.choiceButtonPool >= index then
        button = self.choiceButtonPool[index]
        core.ecs_world.entities:add(button)
    else
        -- create a new choice button
        button = core.newEntitytInWorld()
        table.insert(self.choiceButtonPool, button) -- add to the pool
        button.tform = {x = 1100, y = 300+index * 60}
        button.ui = true
        button.rectangle = {width=200, height=50}
        button.material = {red=0, green=0, blue=1, alpha=0.7}
        button.textbox = {
            font = love.graphics.newFont(20),
            text = choice.text,
            limit = 200,
            ox = 100,
            oy = 25,
            align = "center",
        }
        button.choiceIndex = index
        button.onPointerDown = function(entity)
            self.story:ChooseChoiceIndex(entity.choiceIndex) -- choose the choice at the index
            self:hideChoices() -- hide all choices after selecting one
        end
    end
    button.tform.y = 300 + index * 60
    button.textbox.text = choice.text
    -- the choice might also have tags:
    if #choice.tags > 0 then
        --print(" # tags: " .. table.concat(choice.tags, ", "))
    end
end

return InkReader