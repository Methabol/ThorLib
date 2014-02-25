local addon, SHARED, _ENV = ThorLib.module.setup(...)
-- ########################################################################


local self_unit = ThorLib.get_self()  --FIXME
local current_mails = {}


-- ################################################################################
--

INIT_VARS(function()
  S.DC.a_queue = {
    handler = Inspect.Queue.Handler(),
    status = Inspect.Queue.Status(),
  }
          
  S.C.current_mails = nil
  S.DC.current_mails = current_mails

end)

-- ################################################################################
function get_current_mails()
  return current_mails
end

-- ###############################################################################
--  ui
local context
local anchor
local last_anchor
local buttons = {}
local ui_settings = {
  font_size = 15,
  strength = 2,
}

function init_ui()
  local context = UI.CreateContext("HUD")
  anchor = UI.CreateFrame("Text", "button", context)
  anchor:SetText("Mail")
  anchor:SetBackgroundColor(0,0,1)
  anchor:SetFontSize(ui_settings.font_size)
  anchor:SetPoint("TOPLEFT", UI.Native.Mail, "TOPRIGHT", 0, 0)
  local function set_vis()
    local visflag = UI.Native.Mail:GetLoaded()
    anchor:SetVisible(visflag)
    --FIXME enable callbacks here
  end
  UI.Native.Mail:EventAttach(Event.UI.Native.Loaded, set_vis, "testlabel")
  set_vis()  
  
  last_anchor = anchor
end

function add_button(text, color, callbacks)
  if not ThorLib.ui then error("ThorLib_UI is required for this functionality", 2) end
  if not anchor then init_ui() end
  local button = UI.CreateFrame("Text", "mailbutton", anchor)
   ThorLib.ui.add_methods(button)
  button:SetText(text)
  button:SetFontSize(ui_settings.font_size)
  button:SetEffectGlow({strength = ui_settings.strength})
  --FIXM TLUI methods
  button:SetBackgroundColor(ThorLib.ui.get_color(color or "black"))
  
  button:SetPoint("TOPLEFT", last_anchor, "BOTTOMLEFT")
  last_anchor = button
  
  button:add_mouse_events(callbacks or {})

  
  buttons[button] = true
  return button
end




-- ######################################################
local QUEUE_TIMEOUT = 3    --FIXME settings

-- ######################################################
--  queue delete
delete_queue = {}
delete_block = false
delete_current = false

function queue_delete(id, callback)
  delete_queue[id] = {
    id = id,
    callback = callback or function()end,
  }
  run_delete_queue()
end

function run_delete_queue()
  if delete_block then
    if delete_block + QUEUE_TIMEOUT < Inspect.Time.Real() then
      local curr = delete_current 
      delete_block = false
      delete_current = false
      curr.callback(true, "ThorLib: Queue Timeout")
    end
    return 
  end
  
  --
  local id, queue_data = next(delete_queue)
  if not id then return end
  delete_queue[id] = nil
  local maildata = current_mails[id]
  if not maildata then
    return queue_data.callback(true, "ThorLib: Mail no longer available.")
  end
  
  if maildata.data.attachments then
    debug_print("Skipping mail ", id, " because it still has attachments", maildata.data.attachments)
    return queue_data.callback(true, "ThorLib: Can't delete mail with attachment.")
  end
  
  
  function delete_result(fail, errmsg)
    if fail then
      debug_print("Mail delete failed:", id , errmsg)
    end
    queue_data.callback(fail, errmsg)
    delete_block = false
    delete_current = false
    run_delete_queue()
  end
  
  debug_print("deleting: ", id)

  delete_block = Inspect.Time.Real()
  delete_current = queue_data
  Command.Mail.Delete(id, delete_result)  
end



-- ######################################################
--  queue take

take_queue = {}
take_block = false
take_current = false

function queue_take(id, callback, list) --FIXME change order
  take_queue[id] = {
    list = list or false,
    callback = callback or function()end,
  }
  run_take_queue()
end

function run_take_queue()
  if take_block then
    if take_block + QUEUE_TIMEOUT < Inspect.Time.Real() then
      local curr = take_current 
      take_block = false
      take_current = false
      curr.callback(true, "ThorLib: Queue Timeout")
    end
    return 
  end
  
  local id, takedata = next(take_queue)
  if not id then return end
  take_queue[id] = nil
  local maildata = current_mails[id]
  if not maildata then
    return takedata.callback(true, "ThorLib: Mail no longer available.")
  end
  
  if not(maildata.data.attachments) then
    debug_print("No attachments: ", id)
    queue_delete(id)
  elseif maildata.status == "detail" then
  --  debug_print("we got detail, taking")
    local function take_result(fail, message)
      if fail then
        debug_print("mail take failed: ", id, fail, tostring(message))
        -- FIXME requeue?
      --  queue_take(id, takedata.callback, takedata.list)
      end
    end
    take_block = Inspect.Time.Real()
    take_current = takedata
    local takelist = takedata.list or maildata.data.attachments
    add_mail_trigger(id, function(id, status, data)
      debug_print("Got mail trigger:", id)
      take_block = false
      take_current = false
      takedata.callback(fail, message)
      S.DC.maildata_taketrigger_test = maildata or "maildata error"
      if not(maildata.data.attachments) or
        ( type(maildata.data.attachments) == "table" and not next(maildata.data.attachments) )
      then
        queue_delete(id)
      end
      debug_print("should have queued delete")
      run_take_queue()
    end)
    Command.Mail.Take(id, takelist, take_result)
  else
    debug_print("no detail for mail ", id)
    queue_open(id, function(flag)
      debug_print("reopened, requeing ", id)
      queue_take(id, takedata.callback, takedata.list)
    end)
    
 --   run_take_queue()
 --   debug_print("no detail for mail: ", id) --FIXME
  end



end

-- ######################################################
--  queue open

mail_queue = ThorLib.queue.create{
  name = "ThorLib Command.Mail.Open",
  timout = QUEUE_TIMEOUT,
  on_run = function(data)
    local id = data.id
    local maildata = current_mails[id]
    if not maildata then
      mail_queue:unblock()
      return data.callback(true, "ThorLib: Mail no longer available.")
    end
    local fail_msg = "Mail command failed:"
    local function check_result(fail, message)
      if fail then
        debug_print(fail_msg, id, message)
      end
      data.callback(fail, message)
      mail_queue:unblock()
    end
    
    
    if data.cmd == "open" then
      --FIXME check if we already have detail
      fail_msg = "Open mail failed:"
      Command.Mail.Open(id, check_result)
    else
      error("Wrong command: "..tostring(cmd))
    end
  end,
}

function queue_open(id, callback)
  mail_queue:add({
    id = id,
    callback = callback or function()end,
    cmd = "open", 
  })
end
  



-- ###########################################################################
-- run mail queues
function run_mail_queue()
--  TTM.handle_queue_open()
 -- handle_mail_queue()
--  TTM.handle_take_queue()
--  run_open_queue()
  run_take_queue()
  run_delete_queue()
end
  
  
Command.Event.Attach(Event.System.Update.Begin, run_mail_queue, "ThorLib_Mail")

			--
			--	data = {
			--		attachments = 1,
			--		expire = 1393912361,
			--		from = "Auction House",
			--		id = "m035400002D522977",
			--		read = true,
			--		subject = "Auction Sold for Break Point"
			--	},
			--	status = "basic",
			--	time = 1392063530
			--},


-- ###############################################################################
--  standard templates
templates = {
  auction_sold = {
    subject = "^Auction Sold for (.+)$",
    log = true,
    body = {
      item = "^Your auction for (.-) was sold to .-%.\n",
      buyer = "^Your auction for .- was sold to (.-)%.\n",
      bid = "Bid: (.-)\n",
      fee = "Fee: (.-)\n",
      deposit = "Deposit: (.-)\n",
      net = "Net: (.-)\n",
      auction_id = "Auction Id: (%d+)",
    },
  },
  auction_expired = {
    subject = "^Auction Expired for (.+)$",
    log = true,
    body = {
      item = "Your auction for (.-) expired with no bids.\n",
      auction_id = "Auction Id: (%d+)",
    },
  },
  auction_outbid = {
--    "Outbid on Auction for Lycini Admiralty Orders 1"
    subject =  "^Outbid on Auction for (.+)$",
    log = true,
    body = {
      item = "You were outbid on an auction for (.-)%.\n",
      auction_id = "Auction Id: (%d+)",
    },
  },
  auction_won = {
    subject =  "^Auction Won for (.+)$",
    log = true,
    body = {
      item = "You won an auction for: (.-)%.\n",
      auction_id = "Auction Id: (%d+)",
    },
  },
}

function add_template(name, data)
  templates[name] = data  --FIXME check syntax?
end
--FIXME add_template func, move placeholder to tools


-- #################################################################################
--  handle categories
function check_category(mailid, data)
  data.category = nil
  for cat_name, template in pairs(templates) do
    if string.match(data.data.subject, template.subject) then
      data.category = cat_name
      data.category_data = nil
      
      --if cat_name == "auction_sold" then
      --  S.DC.amail = data
      --  debug_print("Found auction_sold:" , cat_name, mailid)
      --end
      
      local body = data.data.body
      local fail_flag = false
      if body then
        local cat_data = {}
        for tag, regex in pairs(template.body) do
          local temp_str = body:match(regex)
          if temp_str then
            cat_data[tag] = temp_str
          else
            fail_flag = true
          end
        end
        if not fail_flag then
          data.category_data = cat_data
          if template.log then
            local str = string.format("ThorMail|%s|%s|%s", cat_name, mailid, data.data.subject)
            for name, dstr in pairs(cat_data) do
              str = string.format("%s|%s=%s", str, name, dstr)
            end
            print(str)
          end
        end
      end
      if template.event then
        template.event(mailid, data)
      end
      break -- found match
    end
  end
end

-- ######################################################
--   triggers
local mail_triggers = {}

function add_mail_trigger(id, callback)
  table.insert(vivify(mail_triggers, id), callback)
end



-- ######################################################
--  

function mail_event(handle, mails)
  ThorLib.scheduler.run_coro(function()
    for id, status in pairs(mails) do
      local data = false
      if status then
        data = ThorLib.vivify(current_mails, id)
        if type(data.attachments) == "table" and not(next(data.attachments)) then
          data.attachments = false
        end
        data.status = status
        data.time = Inspect.Time.Server()
        data.data = Inspect.Mail.Detail(id)
        check_category(id, data)
      else
        current_mails[id] = nil
      end
      -- triggers and events
      local triggers = mail_triggers[id]
      if triggers then
        mail_triggers[id] = nil
        for num, callback in ipairs(triggers) do
          callback(id, status, data)
        end
      end
      events.mail(id, status, data)
      --
      ThorLib.scheduler.watchdog_check()
    end
  end)
end

Command.Event.Attach(Event.Mail, mail_event, "ThorLib_mail")

-- ########################################################################

events = {}
events.mail = Utility.Event.Create("ThorLib", "Mail" )




-- ########################################################################
--  exports
ThorLib.mail = {
  add_template = add_template,
  get_current_mails = get_current_mails,
  add_button = add_button,
  --
  queue_open = queue_open,
  queue_take = queue_take,
  queue_delete = queue_delete,
}

