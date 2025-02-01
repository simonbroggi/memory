local core = require("core")

local state = {}

function state:init(manager)
    self.manager = manager
    self.name = "Computer Collect"
    print(self.name, "initialized")
end

function state:enter()
    print(self.name, "enter")
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
            -- print("first card pair index: " .. pairIndex)
        else
            local pi = card.cardSet.pairIndices[card.index]
            if pi == pairIndex then
                -- print("found a pair!")
                self.collectCards[#self.collectCards+1] = e
            else
                -- print("no pair")
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

function state:exit()
    print(self.name, "exit")
end

function state:update(dt)
    self.time = self.time + dt
    if not self.collectStart and self.time > 0.5 then
        self.collectStart = true
        local doTransitions = false
        for i, e in ipairs(self.collectCards) do
            self.manager.num_cards_player_collected = self.manager.num_cards_player_collected + 1
            e.body:setPosition(-760, -450) -- todo: animation!
            doTransitions = true -- if animating remove this and instead add an onDone callback
            e.card.inPlay = false
            --core.destroyEntity(e)
            self.manager.revealedCardEntities[e] = nil
            self.collectCards[i] = nil
        end
        for i, e in ipairs(self.flipCards) do
            doTransitions = false -- when concealCards is called a onDone that does transition is created
            self.manager.concealCard(e)
            self.flipCards[i] = nil
        end

        if doTransitions then
            self.manager.do_transitions()
        end

        -- print("collected a totoal of " .. self.manager.num_cards_player_collected .. " so far.")
        
        -- transition from update seems baad. that's what transitions are for...
        -- self.manager.set_state(self.manager.computerTurn)
        -- todo: call manager.do_transitions() once all animations are done.

    end
    
    --self.manager.do_transitions()
end


-- todo: figure out what belongs in transitions and what in update!!
state.transitions = {
    function (selfState)
        local nRevealedCards = selfState.manager.numRevealedCards()
        --print("NUMBER revealed cards: "..nRevealedCards)
        if nRevealedCards == 0 then
            return selfState.manager.set_state(selfState.manager.playerTurn)
        end
        --print("still ending turn")
    end,
    -- function (selfState)
    --     -- print("de?")
    --     local p = {selfState.manager.getRevealedPairCards()}
    --     for i, e in ipairs(p) do
    --         print("DESTROY card")
    --         core.destroyEntity(e)
    --         selfState.manager.revealedCardEntities[e] = nil
    --     end
    --     print("collect cards if pairs match")
    --     return selfState.manager.set_state(selfState.manager.computerTurn)
    -- end
}


return state