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
local patch = require 'memory.patch';

local cheat = T{
    ptrs = T{
        check_ownership = hook.memory.find(0, 0, '74??6A1A55E8????????0FB7', 0, 0),
        check_time      = hook.memory.find(0, 0, '75??83BEE40200000074??6A5C', 0, 0),
    },
    patches = T{},
    ui = T{
        enabled = T{ false, },
    },
};

cheat.load = function ()
    if (not cheat.ptrs:all(function (v) return v ~= nil and v ~= 0; end)) then
        hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, '[cheats.sleep_anywhere_anytime] Failed to locate all required pointers!');
        return false;
    end

    cheat.patches.check_ownership   = patch:new(cheat.ptrs.check_ownership, T{ 0xEB, 0x3A, });
    cheat.patches.check_time        = patch:new(cheat.ptrs.check_time, T{ 0xEB, 0x32, });

    return true;
end

cheat.unload = function ()
    cheat.disable();
end

cheat.enable = function ()
    cheat.patches.check_ownership:enable();
    cheat.patches.check_time:enable();
end

cheat.disable = function ()
    cheat.patches.check_ownership:disable();
    cheat.patches.check_time:disable();
end

cheat.render = function ()
    if (imgui.Checkbox('Sleep Anywhere/Anytime', cheat.ui.enabled)) then
        if (cheat.ui.enabled[1]) then
            cheat.enable();
        else
            cheat.disable();
        end
    end
end

return cheat;