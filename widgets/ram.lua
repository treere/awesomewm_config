local awful = require("awful")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local naughty = require("naughty")

--- Main ram widget shown on wibar

local text = wibox.widget {
	 text = "--",
	 align  = "center",
	 valign = "center",
	 widget = wibox.widget.textbox
}

local ramgraph_widget = wibox.widget {
	 text,
	 border_width = 0,
	 colors = {
			'#FF0000','#0000FF','#ffffff55', 
	 },
	 start_angle = 3.1415926535, --4.71238898, -- 2pi*3/4
	 display_labels = false,
	 widget = wibox.container.arcchart,
	 thickness = 2,
	 paddings = 0,
}

local total, used, free, shared, buff_cache, available

watch('bash -c "free | grep Mem"', 30,
    function(widget, stdout, stderr, exitreason, exitcode)
        total, used, free, shared, buff_cache, available = stdout:match('(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)')
        widget.values = { used,buff_cache,free }
				text.text = string.format("%02.0f",used/total*100)
    end,
    ramgraph_widget
)

local notification
local function show_ram_status()
	 notification = naughty.notify {
			text = string.format("Used: %5.2f%s\nFree: %5.2f%s\nBuff: %5.2f%s",100*used/total,'%',100*free/total,'%',100*buff_cache/total,'%'),
			title = "Ram status",
			timeout = 5,
			hover_timeout = 0.5,
			width = 200,
	 }
end

ramgraph_widget:connect_signal("button::press", function(_,_,_,button) 
	if (button == 3) then show_ram_status() end
end)
ramgraph_widget:connect_signal("mouse::leave", function() naughty.destroy(notification) end)


return ramgraph_widget
