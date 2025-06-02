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
        local tags = self.story:currentTags()
        if  #tags > 0 then
            print(" # tags: " .. table.concat(tags, ", "), '\n')
        end
        continued = true
    end
    if continued then
        local choices = self.story:currentChoices()
        for i,c in ipairs(choices) do
            print(i .. ": ", c.text)
            if #c.tags > 0 then
                print(" # tags: " .. table.concat(c.tags, ", "))
            end
        end
    end
end

return InkReader