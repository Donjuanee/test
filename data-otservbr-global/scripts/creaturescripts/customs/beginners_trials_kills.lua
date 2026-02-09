local beginnersTrialsKills = CreatureEvent("BeginnersTrialsKills")

local VALID = {
	["rotworm"] = true,
	["carrion worm"] = true,
	["troll"] = true,
	["swamp troll"] = true,
	["troll champion"] = true,
}

local REQUIRED = 100

function beginnersTrialsKills.onKill(player, target)
	if not player or not target then
		return true
	end

	if not target:isMonster() then
		return true
	end

	-- quest not started / already rewarded
	if player:getStorageValue(Storage.Custom.BeginnersTrials.Questline) ~= 1 then
		return true
	end

	local stage = player:getStorageValue(Storage.Custom.BeginnersTrials.Stage)
	local rotworm = player:getStorageValue(Storage.Custom.BeginnersTrials.RotwormTrouble)
	if stage ~= 1 or rotworm ~= 1 then
		return true
	end

	local name = target:getName():lower()
	if not VALID[name] then
		return true
	end

	local kills = math.max(player:getStorageValue(Storage.Custom.BeginnersTrials.Kills), 0)
	if kills >= REQUIRED then
		return true
	end

	kills = kills + 1
	player:setStorageValue(Storage.Custom.BeginnersTrials.Kills, kills)
	player:sendStorageValue(Storage.Custom.BeginnersTrials.Kills, kills)

	if kills >= REQUIRED then
		player:setStorageValue(Storage.Custom.BeginnersTrials.Stage, 2)
		player:sendStorageValue(Storage.Custom.BeginnersTrials.Stage, 2)
		player:setStorageValue(Storage.Custom.BeginnersTrials.RotwormTrouble, 2)
		player:sendStorageValue(Storage.Custom.BeginnersTrials.RotwormTrouble, 2)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have completed 'Beginner's Trials: Rotworm Trouble'. Return to Eldric Wayfarer for your reward.")
	end
	return true
end

beginnersTrialsKills:register()