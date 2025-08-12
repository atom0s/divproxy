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

    typedef struct CPartyManagerEntry
    {
        uint32_t            agent_index;        // The agent index this member is controlling.
        uint32_t            flags;
        uint32_t            unknown0008;        // Unknown. [Used with multiplayer code.]
        uint32_t            unknown000C;        // Unknown. [Used with multiplayer code.]
        uint32_t            unknown0010;        // Unknown. [Used with multiplayer code.]
        uint32_t            unknown0014;        // Unknown. [Used with multiplayer code.]
    } CPartyManagerEntry;

    typedef struct CPartyManager
    {
        CPartyManagerEntry* members;
        int32_t             members_size;
        int32_t             unknown0008;        // Unknown. [Used as an agent index.]
        uint32_t            unknown000C;        // Unknown.
        int32_t             player_agent_index;
        uint32_t            unknown0014;        // Unknown. [Used as an index into members array.]
    } CPartyManager;

]];