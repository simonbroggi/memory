local state = {}

function state:init(manager)
    self.manager = manager
end

function state:enter()
    -- allow flipping cards
    self.manager.num_player_turns = self.manager.num_player_turns + 1
    print("player turn " .. self.manager.num_player_turns)
    self.manager.cardTapHandler = self.manager.revealCard
end

function state:exit()
    -- dont allow flipping cards
    self.manager.cardTapHandler = self.manager.dontAllowFlipCard
end

state.transitions = {
    function (stateParam)
        local nRevealedCards = stateParam.manager.numRevealedCards()
        if nRevealedCards == 2 then
            return stateParam.manager.set_state(stateParam.manager.endPlayerTurn)
        elseif nRevealedCards > 2 then
            print("CHEATING?!")
            return stateParam.manager.set_state(stateParam.manager.endPlayerTurn)
        end
    end,
    function (stateParam)
        print("reveal another card!")
    end
}

return state