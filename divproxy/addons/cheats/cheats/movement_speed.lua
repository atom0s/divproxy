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
local cave  = require 'memory.cave';

local cheat = T{
    ptrs = T{
        movement_speed = hook.memory.find(0, 0, '0FB6BE17020000', 0, 0),
    },
    patches = T{},
    ui = T{
        enabled = T{ false, },
        speed   = T{ 8, },
    },
};

cheat.load = function ()
    if (not cheat.ptrs:all(function (v) return v ~= nil and v ~= 0; end)) then
        hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, '[cheats.movement_speed] Failed to locate all required pointers!');
        return false;
    end

    cheat.patches.movement_speed = cave:new(cheat.ptrs.movement_speed, 7, 2, ([[
        cave_return:
            .db 0x90, 0x90, 0x90, 0x90

        cave_storage:
            .db 8, 0, 0, 0

        cave_start:
            pop     dword ptr [cave_return]
            pushad
            pushfd
            mov     eax, dword ptr [%d]
            mov     eax, dword ptr [eax+%d]
            mov     eax, dword ptr [eax+%d]
            cmp     ax, word ptr [esi+%d]
            jne     cave_skip
            popfd
            popad
            movzx   edi, byte ptr [cave_storage]
            jmp     cave_exit
        cave_skip:
            popfd
            popad
            movzx   edi, byte ptr [esi+0x0217]
        cave_exit:
            push    dword ptr [cave_return]
            ret
    ]]):fmt(
        game.get_player_address(),
        ffi.offsetof('CPlayer', 'party_manager'),
        ffi.offsetof('CPartyManager', 'player_agent_index'),
        ffi.offsetof('CAgent', 'index')
    ));
    cheat.patches.movement_speed:set_offset(8);

    return true;
end

cheat.unload = function ()
    cheat.disable();
end

cheat.enable = function ()
    cheat.patches.movement_speed:enable();
end

cheat.disable = function ()
    cheat.patches.movement_speed:disable();
end

cheat.render = function ()
    if (imgui.Checkbox('Edit Movement Speed', cheat.ui.enabled)) then
        if (cheat.ui.enabled[1]) then
            cheat.enable();
        else
            cheat.disable();
        end
    end
    if (cheat.ui.enabled[1]) then
        if (imgui.SliderInt('Speed', cheat.ui.speed, 1, 100)) then
            hook.memory.write_uint8(cheat.patches.movement_speed:get_cave_address() + 4, cheat.ui.speed[1]);
        end
    end
end

return cheat;