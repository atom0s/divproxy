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
    typedef void (__thiscall* CPlayer_UpdateUi)(uint32_t);
]];

local cheat = T{
    ptrs = T{
        update_ui = hook.memory.find(0, 0, '8B81B40400008B48108B15????????8B420C53558B2C888B', 0, 0),
    },
};

cheat.load = function ()
    if (not cheat.ptrs:all(function (v) return v ~= nil and v ~= 0; end)) then
        hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, '[cheats.repair] Failed to locate all required pointers!');
        return false;
    end
    return true;
end

cheat.unload = function ()
end

cheat.render = function ()
    imgui.Separator();
    if (imgui.Button('Repair Equipment')) then
        local player = game.get_agent(game.get_player_index());
        if (player ~= nil and player.statistics ~= nil) then
            local equip = player.statistics.equipment;
            for x = 0, 10 do
                if (equip[x] ~= nil) then
                    equip[x].durability_current = equip[x].durability_max;
                end
            end
        end

        -- Update the UI buttons..
        ffi.cast('CPlayer_UpdateUi', cheat.ptrs.update_ui)(hook.memory.read_uint32(game.get_player_address()));
    end
end

return cheat;