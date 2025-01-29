local state = {}

function state:init(manager)
    self.manager = manager
    self.name = "Player Turn"
end

function state:enter()
    -- allow flipping cards
    self.manager.num_player_turns = self.manager.num_player_turns + 1
    print("AAAplayer turn " .. self.manager.num_player_turns .. " enter")
    self.manager.cardTapHandler = self.manager.revealCard
end

function state:exit()
    -- dont allow flipping cards
    print("DDDdont allow flipping cards")
    self.manager.cardTapHandler = self.manager.dontAllowFlipCard
end

state.transitions = {
    function (selfState)
        local nRevealedCards = selfState.manager.numRevealedCards()
        if nRevealedCards == 2 then
            return selfState.manager.set_state(selfState.manager.endPlayerTurn)
        elseif nRevealedCards > 2 then
            print("CHEATING?!")
            return selfState.manager.set_state(selfState.manager.endPlayerTurn)
        end
    end,
    function (selfState)
        print("reveal another card!")
    end
}

return state