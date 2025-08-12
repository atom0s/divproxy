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

    typedef struct CTimeManager
    {
        uint32_t    ticks;
        uint32_t    ticks_remaining;
        uint32_t    days_elapsed;
        uint32_t    current_hour;
        uint32_t    ticks_per_hour;
        uint32_t    time_paused;
    } CTimeManager;

]];

--[[
*
* Helper Functions
*
--]]

game = game or T{};

game.get_time_manager = function ()
    local ptr = hook.memory.read_uint32(game.ptrs.time_manager);
    if (ptr == 0) then return nil; end
    return ffi.cast('CTimeManager*', hook.memory.read_uint32(ptr));
end