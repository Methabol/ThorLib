local addon, TLDB, _ENV = ThorLib.module.setup(...)
-- ###############################################

local buffs_db

-- ###################################################
-- buffs


local function find_buff(find,callback)
  return TLDB.find_item(buffs_db, find, callback)
end

local function handle_buff(handle, unit, buffs)
--  if not buffs_db.data then
--    return    --FIXME debug
--  end
  --FIXME ready?
  for buffid, bufftype in pairs(buffs) do
    if bufftype and not buffs_db.data[bufftype] then --FIXME check bufftype boolean
      local detail = Inspect.Buff.Detail(unit, buffid)
      debug_print("Found new buff:", bufftype, detail.name)
      TLDB.check_item(buffs_db, bufftype, detail)
    end
  end  
end

P.ADD_INIT(function ()
  buffs_db = TLDB.setup_db("buffs",
  {
    name = true,
    description = true,
    icon = true,
    abilityNew = true, 
    duration = true,
    noncancelable = true,
    stack = true,             --FIXME
    debuff = true,
    curse = true,
    disease = true,
    expired = true,
    poison = true, 
    rune = true, 

    
    begin = false,
    remaining = false,
    type = false,
    id = false,
    caster = false,
    descriptionComplete = false,
  })
  Command.Event.Attach(Event.Buff.Add, handle_buff, "TLD_Event.Buff.Add")
end)


P.RUN_INIT("+++ DATABASE BUFF LOADED")

-- #############################################################
--  exports
ThorLib.database.find_buff = find_buff

