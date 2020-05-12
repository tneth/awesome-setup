
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local https           = require("ssl.https")

local newtimer        = require("lain.helpers").newtimer

local wibox           = require("wibox")
local string          = { format = string.format,
                          gsub = string.gsub,
			  match = string.match }

local setmetatable    = setmetatable

local fm = {}

local function worker(args)
    local args     = args or {}
    local timeout  = 10
    local settings = args.settings or function() end

    fm.widget = wibox.widget.textbox('')

    function update()
        fm_now = {}

	local song = {}

	https.request{
		url = "https://138chan.com/fm/get_pidgin.php",
		sink = ltn12.sink.table(song)
	}

        fm_now.song = table.concat(song)
        widget = fm.widget
        settings()
    end

    newtimer("fm", timeout, update)

    return fm.widget
end

return setmetatable(fm, { __call = function(_, ...) return worker(...) end })
