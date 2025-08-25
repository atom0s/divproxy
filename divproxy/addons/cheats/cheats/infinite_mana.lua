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
local game  = require 'game';
local imgui = require 'imgui';
local patch = require 'memory.patch';

local cheat = T{
    ptrs = T{
        cast    = hook.memory.find(0, 0, '294808837C243400', 0, 0),
        drain   = hook.memory.find(0, 0, '2947088B512C837A08005F', 0, 0),
        feign   = hook.memory.find(0, 0, '0141088B762C837E0800', 0, 0),
    },
    patches = T{},
    ui = T{
        enabled = T{ false, },
    },
};

cheat.load = function ()
    if (not cheat.ptrs:all(function (v) return v ~= nil and v ~= 0; end)) then
        hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, '[cheats.infinite_mana] Failed to locate all required pointers!');
        return false;
    end

    cheat.patches.cast  = patch:new(cheat.ptrs.cast, T{ 0x90, 0x90, 0x90, });
    cheat.patches.drain = patch:new(cheat.ptrs.drain, T{ 0x90, 0x90, 0x90, });
    cheat.patches.feign = patch:new(cheat.ptrs.feign, T{ 0x90, 0x90, 0x90, });

    return true;
end

cheat.unload = function ()
    cheat.disable();
end

cheat.enable = function ()
    cheat.patches.cast:enable();
    cheat.patches.drain:enable();
    cheat.patches.feign:enable();

    local player = game.get_agent(game.get_player_index());
    if (player) then
        player.statistics.mana = player.statistics.max_mana;
    end
end

cheat.disable = function ()
    cheat.patches.cast:disable();
    cheat.patches.drain:disable();
    cheat.patches.feign:disable();
end

cheat.render = function ()
    if (imgui.Checkbox('Infinite Mana', cheat.ui.enabled)) then
        if (cheat.ui.enabled[1]) then
            cheat.enable();
        else
            cheat.disable();
        end
    end
end

return cheat;