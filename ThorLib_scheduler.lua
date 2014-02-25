local addon, TL, _ENV = ThorLib.module.setup(...)
-- ###########################################################
--  settings

local DEFAULT_WATCHDOG = 0.05


-- ##################################################################
--  generic methods

local function create_scheduler_object(job_list, obj, options)
  obj = obj or {}
  options = options or {}
  
  obj.status = true

  local on_exit_list = {}
  function obj:on_exit(func, ...)
    table.insert(on_exit_list, {func, ...})
  end
  if options.on_exit then
    obj:on_exit(options.on_exit)
  end
  function obj:remove()
    job_list[obj] = nil
    for i, func_li in ipairs(on_exit_list) do
      func_li[1](unpack(func_li, 2))
    end
    obj.status = false
  end
  
  obj.snooze_flag = options.snooze or options.snooze_flag
  function obj:snooze(flag)
    obj.snooze_flag = flag
  end
  
  job_list[obj] = true
  return obj
end

-- ##################################################################
--  coro

local coro_list = {}

-- ##############################################################
--

local function run_coro(options, func, ...)
  if type(options) == "function" then
    return run_coro({}, options, func, ...)
  end

  local obj = create_scheduler_object(coro_list, {
    coro = coroutine.create(func),
  }, options)
  
  function obj:run(...)
    local okflag, message = coroutine.resume(obj.coro, ...)
    if not okflag then
      error("coroutine error: "..message)
    end
    obj.status = coroutine.status(obj.coro)
    if obj.status == "dead" then
      obj:remove()
    end
  end
  
  obj:run(...)
  
  return obj
end

local function coro_tick()
  for data, _ in pairs(coro_list) do
    local coro = data.coro
    if not data.snooze_flag then
      if Inspect.System.Watchdog() < DEFAULT_WATCHDOG then
        break
      end
      data.status = coroutine.status(coro)
      if data.status == "suspended" then
        local okflag, message = coroutine.resume(coro)
        if not okflag then
          error("Coroutine error: "..message)
        end
        if coroutine.status(coro) == "dead" then
          data:remove()
        end        
      elseif data.status == "dead" then
        data:remove()
      end
    end
  end
  
end

local function watchdog_check()
  if Inspect.System.Watchdog() < DEFAULT_WATCHDOG then
    coroutine.yield()
  end
end

-- ##################################################################
--  secure

local secure_queue = {}
local secure_flag

local function run_secure(func) ---FIXME support vararg
  if secure_flag then
    table.insert(secure_queue, func)    --object?
  else
    func()
  end
end

local function secure_enter(h)
  secure_flag = true
end
local function secure_leave(h)
  secure_flag = false
  for i, func in pairs(secure_queue) do
    func()
  end
  secure_queue = {}
end

P.ADD_INIT(function ()
  secure_flag = Inspect.System.Secure()
  Command.Event.Attach(Event.System.Secure.Enter, secure_enter, "ThorLib_scheduler")
  Command.Event.Attach(Event.System.Secure.Leave, secure_leave, "ThorLib_scheduler")
end)


-- ##################################################################
--  cron

local jobs = {}

-- ##################################################################
--  

local function create_job(options, func, ...)
  local job = {
    func = func,
    parameters = { ... },
    --
    next_time = 0,
    repeat_time = options.time,
    limit = options.limit,
    --
    snooze_flag = false
  }
  
  if options.delay then
    job.next_time = Inspect.Time.Real() + options.delay
  elseif options.time then
    job.next_time = Inspect.Time.Real() + options.time
  end
  debug_print("NOW: ", Inspect.Time.Real(), "NEXT:", job.next_time) --FIXME
  
  function job:remove()
    jobs[job] = nil
  end
  function job:snooze(flag)
    job.snooze_flag = flag
  end

  jobs[job] = true
  return job
end

-- #################################################################
--  frameticks

local function cron_tick()
  local now = Inspect.Time.Real()
  for job, flag in pairs(jobs) do
    if not( job.snooze_flag )and (  now > job.next_time ) then
      job.func(unpack(job.parameters))

      if job.repeat_time then
        job.next_time = now + job.repeat_time
      else
        job:remove()
      end
      
      if job.limit then
        job.limit = job.limit - 1
        if job.limit <= 0 then
          job:remove()
        end
      end
    end
  end
end


-- ###########################################################
--  setup shortcuts

local function run_once(delay, func, ...)
  return create_job({delay = delay}, func, ...)
end
local function run_repeat(time, func, ...)
  return create_job({time = time}, func, ...)
end


-- ###########################################################
--  setup events

P.ADD_INIT(function()
  local function tick()
    cron_tick()
    coro_tick()
  end
  Command.Event.Attach(Event.System.Update.Begin, tick, "ThorLib_scheduler")
end)
  


-- ###########################################################
-- exports
ThorLib.scheduler = {
  run_once = run_once,
  run_repeat = run_repeat,
  create_job = create_job,
  --
  run_coro = run_coro,
  watchdog_check = watchdog_check,
  check_watchdog = watchdog_check,
  --
  run_secure = run_secure,
  --
  ready = P.INIT_READY,
}


P.RUN_INIT("Scheduler init done.")  --FIXME delay?

