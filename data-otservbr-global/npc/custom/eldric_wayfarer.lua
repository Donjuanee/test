-- Update calls to sendStorageValue for real-time quest tracking

function onPlayerQuestUpdate(player)
    -- Assuming existing setStorageValue calls
    player:setStorageValue(1, 1)  -- example storage value
    player:sendStorageValue(1, 1)  -- added for real-time tracking

    -- More game logic...
    player:setStorageValue(2, 2)  -- another example
    player:sendStorageValue(2, 2)  -- added for real-time tracking
end