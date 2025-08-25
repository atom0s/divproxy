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

require 'common';
local ffi   = require 'ffi';
local game  = require 'game';
local imgui = require 'imgui';

ffi.cdef[[
    typedef void (__thiscall* agent_revive_f)(uint32_t);
]];

local cheat = T{
    ptrs = T{
        vtbl = hook.memory.find(0, 0, 'C706????????89BE44030000899E48030000', 2, 0),
    },
};

cheat.load = function ()
    if (not cheat.ptrs:all(function (v) return v ~= nil and v ~= 0; end)) then
        hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, '[cheats.heal_revive] Failed to locate all required pointers!');
        return false;
    end

    cheat.ptrs.vtbl = hook.memory.read_uint32(cheat.ptrs.vtbl);
    if (cheat.ptrs.vtbl == 0) then
        hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, '[cheats.heal_revive] Failed to read valid vtbl pointer!');
        return false;
    end

    return true;
end

cheat.unload = function ()
end

cheat.render = function ()
    imgui.Separator();
    if (imgui.Button('Heal Player')) then
        local player = game.get_agent(game.get_player_index());
        if (player) then
            player.statistics.hp    = player.statistics.max_hit_points;
            player.statistics.mana  = player.statistics.max_mana;
            player.stamina_counter  = player.statistics.max_stamina * 300;
        end
    end
    imgui.SameLine();
    if (imgui.Button('Revive Player')) then
        local player_addr   = game.get_agent_address(game.get_player_index());
        local player        = game.get_agent(game.get_player_index());

        if (player_addr ~= 0 and player ~= nil) then
            -- Update the players health..
            player.statistics.hp = player.statistics.max_hit_points;

            -- Revive the player..
            local func = ffi.cast('agent_revive_f', ffi.cast('uint32_t*', cheat.ptrs.vtbl)[14]);
            func(player_addr);
        end
    end
end

return cheat;