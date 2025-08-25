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
        get_inventory_weight    = hook.memory.find(0, 0, '57E8????????83C4045F5E8BC35BC3', 11, 0),
        get_item_weight         = hook.memory.find(0, 0, '83C4045F8BC65EC20800', 4, 0),
    },
    patches = T{},
    ui = T{
        enabled = T{ false, },
    },
};

cheat.load = function ()
    if (not cheat.ptrs:all(function (v) return v ~= nil and v ~= 0; end)) then
        hook.console.write(T{ 1.0, 0.4, 0.4, 1.0 }, '[cheats.unlimited_carry_weight] Failed to locate all required pointers!');
        return false;
    end

    cheat.patches.get_inventory_weight  = patch:new(cheat.ptrs.get_inventory_weight, T{ 0x31, 0xC0, });
    cheat.patches.get_item_weight       = patch:new(cheat.ptrs.get_item_weight, T{ 0x31, 0xC0, });

    return true;
end

cheat.unload = function ()
    cheat.disable();
end

cheat.enable = function ()
    cheat.patches.get_inventory_weight:enable();
    cheat.patches.get_item_weight:enable();

    -- Update the player agent to remove the encumbered flag..
    local player = game.get_agent(game.get_player_index());
    if (player ~= nil) then
        player.current_weight   = 0;
        player.parameter1       = bit.band(player.parameter1, bit.bnot(0x40000000));
    end
end

cheat.disable = function ()
    cheat.patches.get_inventory_weight:disable();
    cheat.patches.get_item_weight:disable();
end

cheat.render = function ()
    if (imgui.Checkbox('Unlimited Carry Weight', cheat.ui.enabled)) then
        if (cheat.ui.enabled[1]) then
            cheat.enable();
        else
            cheat.disable();
        end
    end
end

return cheat;