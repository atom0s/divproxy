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

local inheritance   = require 'inheritance';
local ffi           = require 'ffi';

ffi.cdef[[

    typedef struct TIndexedFile
    {
        uintptr_t       vtbl;
        const char*     indexed_path_b_;        // Path to the indexed file. (b) [Handled via metatype!]
        const char*     indexed_path_i_;        // Path to the indexed file. (i) [Handled via metatype!]
        int32_t         indexed_entry_size_i;
        int32_t         indexed_offset;
        void*           indexed_file_b;         // FILE*
        void*           indexed_file_i;         // FILE*
        const char*     indexed_mode_;          // The current file mode string. (ie. rb, wb, etc.) [Handled via metatype!]
        int32_t         indexed_size_b;
        int32_t         indexed_size_i;
        int32_t         indexed_state;
        int32_t         indexed_entry_count_i;
        void*           indexed_buffer_i;
    } TIndexedFile;

    typedef struct TRamFile
    {
        TIndexedFile    BaseClass;              // C++ inheritance workaround.
        int32_t         ram_entry_size_i;
        uint32_t        ram_offset;
        int32_t         ram_size_b;
        int32_t         ram_size_i;
        uint8_t*        ram_buffer_i;
        uint8_t*        ram_buffer_b;
    } TRamFile;

    typedef struct TBufferedRamFile
    {
        TRamFile        BaseClass;              // C++ inheritance workaround.
        const char*     buffered_path_b_;       // Path to the buffered file. (b) [Handled via metatype!]
        const char*     buffered_path_i_;       // Path to the buffered file. (i) [Handled via metatype!]
        void*           buffered_file_b;        // FILE*
        void*           buffered_file_i;        // FILE*
    } TBufferedRamFile;

]];

ffi.metatype('TIndexedFile', T{
    __index = inheritance.index:bindn(0, function (self, k)
        return switch(k, T{
            -- Properties
            [T{ 'indexed_path_b', 'indexed_path_i', 'indexed_mode', }] = function ()
                return game.safe_read_string(self[k .. '_'], '');
            end,
            [switch.default] = function ()
                error(('struct \'TIndexedFile\' has no member: %s'):fmt(k));
            end,
        });
    end),
    __newindex = inheritance.newindex:bindn(0, function (_, k, _)
        error(('struct \'TIndexedFile\' has no member: %s'):fmt(k));
    end),
});

inheritance.proxy(1, 'TRamFile');

ffi.metatype('TBufferedRamFile', T{
    __index = inheritance.index:bindn(2, function (self, k)
        return switch(k, T{
            -- Properties
            [T{ 'buffered_path_b', 'buffered_path_i', }] = function ()
                return game.safe_read_string(self[k .. '_'], '');
            end,
            [switch.default] = function ()
                error(('struct \'TBufferedRamFile\' has no member: %s'):fmt(k));
            end,
        });
    end),
    __newindex = inheritance.newindex:bindn(2, function (_, k, _)
        error(('struct \'TBufferedRamFile\' has no member: %s'):fmt(k));
    end),
});