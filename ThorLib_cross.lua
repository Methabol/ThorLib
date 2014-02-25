local addon, SHARED, _ENV = ThorLib.module.setup(...)

-- ####################################################################


local self_uid = Inspect.Unit.Lookup("player")


-- ####################################################################

local cross_meta_data

-- ####################################################################
INIT_VARS(function()
  cross_meta_data = vivify(S.G, "cross_meta_data")
  update_cross_meta()  
end)


-- ####################################################################

function update_cross_meta()
  if not cross_meta_data then return end
  
  local self_meta = vivify(cross_meta_data, self_uid)

  local detail = Inspect.Unit.Detail("player")  --FIXME check available
  self_meta.name = detail.name or "UNKNOWN"
  self_meta.shard = detail.shard or "UNKNOWN"     --FIXME never unknown
  self_meta.last_updated = Inspect.Time.Server()
  self_meta.uid = self_uid
  self_meta.detail = detail
  
  
  return self_meta  
end

function avail_full(h, units)
  for uid in pairs(units) do
    if uid == self_uid then
      update_cross_meta()
      Command.Event.Detach(Event.Unit.Availability.Full, avail_full, "ThorLib_Cross")
    end
  end
end


Command.Event.Attach(Event.Unit.Availability.Full, avail_full, "ThorLib_Cross")



-- ####################################################################


--FIXME options: include_self
function load_cross(var, field, options)
  if not options then options = {} end
  
  local all_data = ThorLib.vivify(var, field)
  
  local self_data = ThorLib.vivify(all_data, self_uid)
  
  local cross_data = {}
  for uid, data in pairs(all_data) do
    if uid ~= self_uid or options.include_self then
      cross_data[uid] = data
    end
    local metadata = cross_meta_data[uid] or {}
    setmetatable(data, {
      __index = {
        _meta = metadata,
      }
    })

    if options.meta == true then
      data._meta = metdata
    elseif type(options.meta) == "table" then
      for key, flag in pairs(options.meta) do
        if flag then
          data[key] = metadata[key]
        end
      end
    end
    if options.init then
      for key, val in pairs(options.init) do
        if data[key] == nil then
          data[key] = val
        end
      end
    end
    
    
  end

    
  
  
  
  return self_data, cross_data
end









-- ####################################################################





-- ####################################################################
-- Export
ThorLib.cross = {
  load_cross = load_cross, 
  
  
  
}





