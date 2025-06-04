local core = require("core")
local Story = require("tinta.love")

local InkReader = {
}

function InkReader:init()
    local story_definition = import("ink_story.story_main")
    self.story = Story(story_definition)

    -- add a choice button pool
    self.choiceButtonPool = {}
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

end

return InkReader