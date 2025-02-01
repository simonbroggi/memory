local state = {}

---initialize the state
---@param manager CardManager
function state:init(manager)
    self.manager = manager
    self.name = "Computer Turn"
    print(self.name, "initialized")
end

function state:enter()
    print(self.name, "enter")
    self.time = 0

    -- todo: first choose one and then coose another. probably do it in update with a delay.

    local unrevealed_cards = self.manager:get_undefined_cards_in_play()
    if #unrevealed_cards > 0 then
        local cardEntity = unrevealed_cards[math.random(#unrevealed_cards)]
        self.manager.revealCard(cardEntity)
        return
    end


    local cards_in_play = self.manager:get_cards_in_play()

    if cards_in_play < 2 then
        print("The Game is over, less then two cards.")
        return
    end

    -- choose two random cards and reveal them
    local r1 = math.random(#cards_in_play)
    local r2 = math.random(#cards_in_play-1)
    if r2 == r1 then
        r2 = r2+1
    end
    self.manager.revealCard( self.cards_to_choose_from[r1] )
    self.manager.revealCard( self.cards_to_choose_from[r2] )

end

function state:update(dt)
    state.time = state.time + dt
    
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