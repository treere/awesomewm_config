-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup").widget

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	 naughty.notify({ preset = naughty.config.presets.critical,
										title = "Oops, there were errors during startup!",
										text = awesome.startup_errors })
end


function resize(c)
  local grabber 
	grabber = awful.keygrabber.run(function(mod, key, event)
    if event == "release" then return end

		naughty.notify({title= event,text= key })
		awful.keygrabber.stop(grabber)
  end)
end


-- Fake wmname
awful.util.spawn_with_shell("wmname LG3D")

-- Autorun programs
awful.spawn.with_shell("~/.config/awesome/autorun.sh")

-- Handle runtime errors after startup
do
	 local in_error = false
	 awesome.connect_signal("debug::error", function (err)
														 -- Make sure we don't go into an endless error loop
														 if in_error then return end
														 in_error = true

														 naughty.notify({ preset = naughty.config.presets.critical,
																							title = "Oops, an error happened!",
																							text = tostring(err) })
														 in_error = false
	 end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "alacritty -e tmux"
editor = os.getenv("EDITOR") or "emacs"
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	 awful.layout.suit.floating,
	 awful.layout.suit.tile,
	 awful.layout.suit.magnifier,
}
-- }}}

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
	 awful.button({ }, 1, function(t) t:view_only() end),
	 awful.button({ modkey }, 1, function(t)
				 if client.focus then
						client.focus:move_to_tag(t)
				 end
	 end),
	 awful.button({ }, 3, awful.tag.viewtoggle),
	 awful.button({ modkey }, 3, function(t)
				 if client.focus then
						client.focus:toggle_tag(t)
				 end
	 end),
	 awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
	 awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
	 awful.button({ }, 4, function ()
				 awful.client.focus.byidx(1)
	 end),
	 awful.button({ }, 5, function ()
				 awful.client.focus.byidx(-1)
	 end)
)

local function set_wallpaper(s)
	 gears.wallpaper.maximized("/home/treere/.config/awesome/wallpaper/all_good.png", s, true)
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
			awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[2])
end)

awful.screen.connect_for_each_screen(function(s)
			-- Wallpaper
			set_wallpaper(s)
			
			-- Create a promptbox for each screen
			s.mypromptbox = awful.widget.prompt()
			-- Create an imagebox widget which will contain an icon indicating which layout we're using.
			-- We need one layoutbox per screen.
			s.mylayoutbox = awful.widget.layoutbox(s)

			-- Create a taglist widget
			s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

			-- Create a tasklist widget
			s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons, { disable_task_name = true })

			-- Create the wibox
			s.mywibox = awful.wibar({ position = "top", screen = s })

			-- Add widgets to the wibox

			if s == screen.primary then
				 s.mywibox:setup {
						layout = wibox.layout.align.horizontal,
						{ -- Left widgets
							 layout = wibox.layout.fixed.horizontal,
							 s.mytaglist,
							 s.mypromptbox,
						},
						s.mytasklist, -- Middle widget
						{ -- Right widgets
							 layout = wibox.layout.fixed.horizontal,
							 wibox.widget.systray(),
							 require("widgets.battery"),
							 require("widgets.volume"),
							 require("widgets.ram"),
							 require("widgets.temp"),
							 wibox.widget.textclock(" %y %m %d %k:%M"),
							 s.mylayoutbox,
						},
				 }
			else
				 s.mywibox:setup {
						layout = wibox.layout.align.horizontal,
						{ -- Left widgets
							 layout = wibox.layout.fixed.horizontal,
							 s.mytaglist,
							 s.mypromptbox,
						},
						s.mytasklist, -- Middle widget
						{ -- Right widgets
							 layout = wibox.layout.fixed.horizontal,
							 s.mylayoutbox,
						},
				 }
			end
end)
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
	 -- Popup
	 awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
			{description="show help", group="awesome"}),

	 -- Move tags
	 awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
			{description = "view previous", group = "tag"}),
	 awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
			{description = "view next", group = "tag"}),
	 awful.key({ modkey, "Control" }, "j",   awful.tag.viewprev,
			{description = "view previous", group = "tag"}),
	 awful.key({ modkey,"Control"  }, "k",  awful.tag.viewnext,			
			{description = "view next", group = "tag"}),
	 awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
			{description = "go back", group = "tag"}),

	 -- Volume Keys
   awful.key({}, "XF86AudioLowerVolume", function ()
     awful.util.spawn("amixer -q -D pulse sset Master 5%-", false)
   end),
   awful.key({}, "XF86AudioRaiseVolume", function ()
     awful.util.spawn("amixer -q -D pulse sset Master 5%+", false)
   end),
   awful.key({}, "XF86AudioMute", function ()
     awful.util.spawn("amixer -D pulse set Master 1+ toggle", false)
   end),   -- Volume Keys
   awful.key({}, "XF86AudioLowerVolume", function ()
     awful.util.spawn("amixer -q -D pulse sset Master 5%-", false)
   end),
   awful.key({}, "XF86AudioRaiseVolume", function ()
     awful.util.spawn("amixer -q -D pulse sset Master 5%+", false)
   end),
   awful.key({}, "XF86AudioMute", function ()
     awful.util.spawn("amixer -D pulse set Master 1+ toggle", false)
   end),

	 -- Move clients
	 awful.key({ modkey,           }, "j", function()  awful.client.focus.byidx(-1) end,
			{description = "focus next by index", group = "client"}),
	 awful.key({ modkey,           }, "k", function () awful.client.focus.byidx( 1) end,
			{description = "focus previous by index", group = "client"}),

	 -- Screens
	 awful.key({ modkey,  }, "o", function () awful.screen.focus_relative( 1) end,
			{description = "focus the next screen", group = "screen"}),
	 awful.key({ modkey, "Control" }, "Left", function () awful.screen.focus_relative( 1) end,
			{description = "focus the next screen", group = "screen"}),
	 awful.key({ modkey, "Control" }, "Right", function () awful.screen.focus_relative(-1) end,
			{description = "focus the previous screen", group = "screen"}),
	 
	 -- Layout manipulation
	 awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
			{description = "swap with next client by index", group = "client"}),
	 awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
			{description = "swap with previous client by index", group = "client"}),
	 awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
			{description = "jump to urgent client", group = "client"}),
	 awful.key({ modkey,           }, "Tab",
			function ()
				 awful.client.focus.history.previous()
				 if client.focus then
						client.focus:raise()
				 end
			end,
			{description = "go back", group = "client"}),

	 -- Standard program
	 awful.key({ modkey, "Shift"   }, "Return",
			function ()
				 local matcher = function (c)
						return awful.rules.match(c, {class = 'Alacritty'}) and c.screen == awful.screen.focused()
				 end
				 awful.client.run_or_raise(terminal, matcher)
			end,
			{description = "open a terminal", group = "launcher"}),
	 awful.key({ modkey, "Shift"   }, "w"     ,
			function ()
				 local matcher = function (c)
						return awful.rules.match(c, {class = 'Firefox'})
				 end
				 awful.client.run_or_raise("firefox-developer-edition", matcher)
			end,
			{description = "Launch Firefox", group = "launcher"}),
	 awful.key({ modkey, "Shift"   }, "e"     ,
			function ()
				 local matcher = function (c)
						return awful.rules.match(c, {class = 'Emacs'})
				 end
				 awful.client.run_or_raise("emacs", matcher)
			end,
			{description = "Launch emacs", group = "launcher"}),

	 -- Manage Awesome
	 awful.key({ modkey, "Shift" }, "r", awesome.restart,
			{description = "reload awesome", group = "awesome"}),
	 awful.key({ modkey, "Shift", "Control"  }, "q", awesome.quit,
			{description = "quit awesome", group = "awesome"}),

	 -- Resize windows
	 awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
			{description = "increase master width factor", group = "layout"}),
	 awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
			{description = "decrease master width factor", group = "layout"}),
	 awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
			{description = "increase the number of master clients", group = "layout"}),
	 awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
			{description = "decrease the number of master clients", group = "layout"}),
	 awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
			{description = "increase the number of columns", group = "layout"}),
	 awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
			{description = "decrease the number of columns", group = "layout"}),

	 -- Change layout
	 awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
			{description = "select next", group = "layout"}),
	 awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
			{description = "select previous", group = "layout"}),

	 -- Restore minimized
	 awful.key({ modkey, "Control" }, "n",
			function ()
				 local c = awful.client.restore()
				 -- Focus restored client
				 if c then
						client.focus = c
						c:raise()
				 end
			end,
			{description = "restore minimized", group = "client"}),

	 -- Prompt
	 awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
			{description = "run prompt", group = "launcher"}),
	 awful.key({ modkey },            "p",     function () awful.spawn("rofi -show run") end,
			{description = "run rofi", group = "launcher"}),

	 -- Other
	 awful.key({ modkey }, "b",
			function ()
				 myscreen = awful.screen.focused()
				 myscreen.mywibox.visible = not myscreen.mywibox.visible
			end,
			{description = "toggle statusbar",group = "awesome"}),
	awful.key({ modkey, "Control" }, "b"  , function () awful.spawn("slock") end,
						{description = "Lock the screen",group = "launcher"})
)

clientkeys = gears.table.join(
	 awful.key({ modkey, "Shift"   }, "b",
			function (c)
				 awful.titlebar.toggle(c)
			end,
			{ description = "Shot titlebar", group = "client"}
	 ),
	 awful.key({ modkey,           }, "f",
			function (c)
				 c.fullscreen = not c.fullscreen
				 c:raise()
			end,
			{description = "toggle fullscreen", group = "client"}),
	 awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
			{description = "close", group = "client"}),
	 awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
			{description = "toggle floating", group = "client"}),
	 awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
			{description = "move to master", group = "client"}),
	 awful.key({ modkey, "Control" }, "o",      function (c) c:move_to_screen()               end,
			{description = "move to screen", group = "client"}),
	 awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
			{description = "toggle keep on top", group = "client"}),
	 awful.key({ modkey,           }, "n",
			function (c)
				 -- The client currently has the input focus, so it cannot be
				 -- minimized, since minimized clients can't have the focus.
				 c.minimized = true
			end ,
			{description = "minimize", group = "client"}),
	 awful.key({ modkey,           }, "m",
			function (c)
				 c.maximized = not c.maximized
				 c:raise()
			end ,
			{description = "(un)maximize", group = "client"}),
	 awful.key({ modkey, "Control" }, "m",
			function (c)
				 c.maximized_vertical = not c.maximized_vertical
				 c:raise()
			end ,
			{description = "(un)maximize vertically", group = "client"}),
	 awful.key({ modkey, "Shift"   }, "m",
			function (c)
				 c.maximized_horizontal = not c.maximized_horizontal
				 c:raise()
			end ,
			{description = "(un)maximize horizontally", group = "client"}),
			awful.key({modkey, },"d",	function (c) resize(c); end,
			{description = "Resize a windows", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	 globalkeys = gears.table.join(globalkeys,
																 -- View tag only.
																 awful.key({ modkey }, "#" .. i + 9,
																		function ()
																			 local screen = awful.screen.focused()
																			 local tag = screen.tags[i]
																			 if tag then
																					tag:view_only()
																			 end
																		end,
																		{description = "view tag #"..i, group = "tag"}),
																 -- Toggle tag display.
																 awful.key({ modkey, "Control" }, "#" .. i + 9,
																		function ()
																			 local screen = awful.screen.focused()
																			 local tag = screen.tags[i]
																			 if tag then
																					awful.tag.viewtoggle(tag)
																			 end
																		end,
																		{description = "toggle tag #" .. i, group = "tag"}),
																 -- Move client to tag.
																 awful.key({ modkey, "Shift" }, "#" .. i + 9,
																		function ()
																			 if client.focus then
																					local tag = client.focus.screen.tags[i]
																					if tag then
																						 client.focus:move_to_tag(tag)
																					end
																			 end
																		end,
																		{description = "move focused client to tag #"..i, group = "tag"}),
																 -- Toggle tag on focused client.
																 awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
																		function ()
																			 if client.focus then
																					local tag = client.focus.screen.tags[i]
																					if tag then
																						 client.focus:toggle_tag(tag)
																					end
																			 end
																		end,
																		{description = "toggle focused client on tag #" .. i, group = "tag"})
	 )
end

clientbuttons = gears.table.join(
	 awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
	 awful.button({ modkey }, 1, awful.mouse.client.move),
	 awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	 -- All clients will match this rule.
	 { rule = { },
		 properties = { border_width = beautiful.border_width,
										border_color = beautiful.border_normal,
										focus = awful.client.focus.filter,
										raise = true,
										keys = clientkeys,
										buttons = clientbuttons,
										screen = awful.screen.preferred,
										size_hints_honor = false,
										placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
	 },

	 -- Floating clients.
	 { rule_any = {
        instance = {
					 "DTA",  -- Firefox addon DownThemAll.
					 "copyq",  -- Includes session name in class.
        },
        class = {
					 "Arandr",
					 "Gpick",
					 "Kruler",
					 "MessageWin",  -- kalarm.
					 "Sxiv",
					 "Wpa_gui",
					 "pinentry",
					 "veromix",
					 "xtightvncviewer"},

        name = {
					 "Event Tester",  -- xev.
        },
        role = {
					 "AlarmWindow",  -- Thunderbird's calendar.
					 "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
	 }, properties = { floating = true }},

	 -- Add titlebars absent clients and dialogs
	 { rule_any = {type = { "normal", "dialog" }
								}, properties = { titlebars_enabled = true }
	 },

	 -- Set Firefox to always map on the tag named "2" on screen 1.
	 -- { rule = { class = "Firefox" },
	 --  properties = { screen = 2, tag = "www" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
												 -- Set the windows at the slave,
												 -- i.e. put it at the end of others instead of setting it master.
												 -- if not awesome.startup then awful.client.setslave(c) end

												 if awesome.startup and
														not c.size_hints.user_position
												 and not c.size_hints.program_position then
														-- Prevent clients from being unreachable after screen count changes.
														awful.placement.no_offscreen(c)
												 end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
												 -- buttons for the titlebar
												 local buttons = gears.table.join(
														awful.button({ }, 1, function()
																	client.focus = c
																	c:raise()
																	awful.mouse.client.move(c)
														end),
														awful.button({ }, 3, function()
																	client.focus = c
																	c:raise()
																	awful.mouse.client.resize(c)
														end)
												 )

												 awful.titlebar(c) : setup
												 {
														{ -- Left
															 awful.titlebar.widget.iconwidget(c),
															 buttons = buttons,
															 layout  = wibox.layout.fixed.horizontal
														},
														{ -- Middle
															 { -- Title
																	align  = "center",
																	widget = awful.titlebar.widget.titlewidget(c)
															 },
															 buttons = buttons,
															 layout  = wibox.layout.flex.horizontal
														},
														{ -- Right
															 awful.titlebar.widget.floatingbutton (c),
															 awful.titlebar.widget.maximizedbutton(c),
															 awful.titlebar.widget.stickybutton   (c),
															 awful.titlebar.widget.ontopbutton    (c),
															 awful.titlebar.widget.closebutton    (c),
															 layout = wibox.layout.fixed.horizontal()
														},
														layout = wibox.layout.align.horizontal
												 }
												 awful.titlebar.hide(c)
												 
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
												 if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
												 and awful.client.focus.filter(c) then
														client.focus = c
												 end
end)

client.connect_signal("focus", function(c) 
												 c.border_color = beautiful.border_focus 
end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
