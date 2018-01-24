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

local temp_widget = wibox.widget {
	 text,
	 min_value = 40,
	 max_value = 100,
	 start_angle = 3.1415926535, --4.71238898, -- 2pi*3/4
	 widget = wibox.container.arcchart,
	 bg = "ffffff55",
	 thickness = 2,
	 paddings = 0,
}

local mean_temp

watch([[bash -c "sensors -u | grep input -m2 | cut -d' ' -f4 | mean"]], 1,
    function(widget, stdout, stderr, exitreason, exitcode)
        mean_temp = stdout:match('(%d+)')
        widget.value = mean_temp
				text.text = string.format("%02.0f",mean_temp)

	 if tonumber(mean_temp) > 65 then
			widget.colors = { "#FF0000FF" }
	 else
			widget.colors = { "#00FF00FF" }
	 end
    end,
    temp_widget
)

local notification
function show_ram_status()
	 notification = naughty.notify {
			text = "Mean CPU temp " .. mean_temp,
			title = "Temp status",
			timeout = 5,
			hover_timeout = 0.5,
			width = 200,
	 }
end

temp_widget:connect_signal("mouse::enter", function() show_ram_status() end)
temp_widget:connect_signal("mouse::leave", function() naughty.destroy(notification) end)


return temp_widget
