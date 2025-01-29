local state = {}

---comment
---@param manager CardManager
function state:init(manager)
    self.manager = manager
    self.name = "Computer Turn"
end

function state:enter()
    print("computr turn")
    -- pick a card and flip it
    
    -- assuming all cards are facing down.

    
    self.cards_to_choose_from = self.manager:get_cards_in_play()
    print("computre needs to choose from " .. #self.cards_to_choose_from .. " cards")
    self.manager.revealCard( self.cards_to_choose_from[math.random(#self.cards_to_choose_from)] )
    self.cards_to_choose_from = self.manager:get_cards_in_play()
    self.manager.revealCard( self.cards_to_choose_from[math.random(#self.cards_to_choose_from)] )

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
        print("ccomputer takes another card another card!")
    end
}

return state