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
local imgui = require 'imgui';

ffi.cdef[[
    typedef uint8_t* (__thiscall* CSpriteContainer_GetShroudBuffer_f)(uint32_t);
]];

local cheat = T{};

local function set_shroud_mask(val)
    local sptr = hook.get_slash_value(0);
    if (sptr == 0) then return; end

    local vtbl = hook.memory.read_uint32(sptr);
    if (vtbl == 0) then return; end

    local func = ffi.cast('CSpriteContainer_GetShroudBuffer_f', hook.memory.read_uint32(vtbl + 0xDC));
    local buff = func(sptr);
    if (buff == 0 or buff == nil) then
        return;
    end

    ffi.fill(buff, 0x80601, val);
end

cheat.load = function ()
    return true;
end

cheat.unload = function ()
end

cheat.render = function ()
    imgui.Separator();
    if (imgui.Button('Reveal Whole Map')) then
        set_shroud_mask(0x00);
    end
    imgui.SameLine();
    if (imgui.Button('Hide Whole Map')) then
        set_shroud_mask(0x0F);
    end
end

return cheat;