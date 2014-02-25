local addon, TL, _ENV = ThorLib.module.setup(...)
-- ######################################################################


local events_trans = {
    left = Event.UI.Input.Mouse.Left.Down,
}

--[[######################################################################

  redirect:
    text
    bg
]]

function add_methods(frame, redirect)
  if not frame.TL then frame.TL = {} end
  local TL = frame.TL

  redirect = redirect or {}
  for i, key in pairs({ "bg", "text"}) do
    if not redirect[key] then
      redirect[key] = frame
    end
  end

-- ######################################
  
  function frame:set_color(bg, text)
    if bg then
      redirect.bg:SetBackgroundColor(ThorLib.ui.get_color(bg))
      TL.color_bg = bg
    end
    if text then
      redirect.text:SetTextColor(ThorLib.ui.get_color(text))
      TL.color_text = text
    end
  end

-- ######################################

  function frame:add_mouse_events(name, callback)
    local callbacks
    if type(name) == "table" then
      callbacks = name
    else
      callbacks = { [name] = callback }
    end
    
    for ename, func in pairs(callbacks) do
      local event = events_trans[ename] or
        error("Invalid event name: ".. ename)
      frame:EventAttach(event, func, "ThorLib_UI")  --FIXME current addon?
    end
  end    
  
-- ######################################
  function frame:draggable(handler, target)
    ThorLib.ui.add_draggable(frame, handler, target)
  end
  
  
  
end
















-- ######################################################################
--  exports
ThorLib.table.merge(ThorLib.ui, {
  add_methods = add_methods, 
  
})