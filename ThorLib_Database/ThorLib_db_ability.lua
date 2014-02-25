local addon, TLDB, _ENV = ThorLib.module.setup(...)
-- ###############################################

local abilities_db

-- #############################
--  abilites

local function find_ability(find,callback)
  --FIXME assert ?
  return TLDB.find_item(abilities_db, find, callback)
end

local function handle_ability_new(handle, abilities)
--  if not abilities_db.ready then
--   return  --FIXME debug
--  end

  assert(abilities_db.ready, "Abilities Db not initialized")  --FIXME delay instead?
  
  for ability, dummyflag in pairs(abilities) do
    if not abilities_db.data[ability] then    ---FIXME make this work correctly
      local detail = Inspect.Ability.New.Detail(ability)
      if detail then
        print("New:", ability, detail.name)
        TLDB.check_item(abilities_db, ability, detail)
      else
        print("WARNING: no data for abilibty: ", ability)
        --FIXME make sure we skip these in the future
      end
    end
  end
end

P.ADD_INIT(function()
  abilities_db = TLDB.setup_db("abilities",
  {
    name = true,
    castingTime = true,
    costPlanarCharge = true,
    icon = true,
    description = true,
    autoattack = true,
    weapon = true,
    costCharge = true, 
    costEnergy = true,
    costMana = true, 
    costPower = true,
   
    id = false,
    idNew = false,
    unusable = false,
    currentCooldownBegin = false,
    currentCooldownDuration = false, 
    currentCooldownRemaining = false,
    outOfRange = false,
--    rangeMax = false,
--    rangeMin = false,
    target = false, 
  })

  Command.Event.Attach(Event.Ability.New.Add, handle_ability_new, "TLD_Event.Ability.New.Add")
end)

P.RUN_INIT("+++ DATABASE ABILITY LOADED")

-- ##########################################################################
--  exports
ThorLib.database.find_ability = find_ability


