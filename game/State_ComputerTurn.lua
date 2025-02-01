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
    -- pick a card and flip it
    
    -- assuming all cards are facing down.

    -- todo: fix this. first choose one and then coose another. probably do it in update.


    self.cards_to_choose_from = self.manager:get_cards_in_play()
    -- print("computre needs to choose from " .. #self.cards_to_choose_from .. " cards")

    -- choose two random cards 
    local r1 = math.random(#self.cards_to_choose_from)
    local r2 = math.random(#self.cards_to_choose_from-1)
    if r2 == r1 then
        r2 = r2+1
    end

    print("r1,r2=", r1, r2)
    self.manager.revealCard( self.cards_to_choose_from[r1] )
    self.manager.revealCard( self.cards_to_choose_from[r2] )

end

function state:update(dt)
    
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