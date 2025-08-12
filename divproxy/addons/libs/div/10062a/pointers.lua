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

game = game or T{};

game.ptrs = T{
    -- Managers & Global Objects
    agent_manager       = hook.memory.find(0, 0, '8B15????????8B82B40400008B48108B15????????8B420C8B0C88', 17, 0),
    alignment_manager   = hook.memory.find(0, 0, 'B9????????E8????????8B560C8BF88B0250B9', 1, 0),
    configlcl           = hook.memory.find(0, 0, 'A3????????8D4A01EB', 1, 0),
    game_clock          = hook.memory.find(0, 0, '8B0D????????E8????????8B0D????????84C075??E9????????E9', 2, 0),
    inventory_manager   = hook.memory.find(0, 0, 'A3????????33C98908A1????????68040200008948048B', 1, 0),
    object_manager      = hook.memory.find(0, 0, '8B0D????????E8????????8B8EA4010000', 2, 0),
    player              = hook.memory.find(0, 0, '8B15????????8B82B40400008B48108B15????????8B420C8B0C88', 2, 0),
    save_manager        = hook.memory.find(0, 0, 'A3????????C74044', 1, 0),
    time_manager        = hook.memory.find(0, 0, 'A1????????568BF18B4808890E8B0D1C', 1, 0),
    world               = hook.memory.find(0, 0, '8B15????????8B42408B523C51', 2, 0),

    -- CObjectData: Function Pointers
    cobjectdata_has_property_space  = hook.memory.find(0, 0, '568B74240CB80100000033D2B9????????85C6', 0, 0),
    cobjectdata_get_properties_size = hook.memory.find(0, 0, '568B742408B90100000033C0BA????????85CE', 0, 0),
    cobjectdata_get_property        = hook.memory.find(0, 0, '8B442408508B4424088B085183C00450E8????????83C40CC3', 0, 0),
    cobjectdata_set_property        = hook.memory.find(0, 0, '8B44240C8B4C2408508B442408515083C00450E8', 0, 0),
    cobjectdata_remove_property     = hook.memory.find(0, 0, '535556578B7C241CBD010000008BCF8B', 0, 0),
};

-- Validate all pointers were found..
local errs = game.ptrs:filter(function (v) return v == nil or v == 0; end);
if (not errs:empty()) then
    error(('[game] Error: Failed to locate required pointers(s): %s'):fmt(errs:sortkeys():join(', ')));
end

return game;
