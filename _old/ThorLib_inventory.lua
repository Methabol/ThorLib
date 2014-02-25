local addon, TL, _ENV = ThorLib.module.setup(...)
-- ###########################################################


local scanlist = {
  Utility.Item.Slot.Inventory(),
  Utility.Item.Slot.Bank(),
  Utility.Item.Slot.Quest(), 
  Utility.Item.Slot.Equipment(),
  Utility.Item.Slot.Wardrobe(),
  --FIXME handle guildbank
}

-- ###########################################################


local slots_list = {}
local item_data_list = {}
local scan_complete = false

local dispatch = {}                   -- dispatch functions for generated events

-- ###########################################################

ThorLib.add_init_vars(addon, function()
  if DEBUG then    
    TL.debug_char.slots_list = slots_list
    TL.debug_char.item_list = item_data_list
  end
end)

-- ###########################################################


--FIXME space out scanlist
local function scan_inventory()
  local test_slots = Utility.Item.Slot.Inventory(1, 1)
  debug_print("=== Items Scan Initialized ===", test_slots)
  while true do
    local t = Inspect.Item.List(test_slots)--FIXME slots by slots
    if t ~= nil then
      debug_print("=== items found: ", test_slots, " = ", t)
      break
    else
      coroutine.yield()
    end
  end
  debug_print("=== Items Scan Started ===")


  for i, scanstring in ipairs(scanlist) do
    local scanned = Inspect.Item.List(scanstring)
    P.add_item_job("slot", scanned, false)
    ThorLib.scheduler.watchdog_check()
  end

  debug_print("=== Items Scan Done ===")
  scan_complete = true
end

ThorLib.scheduler.run_coro(scan_inventory)


-- ###########################################################
--  translate raw events

-- ########################################
--   handle item events

  -- type =      MOVE/REMOVE/ADD/CHANGE
  -- itemid =    id of item
  -- slot =
  -- slot_from = original slot for MOVE
  -- data =      data for current item, or data for old item if REMOVE
  -- changed =   changed fields for CHANGE
  -- removed =   removed fields for REMOVE


-- ########################################

local item_jobs = {}

local function run_item_jobs()
  while true do
    ThorLib.scheduler.watchdog_check()
    local job = table.remove(item_jobs, 1)
    if not(job) then
      coroutine.yield()
    else
      if job.jobtype == "slot" then
        local old_slots = {}
        for slot, itemid in pairs(job.updates) do
          old_slots[slot] = slots_list[slot]
          slots_list[slot] = itemid
          if itemid and not(item_data_list[itemid]) then
            item_data_list[itemid] = Inspect.Item.Detail(itemid)
          end
          ThorLib.scheduler.watchdog_check()
        end
        if job.send_event_flag then
          dispatch.item_slot(job.updates, old_slots)
        end
      elseif job.jobtype == "update" then
        local old_item_data = {}
        for slot, itemid in pairs(job.updates) do
          old_item_data[itemid] = item_data_list[itemid]
          item_data_list[itemid] = Inspect.Item.Detail(itemid)
          ThorLib.scheduler.watchdog_check()
        end
        if job.send_event_flag then
          dispatch.item_update(job.updates, old_item_data)
        end
      else
        error(string.format("Invalid jobtype: %s", job.jobtype))
      end
    end
  end
end

P.ADD_INIT(run_item_jobs)

function P.add_item_job(jobtype, updates, send_event_flag)
  table.insert(item_jobs, {             
    jobtype = jobtype,
    updates = updates,
    send_event_flag = send_event_flag,
  })
end  



local function event_item_slot(handle, updates)
--  if not scan_complete then error "FIXME" end       --FIXME delay instead
  P.add_item_job("slot", updates, true)
end
  
local function event_item_update(handle, updates)
--  if not scan_complete then error "FIXME" end       --FIXME delay instead
  P.add_item_job("update", updates, true)
end

-- ###########################################################
local count_items = {}
local recount_cache = {}
--local count_slots = {}

local function recount_loop()
  while not scan_complete do
    coroutine.yield()
  end
  while true do
    if not next(recount_cache) then
      coroutine.yield()
    else
      local recount = recount_cache
      recount_cache = {}

      for itype, counter in pairs(recount) do
        counter.slots = {}
        counter.items = {}
      end
      
      for slot, itemid in pairs(slots_list) do
        local itemdata = item_data_list[itemid or ""]
        local counter = recount[itemdata.type or ""]
        if counter then
          counter.slots[slot] = itemid
          counter.items[itemid] = itemdata
          counter.detail = itemdata
        end        
        ThorLib.scheduler.watchdog_check()
      end
      for itype, counter in pairs(recount) do
        counter:do_recount()
      end
      --FIXME dispatch events
    end
  end
end
ThorLib.scheduler.run_coro(recount_loop)




local function add_counter(itype)   --FIXME add remove with tag
  local counter = count_items[itype]
  if not counter then
    counter = {
      count = 0,
      slots = {},
      items = {},
      itype = itype, 
    }

    function counter:do_recount()
      local total = 0
      local old_total = counter.count
      for itype, idata in pairs(items) do
        total = total + (idata.stack or 1)
      end
      counter.count = total
      if old_total ~= total then
        --FIXME dispatch event
      end
    end

    count_items[itype] = counter
  end
  recount_cache[itype] = counter
  return counter
end

local function counter_event_slot(h, updates, old_slots)
  for slot, itemid in pairs(updates) do
    
  end
end

local function counter_event_update(h, updates, old_data)
  for slot, itemid in pairs(updates) do
  end
end

-- ###########################################################

P.ADD_INIT(function()
  -- FIXME init dependecies
  dispatch.item_update  = Utility.Event.Create("ThorLib", "Inventory.Update")
  dispatch.item_slot    = Utility.Event.Create("ThorLib", "Inventory.Slot")

  Command.Event.Attach(Event.Item.Update, event_item_update, "ThorLib_Inventory")
  Command.Event.Attach(Event.Item.Slot,   event_item_slot,   "ThorLib_Inventory")

  dispatch.counter = Utility.Event.Create("ThorLib", "Inventory.Counter")

  
end)

-- ###########################################################
if false then --FIXME old hook s
  Command.Event.Attach(Event.Item.Update, event_item_update, "ThorLib_Inventory")
  Command.Event.Attach(Event.Item.Slot,   event_item_slot,   "ThorLib_Inventory")
  
  dispatch.add     = Utility.Event.Create("ThorLib", "Inventory.Add")
  dispatch.move    = Utility.Event.Create("ThorLib", "Inventory.Move")
  dispatch.remove  = Utility.Event.Create("ThorLib", "Inventory.Remove")
  dispatch.change  = Utility.Event.Create("ThorLib", "Inventory.Change")

  dispatch.item_update = Utility.Event.Create("ThorLib", "Item.Update")
  dispatch.item_slot   = Utility.Event.Create("ThorLib", "Item.Slot")
 
  
  -- counter
  dispatch.counter = Utility.Event.Create("ThorLib", "Inventory.Counter")
  Command.Event.Attach(Event.ThorLib.Inventory.Add, counter_add, "ThorLib_Inventory")
  Command.Event.Attach(Event.ThorLib.Inventory.Change, counter_change, "ThorLib_Inventory")
  Command.Event.Attach(Event.ThorLib.Inventory.Remove, counter_remove, "ThorLib_Inventory")
  Command.Event.Attach(Event.ThorLib.Inventory.Move, counter_move, "ThorLib_Inventory")--fixme
  ---- 
--  Command.Event.Attach(Event.ThorLib.Item.Slot, counter_slot, "ThorLib_Inventory")--fixme
--  Command.Event.Attach(Event.ThorLib.Item.Update, counter_slot, "ThorLib_Inventory")--fixme
  
  
end

P.RUN_INIT()

-- ###########################################################
-- exports
ThorLib.inventory = {
  create_counter = create_counter,
  add_counter = add_counter, 
  
  
}



