-- Minimal stub config to prevent startup errors when task_missions system is not installed.

TaskMissions = TaskMissions or {}
TaskMissions.tasks = TaskMissions.tasks or {}

function TaskMissions.getUseTaskByActionId(aid) return nil end
function TaskMissions.getCurrentChainTask(player) return nil end
function TaskMissions.getState(player, task) return 0 end
function TaskMissions.getProgress(player, task) return 0 end
function TaskMissions.setProgress(player, task, value) return true end
function TaskMissions.tryComplete(player, task) return false end

function TaskMissions.getTaskByIdOrName(param) return nil end
function TaskMissions.buildList(player) return "No missions configured." end

function TaskMissions.accept(player, task) return false end
function TaskMissions.cancel(player, task) return false end
function TaskMissions.claim(player, task) return false end
