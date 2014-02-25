local addon, TLDB, _ENV = ThorLib.module.setup(...)
-- ###############################################

local databases = {}
local DB = {} --FIXME obsolete?

-- #############################################
--  database functions

P.INIT_VARS(function()
  S.C.test2 = 5            
end)

local function init_db_vars(db, name)
  debug_print("$$$ running init_db_vars "..name)
  db.data   = ThorLib.vivify(S.G, db.storage_data)
  db.lookup = ThorLib.vivify(S.G, db.storage_lookup)   --FIXME don't save
  S.G.test = (S.G.test or 0) + 1
  S.C.test = (S.G.test or 0) + 1
  
--  ThorLib_db_saved_global[db.storage_debug] = nil

      --fixme generate lookup by coro
    
--      for id, _ in pairs(db.data) do
--        TLDB.check_item(db, id)    --FIXME watchdog check
--        ThorLib.scheduler.watchdog_check()
--      end
  db.ready = true   --FIXME better
  debug_print("$$$ finished init_db_vars "..name)
end


function TLDB.setup_db(name, fields)
  databases[name] = {
    fields = fields,
    name = name, 
    storage_data = string.format("known_%s", name),
    storage_lookup = string.format("known_%s_lookup", name),      --FIXME
    storage_debug = string.format("a_unknown_fields_%s", name),   --FIXME
    data = nil,
    lookup = nil,
    delayed = {},
  }
--  ThorLib.init.add_init_vars(addon, init_db_vars, databases[name], name)
  P.INIT_VARS(function()
    init_db_vars(databases[name], name)
  end)

  return databases[name]
end
--FIXME add tag to callbacka + add clear

function TLDB.find_item(db, find, callback)
  local return_data

  if not db.data then
    return  --FIXME temp debug
  end
  
  -- lookup by id
  local data = db.data[find]
  local namedata = db.lookup[find]
  if data then
    return_data = { [find] = data }
  elseif namedata then
    return_data = {}
    for id, _ in pairs(namedata) do
      return_data[id] = db.data[id]
    end
  end      
  
  if callback then
    --FIXME makes sure we unregister callbacks if the original call's trigger is removed
    if return_data then
      callback(return_data)
    else
      table.insert( ThorLib.vivify(db.delayed, find), callback) 
    end
  end

  --FIXME return object instead
  return return_data
end

function TLDB.check_item(db, id, newdata)
  local data = ThorLib.vivify(db.data, id)  
  if newdata then
    data.raw = newdata
  end
  
  if data.raw then
    for key, flag in pairs(db.fields) do
      if flag and data.raw[key] then
        data[key] = data.raw[key]
        data.raw[key] = nil
      elseif flag == false then
        data.raw[key] = nil
      end        
    end
    
    for key, val in pairs(data.raw) do
--FIXME      ThorLib.vivify(TLDB.DEBUG_GLOBAL, db.storage_debug)[key] = { value = val, id = id }
    end
    if not next(data.raw) then 
    --  data.raw = nil
    end
  end
  
  -- update lookup
  if data.name then
    ThorLib.vivify(db.lookup, data.name)[id] = true   
  else
    print(string.format("WARNING no name: '%s'", id))   --FIXME
  end

  --- run delayed
  for _, check in pairs({id, data.name}) do
    local callback_list = db.delayed[check]
    if callback_list then
      for _, fn in pairs(callback_list) do
        fn( TLDB.find_item(db, check) )
      end
      db.delayed[check] = nil
    end
  end
end


--FIXME add castbar?


-- #################################################
--  initialization
local init_started      -- init started
local init_vars_ready   -- saved vars ready for init
local init_done         -- init completed

local function do_init_vars()
  if not init_vars_ready then return end
  if not init_started then return end
  if init_done then return end
  
  if not ThorLib_db_saved_global then ThorLib_db_saved_global = {} end
  
  ThorLib.scheduler.run_coro(function()
    for name, db in pairs(databases) do
    end
    init_done = true
  end)
end

--Command.Event.Attach(Event.Addon.SavedVariables.Load.End, function(handle, name)
--  if name ~= addon.identifier then return end
--  init_vars_ready = true --FIXME after?
--  do_init_vars()
--end, "TL_database_load")


local function init()
  if init_started then return end
  init_started = true
--  ability_db_init()
--FIXME old  buff_db_init()
  do_init_vars()
end

local function ready()
  return init_done
end



-- #################################################
--  init
P.RUN_INIT("+++ DATABASE LOADED")


-- #################################################
--  exports

ThorLib.database = {
  init = init,    --FIXME check init/ready
  ready = ready,
}



