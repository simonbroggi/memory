local core = require("core")

local state = {}

function state:init(manager)
    self.manager = manager
end

function state:enter()
    self.collectCards = {}
    self.flipCards = {}
    self.time = 0
    self.collectStart = false
    local pairIndex = 0
    local firstCardEntity
    -- check the revealed cards sort them by ones that can be collected and ones that need to be flipped back
    for e in pairs(self.manager.revealedCardEntities) do
        local card = e.card
        if pairIndex == 0 then -- first revealed card enity
            firstCardEntity = e
            pairIndex = card.cardSet.pairIndices[card.index]
            print("first card pair index: " .. pairIndex)
        else
            local pi = card.cardSet.pairIndices[card.index]
            if pi == pairIndex then
                print("found a pair!")
                self.collectCards[#self.collectCards+1] = e
            else
                print("no pair")
                self.flipCards[#self.flipCards+1] = e
            end
        end
    end
    if #self.collectCards > 0 then
        self.collectCards[#self.collectCards+1] = firstCardEntity
    else
        self.flipCards[#self.flipCards+1] = firstCardEntity
    end
end

function state:update(dt)
    self.time = self.time + dt
    if not self.collectStart and self.time > 0.5 then
        self.collectStart = true
        for i, e in ipairs(self.collectCards) do
            self.manager.num_cards_player_collected = self.manager.num_cards_player_collected + 1
            core.destroyEntity(e)
            self.manager.revealedCardEntities[e] = nil
            self.collectCards[i] = nil
        end
        for i, e in ipairs(self.flipCards) do
            self.manager.concealCard(e)
            self.flipCards[i] = nil
        end
        print("collected a totoal of " .. self.manager.num_cards_player_collected .. " so far.")
        self.manager.set_state(self.manager.playerTurn)
        -- todo: call manager.updateState() once all animations are done.

    end
    --manager.updateState()
end



state.transitions = {
    function (stateParam)
        local nRevealedCards = stateParam.manager.numRevealedCards()
        print("NUM revealed cards: "..nRevealedCards)
        if nRevealedCards == 0 then
            return stateParam.manager.set_state(stateParam.manager.playerTurn)
        end
        print("still ending turn")
    end,
    function (stateParam)
        print("de?")
        local p = {stateParam.manager.getRevealedPairCards()}
        for i, e in ipairs(p) do
            print("destroy card")
            core.destroyEntity(e)
            stateParam.manager.revealedCardEntities[e] = nil
        end
        print("collect cards if pairs match")
        return stateParam.manager.set_state(stateParam.manager.playerTurn)
    end
}


return state