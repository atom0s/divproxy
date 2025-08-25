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

local filters = T{};

--[[
* Filters an array of values within a table of key/value pairs using the fields 'index' and 'value'.
*
* @param {table} values - The array values.
* @param {table} props - The table properties. (Must contain a 'filters' and 'struct' member!)
* @return {table} The filtered list of values.
--]]
filters.filter_array = function (values, props)
    local has_p_filter = #props.filters.p.buffer[1] > 0;
    local has_v_filter = #props.filters.v.buffer[1] > 0;

    if (not has_p_filter and not has_v_filter) then
        return values;
    end

    local members = T{};

    p_filter = has_p_filter and props.filters.p.buffer[1]:lower() or nil;
    v_filter = has_v_filter and props.filters.v.buffer[1]:lower() or nil;

    values:each(function (v, k)
        local match = T{};

        if (has_p_filter) then match:append(values[k].index:tostring():contains(p_filter)); end
        if (has_v_filter) then match:append(values[k].value:tostring():contains(v_filter)); end

        if (#match and match:all(function (vv) return vv == true; end)) then
            members:append(values[k]);
        end
    end);

    return members;
end

--[[
* Filters an objects members.
*
* @param {cdata} objs - The parent object.
* @param {table} props - The table properties. (Must contain 'struct' member!)
* @return {table} The filtered list of members.
--]]
filters.filter_members = function (objs, props)
    local f = props.struct:filteri(function (v)
        if (v.search_filter == nil) then
            v.search_filter = T{ buffer = T{ '', }, size = 32, };
        end
        return #v.search_filter.buffer[1] > 0;
    end);

    local ret = T{};

    objs:each(function (v)
        if (#f == 0) then
            ret:append(v);
        else
            local pass = f:all(function (vv)
                return tostring(v[vv.name:trimend('_')]):lower():contains(vv.search_filter.buffer[1]:lower());
            end);
            if (pass) then
                ret:append(v);
            end
        end
    end);

    return ret;
end

--[[
* Filters an objects property name and values.
*
* @param {cdata} obj - The parent object.
* @param {table} props - The table properties. (Must contain a 'filters' and 'struct' member!)
* @return {table} The filtered list of members.
--]]
filters.filter_properties = function (obj, props)
    local has_p_filter = #props.filters.p.buffer[1] > 0;
    local has_v_filter = #props.filters.v.buffer[1] > 0;

    if (not has_p_filter and not has_v_filter) then
        return props.struct;
    end

    local members = T{};

    p_filter = has_p_filter and props.filters.p.buffer[1]:lower() or nil;
    v_filter = has_v_filter and props.filters.v.buffer[1]:lower() or nil;

    props.struct:each(function (v, k)
        local match = T{};

        if (has_p_filter) then match:append(v.name:trimend('_'):lower():contains(p_filter)); end
        if (has_v_filter) then match:append(tostring(obj[v.name:trimend('_')]):lower():contains(v_filter)); end

        if (#match and match:all(function (vv) return vv == true; end)) then
            members:append(props.struct[k]);
        end
    end);

    return members;
end

return filters;