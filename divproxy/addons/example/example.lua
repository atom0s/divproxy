--[[
* divproxy - Copyright (c) 2025 atom0s [atom0s@live.com]
*
* Contact: https://www.atom0s.com/
* Contact: https://discord.gg/UmXNvjq
* Contact: https://github.com/atom0s
* Support: https://paypal.me/atom0s
* Support: https://patreon.com/atom0s
* Support: https://github.com/sponsors/atom0s
*
* This file is part of divproxy.
*
* divproxy is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* divproxy is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero General Public License for more details.
*
* You should have received a copy of the GNU Affero General Public License
* along with divproxy.  If not, see <https://www.gnu.org/licenses/>.
--]]

addon.name      = 'example';
addon.author    = 'atom0s';
addon.version   = '1.0;'
addon.desc      = 'Example addon demonstrating the available events.';
addon.link      = 'https://atom0s.com';

require 'common';
local ffi   = require 'ffi';
local imgui = require 'imgui';

-- Example window variables..
local window = T{
    is_open = T{ true },
};

--[[
* event: load
* desc : Event called when the addon is first loaded.
--]]
hook.events.register('load', 'load_cb', function ()
    print('[example] Example addon has been loaded!');
end);

--[[
* event: unload
* desc : Event called when the addon is unloaded.
--]]
hook.events.register('unload', 'unload_cb', function ()
    print('[example] Example addon has been unloaded!');
end);

--[[
* event: command
* desc : Event called when an unhandled command is passed to the console.
--]]
hook.events.register('command', 'command_cb', function (e)
    --[[ Valid Arguments

    e.command - (ReadOnly) The command string entered into the console.
    e.blocked - (Writable) Flag that states if the command has been, or should be, blocked.
    --]]

    -- Ignore already handled commands..
    if (e.blocked) then
        return;
    end

    -- Parse the command for arguments..
    local args = e.command:args();

    -- Only handle commands that start with /example..
    if (#args == 0 or args[1] ~= '/example') then
        return;
    end

    -- Mark all /example commands as handled..
    e.blocked = true;

    -- Handle: /example
    if (#args == 1) then
        print('[example] Example command executed! (With no arguments!)');
        return;
    end

    -- Handle: /example derp
    if (#args == 2 and args[2]:any('derp')) then
        print('[example] Example command executed! (With `derp` argument!)');
        return;
    end

    -- Handle: /example window
    if (#args == 2 and args[2]:any('window')) then
        -- Toggle the window visibility..
        window.is_open[1] = not window.is_open[1];
        return;
    end

    -- Handle unknown /example commands..
    print('[example] Unknown /example command!');
end);

--[[
* event: d3d_present
* desc : Event called when the game is rendering a frame.
--]]
hook.events.register('d3d_present', 'd3d_present_cb', function ()
    if (not window.is_open[1]) then
        return;
    end

    -- Display a simple window with ImGui..
    if (imgui.Begin('Example Window', window.is_open)) then
        imgui.Text('Hello world, from the example addon!');
        if (imgui.Button('Press Me')) then
            print('[example] Button was pressed!');
        end
    end
    imgui.End();
end);

--[[
* event: main_menu
* desc : Event called when divproxy is rendering its main menu.
--]]
hook.events.register('main_menu', 'main_menu_cb', function ()
    --[[
    Note: This is called within a BeginMainMenu/EndMainMenu block!
    --]]

    if (imgui.BeginMenu(ICON_FA_BOLT .. 'Example: Menu')) then
        if (imgui.Selectable(ICON_FA_BOLT .. 'Example: Print To Console')) then
            print('[example] Menu item was clicked!');
        end
        imgui.EndMenu();
    end
end);

--[[
* event: key
* desc : Event called when a key event is sent to the game window.
--]]
hook.events.register('key', 'key_cb', function (e)
    --[[ Valid Arguments

    e.hwnd      - (ReadOnly) The command string entered into the console.
    e.msg       - (ReadOnly) The event message.
    e.wparam    - (ReadOnly) The event WPARAM value.
    e.lparam    - (ReadOnly) The event LPARAM value.
    e.blocked   - (Writable) Flag that states if the input has been, or should be, blocked.
    --]]

    -- Ignore already blocked messages..
    if (e.blocked) then
        return true;
    end

    -- Check for WM_KEYUP press for F1..
    if (e.msg == 0x0101 and e.wparam == 0x70) then
        print('[example] Key event: WM_KEYUP - F1 was pressed!');
    end
end);

--[[
* event: mouse
* desc : Event called when a mouse event is sent to the game window.
--]]
hook.events.register('mouse', 'mouse_cb', function (e)
    --[[ Valid Arguments

    e.hwnd      - (ReadOnly) The command string entered into the console.
    e.msg       - (ReadOnly) The event message.
    e.wparam    - (ReadOnly) The event WPARAM value.
    e.lparam    - (ReadOnly) The event LPARAM value.
    e.blocked   - (Writable) Flag that states if the input has been, or should be, blocked.
    --]]

    -- Ignore already blocked messages..
    if (e.blocked) then
        return true;
    end

    -- Check for WM_MOUSEHWHEEL events..
    if (e.msg == 0x020A) then

        -- Obtain the mouse event properties..
        local delta = tonumber(ffi.cast('int16_t', bit.band(bit.rshift(e.wparam, 16), 0xFFFF)));
        local x     = tonumber(ffi.cast('int16_t', bit.band(e.lparam, 0xFFFF)));
        local y     = tonumber(ffi.cast('int16_t', bit.band(bit.rshift(e.lparam, 16), 0xFFFF)));

        print(('[example] Mouse event: WM_MOUSEHWHEEL - Mouse wheel was scrolled %s at %d x %d!'):fmt(delta > 0 and 'up' or 'down', x, y));
    end
end);