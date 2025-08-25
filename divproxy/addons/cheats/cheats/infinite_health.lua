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

local cheat = T{
    ptrs = T{
        vtbl = hook.memory.find(0, 0, 'C706????????89BE44030000899E48030000', 2, 0),
    },
    ui = T{
        enabled = T{ false, },
    },
};

cheat.load = function ()
    if (not cheat.ptrs:all(function (v) return v ~= nil and v ~= 0; end)) then
        hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, '[cheats.infinite_health] Failed to locate all required pointers!');
        return false;
    end

    cheat.ptrs.vtbl = hook.memory.read_uint32(cheat.ptrs.vtbl);
    if (cheat.ptrs.vtbl == 0) then
        hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, '[cheats.infinite_health] Failed to read valid vtbl pointer!');
        return false;
    end

    cheat.ptrs.cave1 = hook.memory.assembler.cave([[
        xor     eax, eax
        ret     0x10
    ]]);
    cheat.ptrs.cave2 = hook.memory.assembler.cave([[
        xor     eax, eax
        ret     0x14
    ]]);

    return true;
end

cheat.unload = function ()
    cheat.disable();

    hook.memory.assembler.release(cheat.ptrs.cave1);
    hook.memory.assembler.release(cheat.ptrs.cave2);
end

cheat.enable = function ()
    if (cheat.ptrs.vtbl == 0 or cheat.ptrs.cave1 == 0 or cheat.ptrs.cave2 == 0) then
        cheat.ui.enabled[1] = false;
        return;
    end

    local ret, prot = hook.memory.unprotect(cheat.ptrs.vtbl, 0x100);
    if (not ret) then
        cheat.ui.enabled[1] = false;
        hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, '[cheats.infinite_health] Failed to unprotect vtbl memory!');
        return;
    end

    local vtbl = ffi.cast('uint32_t*', cheat.ptrs.vtbl);

    cheat.ptrs.backup1 = vtbl[0x08];
    cheat.ptrs.backup2 = vtbl[0x09];
    cheat.ptrs.backup3 = vtbl[0x0A];

    vtbl[0x08] = cheat.ptrs.cave1;
    vtbl[0x09] = cheat.ptrs.cave1;
    vtbl[0x0A] = cheat.ptrs.cave2;

    hook.memory.protect(cheat.ptrs.vtbl, 0x100, prot);

    local player = game.get_agent(game.get_player_index());
    if (player) then
        player.statistics.hp = player.statistics.max_hit_points;
    end
end

cheat.disable = function ()
    if (cheat.ptrs.vtbl == 0) then
        return;
    end

    local ret, prot = hook.memory.unprotect(cheat.ptrs.vtbl, 0x100);
    if (not ret) then
        hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, '[cheats.infinite_health] Failed to unprotect vtbl memory!');
        return;
    end

    local vtbl = ffi.cast('uint32_t*', cheat.ptrs.vtbl);

    if (cheat.ptrs.backup1 ~= nil) then vtbl[0x08] = cheat.ptrs.backup1; end
    if (cheat.ptrs.backup2 ~= nil) then vtbl[0x09] = cheat.ptrs.backup2; end
    if (cheat.ptrs.backup3 ~= nil) then vtbl[0x0A] = cheat.ptrs.backup3; end

    cheat.ptrs.backup1 = nil;
    cheat.ptrs.backup2 = nil;
    cheat.ptrs.backup3 = nil;

    hook.memory.protect(cheat.ptrs.vtbl, 0x100, prot);
end

cheat.render = function ()
    if (imgui.Checkbox('Infinite Health', cheat.ui.enabled)) then
        if (cheat.ui.enabled[1]) then
            cheat.enable();
        else
            cheat.disable();
        end
    end
end

return cheat;