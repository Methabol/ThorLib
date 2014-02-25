local addon, TL, _ENV = ThorLib.module.setup(...)
-- ######################################################################
--   draggable


local function add_draggable(frame, handler, target_frame)
  if not target_frame then
    target_frame = frame
  end

  if type(handler) == "table" then
    local pos = handler
    handler = function(diff_x, diff_y)
      pos.x = pos.x + diff_x
      pos.y = pos.y + diff_y
      target_frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", pos.x, pos.y)
    end
  end

  local draggable = true
  function frame:draggable(flag)
    if flag ~= nil then
      draggable = flag
    end
    return draggable
  end

  local down_flag = false
  frame:EventAttach(Event.UI.Input.Mouse.Left.Down, function() down_flag = true end, "tcpu")
  frame:EventAttach(Event.UI.Input.Mouse.Left.Up, function() down_flag = false end, "tcpu")

  local last_x, last_y
  local function mouse_move(h, _, x, y)
    if down_flag and draggable then
      local diff_x = x - last_x
      local diff_y = y - last_y
      handler(diff_x, diff_y)
    end
    last_x = x
    last_y = y
  end
  frame:EventAttach(Event.UI.Input.Mouse.Cursor.Move, mouse_move, "tcpu")
end




-- ######################################################################
--  exports
ThorLib.table.merge(ThorLib.ui, {
  add_draggable = add_draggable
})

