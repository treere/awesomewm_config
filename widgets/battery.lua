local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local watch = require("awful.widget.watch")

local batteryarc = wibox.widget {
    max_value = 1,
    rounded_edge = true,
    thickness = 2,
    start_angle = 3.14159,
    bg = "#00000011",
    paddings = 0,
    widget = wibox.container.arcchart,
}

watch("acpi", 30,
    function(widget, stdout, stderr, exitreason, exitcode)
        local batteryType
        local _, status, charge_str, time = string.match(stdout, '(.+): (%a+), (%d?%d%d)%%,? ?.*')
        local charge = tonumber(charge_str)
        widget.value = charge / 100

        if charge < 10 then
					 batteryarc.colors = { "#FF0000FF" }
					 if status ~= 'Charging' then
							show_battery_warning()
					 end
        elseif charge > 10 and charge < 30 then
            batteryarc.colors = { "#FFFF00FF" }
        else
            batteryarc.colors = { "#FFFFFFFF" }
        end

    end,
    batteryarc)

-- Popup with battery info
-- One way of creating a pop-up notification - naughty.notify
local notification
function show_battery_status()
    awful.spawn.easy_async([[bash -c 'acpi']],
        function(stdout, _, _, _)
            notification = naughty.notify {
                text = stdout,
                title = "Battery status",
                timeout = 5,
                hover_timeout = 0.5,
                width = 200,
            }
        end)
end

batteryarc:connect_signal("mouse::enter", function() show_battery_status() end)
batteryarc:connect_signal("mouse::leave", function() naughty.destroy(notification) end)

--[[ Show warning notification ]]
function show_battery_warning()
    naughty.notify {
        text = "Huston, we have a problem",
        title = "Battery is dying",
        timeout = 5,
        hover_timeout = 0.5,
        position = "bottom_right",
        bg = "#F06060",
        fg = "#EEE9EF",
        width = 300,
    }
end

return batteryarc
