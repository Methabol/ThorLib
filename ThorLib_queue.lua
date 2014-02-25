local addon, SHARED, _ENV = ThorLib.module.setup(...)
-- ########################################################################
DEFAULT_TIMEOUT = 10
-- ########################################################################


function create(options)
  options = options or {}
  local obj = {
    name = options.name or error("name not set", 2),
--    max_queue = options.max_queue or false,
    timeout = options.timeout or DEFAULT_TIMEOUT,
    snooze = options.snooze or false,
    type = options.type or "queue",
    --FIXME throttle
    --
    queue = {},
    block_time = false,
    current = false,
    --
    on_run = options.on_run or error("Missing on_run event", 2),
    on_timeout = options.on_timeout or false, 
  }

  
  function obj:add(data, options)
    options = options or {}
    local item = {
      data = data
    }
    
    if options.first then
      table.insert(obj.queue, 1, item)
    else
      table.insert(obj.queue, item)
    end
    obj:run()
  end
  
  function obj:unblock()
    obj.current = false
    obj.block_time = false
    obj:run()
  end
  function obj:block(item)
    if item then
      obj.current = item
    end
    obj.block_time = Inspect.Time.Real()
  end

  function obj:run()
    if obj.block_time then
      if obj.block_time + obj.timeout < Inspect.Time.Real() then
        obj.block_time = false
        if obj.on_timout then
          obj.on_timeout(obj.current)
        else
          error("queue timeout: ".. obj.name)
        end
      end
    end
    local item = table.remove(obj.queue)
    if not item then return end
    obj:block(item)
    obj.on_run(item.data, item)
    
  end



  function obj:snooze(flag)
    obj.snooze = flag   
  end
  
  return obj
end




-- ########################################################################
--  run queues
all_queues = {}

function run_all_queues()
  for queue, flag in pairs(all_queues) do
    if not queue.snooze then
      queue:run()
    end
  end
end    

Command.Event.Attach(Event.System.Update.Begin, run_all_queues, "ThorLib_queue")



-- ########################################################################
--  Exports
ThorLib.queue = {
  create = create, 
  
}








