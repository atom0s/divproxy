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
local reflect   = require 'reflect';
local reflex    = T{};

local member_properties = T{
    bits            = 0,
    element_count   = 0,
    element_size    = 0,
    enum_type       = '',
    is_array        = false,
    is_bitfield     = false,
    is_bool         = false,
    is_const        = false,
    is_enum         = false,
    is_function     = false,
    is_ptr          = false,
    is_struct       = false,
    is_transparent  = false,
    is_union        = false,
    is_unsigned     = false,
    is_vla          = false,
    is_volatile     = false,
    memory_size     = 0,
    name            = '(anonymous)',
    offset          = 0,
};

--[[
* Populates common flags for the given structure member.
*
* @param {table} member - The processed member table.
* @param {table} m - The structure member being processed.
* @param {table} options - Reflection options.
--]]
reflex.populate_flags = function (member, m, options)
    if (not member.is_bool)     then member.is_bool     = m.bool        and true or false; end
    if (not member.is_const)    then member.is_const    = m.const       and true or false; end
    if (not member.is_unsigned) then member.is_unsigned = m.unsigned    and true or false; end
    if (not member.is_vla)      then member.is_vla      = m.vla         and true or false; end
    if (not member.is_volatile) then member.is_volatile = m.volatile    and true or false; end

    if (m.type) then
        reflex.populate_flags(member, m.type, options);
    end

    if (m.element_type) then
        reflex.populate_flags(member, m.element_type, options);
    end
end

--[[
* Process an array structure member.
*
* @param {table} m - The structure member being processed.
* @param {table} options - Reflection options.
* @return {table} The processed member table.
--]]
reflex.array = function (m, options)
    local member = T{};

    member.is_array         = true;
    member.element_count    = m.size / m.element_type.size;
    member.element_size     = m.element_type.size;

    return member:merge(reflex.parse_member(m.element_type, options));
end

--[[
* Process a bitfield structure member.
*
* @param {table} m - The structure member being processed.
* @param {table} options - Reflection options.
* @return {table} The processed member table.
--]]
reflex.bitfield = function (m, options)
    local member = T{};

    member.is_bitfield  = true;
    member.bits         = m.size * 8;

    return member:merge(reflex.parse_member(m.type, options));
end

--[[
* Process an enum structure member.
*
* @param {table} m - The structure member being processed.
* @param {table} options - Reflection options.
* @return {table} The processed member table.
--]]
reflex.enum = function (m, options)
    local member = T{};

    member.is_enum      = true;
    member.enum_type    = m.name;

    return member:merge(reflex.parse_member(m.type, options));
end

--[[
* Process a field structure member.
*
* @param {table} m - The structure member being processed.
* @param {table} options - Reflection options.
* @return {table} The processed member table.
--]]
reflex.field = function (m, options)
    return reflex.parse_member(m.type, options);
end

--[[
* Process an float structure member.
*
* @param {table} m - The structure member being processed.
* @param {table} options - Reflection options.
* @return {table} The processed member table.
--]]
reflex.float = function (m, options)
    local member = T{};

    member.ctype = switch(m.size, T{
        [4] = function () return 'float'; end,
        [8] = function () return 'double'; end,
        [switch.default] = function()
            error(('reflex: unsupported float size: %d'):fmt(m.size));
        end,
    });

    return member;
end

--[[
* Process a function structure member.
*
* @param {table} m - The structure member being processed.
* @param {table} options - Reflection options.
* @return {table} The processed member table.
--]]
reflex.func = function (m, options)
    local member = T{};

    member.is_function  = true;
    member.ctype        = 'func';

    -- TODO:
    -- Further processing can be done here to reflect the function arguments, calling conventions, return type, etc.

    return member;
end

--[[
* Process an integer structure member.
*
* @param {table} m - The structure member being processed.
* @param {table} options - Reflection options.
* @return {table} The processed member table.
--]]
reflex.int = function (m, options)
    local member = T{};

    member.ctype = switch(m.size, T{
        [1] = function ()
            if (m.bool) then
                return 'bool';
            end
            return m.unsigned and 'uint8_t' or 'int8_t';
        end,
        [2] = function () return m.unsigned and 'uint16_t' or 'int16_t'; end,
        [4] = function () return m.unsigned and 'uint32_t' or 'int32_t'; end,
        [8] = function () return m.unsigned and 'uint64_t' or 'int64_t'; end,
        [switch.default] = function()
            error(('reflex: unsupported int size: %d'):fmt(m.size));
        end,
    });

    return member;
end

--[[
* Process a pointer structure member.
*
* @param {table} m - The structure member being processed.
* @param {table} options - Reflection options.
* @return {table} The processed member table.
--]]
reflex.ptr = function (m, options)
    local member = T{};

    member.is_ptr = true;
    member:merge(reflex.parse_member(m.element_type, options));
    member.ctype = member.ctype .. '*';

    return member;
end

--[[
* Process a struct structure member.
*
* @param {table} m - The structure member being processed.
* @param {table} options - Reflection options.
* @return {table} The processed member table.
--]]
reflex.struct = function (m, options)
    local member = T{};

    member.is_struct    = true;
    member.ctype        = m.name;
    member.struct       = reflex.reflect(m.name, options);

    -- TODO:
    -- Add prevention for stack overflows when structures are self-referencing.

    return member;
end

--[[
* Process a union structure member.
*
* @param {table} m - The structure member being processed.
* @param {table} options - Reflection options.
* @return {table} The processed member table.
--]]
reflex.union = function (m, options)
    local member = T{};

    member.is_union         = true;
    member.ctype            = 'union';
    member.memory_size      = m.size;
    member.is_transparent   = m.transparent and true or false;
    member.struct           = reflex.reflect(m.typeid, options);

    -- TODO:
    -- Further process the unions members to expand them outside of the 'struct' field?

    return member;
end

--[[
* Process a void structure member.
*
* @param {table} m - The structure member being processed.
* @param {table} options - Reflection options.
* @return {table} The processed member table.
--]]
reflex.void = function (m, options)
    local member = T{};

    member.ctype = 'void';

    return member;
end

--[[
* Process a structure member.
*
* @param {table} m - The structure member being processed.
* @param {table} options - Reflection options.
* @return {table} The processed member table.
--]]
reflex.parse_member = function (m, options)
    local f = reflex[m.what];
    if (not f) then
        error(('reflex: unsupported member type: %s'):fmt(m.what));
    end
    return f(m, options);
end

--[[
* Reflects an FFI ctype back into a Lua table of structure members.
*
* @param {ctype} ctype - The C-type to reflect.
* @param {table} options - Reflection options.
* @return {table} Table containing the reflected structure members.
--]]
reflex.reflect = function (ctype, options)
    options = options or T{};
    options.expand_base_classes = options.expand_base_classes or false;

    local t = type(ctype) == 'number' and reflect.fromid(ctype) or reflect.typeof(ctype);
    if (t == nil) then
        error('reflex: invalid ctype!');
    end

    if (not T{ 'struct', 'union', }:contains(t.what)) then
        error(('reflex: invalid ctype; expected \'struct\', got: %s'):fmt(t.what));
    end

    local members = T{};

    for m in t:members() do
        local member = member_properties:clone();

        reflex.populate_flags(member, m, options);

        member.name     = m.name and m.name or '(anonymous)';
        member.offset   = m.offset;

        if (m.type) then
            member.memory_size = m.type.size;
        end

        -- Support expanding custom 'BaseClass' inheritance chains..
        if (options.expand_base_classes and member.name == 'BaseClass') then
            reflex.parse_member(m, options):merge(member, false).struct:each(function (v) members:append(v); end);
        else
            members:append(reflex.parse_member(m, options):merge(member, false));
        end
    end

    return members;
end

return reflex;