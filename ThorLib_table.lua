local addon, TL, _ENV = ThorLib.module.setup(...)
-- ###########################################################


-- ###########################################################
--  copy & copy_deep
--[[
  ThorLib.copy(table)                 -- copies table
  ThorLib.copy_deep(table, depth)     -- copies table to depth
]]--


local function copy(li1)    --FIXME replace copy_table from main
  local new = {}
  for key, val in pairs(li1) do
    new[key] = val
  end
  return new
end

local DEFAULT_DEPTH = 5

function copy_deep(tab, depth, refcache)
  refcache = refcache or {}
  depth = depth or DEFAULT_DEPTH
  if tonumber(depth) then
    depth = depth - 1
    if depth <= 0 then
      depth = false
    end
  end
  
  local new = {}
  for key, val in pairs(tab) do
    if depth and (type(val) == "table") then
      local newvalue = refcache[val]
      if not newvalue then
        newvalue = copy_deep(val, depth, refcache)
        if depth == true then
          refcache[val] = newvalue
        end
      end
      new[key] = newvalue
    else
      new[key] = val
    end
  end
  return new
end




-- ###########################################################
--  Compare
--  identical_flag, new_keys, removed_keys, changed_keys = ThorLib.table.compare(new, old)


local function compare(old, new)
  if old == new then return
    true, {}, {}, {}
  end
  local new_copy = copy(new)
  local removed = {}
  local changed = {}
  
  local identical = true
  for key, val in pairs(old) do
    if val == new[key] then
      new_copy[key] = nil
    else
      identical = false
      if new[key] == nil then
        removed[key] = val
      else
        changed[key] = new[key]
      end
    end
  end
  if next(new_copy) then
    identical = false
  end

  return identical, new_copy, changed, removed
end

local function merge(old, new, keepflag)    --FIXME keepflag
  for key, val in pairs(new) do
    old[key] = val
  end
  return old
end


-- ###########################################################






-- ###########################################################
-- exports

ThorLib.table = {
  copy        = copy, 
  compare     = compare,
  merge       = merge,
}


