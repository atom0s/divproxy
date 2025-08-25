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

addon.name      = 'debugview';
addon.author    = 'atom0s';
addon.version   = '1.0;'
addon.desc      = 'Debugging tools to view various information about the current game state.';
addon.link      = 'https://atom0s.com';

require 'common';
require 'win32types';

local ffi   = require 'ffi';
local game  = require 'game';
game.settings.use_memory_checks = true;
local imgui = require 'imgui';

local debugview = T{
    gc      = nil,
    tools   = T{},
};

--[[
* Loads the available debug tools from the /tools/ folder.
--]]
debugview.load_tools = function ()
    T(hook.fs.get_dir(addon.path .. '\\tools\\', '.*.lua', true)):each(function (v)
        local tool = T{};
        local s, e = pcall(function ()
            local f = loadfile(('%s\\tools\\%s'):fmt(addon.path, v));
            if (f == nil or type(f) ~= 'function') then
                error('invalid tool file; cannot load');
            end

            tool = f();
            if (tool == nil or type(tool) ~= 'table') then
                error('invalid tool file; expected table return')
            end

            local funcs = T{ 'load', 'unload', 'menu', 'render', };
            funcs:each(function (vv)
                if (tool[vv] == nil or type(tool[vv]) ~= 'function') then
                    error('invalid tool file; missing required function: ' .. vv);
                end
            end);
        end);

        if (s == false or e ~= nil) then
            hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, ('[DebugView] Failed to load tool file \'%s\' due to error:'):fmt(v));
            hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, ('[DebugView] %s'):fmt(e));
            return;
        end

        if (not tool.load()) then
            tool.unload();

            hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, ('[DebugView] Failed to load tool file \'%s\' due to error:'):fmt(v));
            hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, ('[DebugView] %s'):fmt('failed to initialize'));
            return;
        end

        debugview.tools:append(tool);
    end);
end

--[[
* Unloads the currently loaded debug tools.
--]]
debugview.unload_tools = function ()
    debugview.tools:each(function (v)
        v.unload();
    end);
    debugview.tools:clear();
end

--[[
* event: load
* desc : Event called when the addon is first loaded.
--]]
hook.events.register('load', 'load_cb', function ()
    debugview.load_tools();
end);

--[[
* event: d3d_present
* desc : Event called when the game is rendering a frame.
--]]
hook.events.register('d3d_present', 'd3d_present', function (e)
    -- Prevent rendering while game is loading to ensure objects are accessible..
    if (game.get_player().quicksave_load_path ~= 0 or
        game.get_save_manager().is_loading ~= 0) then
        return;
    end

    debugview.tools:each(function (v) v.render(); end);
end);

--[[
* event: main_menu
* desc : Event called when divproxy is rendering its main menu.
--]]
hook.events.register('main_menu', 'main_menu_cb', function ()
    if (imgui.BeginMenu(ICON_FA_BUG .. ' DebugView')) then
        imgui.SeparatorText('Tools');
        if (#debugview.tools > 0) then
            debugview.tools:each(function (v) v.menu(); end);
        else
            imgui.MenuItemEx('No tools loaded.', ICON_FA_TRIANGLE_EXCLAMATION, nil, false, false);
        end
        if (imgui.MenuItemEx('Reload Tools', ICON_FA_RECYCLE, nil, false, true)) then
            debugview.unload_tools();
            debugview.load_tools();
            hook.console.write(T{ 0.0, 1.0, 0.0, 1.0 }, '[DebugView] Tools reloaded!');
        end
        imgui.EndMenu();
    end
end);

-- Cleanup..
debugview.gc = ffi.gc(ffi.cast('uint8_t*', 0), function ()
    debugview.unload_tools();
end);