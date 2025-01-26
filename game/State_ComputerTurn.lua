local state = {}

function state:init(manager)
    self.manager = manager
end

function state:enter()
    print("computr turn")
    -- pick a card and flip it
end

function state:update(dt)
    
end

function state:exit()

end

state.transitions = {
    function (selfState)
        local nRevealedCards = selfState.manager.numRevealedCards()
        if nRevealedCards == 2 then
            -- collect cards
            return selfState.manager.set_state(selfState.manager.playerTurn)
        end
    end,
    function (selfState)
        print("computer takes another card another card!")
    end
}

return state