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
local imgui = require 'imgui';
local cave  = require 'memory.cave';

local cheat = T{
    ptrs = T{
        bonus_points = hook.memory.find(0, 0, '8B0D????????8B04815EC3', 0, 0),
    },
    patches = T{},
    ui = T{
        enabled = T{ false, },
    },
};

cheat.load = function ()
    if (not cheat.ptrs:all(function (v) return v ~= nil and v ~= 0; end)) then
        hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, '[cheats.infinite_bonus_points] Failed to locate all required pointers!');
        return false;
    end

    -- Read the pointer for the statset base..
    local statset_ptr = hook.memory.read_uint32(cheat.ptrs.bonus_points + 2);

    cheat.patches.bonus_points = cave:new(cheat.ptrs.bonus_points, 9, 4, ([[
        cave_return:
            .db 0x90, 0x90, 0x90, 0x90

        cave_start:
            pop     dword ptr [cave_return]
            cmp     edx, 0
            jne     not_player
            mov     ecx, [0x%08X]
            mov     dword ptr [ecx+eax*0x04], 0x63
            mov     eax, [ecx+eax*0x04]
            jmp     cave_exit
        not_player:
            mov     ecx, [0x%08X]
            mov     eax, [ecx+eax*0x04]
        cave_exit:
            push    dword ptr [cave_return]
            ret
    ]]):fmt(statset_ptr, statset_ptr));

    return true;
end

cheat.unload = function ()
    cheat.disable();
end

cheat.enable = function ()
    cheat.patches.bonus_points:enable();
end

cheat.disable = function ()
    cheat.patches.bonus_points:disable();
end

cheat.render = function ()
    if (imgui.Checkbox('Infinite Bonus Points', cheat.ui.enabled)) then
        if (cheat.ui.enabled[1]) then
            cheat.enable();
        else
            cheat.disable();
        end
    end
end

return cheat;