local core = require("core")
local Story = require("tinta.love")

local InkReader = {
}

function InkReader:init()
    local story_definition = import("ink_story.story_main")
    self.story = Story(story_definition)
end

function InkReader:update(dt)
    --- SIMPLE SYNC VERSION
    local continued = false
    while self.story:canContinue() do
        local t = self.story:Continue()
        print(t)
        if t:starts_with("RILEY: ") then
            t = t:sub(8) -- remove "RILEY: "
            local text = self.rileySpeach.textbox.text
            if text == "" then
                self.rileySpeach.textbox.text = t
            else
                self.rileySpeach.textbox.text = self.rileySpeach.textbox.text .. t
            end
        else
            local text = self.caption.textbox.text
            if text == "" then
                self.caption.textbox.text = t
            else
                -- append to the caption text
                self.caption.textbox.text = self.caption.textbox.text .. t
            end
        end
        local tags = self.story:currentTags()
        if  #tags > 0 then
            print(" # tags: " .. table.concat(tags, ", "), '\n')
        end
        continued = true
    end
    if continued then
        local newChoices = self.story:currentChoices()
        self:presentChoices(newChoices)
    end
end

function InkReader:presentChoices(choices)
    local width = love.graphics.getWidth() / #choices
    -- todo: buttons

    for i,c in ipairs(choices) do
        print(i .. ": ", c.text)
        if #c.tags > 0 then
            print(" # tags: " .. table.concat(c.tags, ", "))
        end
    end
end

return InkReader