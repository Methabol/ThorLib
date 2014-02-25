local addon, TL, _ENV = ThorLib.module.setup(...)
-- ###########################################################






-- ###########################################################


-- ###########################################################

itemid_triggers = {}


function add_item_trigger(itemid, callback)
  local trig = vivify(itemid_triggers, itemid)
  table.insert(vivify(trig, "callbacks"), callback)
  vivify(trig, "slotcache")
  trig.start = Inspect.Time.Real()
end

function check_triggers(updates)
  local triggers = {}
  for slot, itemid in pairs(updates) do
    for _, data in pairs(itemid_triggers) do
      data.slotcache[slot] = itemid
    end
    local trig = itemid_triggers[itemid]
    if trig then
      triggers[itemid] = trig
    end
  end
  for itemid, trigger in pairs(triggers) do
    itemid_triggers[itemid] = nil
    for i, callback in pairs(trigger.callbacks) do
      callback(trigger.slotcache)
    end
  end
end

function event_item_slot(h, updates)
  check_triggers(updates)
end

function event_item_update(h, updates)
  check_triggers(updates)
end

function split_item(itemid, newstack, callback)

  add_item_trigger(itemid, function(slotcache)
    handle_split(itemid, slotcache, callback)
  end)

  Command.Item.Split(itemid, newstack)    --FIXME throttle?
end

function handle_split(old_itemid, slotcache, callback)
  debug_print("Split finished")
  local old_detail = Inspect.Item.Detail(old_itemid)
  for slot, newitem in pairs(slotcache) do
    if newitem and newitem ~= old_itemid then
      local new_detail = Inspect.Item.Detail(newitem)
      if new_detail.type == old_detail.type then
        callback(newitem, new_detail)
      end
    end
  end
end



Command.Event.Attach(Event.Item.Slot, event_item_slot, "ThorLib_inventory")
Command.Event.Attach(Event.Item.Update, event_item_update, "ThorLib_inventory")


-- ###########################################################
-- exports

ThorLib.inventory = {
  split_item = split_item, 

}


