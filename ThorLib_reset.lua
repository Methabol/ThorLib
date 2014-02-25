local addon, TL, _ENV = ThorLib.module.setup(...)
-- #######################################################
--   setup

local daily_offset  = 11              -- offset for daily reset in hours
local weekly_offset  =  3             -- offset for weekly reset in days

-- #######################################################

local dreset = 60 * 60 * daily_offset
local wreset = dreset + 60*60*24 * weekly_offset
--
local current_time
local current_daily
local current_weekly
--
local daily_event_func
local weekly_event_func

local function check_reset()
  local stime = Inspect.Time.Server()
  if stime ~= current_time then
    current_time = stime
    local dold = current_daily
    local wold = current_weekly    
    current_daily = os.date("!%Y-%m-%d", stime - dreset  )
    current_weekly = os.date("!%U", stime - wreset )

    if dold and dold ~= current_daily then
      daily_event_func(current_daily)
    end
    if wold and wold ~= current_weekly then
      weekly_event_func(current_weekly)
    end
  end
  return current_daily, current_weekly
end



local init_done
local function init()
  if init_done then return end
  daily_event_func = Utility.Event.Create("ThorLib", "Reset.Daily")
  weekly_event_func = Utility.Event.Create("ThorLib", "Reset.Weekly")
  Command.Event.Attach(Event.System.Update.Begin, function() check_reset() end, "ThorLib_reset")
  init_done = true
end
init()

-- ######################################
--  exports

if not ThorLib then ThorLib = {} end
ThorLib.reset = {
  init = init,
  ready = function() return init_done end,
  tokens = check_reset,  
}

TL.reset = {}



