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
require 'win32types';

local ffi = require 'ffi';

ffi.cdef[[

    typedef struct CWorld
    {
        void*           unknown0000;        // Unknown. [Pointer to a list of objects. Potentially Door/Chest list. Entries are 0x88 bytes in size each.]
        int32_t         unknown0004;        // Unknown. [Always 64. Used in position calculations.]
        int32_t         unknown0008;        // Unknown. [Always 64. Used in position calculations.]
        void*           map_file_handle;    // The currently opened map's file handle.
        const char*     map_name_;          // The currently opened map's name. [Handled via metatype!]
        int32_t         unknown0014;        // Unknown. [Used with unknown0000 indexing.]
        int32_t         unknown0018;        // Unknown. [Used with unknown0000 indexing.]
        void*           world_map_data;     // Pointer to world information. [Loaded from the given map file. ie. world.x0]
        int32_t         unknown0020;        // Unknown. [Used as an index into world_map_data.]
        int32_t         unknown0024;        // Unknown. [Used with world_map_data indexing. (Calculated value as: 2 * 64 + 64)]
        void*           unknown0028;        // Unknown. [Used as a pointer, data populated from the current map file.]
        int32_t         unknown002C;        // Unknown. [Calculated value. (Used like a width related value.)]
        int32_t         unknown0030;        // Unknown. [Calculated value. (Used like a height related value.)]
        int32_t         unknown0034;        // Unknown. [Calculated value.]
        int32_t         unknown0038;        // Unknown. [Calculated value.]
        int32_t         unknown003C;        // Unknown. [Calculated value.]
        int32_t         unknown0040;        // Unknown. [Calculated value.]
        void*           unknown0044;        // Unknown. [Used as a pointer.]
        int32_t         unknown0048;        // Unknown. [Used as a count or size with unknown0044.]
        int32_t         unknown004C;        // Unknown. [Used as a size with unknown0050.]
        uint16_t*       unknown0050;        // Unknown. [Used as a pointer to object related values. (Door/Chest related?)]
        void*           unknown0054;        // Unknown. [Pointer to CPulsatingRingTransformation object.]
    } CWorld;

]];

ffi.metatype('CWorld', T{
    __index = function (self, k)
        return switch(k, T{
            -- Properties
            ['map_name'] = function ()
                return game.safe_read_string(self.map_name_, '');
            end,
            [switch.default] = function ()
                error(('struct \'CWorld\' has no member: %s'):fmt(k));
            end,
        });
    end,
    __newindex = function (_, k, _)
        error(('struct \'CWorld\' has no member: %s'):fmt(k));
    end,
});

--[[
*
* Helper Functions
*
--]]

game = game or T{};

game.get_world = function ()
    local ptr = hook.memory.read_uint32(game.ptrs.world);
    if (ptr == 0) then return nil; end
    return ffi.cast('CWorld*', hook.memory.read_uint32(ptr));
end