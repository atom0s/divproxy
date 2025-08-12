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
local ffi = require 'ffi';

local cave_type = T{};

function cave_type:new(address, size, nops, cave_code)
    local o = T{};

    setmetatable(o, self);
    self.__index = self;

    o.enabled_  = false;
    o.address_  = address;
    o.offset_   = 4;
    o.size_     = size;
    o.nops_     = nops;
    o.backup_   = hook.memory.read_array(address, size);
    o.cave_     = hook.memory.assembler.cave(cave_code);
    o.cave_gc_  = ffi.gc(ffi.cast('uint8_t*', 0), function ()
        o:disable();
        hook.memory.assembler.release(o.cave_);
    end);

    return o;
end

function cave_type:enable()
    if (self.enabled_) then
        return;
    end
    local ret, prot = hook.memory.unprotect(self.address_, #self.backup_);
    if (ret) then
        hook.memory.assembler.call(self.address_, self.cave_ + self.offset_, self.nops_);
        hook.memory.protect(self.address_, #self.backup_, prot);

        self.enabled_ = true;
    end
end

function cave_type:disable()
    if (not self.enabled_) then
        return;
    end
    local ret, prot = hook.memory.unprotect(self.address_, #self.backup_);
    if (ret) then
        hook.memory.write_array(self.address_, self.backup_);
        hook.memory.protect(self.address_, #self.backup_, prot);

        self.enabled_ = false;
    end
end

function cave_type:set_offset(offset)
    self.offset_ = offset;
end

function cave_type:enabled()
    return self.enabled_;
end

function cave_type:get_cave_address()
    return self.cave_;
end

return cave_type;