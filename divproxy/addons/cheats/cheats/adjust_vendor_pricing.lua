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
        buy_rate    = hook.memory.find(0, 0, 'D9870C020000D95C2428D9EE', 0, 0),
        sell_rate   = hook.memory.find(0, 0, 'D98708020000D95C242C', 0, 0),
    },
    patches = T{},
    ui = T{
        enabled     = T{ false, },
        buy_rate    = T{ 1, },
        sell_rate   = T{ 1, },
    },
};

cheat.load = function ()
    if (not cheat.ptrs:all(function (v) return v ~= nil and v ~= 0; end)) then
        hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, '[cheats.adjust_vendor_pricing] Failed to locate all required pointers!');
        return false;
    end

    cheat.patches.buy_rate = cave:new(cheat.ptrs.buy_rate, 6, 1, [[
        cave_return:
            .db 0x90, 0x90, 0x90, 0x90

        cave_storage:
            .db 0x00, 0x00, 0x00, 0x3F

        cave_start:
            pop     dword ptr [cave_return]
            fld     dword ptr [cave_storage]
            push    dword ptr [cave_return]
            ret
    ]]);
    cheat.patches.buy_rate:set_offset(8);

    cheat.patches.sell_rate = cave:new(cheat.ptrs.sell_rate, 6, 1, [[
        cave_return:
            .db 0x90, 0x90, 0x90, 0x90

        cave_storage:
            .db 0x00, 0x00, 0x00, 0x3F

        cave_start:
            pop     dword ptr [cave_return]
            fld     dword ptr [cave_storage]
            push    dword ptr [cave_return]
            ret
    ]]);
    cheat.patches.sell_rate:set_offset(8);

    return true;
end

cheat.unload = function ()
    cheat.disable();
end

cheat.enable = function ()
    cheat.patches.buy_rate:enable();
    cheat.patches.sell_rate:enable();
end

cheat.disable = function ()
    cheat.patches.buy_rate:disable();
    cheat.patches.sell_rate:disable();
end

cheat.render = function ()
    if (imgui.Checkbox('Adjust Vendor Rates', cheat.ui.enabled)) then
        if (cheat.ui.enabled[1]) then
            cheat.enable();
        else
            cheat.disable();
        end
    end
    if (cheat.ui.enabled[1]) then
        if (imgui.InputFloat('Buy Rate', cheat.ui.buy_rate)) then
            if (cheat.ui.buy_rate[1] <= 0) then
                cheat.ui.buy_rate[1] = 1.0;
            end
            hook.memory.write_float(cheat.patches.buy_rate:get_cave_address() + 4, cheat.ui.buy_rate[1]);
        end
        if (imgui.InputFloat('Sell Rate', cheat.ui.sell_rate)) then
            if (cheat.ui.sell_rate[1] <= 0) then
                cheat.ui.sell_rate[1] = 1.0;
            end
            hook.memory.write_float(cheat.patches.sell_rate:get_cave_address() + 4, cheat.ui.sell_rate[1]);
        end
    end
end

return cheat;