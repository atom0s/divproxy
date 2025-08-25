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
        gain_experience = hook.memory.find(0, 0, '0181940000008B8994000000894C240C', 0, 0),
    },
    patches = T{},
    ui = T{
        enabled = T{ false, },
        rate    = T{ 1, },
    },
};

cheat.load = function ()
    if (not cheat.ptrs:all(function (v) return v ~= nil and v ~= 0; end)) then
        hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, '[cheats.experience_multiplier] Failed to locate all required pointers!');
        return false;
    end

    cheat.patches.gain_experience = cave:new(cheat.ptrs.gain_experience, 6, 1, [[
        cave_return:
            .db 0x90, 0x90, 0x90, 0x90

        cave_storage:
            .db 8, 0, 0, 0

        cave_start:
            pop     dword ptr [cave_return]
            imul    eax, [cave_storage]
            add     dword ptr [ecx+0x94], eax
            push    dword ptr [cave_return]
            ret
    ]]);
    cheat.patches.gain_experience:set_offset(8);

    return true;
end

cheat.unload = function ()
    cheat.disable();
end

cheat.enable = function ()
    cheat.patches.gain_experience:enable();
end

cheat.disable = function ()
    cheat.patches.gain_experience:disable();
end

cheat.render = function ()
    if (imgui.Checkbox('Experience Multiplier', cheat.ui.enabled)) then
        if (cheat.ui.enabled[1]) then
            cheat.enable();
        else
            cheat.disable();
        end
    end
    if (cheat.ui.enabled[1]) then
        if (imgui.InputInt('Exp. Multiplier', cheat.ui.rate)) then
            if (cheat.ui.rate[1] <= 0) then
                cheat.ui.rate[1] = 1;
            end
            hook.memory.write_uint8(cheat.patches.gain_experience:get_cave_address() + 4, cheat.ui.rate[1]);
        end
    end
end

return cheat;