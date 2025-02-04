local state = {}

---initialize the state
---@param manager CardManager
function state:init(manager)
    self.manager = manager
    self.name = "Computer Turn"
    print(self.name, "initialized")
end

local function wait(t)
    local anim = {}
    anim.t = t
    function anim:update(dt)
        -- print("wait", self.t)
        self.t = self.t-dt
        if self.t > 0 then
            return true
        end
    end
    return anim
end
local function printsomething(str)
    local anim = {}
    function anim:update(dt)
        print(str)
    end
    return anim
end

local function flipFirstCard()
    local anim = {}
    function anim:update(dt)
        -- reveal a card that hasn't been revealed, or any if all have previously been revealed.
        local cards_to_choose_from = state.manager:get_undefined_cards_in_play()
        if #cards_to_choose_from == 0 then
            cards_to_choose_from = state.manager:get_cards_in_play()
        end
        local cardEntity = cards_to_choose_from[math.random(#cards_to_choose_from)]
        state.manager.revealCard(cardEntity)
    end
    return anim
end

local function flipSecondCard()
    local anim = {}
    function anim:update(dt)
        local manager = state.manager
        local flipped_cards = manager:get_flipped_cards_in_play()
        assert(#flipped_cards == 1, "Only one card should be flipped")
        local flipped_card = flipped_cards[1]

        local definedCards = manager:get_defined_cards_in_play()
        local knownPair = false
        for i, entity in ipairs(definedCards) do
            manager.isPair(entity.card, flipped_card.card)
            knownPair = true
        end
        local cards_to_choose_from
        if knownPair then
            cards_to_choose_from = state.manager:get_undefined_cards_in_play()
        else
            cards_to_choose_from = state.manager:get_defined_cards_in_play()
            for i, e in ipairs(cards_to_choose_from) do
                if e.card.facingUp then
                    cards_to_choose_from:remove(e)
                end
            end
        end
        if #cards_to_choose_from == 0 then
            cards_to_choose_from = state.manager:get_cards_in_play()
            for i, e in ipairs(cards_to_choose_from) do
                if e.card.facingUp then
                    cards_to_choose_from:remove(e)
                end
            end
        end
        local cardEntity = cards_to_choose_from[math.random(#cards_to_choose_from)]
        state.manager.revealCard(cardEntity)
    end
    return anim
end

function state:enter()
    print(self.name, "enter")
    self.time = 0
    self.animChain = {}
    self.animChain[#self.animChain+1] = printsomething("computer going to wait a bit before turning first card")
    self.animChain[#self.animChain+1] = wait(0.8)
    self.animChain[#self.animChain+1] = flipFirstCard()
    self.animChain[#self.animChain+1] = wait(0.7)
    self.animChain[#self.animChain+1] = flipSecondCard()



    -- -- todo: first choose one and then coose another. probably do it in update with a delay.

    -- local unrevealed_cards = self.manager:get_undefined_cards_in_play()
    -- if #unrevealed_cards > 0 then
    --     local cardEntity = unrevealed_cards[math.random(#unrevealed_cards)]
    --     self.manager.revealCard(cardEntity)
    --     return
    -- end


    -- local cards_in_play = self.manager:get_cards_in_play()

    -- if cards_in_play < 2 then
    --     print("The Game is over, less then two cards.")
    --     return
    -- end

    -- -- choose two random cards and reveal them
    -- local r1 = math.random(#cards_in_play)
    -- local r2 = math.random(#cards_in_play-1)
    -- if r2 == r1 then
    --     r2 = r2+1
    -- end
    -- self.manager.revealCard( self.cards_to_choose_from[r1] )
    -- self.manager.revealCard( self.cards_to_choose_from[r2] )

end

function state:update(dt)
    state.time = state.time + dt
    -- print(#self.animChain)
    -- while dt > 0 do

        if #self.animChain >= 1 then
            local anim = self.animChain[1]
            local continue = anim:update(dt)
            if not continue then
                table.remove(self.animChain, 1)
            end
        end
    -- end
end

function state:exit()
    print(self.name, "exit")
end

state.transitions = {
    function (selfState)
        local nRevealedCards = selfState.manager.numRevealedCards()
        print("n revealCard " .. nRevealedCards)
        if nRevealedCards == 2 then
            -- collect cards
            return selfState.manager.set_state(selfState.manager.computerCollect)
        end
    end,
}

return state