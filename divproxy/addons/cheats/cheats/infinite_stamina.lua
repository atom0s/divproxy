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
local game  = require 'game';
local imgui = require 'imgui';
local cave  = require 'memory.cave';

local cheat = T{
    ptrs = T{
        stamina = hook.memory.find(0, 0, '01BE540300008B839000000069C02C010000', 0, 0),
    },
    patches = T{},
    ui = T{
        enabled = T{ false, },
    },
};

cheat.load = function ()
    if (not cheat.ptrs:all(function (v) return v ~= nil and v ~= 0; end)) then
        hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, '[cheats.infinite_stamina] Failed to locate all required pointers!');
        return false;
    end

    cheat.patches.stamina = cave:new(cheat.ptrs.stamina, 6, 1, [[
        cave_return:
            .db 0x90, 0x90, 0x90, 0x90

        cave_start:
            pop     dword ptr [cave_return]
            mov     edi, 0x7A120
            mov     [esi+0x0354], edi
            push    dword ptr [cave_return]
            ret
    ]]);

    return true;
end

cheat.unload = function ()
    cheat.disable();
end

cheat.enable = function ()
    cheat.patches.stamina:enable();

    local player = game.get_agent(game.get_player_index());
    if (player) then
        player.stamina_counter = player.statistics.max_stamina * 300;
    end
end

cheat.disable = function ()
    cheat.patches.stamina:disable();
end

cheat.render = function ()
    if (imgui.Checkbox('Infinite Stamina', cheat.ui.enabled)) then
        if (cheat.ui.enabled[1]) then
            cheat.enable();
        else
            cheat.disable();
        end
    end
end

return cheat;