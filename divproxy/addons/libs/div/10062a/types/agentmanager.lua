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

    typedef struct CAgentManager
    {
        uint32_t*       visual_agents_indexes;
        int32_t         visual_agents_indexes_size;
        int32_t         visual_agents_indexes_max;
        CAgent**        agents;
        int32_t         agents_size;
        int32_t         unknown0014;                // Unknown. [Used as an agent index.]
        int32_t         agents_max;
        int32_t         next_available_agent_index;
        uint8_t*        agents_available;
        uint32_t*       agent_variable_manager;
        CAgentClass**   agent_classes;
        int32_t         agent_classes_size;
        int32_t         agent_classes_max;
        uint32_t        visibile_bounds_x;
        uint32_t        visibile_bounds_y;
        uint32_t        unknown003C;                // Unknown. [Used as a flag related to eggs.]
        uint32_t*       attacking_agents_indexes;
        int32_t         attacking_agents_indexes_size;
        int32_t         attacking_agents_indexes_max;
        uint32_t        game_difficulty;
    } CAgentManager;

]];

--[[
*
* Helper Functions
*
--]]

game = game or T{};

game.get_agent_manager = function ()
    local ptr = hook.memory.read_uint32(game.ptrs.agent_manager);
    if (ptr == 0) then return nil; end
    return ffi.cast('CAgentManager*', hook.memory.read_uint32(ptr));
end

game.get_agent = function (idx)
    local mgr = game.get_agent_manager();
    if (mgr == nil) then
        return nil;
    end

    local agent = mgr.agents[idx];
    if (agent == 0 or agent == nil) then
        return nil;
    end

    return switch(agent.this_size, T{
        [ffi.sizeof('CAgentNpc')]   = function () return ffi.cast('CAgentNpc*', agent); end,
        [ffi.sizeof('CPartyMember')]= function () return ffi.cast('CPartyMember*', agent); end,
        [switch.default]            = function () return ffi.cast('CAgent*', agent); end,
    });
end

game.get_agent_class = function (idx)
    local mgr = game.get_agent_manager();
    if (mgr == nil) then
        return nil;
    end
    return mgr.agent_classes[idx];
end

game.get_agent_manager_address = function ()
    return hook.memory.read_uint32(game.ptrs.agent_manager);
end

game.get_agent_address = function (idx)
    local agent = game.get_agent(idx);
    if (agent == 0 or agent == nil) then
        return 0;
    end
    return tonumber(ffi.cast('uint32_t', agent));
end