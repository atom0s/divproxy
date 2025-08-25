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

local cheat = T{
    ptrs = T{
        vtbl = hook.memory.find(0, 0, 'C706????????89BEA400000089BEA8000000', 2, 0),
    },
    ui = T{
        enabled = T{ false, },
    },
};

cheat.load = function ()
    if (not cheat.ptrs:all(function (v) return v ~= nil and v ~= 0; end)) then
        hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, '[cheats.one_hit_kills] Failed to locate all required pointers!');
        return false;
    end

    cheat.ptrs.vtbl = hook.memory.read_uint32(cheat.ptrs.vtbl);
    if (cheat.ptrs.vtbl == 0) then
        hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, '[cheats.one_hit_kills] Failed to read valid vtbl pointer!');
        return false;
    end

    cheat.ptrs.cave1 = hook.memory.assembler.cave([[
        mov     eax, dword ptr [esp+0x04]
        sub     dword ptr [eax+0x04], 999999999
        mov     eax, 1
        ret     0x0C
    ]]);
    cheat.ptrs.cave2 = hook.memory.assembler.cave([[
        mov     eax, dword ptr [esp+0x04]
        sub     dword ptr [eax+0x04], 999999999
        mov     eax, 1
        ret     0x0C
    ]]);
    cheat.ptrs.cave3 = hook.memory.assembler.cave([[
        mov     eax, dword ptr [esp+0x04]
        sub     dword ptr [eax+0x04], 999999999
        mov     eax, 1
        ret     0x0C
    ]]);
    cheat.ptrs.cave4 = hook.memory.assembler.cave([[
        mov     eax, dword ptr [esp+0x04]
        sub     dword ptr [eax+0x04], 999999999
        mov     eax, 1
        ret     0x0C
    ]]);
    cheat.ptrs.cave5 = hook.memory.assembler.cave([[
        mov     eax, dword ptr [esp+0x04]
        sub     dword ptr [eax+0x04], 999999999
        mov     eax, 1
        ret     0x08
    ]]);

    return true;
end

cheat.unload = function ()
    cheat.disable();

    hook.memory.assembler.release(cheat.ptrs.cave1);
    hook.memory.assembler.release(cheat.ptrs.cave2);
    hook.memory.assembler.release(cheat.ptrs.cave3);
    hook.memory.assembler.release(cheat.ptrs.cave4);
    hook.memory.assembler.release(cheat.ptrs.cave5);
end

cheat.enable = function ()
    if (cheat.ptrs.vtbl == 0 or cheat.ptrs.cave1 == 0 or cheat.ptrs.cave2 == 0 or cheat.ptrs.cave3 == 0 or cheat.ptrs.cave3 == 0 or cheat.ptrs.cave4 == 0) then
        cheat.ui.enabled[1] = false;
        return;
    end

    local ret, prot = hook.memory.unprotect(cheat.ptrs.vtbl, 0x100);
    if (not ret) then
        cheat.ui.enabled[1] = false;
        hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, '[cheats.one_hit_kills] Failed to unprotect vtbl memory!');
        return;
    end

    local vtbl = ffi.cast('uint32_t*', cheat.ptrs.vtbl);

    cheat.ptrs.backup1 = vtbl[0x03];
    cheat.ptrs.backup2 = vtbl[0x04];
    cheat.ptrs.backup3 = vtbl[0x05];
    cheat.ptrs.backup4 = vtbl[0x07];
    cheat.ptrs.backup5 = vtbl[0x08];

    vtbl[0x03] = cheat.ptrs.cave1;
    vtbl[0x04] = cheat.ptrs.cave2;
    vtbl[0x05] = cheat.ptrs.cave3;
    vtbl[0x07] = cheat.ptrs.cave4;
    vtbl[0x08] = cheat.ptrs.cave5;

    hook.memory.protect(cheat.ptrs.vtbl, 0x100, prot);
end

cheat.disable = function ()
    if (cheat.ptrs.vtbl == 0) then
        return;
    end

    local ret, prot = hook.memory.unprotect(cheat.ptrs.vtbl, 0x100);
    if (not ret) then
        hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, '[cheats.one_hit_kills] Failed to unprotect vtbl memory!');
        return;
    end

    local vtbl = ffi.cast('uint32_t*', cheat.ptrs.vtbl);

    if (cheat.ptrs.backup1 ~= nil) then vtbl[0x03] = cheat.ptrs.backup1; end
    if (cheat.ptrs.backup2 ~= nil) then vtbl[0x04] = cheat.ptrs.backup2; end
    if (cheat.ptrs.backup3 ~= nil) then vtbl[0x05] = cheat.ptrs.backup3; end
    if (cheat.ptrs.backup4 ~= nil) then vtbl[0x07] = cheat.ptrs.backup4; end
    if (cheat.ptrs.backup5 ~= nil) then vtbl[0x08] = cheat.ptrs.backup5; end

    cheat.ptrs.backup1 = nil;
    cheat.ptrs.backup2 = nil;
    cheat.ptrs.backup3 = nil;
    cheat.ptrs.backup4 = nil;
    cheat.ptrs.backup5 = nil;

    hook.memory.protect(cheat.ptrs.vtbl, 0x100, prot);
end

cheat.render = function ()
    if (imgui.Checkbox('One Hit Kills', cheat.ui.enabled)) then
        if (cheat.ui.enabled[1]) then
            cheat.enable();
        else
            cheat.disable();
        end
    end
end

return cheat;