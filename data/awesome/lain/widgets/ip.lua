
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

local ip = {}

local function worker(args)
    local args     = args or {}
    local timeout  = 1000*60
    local settings = args.settings or function() end

    ip.widget = wibox.widget.textbox('')

    function update()
        ip_now = {}

	local ip_temp = {}

	https.request{
		url = "https://138chan.com/misc/ip.php",
		sink = ltn12.sink.table(ip_temp)
	}

        ip_now.ip = table.concat(ip_temp)
        widget = ip.widget
        settings()
    end

    newtimer("ip", timeout, update)

    return ip.widget
end

return setmetatable(ip, { __call = function(_, ...) return worker(...) end })
