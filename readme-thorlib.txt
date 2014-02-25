





=== main ===

ThorLib.vivify(list, first, ...)

ThorLib.set_defaults(var, key, defaults_list, overrides_list)

ThorLib.add_init_vars(addon_id, func)

vivify = vivify,
get_self = 
old = ThorLib.merge_table(old, new)
copy =  ThorLib.copy_table(old)

ThorLib.add_init_vars(addon, func)

debug_print = ThorLib.init_debug(addon, [consolename])
  

local debug_print = ThorLib.init_debug(addon)     -- creates a debug function

=== coro ===
ThorLib.scheduler.watchdog_check()
ThorLib.scheduler.run_coro(func, ...)



=== events ===


ThorLib.events.register(tag, init_func)

ThorLib.events.attach(tag, tagname, func)

ThorLib.events.execute(tag, ...)


=== roles ====


ThorLib.roles.current()
  -- returns current role
Command.Event.Attach(Event.ThorLib.Role.Change, func, "tag")
  -- attaches an event to func






=== reset ===
Handle daily and weekly resets.

ThorLib.reset.init()                    -- initializes module
ThorLib.reset.ready()
ThorLib.reset.tokens()                  -- returns daily and weekly tokens

Event.ThorLib.Reset.Daily(daily_token)
Event.ThorLib.Reset.Weekly(weekly_token)

=== Cache ===
ThorLib.cache.

Event.ThorLib.Unit.Castbar(units)
ThorLib.cache.castbar(unit)

Event.ThorLib.Buff.Add(unit, buffs)
Event.ThorLib.Buff.Change(unit, buffs)
Event.ThorLib.Buff.Remove(unit, buffs)

ThorLib.cache.buff(unit, buffid)

==== Database ============

ThorLib.database


FIXME

=== ZONE ====

FIXME


=== ui ===
ThorLib.ui.add_draggable(frame, handler, targetframe)
-- handler:  function(diffx, diffy)
   -- or     { x = NUM, y = NUM }







