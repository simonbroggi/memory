local Entity_mt = {
    __newindex = function(t, k, v)
        if k == "body" then
            if v == nil then
                local oldBody = rawget(t, "__body")
                if oldBody then
                    oldBody:setUserData(nil)
                    oldBody:destroy()
                end
                print("WARNING: entity.body set to nil. If an old body was present, it has been destroyed.")
            else
                -- if key is "body" then value should be a love.physics.Body

                -- check if there has not been a body attached to this entity before
                local oldBody = rawget(t, "__body")
                if oldBody then
                    print("WARNING: entity.body overwriting. destroying old body.")
                    oldBody:destroy()
                end
                -- check if the body userdata is empty
                if v:getUserData() then
                    print("WARNING: body already has userdata. overwriting.")
                end

                v:setUserData(t)
            end
            rawset(t, "__body", v)
        else
            rawset(t, k, v)
        end
    end,
    __index = function(t, k)
        if k == "body" then
            -- getting the body attached to an entity
            return rawget(t, "__body")
        else
            return rawget(t, k)
        end
    end,
    -- __tostring = function(t)
    --     return (t.name or "entity") .. ecs.world.entities:indexOf(t)
    -- end,
}

return Entity_mt