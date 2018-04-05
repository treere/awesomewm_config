local awful = require("awful")
local spawn = require("awful.spawn")
local watch = require("awful.widget.watch")
local wibox = require("wibox")

local GET_VOLUME_CMD = 'amixer -D pulse sget Master'
local INC_VOLUME_CMD = 'amixer -D pulse sset Master 5%+'
local DEC_VOLUME_CMD = 'amixer -D pulse sset Master 5%-'
local TOG_VOLUME_CMD = 'amixer -D pulse sset Master toggle'

local text = wibox.widget {
	 text = "--",
	 align  = "center",
	 valign = "center",
	 widget = wibox.widget.textbox
}

local volumearc = wibox.widget {
	 text,
	 min_value = 0,
	 max_value = 1,
	 thickness = 2,
	 start_angle = 3.141592653,
	 bg = "#ffffff55",
	 paddings = 0,
	 widget = wibox.container.arcchart
}

local update_graphic = function(widget, stdout, _, _, _)
	 local mute = string.match(stdout, "%[(o%D%D?)%]")
	 local volume = string.match(stdout, "(%d?%d?%d)%%")
	 volume = tonumber(string.format("% 3d", volume))

	 widget.value = volume / 100;
	 text.text = volume ~= 100 and volume or 'M';
	 
	 if mute == "off" then
			widget.colors = { "#0000FFFF" }
	 else
			widget.colors = { "#00FF00FF" }
	 end
end

local update_volume_arc = function (stdout, stderr, exitreason, exitcode)
	update_graphic(volumearc,stdout, stderr, exitreason, exitcode)
end

increase_volume = function()
	awful.spawn.easy_async(INC_VOLUME_CMD, update_volume_arc)
end
decrease_volume = function()
	awful.spawn.easy_async(DEC_VOLUME_CMD, update_volume_arc)
end
toggle_volume = function()
	awful.spawn.easy_async(TOG_VOLUME_CMD, update_volume_arc)
end
volumearc:connect_signal("button::press", function(_, _, _, button)
														if (button == 4) then awful.spawn.easy_async(INC_VOLUME_CMD, update_volume_arc)
														elseif (button == 5) then awful.spawn.easy_async(DEC_VOLUME_CMD, update_volume_arc)
														elseif (button == 1) then awful.spawn.easy_async(TOG_VOLUME_CMD, update_volume_arc)
														end
end)


watch(GET_VOLUME_CMD, 60, update_graphic, volumearc)

return volumearc
