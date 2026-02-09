-- data/npc/scripts/mission_master.lua
dofile('data/scripts/task_missions/task_missions_config.lua')

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local function msgContains(msg, word)
    msg = (msg or ""):lower()
    word = (word or ""):lower()
    return msg:find(word, 1, true) ~= nil
end

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

local function say(cid, text)
    npcHandler:say(text, cid)
end

local function creatureSayCallback(cid, type, msg)
    local player = Player(cid)
    if not player then return false end
    if not npcHandler:checkInteraction(cid) then return false end

    local m = (msg or ""):lower():gsub("^%s*(.-)%s*$", "%1")

    if m == "missions" or m == "mission" or m == "tasks" or m == "task" then
        say(cid, TaskMissions.buildList(player))
        return true
    end

    if msgContains(m, "help") then
        say(cid, "Say {missions} to see the chain.\nThen use: {info <id>}, {accept <id>}, {cancel <id>}, {claim <id>}.")
        return true
    end

    local cmd, param = m:match("^(%S+)%s+(.+)$")
    if not cmd then
        say(cid, "Say {missions} to see available missions, or {help} for commands.")
        return true
    end

    if cmd == "info" then
        local task = TaskMissions.getTaskByIdOrName(param)
        if not task then
            say(cid, "I don't know that mission. Use {missions}.")
            return true
        end

        local st = TaskMissions.getState(player, task)
        local prog = TaskMissions.getProgress(player, task)

        local rw = task.rewards or {}
        local items = rw.items or {}
        local itemsTxt = {}
        for _, it in ipairs(items) do
            table.insert(itemsTxt, string.format("%dx %d", it.count or 1, it.id or 0))
        end
        if #itemsTxt == 0 then itemsTxt = { "none" } end

        local stTxt = "LOCKED/NOT STARTED"
        if st == 1 then stTxt = "IN PROGRESS" end
        if st == 2 then stTxt = "COMPLETED (CLAIM)" end
        if st == 3 then stTxt = "CLAIMED" end

        say(cid,
            string.format(
                "[%d] %s\n%s\nType: %s\nStatus: %s\nProgress: %d/%d\nRewards: exp=%d, ap=%d, items=%s",
                task.id, task.name, task.description or "",
                task.type, stTxt, prog, task.required,
                tonumber(rw.exp) or 0, tonumber(rw.ap) or 0, table.concat(itemsTxt, ", ")
            )
        )
        return true
    end

    if cmd == "accept" then
        local task = TaskMissions.getTaskByIdOrName(param)
        if not task then
            say(cid, "I don't know that mission. Use {missions}.")
            return true
        end
        local ok, text = TaskMissions.accept(player, task)
        say(cid, text)
        return true
    end

    if cmd == "cancel" then
        local task = TaskMissions.getTaskByIdOrName(param)
        if not task then
            say(cid, "I don't know that mission. Use {missions}.")
            return true
        end
        local ok, text = TaskMissions.cancel(player, task)
        say(cid, text)
        return true
    end

    if cmd == "claim" then
        local task = TaskMissions.getTaskByIdOrName(param)
        if not task then
            say(cid, "I don't know that mission. Use {missions}.")
            return true
        end
        local ok, text = TaskMissions.claim(player, task)
        say(cid, text)
        return true
    end

    say(cid, "I don't understand. Say {missions} or {help}.")
    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
