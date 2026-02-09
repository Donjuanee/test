-- Existing function code

-- Example modification with player:sendStorageValue()
local function setQuestStorage(player, value)
    player:setStorageValue(questStorage, value)
    player:sendStorageValue(questStorage, value)  -- Send updated storage value
end

-- Additional existing code
