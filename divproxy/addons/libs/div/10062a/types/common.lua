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

    typedef struct std_string
    {
        uint32_t        unknown0000;

        union {
            const char* ptr;
            char        buffer[16];
        };

        int32_t         size;
        int32_t         max_size;
    } std_string;

    typedef struct TSentence
    {
        uint32_t        token_count;
        char            tokens[32][4096];
        char            sentence[4096];
        char            token[256];
    } TSentence;

]];

local function std_string_c_str(str)
    return ffi.string(str.size >= 0x10 and str.ptr or str.buffer);
end

ffi.metatype('std_string', T{
    __index = function (_, k)
        return switch(k, T{
            -- Properties
            ['c_str'] = function () return std_string_c_str; end,
            [switch.default] = function ()
                error(('struct \'std_string\' has no member: %s'):fmt(k));
            end,
        });
    end,
    __newindex = function (_, k, _)
        error(('struct \'std_string\' has no member: %s'):fmt(k));
    end
});