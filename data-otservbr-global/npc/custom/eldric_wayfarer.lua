local internalNpcName = "Eldric Wayfarer"

-- AP system (used in ap_sources.lua too)
dofile('data/scripts/lib/ap.lua')

local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = "a seasoned traveller with kind eyes"

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 128,
	lookHead = 78,
	lookBody = 95,
	lookLegs = 114,
	lookFeet = 114,
	lookAddons = 0,
}

npcConfig.flags = { floorchange = false }

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onThink = function(npc, interval) npcHandler:onThink(npc, interval) end
npcType.onAppear = function(npc, creature) npcHandler:onAppear(npc, creature) end
npcType.onDisappear = function(npc, creature) npcHandler:onDisappear(npc, creature) end
npcType.onMove = function(npc, creature, fromPosition, toPosition) npcHandler:onMove(npc, creature, fromPosition, toPosition) end
npcType.onSay = function(npc, creature, type, message) npcHandler:onSay(npc, creature, type, message) end
npcType.onCloseChannel = function(npc, creature) npcHandler:onCloseChannel(npc, creature) end

local REQUIRED = 100

local function getKills(player)
	return math.max(player:getStorageValue(Storage.Custom.BeginnersTrials.Kills), 0)
end

local REQUIRED = 100
local LEGION_HELMET_ID = 3374

-- rewards (edit here)
local REWARD1_COINS = 5 -- crystal coins
local REWARD1_AP = 2
local REWARD2_COINS = 3 -- crystal coins
local REWARD2_AP = 1

local function getKills(player)
	return math.max(player:getStorageValue(Storage.Custom.BeginnersTrials.Kills), 0)
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	if not player then
		return true
	end

	local playerId = player:getId()
	message = message:lower()

	-- ===== KEYWORDS =====
	if MsgContains(message, "mission") then
		local questline = player:getStorageValue(Storage.Custom.BeginnersTrials.Questline)
		local stage = player:getStorageValue(Storage.Custom.BeginnersTrials.Stage)
		local rotworm = player:getStorageValue(Storage.Custom.BeginnersTrials.RotwormTrouble)
		local helmet = player:getStorageValue(Storage.Custom.BeginnersTrials.LegionHelmet)

		-- ===== MISSION 1: ROTWORM TROUBLE =====
		if questline ~= 1 or stage < 1 or rotworm < 1 then
			npcHandler:say({
				"Rotworms and their nasty friends have been crawling out of the tunnels nearby.",
				"Go to the rotworm caves and slay 100 of these creatures: rotworms, carrion worms, trolls, swamp trolls and troll champions.",
				"Will you accept this task?"
			}, npc, creature)
			npcHandler:setTopic(playerId, 1)
			return true
		end

		if rotworm == 1 then
			local kills = getKills(player)
			npcHandler:say(string.format("Keep going, %s. Your progress is %d/%d. Have you finished your task yet?", player:getName(), kills, REQUIRED), npc, creature)
			npcHandler:setTopic(playerId, 2)
			return true
		end

		if rotworm == 2 then
			npcHandler:say("I can see it in your eyes — you did it! Say {yes} and I'll grant your reward.", npc, creature)
			npcHandler:setTopic(playerId, 3)
			return true
		end

		-- ===== MISSION 2: LEGION HELMET =====
		if rotworm >= 3 then
			-- not started yet
			if helmet < 1 then
				npcHandler:say({"Bring me a legion helmet.", "Will you accept this task?"}, npc, creature)
				npcHandler:setTopic(playerId, 4)
				return true
			end

			-- in progress
			if helmet == 1 then
				if player:getItemCount(LEGION_HELMET_ID) >= 1 then
					player:setStorageValue(Storage.Custom.BeginnersTrials.LegionHelmet, 2)
					npcHandler:say("Ah, you have it. Say {yes} and I'll take it and grant your reward.", npc, creature)
					npcHandler:setTopic(playerId, 5)
					return true
				end
				npcHandler:say("Bring me a legion helmet and return here. Say {mission} when you're back.", npc, creature)
				npcHandler:setTopic(playerId, 0)
				return true
			end

			-- ready to reward
			if helmet == 2 then
				npcHandler:say("Say {yes} and I'll take the legion helmet and grant your reward.", npc, creature)
				npcHandler:setTopic(playerId, 5)
				return true
			end

			-- done
			if helmet >= 3 then
				npcHandler:say("Well done. You've completed my beginner's trials. Come back later — I will have more work for you soon.", npc, creature)
				npcHandler:setTopic(playerId, 0)
				return true
			end
		end
	end

	-- ===== YES =====
	if MsgContains(message, "yes") then
		local topic = npcHandler:getTopic(playerId)

		-- accept rotworm mission
		if topic == 1 then
			player:setStorageValue(Storage.Custom.BeginnersTrials.Questline, 1)
			player:setStorageValue(Storage.Custom.BeginnersTrials.Stage, 1)
			player:setStorageValue(Storage.Custom.BeginnersTrials.RotwormTrouble, 1)
			player:setStorageValue(Storage.Custom.BeginnersTrials.Kills, 0)

			npcHandler:say("Excellent! The tunnels will breathe easier. Return to me once you've slain 100 of them.", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end

		-- answer "have you finished?" while in progress
		if topic == 2 then
			local kills = getKills(player)
			if kills < REQUIRED then
				npcHandler:say(string.format("Not yet. You still need to slay %d more. Don't give up!", (REQUIRED - kills)), npc, creature)
				npcHandler:setTopic(playerId, 0)
				return true
			end

			-- safety: if kills reached but stage didn't update (edge case)
			player:setStorageValue(Storage.Custom.BeginnersTrials.Stage, 2)
			player:setStorageValue(Storage.Custom.BeginnersTrials.RotwormTrouble, 2)
			npcHandler:say("That's great! Say {yes} once more and I'll grant your reward.", npc, creature)
			npcHandler:setTopic(playerId, 3)
			return true
		end

		-- give rotworm reward
		if topic == 3 then
			player:addItem(3034, REWARD1_COINS, true) -- crystal coins
			AP.addPoints(player, REWARD1_AP, "Beginner's Trials: Rotworm Trouble")

			-- Mark the mission as fully completed for Quest Log / Quest Tracker.
			-- This mission uses the Kills storage as its quest storageId (see lib/core/quests.lua),
			-- so we switch it from 100 (return) -> 101 (rewarded).
			player:setStorageValue(Storage.Custom.BeginnersTrials.Kills, 101)

			player:setStorageValue(Storage.Custom.BeginnersTrials.Stage, 3)
			player:setStorageValue(Storage.Custom.BeginnersTrials.RotwormTrouble, 3)

			npcHandler:say({
				"That's great! You've proven you're capable of more!",
				string.format("Here is your reward: %d crystal coins and %d attribute points.", REWARD1_COINS, REWARD1_AP),
				"Are you ready for the next {mission}?"
			}, npc, creature)

			npcHandler:setTopic(playerId, 0)
			return true
		end

		-- accept legion helmet mission
		if topic == 4 then
			player:setStorageValue(Storage.Custom.BeginnersTrials.LegionHelmet, 1)
			npcHandler:say("Good. Bring me a legion helmet and return here. Say {mission} when you're back.", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end

		-- give legion helmet reward (and take item)
		if topic == 5 then
			if player:getItemCount(LEGION_HELMET_ID) < 1 then
				npcHandler:say("You don't have a legion helmet with you.", npc, creature)
				npcHandler:setTopic(playerId, 0)
				return true
			end

			player:removeItem(LEGION_HELMET_ID, 1)
			player:addItem(3034, REWARD2_COINS, true)
			AP.addPoints(player, REWARD2_AP, "Beginner's Trials: Legion Helmet")
			player:setStorageValue(Storage.Custom.BeginnersTrials.LegionHelmet, 3)

			npcHandler:say(string.format("Excellent. Here is your reward: %d crystal coins and %d attribute points.", REWARD2_COINS, REWARD2_AP), npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end
	end

	-- ===== NO / DEFAULT =====
	if MsgContains(message, "no") then
		local t = npcHandler:getTopic(playerId)
		if t == 1 or t == 4 then
			npcHandler:say("No worries. Come back when you're ready.", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end
	end

	return true
end
npcHandler:setMessage(MESSAGE_GREET, "New adventurer! Nice to meet you! I've got an easy {mission} for you.")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
