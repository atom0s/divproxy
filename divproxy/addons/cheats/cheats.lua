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

addon.name      = 'cheats';
addon.author    = 'atom0s';
addon.version   = '1.0;'
addon.desc      = 'Implements various cheats.';
addon.link      = 'https://atom0s.com';

require 'common';
require 'win32types';

local ffi   = require 'ffi';
local imgui = require 'imgui';

local window = T{
    is_open = T{ true, },
    cheats  = T{},
    gc      = nil,
};

--[[
* event: load
* desc : Event called when the addon is first loaded.
--]]
hook.events.register('load', 'load_cb', function ()
    local cheat_list = T{
        'infinite_health.lua',
        'infinite_mana.lua',
        'infinite_stamina.lua',
        'infinite_skill_points.lua',
        'infinite_bonus_points.lua',
        'one_hit_kills.lua',
        'super_potions.lua',
        'unlimited_carry_weight.lua',
        'sleep_anywhere_anytime.lua',
        'experience_multiplier.lua',
        'movement_speed.lua',
        'adjust_vendor_pricing.lua',
        'reveal_map.lua',
        'heal_revive.lua',
        'repair.lua',
    };

    cheat_list:each(function (v)
        local cheat = T{};
        local s, e = pcall(function ()
            local f = loadfile(('%s\\cheats\\%s'):fmt(addon.path, v));
            if (f == nil or type(f) ~= 'function') then
                error('invalid cheat file detected; cannot load');
            end

            cheat = f();
            if (cheat == nil or type(cheat) ~= 'table') then
                error('invalid cheat file detected; expected table return');
            end

            local funcs = T{ 'load', 'unload', 'render' };
            funcs:each(function (vv)
                if (cheat[vv] == nil or type(cheat[vv]) ~= 'function') then
                    error(('invalid cheat file detected; missing required function: %s'):fmt(vv));
                end
            end);
        end);

        if (s == false or e ~= nil) then
            hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, ('[cheats] Failed to load cheat file \'%s\' due to error:'):fmt(v));
            hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, ('[cheats] %s'):fmt(e));
            return;
        end

        if (not cheat.load()) then
            cheat.unload();

            hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, ('[cheats] Failed to load cheat file \'%s\' due to error:'):fmt(v));
            hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, '[cheats] Failed to initialize.');
            return;
        end

        window.cheats:append(cheat);
    end);

    hook.console.write(T{ 0.0, 0.8, 1.0, 1.0 }, '[cheats] Use \'/cheats\' in the console to toggle window!');
end);

--[[
* event: command
* desc : Event called when an unhandled command is passed to the console.
--]]
hook.events.register('command', 'command_cb', function (e)
    local args = e.command:args();
    if (#args == 0 or args[1] ~= '/cheats') then
        return;
    end

    e.blocked = true;

    window.is_open[1] = not window.is_open[1];
end);

--[[
* event: d3d_present
* desc : Event called when the game is rendering a frame.
--]]
hook.events.register('d3d_present', 'd3d_present_cb', function ()
    if (not window.is_open[1]) then
        return;
    end
    if (imgui.Begin('Cheats :: by atom0s', window.is_open, ImGuiWindowFlags_AlwaysAutoResize)) then
        window.cheats:each(function (v)
            v.render();
        end);
    end
    imgui.End();
end);

-- Cleanup..
window.gc = ffi.gc(ffi.cast('uint8_t*', 0), function ()
    window.cheats:each(function (v)
        v.unload();
    end);
end);