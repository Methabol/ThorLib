local addon, TL, _ENV = ThorLib.module.setup(...)
-- ######################################################################

-- color names from http://www.w3schools.com/html/html_colornames.asp

local defined_colors = {
  AliceBlue            = { 0.93750, 0.96875, 0.99609, "black", }, 
  AntiqueWhite         = { 0.97656, 0.91797, 0.83984, "black", }, 
  Aqua                 = { 0.00000, 0.99609, 0.99609, "black", }, 
  Aquamarine           = { 0.49609, 0.99609, 0.82813, "black", }, 
  Azure                = { 0.93750, 0.99609, 0.99609, "black", }, 
  Beige                = { 0.95703, 0.95703, 0.85938, "black", }, 
  Bisque               = { 0.99609, 0.89063, 0.76563, "black", }, 
  Black                = { 0.00000, 0.00000, 0.00000, "white", }, 
  BlanchedAlmond       = { 0.99609, 0.91797, 0.80078, "black", }, 
  Blue                 = { 0.00000, 0.00000, 0.99609, "white", }, 
  BlueViolet           = { 0.53906, 0.16797, 0.88281, "black", }, 
  Brown                = { 0.64453, 0.16406, 0.16406, "white", }, 
  BurlyWood            = { 0.86719, 0.71875, 0.52734, "black", }, 
  CadetBlue            = { 0.37109, 0.61719, 0.62500, "black", }, 
  Chartreuse           = { 0.49609, 0.99609, 0.00000, "white", }, 
  Chocolate            = { 0.82031, 0.41016, 0.11719, "white", }, 
  Coral                = { 0.99609, 0.49609, 0.31250, "black", }, 
  CornflowerBlue       = { 0.39063, 0.58203, 0.92578, "black", }, 
  Cornsilk             = { 0.99609, 0.96875, 0.85938, "black", }, 
  Crimson              = { 0.85938, 0.07813, 0.23438, "white", }, 
  Cyan                 = { 0.00000, 0.99609, 0.99609, "black", }, 
  DarkBlue             = { 0.00000, 0.00000, 0.54297, "white", }, 
  DarkCyan             = { 0.00000, 0.54297, 0.54297, "white", }, 
  DarkGoldenRod        = { 0.71875, 0.52344, 0.04297, "white", }, 
  DarkGray             = { 0.66016, 0.66016, 0.66016, "black", }, 
  DarkGreen            = { 0.00000, 0.39063, 0.00000, "white", }, 
  DarkKhaki            = { 0.73828, 0.71484, 0.41797, "black", }, 
  DarkMagenta          = { 0.54297, 0.00000, 0.54297, "white", }, 
  DarkOliveGreen       = { 0.33203, 0.41797, 0.18359, "white", }, 
  DarkOrange           = { 0.99609, 0.54688, 0.00000, "black", }, 
  DarkOrchid           = { 0.59766, 0.19531, 0.79688, "black", }, 
  DarkRed              = { 0.54297, 0.00000, 0.00000, "white", }, 
  DarkSalmon           = { 0.91016, 0.58594, 0.47656, "black", }, 
  DarkSeaGreen         = { 0.55859, 0.73438, 0.55859, "black", }, 
  DarkSlateBlue        = { 0.28125, 0.23828, 0.54297, "white", }, 
  DarkSlateGray        = { 0.18359, 0.30859, 0.30859, "white", }, 
  DarkTurquoise        = { 0.00000, 0.80469, 0.81641, "black", }, 
  DarkViolet           = { 0.57813, 0.00000, 0.82422, "white", }, 
  DeepPink             = { 0.99609, 0.07813, 0.57422, "black", }, 
  DeepSkyBlue          = { 0.00000, 0.74609, 0.99609, "black", }, 
  DimGray              = { 0.41016, 0.41016, 0.41016, "white", }, 
  DodgerBlue           = { 0.11719, 0.56250, 0.99609, "black", }, 
  FireBrick            = { 0.69531, 0.13281, 0.13281, "white", }, 
  FloralWhite          = { 0.99609, 0.97656, 0.93750, "black", }, 
  ForestGreen          = { 0.13281, 0.54297, 0.13281, "white", }, 
  Fuchsia              = { 0.99609, 0.00000, 0.99609, "black", }, 
  Gainsboro            = { 0.85938, 0.85938, 0.85938, "black", }, 
  GhostWhite           = { 0.96875, 0.96875, 0.99609, "black", }, 
  Gold                 = { 0.99609, 0.83984, 0.00000, "black", }, 
  GoldenRod            = { 0.85156, 0.64453, 0.12500, "black", }, 
  Gray                 = { 0.50000, 0.50000, 0.50000, "white", }, 
  Green                = { 0.00000, 0.50000, 0.00000, "white", }, 
  GreenYellow          = { 0.67578, 0.99609, 0.18359, "black", }, 
  HoneyDew             = { 0.93750, 0.99609, 0.93750, "black", }, 
  HotPink              = { 0.99609, 0.41016, 0.70313, "black", }, 
  IndianRed            = { 0.80078, 0.35938, 0.35938, "black", }, 
  Indigo               = { 0.29297, 0.00000, 0.50781, "white", }, 
  Ivory                = { 0.99609, 0.99609, 0.93750, "black", }, 
  Khaki                = { 0.93750, 0.89844, 0.54688, "black", }, 
  Lavender             = { 0.89844, 0.89844, 0.97656, "black", }, 
  LavenderBlush        = { 0.99609, 0.93750, 0.95703, "black", }, 
  LawnGreen            = { 0.48438, 0.98438, 0.00000, "white", }, 
  LemonChiffon         = { 0.99609, 0.97656, 0.80078, "black", }, 
  LightBlue            = { 0.67578, 0.84375, 0.89844, "black", }, 
  LightCoral           = { 0.93750, 0.50000, 0.50000, "black", }, 
  LightCyan            = { 0.87500, 0.99609, 0.99609, "black", }, 
  LightGoldenRodYellow = { 0.97656, 0.97656, 0.82031, "black", }, 
  LightGray            = { 0.82422, 0.82422, 0.82422, "black", }, 
  LightGreen           = { 0.56250, 0.92969, 0.56250, "black", }, 
  LightPink            = { 0.99609, 0.71094, 0.75391, "black", }, 
  LightSalmon          = { 0.99609, 0.62500, 0.47656, "black", }, 
  LightSeaGreen        = { 0.12500, 0.69531, 0.66406, "white", }, 
  LightSkyBlue         = { 0.52734, 0.80469, 0.97656, "black", }, 
  LightSlateGray       = { 0.46484, 0.53125, 0.59766, "black", }, 
  LightSteelBlue       = { 0.68750, 0.76563, 0.86719, "black", }, 
  LightYellow          = { 0.99609, 0.99609, 0.87500, "black", }, 
  Lime                 = { 0.00000, 0.99609, 0.00000, "white", }, 
  LimeGreen            = { 0.19531, 0.80078, 0.19531, "white", }, 
  Linen                = { 0.97656, 0.93750, 0.89844, "black", }, 
  Magenta              = { 0.99609, 0.00000, 0.99609, "black", }, 
  Maroon               = { 0.50000, 0.00000, 0.00000, "white", }, 
  MediumAquaMarine     = { 0.39844, 0.80078, 0.66406, "black", }, 
  MediumBlue           = { 0.00000, 0.00000, 0.80078, "white", }, 
  MediumOrchid         = { 0.72656, 0.33203, 0.82422, "black", }, 
  MediumPurple         = { 0.57422, 0.43750, 0.85547, "black", }, 
  MediumSeaGreen       = { 0.23438, 0.69922, 0.44141, "white", }, 
  MediumSlateBlue      = { 0.48047, 0.40625, 0.92969, "black", }, 
  MediumSpringGreen    = { 0.00000, 0.97656, 0.60156, "black", }, 
  MediumTurquoise      = { 0.28125, 0.81641, 0.79688, "black", }, 
  MediumVioletRed      = { 0.77734, 0.08203, 0.51953, "white", }, 
  MidnightBlue         = { 0.09766, 0.09766, 0.43750, "white", }, 
  MintCream            = { 0.95703, 0.99609, 0.97656, "black", }, 
  MistyRose            = { 0.99609, 0.89063, 0.87891, "black", }, 
  Moccasin             = { 0.99609, 0.89063, 0.70703, "black", }, 
  NavajoWhite          = { 0.99609, 0.86719, 0.67578, "black", }, 
  Navy                 = { 0.00000, 0.00000, 0.50000, "white", }, 
  OldLace              = { 0.98828, 0.95703, 0.89844, "black", }, 
  Olive                = { 0.50000, 0.50000, 0.00000, "white", }, 
  OliveDrab            = { 0.41797, 0.55469, 0.13672, "white", }, 
  Orange               = { 0.99609, 0.64453, 0.00000, "black", }, 
  OrangeRed            = { 0.99609, 0.26953, 0.00000, "white", }, 
  Orchid               = { 0.85156, 0.43750, 0.83594, "black", }, 
  PaleGoldenRod        = { 0.92969, 0.90625, 0.66406, "black", }, 
  PaleGreen            = { 0.59375, 0.98047, 0.59375, "black", }, 
  PaleTurquoise        = { 0.68359, 0.92969, 0.92969, "black", }, 
  PaleVioletRed        = { 0.85547, 0.43750, 0.57422, "black", }, 
  PapayaWhip           = { 0.99609, 0.93359, 0.83203, "black", }, 
  PeachPuff            = { 0.99609, 0.85156, 0.72266, "black", }, 
  Peru                 = { 0.80078, 0.51953, 0.24609, "black", }, 
  Pink                 = { 0.99609, 0.75000, 0.79297, "black", }, 
  Plum                 = { 0.86328, 0.62500, 0.86328, "black", }, 
  PowderBlue           = { 0.68750, 0.87500, 0.89844, "black", }, 
  Purple               = { 0.50000, 0.00000, 0.50000, "white", }, 
  Red                  = { 0.99609, 0.00000, 0.00000, "white", }, 
  RosyBrown            = { 0.73438, 0.55859, 0.55859, "black", }, 
  RoyalBlue            = { 0.25391, 0.41016, 0.87891, "black", }, 
  SaddleBrown          = { 0.54297, 0.26953, 0.07422, "white", }, 
  Salmon               = { 0.97656, 0.50000, 0.44531, "black", }, 
  SandyBrown           = { 0.95313, 0.64063, 0.37500, "black", }, 
  SeaGreen             = { 0.17969, 0.54297, 0.33984, "white", }, 
  SeaShell             = { 0.99609, 0.95703, 0.92969, "black", }, 
  Sienna               = { 0.62500, 0.32031, 0.17578, "white", }, 
  Silver               = { 0.75000, 0.75000, 0.75000, "black", }, 
  SkyBlue              = { 0.52734, 0.80469, 0.91797, "black", }, 
  SlateBlue            = { 0.41406, 0.35156, 0.80078, "black", }, 
  SlateGray            = { 0.43750, 0.50000, 0.56250, "white", }, 
  Snow                 = { 0.99609, 0.97656, 0.97656, "black", }, 
  SpringGreen          = { 0.00000, 0.99609, 0.49609, "white", }, 
  SteelBlue            = { 0.27344, 0.50781, 0.70313, "white", }, 
  Tan                  = { 0.82031, 0.70313, 0.54688, "black", }, 
  Teal                 = { 0.00000, 0.50000, 0.50000, "white", }, 
  Thistle              = { 0.84375, 0.74609, 0.84375, "black", }, 
  Tomato               = { 0.99609, 0.38672, 0.27734, "black", }, 
  Turquoise            = { 0.25000, 0.87500, 0.81250, "black", }, 
  Violet               = { 0.92969, 0.50781, 0.92969, "black", }, 
  Wheat                = { 0.95703, 0.86719, 0.69922, "black", }, 
  White                = { 0.99609, 0.99609, 0.99609, "black", }, 
  WhiteSmoke           = { 0.95703, 0.95703, 0.95703, "black", }, 
  Yellow               = { 0.99609, 0.99609, 0.00000, "black", }, 
  YellowGreen          = { 0.60156, 0.80078, 0.19531, "black", }, 
}

-- ######################################################################

local function convert_name(str)
  str = string.lower(str)
  str = string.gsub(str, "[^a-z]", "")
  return str
end


if true then
  local new = {}
  for name, data in pairs(defined_colors) do
    new[convert_name(name)] = data
  end
  defined_colors = new
end
  

-- ######################################################################

local function get_color(color, flag)
  if type(color) == "table" then
    return unpack(color)
  end
  local li = defined_colors[convert_name(color)] or error("Not valid color: "..color)
  if flag then
    return get_color(li[4]) --FIXME
  else
    return unpack(li, 1, 3)
  end
end


-- ######################################################################
--  exports
ThorLib.table.merge(ThorLib.ui, {
  get_color = get_color
})



