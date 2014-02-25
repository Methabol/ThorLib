local addon, TL, _ENV = ThorLib.module.setup(...)

local TLC = {}  --FIXME remove

-- #################################################

local dispatch = {}
local unit_cache = {}

-- #################################################
--  availability

local function av_set( units, set)
  for unit, spec in pairs(units) do
    local data = unit_cache[unit]
    if data then
      data.availabity = set
    else
      unit_cache[unit] = {
        availabity = set,
        buffs = {},
      }
    end
  end
end
local function av_part(handle, units)
  av_set(units, "full")
end

local function av_part(handle, units)
  av_set(units, "partial")
end

local function av_none(handle, units)
  for unit, spec in pairs(units) do
    unit_cache[unit] = nil
  end
end

local function init_avail()
  Command.Event.Attach(Event.Unit.Availability.Full,    av_full, "TL_av_full")
  Command.Event.Attach(Event.Unit.Availability.Partial, av_part, "TL_av_part")
  Command.Event.Attach(Event.Unit.Availability.None,    av_none, "TL_av_none")
end

-- #################################################
--  castbar

local castbar_func

local function castbar_event(handle, units)
  for unit, flag in pairs(units) do
    unit_cache[unit].castbar = nil    --FIXME check
  end
  castbar_func(units)  
end

function TLC.castbar(unit)
  local udata = unit_cache[unit]
  if not udata then return end    -- FIXME check
  udata.castbar = udata.castbar or Inspect.Unit.Castbar(unit)
  return udata.castbar
end

local thandle_c
function TLC.init_castbar()
  castbar_func, thandle_c = Utility.Event.Create("ThorLib", "Unit.Castbar")
  Command.Event.Attach(Event.Unit.Castbar, castbar_event, "TL_castbar")
end

-- ######################################################
--  buffs
local function buff_clear(unit, buffs)
  local bdata = unit_cache[unit].buffs
  for buffid, bufftype in pairs(buffs) do
    bdata[buffid] = nil
  end
end

local function buff_add(handle, unit, buffs)
  buff_clear(unit, buffs)
  dispatch.buff_add(unit, buffs)
end

local function buff_change(handle, unit, buffs)
  buff_clear(unit, buffs)
  dispatch.buff_change(unit, buffs)
end

local function buff_remove(handle, unit, buffs)
  buff_handle(unit, buffs)
  dispatch.buff_remove(unit, buffs)
end

local function buff(unit, buffid)
  local udata = unit_cache[unit] or {}
  local bdata = udata.buffs or {}
  local detail = bdata[buffid]
  if not detail then
    detail = Inspect.Buff.Detail(unit, buffid)
    bdata[buffid] = detail
  end
  return detail
end

local function init_buff()
  dispatch.buff_add    = Utility.Event.Create("ThorLib", "Buff.Add")
  dispatch.buff_change = Utility.Event.Create("ThorLib", "Buff.Change")
  dispatch.buff_remove = Utility.Event.Create("ThorLib", "Buff.Remove")
  
  Command.Event.Attach(Event.Buff.Add,    buff_add,    "TL_buff_add")
  Command.Event.Attach(Event.Buff.Change, buff_change, "TL_buff_change")
  Command.Event.Attach(Event.Buff.Remove, buff_remove, "TL_buff_remove")
  --FIXME Event.Buff.Description?
end

-- ######################################################
--  init

local cache_ready
local function init()
  if cache_ready then return end
  init_avail()
  TLC.init_castbar()
  init_buff()
  cache_ready = true
end

local function ready()
  return cache_ready
end
  

-- ######################################################
--  exports
if not ThorLib then ThorLib = {} end
ThorLib.cache = {
  init = init,
  ready = ready,
  castbar = TLC.castbar,
}

