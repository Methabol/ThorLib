local addon, SHARED, _ENV = ThorLib.module.setup(...)
-- ########################################################################




function id_generator(format, start)
  local counter = start or 1

  return function()
    local str = string.format(format, counter)
    counter = counter + 1
    return str
  end
  
end





-- ########################################################################
-- exports
ThorLib.table.merge(ThorLib, {
  id_generator = id_generator,   
})
