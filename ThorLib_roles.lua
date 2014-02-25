local addon, TL, _ENV = ThorLib.module.setup(...)




-- ###########################################################
--  Roles change

local roles_event_dispatch

local current_role = false
local current_role_str = false
local wait = Inspect.Time.Real() + 3

local wait = false --FIXME


local function check_role_change()
  if wait then
    if Inspect.Time.Real() < wait then
      return
    else
      wait = false
    end
  end
    
 -- check_role_change_old()
  local new_role = Inspect.TEMPORARY.Role()
  if new_role and new_role ~= current_role then
    current_role = new_role
    current_role_str = string.format("role%02i", new_role)
    roles_event_dispatch(current_role, current_role_str )
  end
end





local function current()
  return current_role, current_role_str
end

-- ################################
--  init
local init_done
local function init()
  if init_done then return end
  Command.Event.Attach(Event.System.Update.Begin, check_role_change, "thorlib_system_update")
  roles_event_dispatch = Utility.Event.Create("ThorLib", "Role.Change") --FIMXE init

  init_done = true
end

init() --fIXME

-- ################################
--  exports

if not ThorLib then ThorLib = {} end

ThorLib.roles = {
  init = init,
  ready = function() return init_done end,
  current = current,
}

-- ThorLib.roles = {} --FIXME


