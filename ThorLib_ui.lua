local addon, TL = ...
if ThorLib == nil then ThorLib = {} end
if ThorLib.ui == nil then ThorLib.ui = {} end

local P = {}


-- ######################################
--  handler for ui mouse events
--
--  usage:
--    frame.add_event = ThorLib.ui.add_event
--    frame:add_event("MouseIn", function(self)
--      ...
--    end)

--function OBSOLETE_ThorLib.ui.add_event(self, tag, func)   --FIXME make into general function
--  --FIXME remove this and use builtin function instead
--  local old_func = self.Event[tag]
--  self.Event[tag] = function(...)
--    func(...)
--    if old_func then old_func(...) end
--  end
--end
  
-- #########################################
-- add color method

local defined_colors = {
  green   = { 0, 1, 0 , "white"},
  red     = { 1, 0, 0 , "white"},
  black   = { 0,0,0, "white" },
  yellow  = { 0.7, 0.7, 0, "black"},
  blue    = { 0,0,1, "white" },
  -- dark
}
local function get_color(color, flag)
  local li = defined_colors[color]
  if not li then
    error("Not valid color: "..color)
  end
  if flag then
    li = defined_colors[li[4]]
    if not li then
      error(string.format("Not valid color: %s for (%s)", color, li[4]))
    end
  end   
  
  return li[1], li[2], li[3]
end

--function FIXMEOBSOLETE_ThorLib.ui.add_method_set_color(item, bgfield, textfield)
--  item.set_color_saved = {}
--  function item:set_color(color)
--    local textcol = white
--    if bgfield then
--      bgfield:SetBackgroundcolor(get_color(color))
--      item.set_color_saved.last_color = color
--    end
--    if textfield then
--      textfield:SetFontColor(get_color(color, true))
--    end
--  end
--  --FIXME add flash
--end

-- ############################################################
--  sidebuttons

  
function FIXME_OBSOLETE_create_side_button(bar, text)
  local function buttons_visible(bar, tag, flag)
    local flags = bar.buttons.flags
    flags[tag] = flag
    flag = false
    for dummy, flag2 in pairs(flags) do
      flag = flag or flag2
    end

    for name, button in pairs(bar.buttons.list) do
      button:SetVisible(flag)
    --FIXME  print("SHOW: ", button, flag)
    end
  end

  
  local buttons = ThorLib.vivify(bar, "buttons")
  ThorLib.vivify(buttons, "flags")
  local name = "button_"..text
  local button = UI.CreateFrame("Frame", name, bar)
  if not buttons.last then buttons.last = bar end
  button:SetPoint("TOPLEFT", buttons.last, "TOPRIGHT", 1, 0)
  button:SetHeight(bar:GetHeight())
  button:SetWidth(bar:GetHeight())
  button:SetBackgroundColor(0,0,0)
  button.text = UI.CreateFrame("Text", name.."_text", button)
  button.text:SetText(text)
  button.text:SetPoint("CENTER", button, "CENTER")

  button:SetLayer(2)    
  button.text:SetLayer(3)

  local function buttons_show2()
    buttons_visible(bar, name, true)
  end    
  local function buttons_hide2()
    buttons_visible(bar, name, false)
  end    
  button:EventAttach(Event.UI.Input.Mouse.Cursor.In, buttons_show2, "buttons show")
  button:EventAttach(Event.UI.Input.Mouse.Cursor.Out, buttons_hide2, "buttons show")

  
  if not buttons.moframe then
    buttons.moframe = UI.CreateFrame("Frame", name.."moframe", bar)
  --  buttons.moframe:SetBackgroundColor(1,0,0)
  --  buttons.moframe:SetAlpha(0.5)
    buttons.moframe:SetPoint("TOPLEFT", bar, "TOPLEFT")
    buttons.moframe:SetPoint("BOTTOM", bar, "BOTTOM")
    buttons.moframe:SetLayer(1)
    local function buttons_show()
      buttons_visible(bar, "moframe", true)
    end
    buttons.moframe:EventAttach(Event.UI.Input.Mouse.Cursor.In, buttons_show, "buttons show")
    local function buttons_hide()
      buttons_visible(bar, "moframe", false)
    end
    buttons.moframe:EventAttach(Event.UI.Input.Mouse.Cursor.Out, buttons_hide, "buttons hide")
  end
  buttons.moframe:ClearPoint("RIGHT")
  buttons.moframe:SetPoint("RIGHT", button, "RIGHT")
    
  buttons.last = button
  button:SetVisible(false)
  ThorLib.vivify(buttons, "list")[name] = button
  
  return button
end


-- ######################################
--   sizer



local function create_sizer(options)
  local col = UI.CreateFrame("Frame", "sizer", options.parent)
  col.options = options
  col.children = {}
 
 
--  local direction = 
  
  local function set_text(self, text, size)
    if text then
      self:SetText(text)
      col.children[self].check_size = true
    end
    if size then
      for frame, data2 in pairs(col.children) do
        frame:SetFontSize(size)
        data2.check_size = true
      end
    end
    if text or size then
      P.add_sizer_updates(self.check_sizes, self)
    end
  end
  local function check_sizes(self)
--    local data = col.children[self]
    for frame, data2 in pairs(col.children) do
      if data2.check_size then
        frame:ClearHeight()
        data2.height = frame:GetHeight()
        frame:SetHeight(data2.height)
        frame:ClearWidth()
        data2.width = frame:GetWidth()
        frame:SetWidth(data2.width)
        data2.check_size = false
      end
    end

    local width = 0
    local height = 0
    for frame, data2 in pairs(col.children) do
      width = math.max(data2.width, width)
      height = math.max(data2.height, height)
    end
    for frame, data2 in pairs(col.children) do
      if data2.set_width ~= width then
        frame:SetWidth(width)
        data2.set_width = width
      end
      if data2.set_height ~= height then
        frame:SetHeight(height)
        data2.set_height = height
      end
    end
    col:SetWidth(width) ---FIXME + height if align?
    col.width = width
    col.height = height
  end
  function col:add_frame(frame, opt2)
    col.children[frame] = {
      height = 0,
      width = 0,
      check_size = true,
    }
    frame.set_text = set_text
    frame.check_sizes = check_sizes

    if options.align then
      frame:SetPoint(options.align, col, options.align)
    end
    P.add_sizer_updates(frame.check_sizes, frame)
    return frame
  end
  

  return col
end

local sizer_queued = {}
function P.add_sizer_updates(func, frame)
  sizer_queued[func] = frame
end

local function  sizer_updates()
  for func, frame in pairs(sizer_queued) do
    func(frame)
  end
  sizer_queued = {}
end



Command.Event.Attach(Event.System.Update.Begin, sizer_updates , "ThorLib Sizer")
  
  

-- ######################################
--  exports

--FIXME
ThorLib.ui.create_sizer = create_sizer
ThorLib.ui.defined_colors = function() return defined_colors2 end


