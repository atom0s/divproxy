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

--[[
* Divine Divinity Lua SDK - Copyright (c) 2025 atom0s [atom0s@live.com]
*
* This file is part of the Divine Divinity Lua SDK (DDLSDK).
*
* Addons can include this file which will then automatically determine the current client
* version and import the rest of the proper DDLSDK files. Individually supported client versions
* will each have their own folder found within the 'libs/div/' folder.
--]]

require 'common';
require 'win32types';

local ffi = require 'ffi';

ffi.cdef[[
    DWORD GetModuleFileNameA(uint32_t, char*, uint32_t);

    // Version: 1.0062A
    typedef void (__cdecl* DivVersion_GetGameLanguageAndVersion_f)(const char*, char*, int32_t, char*, int32_t);
]];

game = game or T{};
game.versions = T{
    -- Version: 1.0062A
    T{ folder = '10062a', version = T{ 1, 0, 0, 62, }, pattern = '81EC88000000A1????????33C4898424840000008B842490000000538B9C2490', }
};

-- Find the first matching version function pattern..
local ptr = game.versions
    :map(function (v) return hook.memory.find(0, 0, v.pattern, 0, 0); end)
    :filter(function (v) return v ~= nil and v ~= 0; end)
    :flatten()
    :first();

-- Obtain the game version from the client function..
local game_name     = ffi.new('char[1024]');
local game_version  = ffi.new('char[1024]');
ffi.C.GetModuleFileNameA(hook.get_game_instance(), game_name, 1024);
ffi.cast('DivVersion_GetGameLanguageAndVersion_f', ptr)(game_name, game_version, 1024, nil, 0);

-- Convert the version string into a number table..
game.version = ffi.string(game_version)
    :gsub('[^%w\\,]+', '')
    :split(',')
    :map(tonumber);

-- Check for a valid matching SDK version..
local _, m = game.versions:find_if(function (v)
    return v.version:eq(game.version);
end);

if (not m) then
    error(('[game] Invalid or unsupported client version: v%d.%d.%d.%d'):fmt(game.version:unpack()));
end

-- Import the detected SDK version..
return require('div.' .. m.folder .. '.main');