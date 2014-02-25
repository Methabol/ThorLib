local addon, TL = ...
local P = {}
-- ###################################################################
--  saved variables handling
--
local vars_loaded = {}
local init_var_list = {}

local function add_init_vars(c_addon, func)
  local addon_id = c_addon.identifier
  print("add_init_vars:", c_addon, addon_id, func)

  if vars_loaded[addon_id] then
    func()
  else
    if not init_var_list[addon_id] then init_var_list[addon_id] = {} end
    table.insert(init_var_list[addon_id], func)
  end
end

Command.Event.Attach(Event.Addon.SavedVariables.Load.End, function(handle, name)
  vars_loaded[name] = true
  if init_var_list[name] then
    for i, func in ipairs(init_var_list[name]) do
      func()
    end
    init_var_list[name] = nil
  end
end, "ThorLib_init_vars")

local function set_defaults(list, key, defaults, overrides)
  if list[key] == nil then list[key] = {} end

  local settings = list[key]
  if defaults then
    for key, val in pairs(defaults) do
      if settings[key] == nil then
        settings[key] = val
      end
    end
  end
  if overrides then
    for key, val in pairs(overrides) do
      settings[key] = val
    end
  end
  return settings
end

-- ###################################################################
--  

add_init_vars(addon, function()
  print("ThorLib Loaded")   --FIXME
end)

-- ###################################################################
--   misc utility
--
local function vivify(list, first, ...)
  if list[first] == nil then list[first] = {} end
  if ... then
    return ThorLib.vivify(list[first], ...)
  else
    return list[first]
  end
end

local self_cached
local function get_self()
  --FIXME availability
  if self_cached then
    return self_cached
  else
    self_cached = Inspect.Unit.Detail("player")
    assert(self_cached, "can't get self data")
    return self_cached
  end
end  

function merge_table(li1, li2)   --FIXME move to thorlib
  for key,val in pairs(li2) do
    li1[key] = val
  end
  return li1
end
function copy_table(li1)    --FIXME table lib
  local new = {}
  for key, val in pairs(li1) do
    new[key] = val
  end
  return new
end


local function split_spaces(str, set_flag)   --FIXME do proper
  local r = {}
  for token in string.gmatch(str, "[^%s]+") do
    table.insert(r, token)
  end
  
  if set_flag then
    local r2 = {}
    for i, token in pairs(r) do
      r2[token] = true
    end
    return r2
  else
    return r
  end
end

local function init_value(li, field, default)
  if not li[field] then
    if type(default) == "function" then
      li[field] = func()
    else
      li[field] = default
    end
  end
  return li[field]
end

-- #####################################################
--   addon data utility
local function get_addon(atemp)
  if atemp == true then
    atemp = Inspect.Addon.Current()
  end  
  local addon_data, addon_id
  if type(atemp) == "string" then
    addon_id = atemp
    addon_data = Inspect.Addon.Detail(atemp) or error("invalid addon name"..atemp)
  elseif type(atemp) == "table" then
    addon_id = atemp.identifier or error("invalid addon data "..atemp)
    addon_data = atemp
  else
    error("Invalid addon data: "..tostring(atemp))
  end
  return addon_id, addon_data
end

-- #####################################################


local slash_callbacks = {} 
local function add_slash(cmd, first, func)
  
  local cb_data = slash_callbacks[cmd]
  
  if not cb_data then
    cb_data = {
      list = {},
      default = nil, 
    }
    
    cb_data.handler = function(handle, args)
      local r = {}
      for token in string.gmatch(args, "[^%s]+") do
        table.insert(r, token)
      end
      if r[1] and cb_data.list[r[1]] then
        cb_data.list[r[1]](r, args)
      else
        cb_data.default(r, args)
      end
    end
    
    
    slash_callbacks[cmd] = cb_data
    Command.Event.Attach(Command.Slash.Register(cmd), cb_data.handler, "ThorLib_Slash")
  end
  if first then
    cb_data.list[first] = func
  else
    cb_data.default = func
  end
end


-- #####################################################
--   exports
if not ThorLib then ThorLib = {} end

merge_table(ThorLib, {
  vivify = vivify,
  split_spaces = split_spaces, 
  set_defaults = set_defaults,
  get_self = get_self, 
  merge_table = merge_table,
  copy_table = copy_table,
  add_init_vars = add_init_vars,
  init_value = init_value,
  get_addon = get_addon,
  add_slash = add_slash,
})






