-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
awful.autofocus = require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
local vicious = require("vicious")
local radical = require("radical")
local obvious = require("obvious")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local lain = require("lain")

awesome.font = "Ubuntu 14"

-- Quake Console
local scratch = require("scratch")

-- Load Debian menu entries
require("debian.menu")

local context = {

}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
   naughty.notify({ preset = naughty.config.presets.critical,
                    title = "Oops, there were errors during startup!",
                    text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
   local in_error = false
   awesome.connect_signal("debug::error", function (err)
                             -- Make sure we don't go into an endless error loop
                             if in_error then return end
                             in_error = true

                             naughty.notify({ preset = naughty.config.presets.critical,
                                              title = "Oops, an error happened!",
                                              text = err })
                             in_error = false
   end)
end
-- }}}

local config = require('config')
config.autorun.init(context)
config.keybinds.init(context)
config.rules.init(context)



-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
-- beautiful.init("~/.config/awesome/themes/default/theme.lua")
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/powerarrow-darker/theme.lua")

-- This is used later as the default terminal and editor to run.
-- terminal = "terminator"

--common
modkey = "Mod4"
altkey = "Mod1"
terminal = 'urxvt'
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor


-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts = {
   awful.layout.suit.floating,
   awful.layout.suit.tile,
   awful.layout.suit.tile.left,
   awful.layout.suit.tile.bottom,
   awful.layout.suit.tile.top,
   awful.layout.suit.fair,
   awful.layout.suit.fair.horizontal,
   awful.layout.suit.max,
   awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
   for s = 1, screen.count() do
      gears.wallpaper.maximized(beautiful.wallpaper, s, true)
   end
end


-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
   -- Each screen has its own tag table.
   tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- {{{ Wibox
markup = lain.util.markup

-- Textclock
clockicon = wibox.widget.imagebox(beautiful.widget_clock)
mytextclock = awful.widget.textclock("%a %b %d, %I:%M")

-- MEM
memicon = wibox.widget.imagebox(beautiful.widget_mem)
memwidget = lain.widgets.mem({
      settings = function()
         widget:set_text(" " .. mem_now.used .. "MB ")
      end
})

-- CPU
cpuicon = wibox.widget.background(wibox.widget.imagebox(
                                     beautiful.widget_cpu),
                                  "#313131")

cpuwidget = wibox.widget.background(lain.widgets.cpu({
                                          settings = function()
                                             widget:set_text(" " .. cpu_now.usage .. "% ")
                                          end
                                                    }), "#313131")

-- Coretemp
tempicon = wibox.widget.imagebox(beautiful.widget_temp)
tempwidget = lain.widgets.temp({
      settings = function()
         widget:set_text(" " .. coretemp_now .. "°C ")
      end
})

-- / fs
fsicon = wibox.widget.background(wibox.widget.imagebox(
                                    beautiful.widget_hdd),
                                 "#313131")

fswidget = lain.widgets.fs({
      settings  = function()
         widget:set_text(" " .. fs_now.used .. "% ")
      end
})
fswidgetbg = wibox.widget.background(fswidget, "#313131")

-- Battery
baticon = wibox.widget.imagebox(beautiful.widget_battery)
batwidget = lain.widgets.bat({
      settings = function()
         if bat_now.perc == "N/A" then
            widget:set_markup(" AC ")
            baticon:set_image(beautiful.widget_ac)
            return
         elseif tonumber(bat_now.perc) <= 5 then
            baticon:set_image(beautiful.widget_battery_empty)
         elseif tonumber(bat_now.perc) <= 15 then
            baticon:set_image(beautiful.widget_battery_low)
         else
            baticon:set_image(beautiful.widget_battery)
         end
         widget:set_markup(" " .. bat_now.perc .. "% ")
      end
})

-- ALSA volume
volicon = wibox.widget.imagebox(beautiful.widget_vol)
volumewidget = lain.widgets.alsa({
      settings = function()
         if volume_now.status == "off" then
            volicon:set_image(beautiful.widget_vol_mute)
         elseif tonumber(volume_now.level) == 0 then
            volicon:set_image(beautiful.widget_vol_no)
         elseif tonumber(volume_now.level) <= 50 then
            volicon:set_image(beautiful.widget_vol_low)
         else
            volicon:set_image(beautiful.widget_vol)
         end

         widget:set_text(" " .. volume_now.level .. "% ")
      end
})
volumewidgetbg = wibox.widget.background(volumewidget, "#313131")

-- Net
neticon = wibox.widget.imagebox(beautiful.widget_net)
neticon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(iptraf) end)))
netwidget = wibox.widget.background(lain.widgets.net({
                                          settings = function()
                                             widget:set_markup(markup("#7AC82E", " " .. net_now.received)
                                                                  .. " " ..
                                                                  markup("#46A8C3", " " .. net_now.sent .. " "))
                                          end
                                                    }), "#313131")

mysystray = wibox.widget.systray()
theme.bg_systray = "#313131"

-- Separators
spr = wibox.widget.textbox(' ')
arrl = wibox.widget.imagebox()
arrl:set_image(beautiful.arrl)
arrl_dl = wibox.widget.imagebox()
arrl_dl:set_image(beautiful.arrl_dl)
arrl_ld = wibox.widget.imagebox()
arrl_ld:set_image(beautiful.arrl_ld)


-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}

mytaglist.buttons = awful.util.table.join(
   awful.button({ }, 1, awful.tag.viewonly),
   awful.button({ modkey }, 1, awful.client.movetotag),
   awful.button({ }, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, awful.client.toggletag),
   awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
   awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
   awful.button({ }, 1, function (c)
         if c == client.focus then
            c.minimized = true
         else
            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() then
               awful.tag.viewonly(c:tags()[1])
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
         end
   end),
   awful.button({ }, 3, function ()
         if instance then
            instance:hide()
            instance = nil
         else
            instance = awful.menu.clients({ width=250 })
         end
   end),
   awful.button({ }, 4, function ()
         awful.client.focus.byidx(1)
         if client.focus then client.focus:raise() end
   end),
   awful.button({ }, 5, function ()
         awful.client.focus.byidx(-1)
         if client.focus then client.focus:raise() end
end))

for s = 1, screen.count() do
   -- Create a promptbox for each screen
   mypromptbox[s] = awful.widget.prompt()
   -- Create an imagebox widget which will contains an icon indicating which layout we're using.
   -- We need one layoutbox per screen.
   mylayoutbox[s] = awful.widget.layoutbox(s)
   mylayoutbox[s]:buttons(awful.util.table.join(
                             awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                             awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                             awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                             awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
   -- Create a taglist widget
   mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

   -- Create a tasklist widget
   mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

   -- Create the wibox
   mywibox[s] = awful.wibox({ position = "top", screen = s })

   -- Widgets that are aligned to the left
   local left_layout = wibox.layout.fixed.horizontal()
   left_layout:add(mylauncher)
   left_layout:add(spr)
   left_layout:add(mytaglist[s])
   left_layout:add(mypromptbox[s])
   left_layout:add(spr)

   -- Widgets that are aligned to the right
   local right_layout = wibox.layout.fixed.horizontal()
   right_layout:add(spr)
   right_layout:add(arrl)
   right_layout:add(arrl_ld)
   right_layout:add(wibox.widget.background(volicon, "#313131"))
   right_layout:add(volumewidgetbg)
   right_layout:add(arrl_dl)
   right_layout:add(memicon)
   right_layout:add(memwidget)
   right_layout:add(arrl_ld)
   right_layout:add(cpuicon)
   right_layout:add(cpuwidget)
   right_layout:add(arrl_dl)
   right_layout:add(tempicon)
   right_layout:add(tempwidget)
   right_layout:add(arrl_ld)
   right_layout:add(fsicon)
   right_layout:add(fswidgetbg)
   right_layout:add(arrl_dl)
   right_layout:add(baticon)
   right_layout:add(batwidget)
   right_layout:add(arrl_ld)
   if s == 1 then right_layout:add(mysystray) end
   right_layout:add(arrl_dl)
   right_layout:add(mytextclock)
   right_layout:add(spr)
   right_layout:add(arrl_ld)
   right_layout:add(mylayoutbox[s])

   -- Now bring it all together (with the tasklist in the middle)
   local layout = wibox.layout.align.horizontal()
   layout:set_left(left_layout)
   layout:set_middle(mytasklist[s])
   layout:set_right(right_layout)

   mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
                         -- Enable sloppy focus
                         c:connect_signal("mouse::enter", function(c)
                                             if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
                                             and awful.client.focus.filter(c) then
                                                client.focus = c
                                             end
                         end)

                         if not startup then
                            -- Set the windows at the slave,
                            -- i.e. put it at the end of others instead of setting it master.
                            -- awful.client.setslave(c)

                            -- Put windows in a smart way, only if they does not set an initial position.
                            if not c.size_hints.user_position and not c.size_hints.program_position then
                               awful.placement.no_overlap(c)
                               awful.placement.no_offscreen(c)
                            end
                         end

                         local titlebars_enabled = false
                         if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
                            -- buttons for the titlebar
                            local buttons = awful.util.table.join(
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

                            -- Widgets that are aligned to the left
                            local left_layout = wibox.layout.fixed.horizontal()
                            left_layout:add(awful.titlebar.widget.iconwidget(c))
                            left_layout:buttons(buttons)

                            -- Widgets that are aligned to the right
                            local right_layout = wibox.layout.fixed.horizontal()
                            right_layout:add(awful.titlebar.widget.floatingbutton(c))
                            right_layout:add(awful.titlebar.widget.maximizedbutton(c))
                            right_layout:add(awful.titlebar.widget.stickybutton(c))
                            right_layout:add(awful.titlebar.widget.ontopbutton(c))
                            right_layout:add(awful.titlebar.widget.closebutton(c))

                            -- The title goes in the middle
                            local middle_layout = wibox.layout.flex.horizontal()
                            local title = awful.titlebar.widget.titlewidget(c)
                            title:set_align("center")
                            middle_layout:add(title)
                            middle_layout:buttons(buttons)

                            -- Now bring it all together
                            local layout = wibox.layout.align.horizontal()
                            layout:set_left(left_layout)
                            layout:set_right(right_layout)
                            layout:set_middle(middle_layout)

                            awful.titlebar(c):set_widget(layout)
                         end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
