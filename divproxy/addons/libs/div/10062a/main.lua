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
local C     = ffi.C;

-- Game Table Definition
game = game or T{};
game.settings = T{
    --[[
    * use_memory_checks (boolean) - Default: false
    *
    *   Enables additional safety checks when accessing certain types of memory values with
    *   LuaJIT's FFI library. [Overrides: ffi.cast, ffi.string]
    --]]
    use_memory_checks = false,
};

--[[
* Pointer & Type Definitons
*
* The following list of files are included into the global namespace to define the various
* pointers and type definitions used with this SDK. Additional functionality is also exposed
* through the 'game' namespace table, such as accessing various game manager objects.
*
* Please Note:
*
*   The order in which these files are included matters and SHOULD NOT be edited!
--]]

T{
    -- Pointers
    'div.10062a.pointers',

    -- Types
    'div.10062a.types.common',
    'div.10062a.types.files',
    'div.10062a.types.savemanager',
    'div.10062a.types.world',
    'div.10062a.types.object',
    'div.10062a.types.inventorymanager',
    'div.10062a.types.item',
    'div.10062a.types.alignmentmanager',
    'div.10062a.types.agentstatistics',
    'div.10062a.types.agentclass',
    'div.10062a.types.agent',
    'div.10062a.types.partymanager',
    'div.10062a.types.player',
    'div.10062a.types.agentmanager',
    'div.10062a.types.gameclock',
    'div.10062a.types.timemanager',
    'div.10062a.types.configlcl',
    'div.10062a.types.objectmanager',
}:each(function (v) require(v); end);

--[[
* FFI Memory Protection Assistance
*
* The following code is used to help prevent unwanted crashes due to invalid memory access
* read/write attempts that can happen when using LuaJIT's FFI module. By default, LuaJIT
* does not have any kind of safety measures in place to prevent invalid memory access
* when using calls such as 'ffi.string'. Due to this, it is possible that the current
* addon, or even the full client, will crash due to a bad read/write attempt.
*
* This feature is off by default but can be enabled as follows:
*
*       require 'game';
*       game.settings.use_memory_checks = true;
*
* WARNING: Using this feature will cause some LuaJIT FFI functions to behave differently
* when they would otherwise cause crashes or exceptions to happen!
--]]

ffi.cdef[[

    typedef struct MEMORY_BASIC_INFORMATION
    {
        void*       BaseAddress;
        void*       AllocationBase;
        uint32_t    AllocationProtect;
        uint32_t    RegionSize;
        uint32_t    State;
        uint32_t    Protect;
        uint32_t    Type;
    } MEMORY_BASIC_INFORMATION;

    enum {
        PAGE_NOACCESS             = 0x01,
        PAGE_READONLY             = 0x02,
        PAGE_READWRITE            = 0x04,
        PAGE_WRITECOPY            = 0x08,
        PAGE_EXECUTE              = 0x10,
        PAGE_EXECUTE_READ         = 0x20,
        PAGE_EXECUTE_READWRITE    = 0x40,
        PAGE_EXECUTE_WRITECOPY    = 0x80,
        PAGE_GUARD                = 0x100,
        PAGE_NOCACHE              = 0x200,
        PAGE_WRITECOMBINE         = 0x400,
    };

    uint32_t VirtualQuery(const void*, MEMORY_BASIC_INFORMATION*, uint32_t);

]];

-- LuaJIT FFI Function Overrides
game.real_ffi_cast      = ffi.cast;
game.real_ffi_string    = ffi.string;

--[[
* Validates if the given address can be accessed.
*
* @param {cdata} addr - The address to check.
* @return {boolean} True if valid, false otherwise.
--]]
game.is_valid_ptr = function (addr)
    local mem = ffi.new('MEMORY_BASIC_INFORMATION');
    local ret = ffi.C.VirtualQuery(game.real_ffi_cast('void*', addr), mem, ffi.sizeof('MEMORY_BASIC_INFORMATION'));

    if (ret == 0 or mem.Protect == 0) then
        return false;
    end

    local mask = bit.bor(C.PAGE_READONLY, C.PAGE_READWRITE, C.PAGE_WRITECOPY, C.PAGE_EXECUTE_READ, C.PAGE_EXECUTE_READWRITE, C.PAGE_EXECUTE_WRITECOPY);
    if (bit.band(mem.Protect, mask) == 0) then
        return false;
    end

    if (bit.band(mem.Protect, bit.bor(C.PAGE_GUARD, C.PAGE_NOACCESS)) ~= 0) then
        return false;
    end

    return true;
end

--[[
* Override for 'ffi.cast' to add pointer validation.
--]]
ffi.cast = function (ctype, init)
    if (not game.settings.use_memory_checks) then
        return game.real_ffi_cast(ctype, init);
    end

    return switch(type(init), T{
        [T{ 'cdata', 'number' }] = function ()
            local addr = tonumber(game.real_ffi_cast('uint32_t', init));
            if (addr == 0 or not game.is_valid_ptr(addr)) then
                return game.real_ffi_cast(ctype, nil);
            end
            return game.real_ffi_cast(ctype, init);
        end,

        -- Note: To prevent unexpected returns, we will allow this to fall through..
        [switch.default] = function () return game.real_ffi_cast(ctype, init); end,
    });
end

--[[
* Override for 'ffi.string' to add pointer validation.
--]]
ffi.string = function (data, size)
    if (not game.settings.use_memory_checks) then
        return game.real_ffi_string(data, size);
    end

    return switch(type(data), T{
        ['cdata'] = function ()
            local addr = tonumber(game.real_ffi_cast('uint32_t', data));
            if (addr == 0 or not game.is_valid_ptr(addr)) then
                return nil;
            end
            return game.real_ffi_string(data, size);
        end,
        ['string'] = function ()
            return game.real_ffi_string(data, size);
        end,
        [switch.default] = function () return nil; end,
    });
end

--[[
* Safely reads a string pointer. (For use with string pointers.)
*
* @param {cdata} addr - The address of the string.
* @param {any} default_value - The default value to return when the string is invalid.
* @return {string|nil} The string on success, default_value otherwise.
--]]
game.safe_read_string = function (addr, default_value)
    default_value = default_value or nil;

    if (addr == 0 or addr == nil) then
        return default_value;
    end

    return ffi.string(addr);
end

return game;