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

    typedef struct CSaveQuickInfo
    {
        uint32_t        unknown0000;
        char            name_[64];              // Handled via metatype!
        uint32_t        preview_width;
        uint32_t        preview_height;
        char            client_version_[64];    // Handled via metatype!
        char            save_version_[64];      // Handled via metatype!
        uint8_t         preview_image[37288];
    } CSaveQuickInfo;

    typedef struct CSaveManager
    {
        CSaveQuickInfo* quick_info;
        uint32_t        is_loading;
        uint32_t        unknown0008;
    } CSaveManager;

]];

ffi.metatype('CSaveQuickInfo', T{
    __index = function (self, k)
        return switch(k, T{
            -- Properties
            [T{'name', 'client_version', 'save_version'}] = function ()
                return ffi.string(self[k .. '_'], 64):split('\0'):first();
            end,
            [switch.default] = function ()
                error(('struct \'CSaveQuickInfo\' has no member: %s'):fmt(k));
            end,
        });
    end,
    __newindex = function (_, k, _)
        error(('struct \'CSaveQuickInfo\' has no member: %s'):fmt(k));
    end
});

--[[
*
* Helper Functions
*
--]]

game = game or T{};

game.get_save_manager = function ()
    local ptr = hook.memory.read_uint32(game.ptrs.save_manager);
    if (ptr == 0) then return nil; end
    return ffi.cast('CSaveManager*', ptr);
end