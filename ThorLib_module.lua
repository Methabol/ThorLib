local addon, TL = ...
-- #####################################################################
--  default settings


local DEFAULT_DEBUG_CONSOLE = "ThorMin"
local DEBUG_FIELD = "_debug"

local storage_aliases = { --FIXME  remove oboslete aliases
  character = { "C", "character", "char", "c", "CHARACTER", "CHAR", "C" },
  shard =     { "S", "shard", "SHARD", "s", "S"},
  account =   { "A", "account", "ACCOUNT", "a", "A"},
  global =    { "G", "global", "GLOBAL", "g", "G"},
}

local debug_storage_aliases = {
  character = { "DC", "DEBUG_CHARACTER", },
  shard =     { "DS", "DEBUG_SHARD", },
  account =   { "DA", "DEBUG_ACCOUNT", },
  global =    { "DG", "DEBUG_GLOBAL", },
}


-- #####################################################################
-- debug_print placeholder
local function debug_print(...)
  --FIXME
end

-- #####################################################################

local vars_loaded = {}
local vars_queued_init_list = {}
local vars_storage = {}
local vars_coro_handles = {}
local debug_storage = {}

local consoles
local debug_queue = {}
local debug_console_id = false

-- #####################################################################
--  storage and saved variables
--
-- get_storage(addon)               -- returns storage for addon, creating if needed
-- load_storage(addon)              -- links storage with saved vars
-- add_init_vars(addon, func)       -- runs func if/when saved vars from addon are ready

local function get_storage(atemp)
  local addon_id, addon_data = ThorLib.get_addon(atemp)
  local storage = vars_storage[addon_id]
  if not storage then
    storage = {}
    vars_storage[addon_id] = storage
    ThorLib.vivify( vars_coro_handles, addon_id )
    ThorLib.vivify( vars_queued_init_list, addon_id)
    -- setup debug storage
    debug_storage[addon_id] = {}
    for tag, list in pairs(debug_storage_aliases) do
      local temp = {}
      debug_storage[addon_id][tag] = temp
      for i, field in ipairs(list) do
        storage[field] = temp
      end
    end
--FIXME    addon_data.shared.STORAGE = storage 
  end
  return storage
end

local function load_storage(atemp)
  local addon_id, addon_data = ThorLib.get_addon(atemp)
  local storage = get_storage(addon_data)
  local ds = debug_storage[addon_id]

  for name, vtype in pairs(addon_data.toc.SavedVariables) do
    if not _G[name] then _G[name] = {} end
    local var = _G[name]
    
    for i, alias in pairs(storage_aliases[vtype]) do
  --    debug_print(string.format("LOAD STORAGE: %s %s %s '%s'", addon_id, name, vtype, alias))
      storage[alias] = var
    end
    -- debug storage
    if debug_console_id then    --FIXME fix if consoles are set after saved vars
      var[DEBUG_FIELD] = ds[vtype]   
    else
      var[DEBUG_FIELD] = nil
    end
  end
end

local function add_init_vars(atemp, func)
  local addon_id, addon_data = ThorLib.get_addon(atemp)
  local storage = get_storage(addon_id)
  
  if vars_loaded[addon_id] then
    load_storage(name)
    debug_print("@@@ running right away: ".. func)
    local handle = ThorLib.scheduler.run_coro(func)
  else
    table.insert(vars_queued_init_list[addon_id], func )
  end
  return storage
end

local function var_load_event(h, name)
  -- init vars
  vars_loaded[name] = true
  if vars_queued_init_list[name] then
    debug_print("@@@ running init vars: "..name)
    load_storage(name)  
    for i, func in ipairs(vars_queued_init_list[name]) do
      debug_print("@@@ calling func: ", func)
      local handle = ThorLib.scheduler.run_coro(func)
    end
    vars_queued_init_list[name] = nil
  end
end

Command.Event.Attach(Event.Addon.SavedVariables.Load.End, var_load_event, "ThorLib_INIT")


-- ######################################################################
-- DEBUG

local function debug_run_queue()
  if not debug_console_id then
    if consoles then
      debug_queue = {}
    end
    return
  end

  for addon_id, lines in pairs(debug_queue) do
    for i, line in ipairs(lines) do
      local str = string.format("[%s]", addon_id)
      for i,s in ipairs(line) do
        str = str .. " " .. tostring(s)
      end
      Command.Console.Display(debug_console_id, true, str, false)

      --FIXME watchdog  + clear lines[i]
    end
    debug_queue[addon_id] = nil
  end
end

local function debug_worker()
  if consoles then
    debug_run_queue()    
  else
    local clist = Inspect.Console.List()     
    if not clist then return end

    consoles = {}
    for id in pairs(clist) do
      consoles[id] = Inspect.Console.Detail(id)
      if consoles[id].name == DEFAULT_DEBUG_CONSOLE then
        debug_console_id = id
      end
    end
  end
end
Command.Event.Attach(Event.System.Update.Begin, debug_worker, "THORLIB_MODULE_DEBUG" )
debug_worker()

local function debug_print_queue(atemp, ...)
  local addon_id, addon_data = ThorLib.get_addon(atemp)
  table.insert(ThorLib.vivify(debug_queue, addon_id), { ... })
  debug_run_queue()    
end



-- #####################################################################

local errfunc = function(a, b, c)
  error(string.format("not allowed to set variables '%s' '%s'", b, c))
end


local function setup(addon_data, shared)
  local addon_id, addon_data = ThorLib.get_addon(addon_data)

  local P = {
    ThorLib = ThorLib, 
    vivify = ThorLib.vivify,
    
  }
  --FIXME setup default imports
  local meta = {
    __index = _G,
--FIXME add strict?    __newindex = errfunc,
  }
  P.P = P               --FIXME maybe remove?
  P.PRIVATE = P
  

  -- setup storage
  local storage = get_storage(addon_data)
  shared.STORAGE = storage
  P.STORAGE = storage
  P.S = storage
  function P.INIT_VARS(func)
    return add_init_vars(addon_data, func)
  end
  shared.INIT_VARS = P.INIT_VARS
  
  --fixme ADD_INIT RUN_INIT INIT_READY
  local init_list = {}
  local init_started = false
  function P.ADD_INIT(func, ...)    --FIXME check take args or no?
    table.insert(init_list, func)
  end
  function P.RUN_INIT(...)
    if init_started then return end
    init_started = true
    --FIXME check handles for ready
    for i, func in ipairs(init_list) do
      ThorLib.scheduler.run_coro(func)   --FIXME run better
    end
    --FIXME message from ...
  end
  function P.INIT_READY(...)
    return true --FIXME
  end
  
  
  -- setup debug
  function P.debug_print(...)         
    debug_print_queue(addon_data, ...)
  end
  --fixme also in shared?
  

  -- final setup  
  setmetatable(P, meta)
  setfenv(2, P)     --FIXME 5.2

  return addon_data, shared, P, storage
end












-- #####################################################################
--  exports
TL.module = {   --FIXME remove later
}

ThorLib.module = {
  setup = setup,
}

