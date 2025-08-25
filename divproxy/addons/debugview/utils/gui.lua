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
local imgui     = require 'imgui';
local ffi       = require 'ffi';
local filters   = require 'utils.filters';

local gui = T{
    types = T{
        floats  = T{ 'float', 'double', },
        ints    = T{ 'int8_t', 'int16_t', 'int32_t', 'int64_t', 'uint8_t', 'uint16_t', 'uint32_t', 'uint64_t', },
    },
};

--[[
* Returns a table of structure members from the given object.
*
* @param {cdata} obj - The structure object holding the elements.
* @param {string} m_name - The name of the array element in the structure.
* @param {string} m_size - The name of the size element in the structure.
* @return {table} Table containing the mapped structure members.
--]]
gui.get_members = function (obj, m_name, m_size)
    return table.range(0, obj[m_size] - 1):map(function (v) return obj[m_name][v]; end);
end

--[[
* Returns a table of array members from the given pointer.
*
* @param {cdata} The array pointer.
* @param {number} The number of array elements.
* @return {table} Table containing the mapped array elements.
--]]
gui.get_array_values = function (obj, size)
    return table.range(0, size - 1):map(function (v) return T{ index = v, value = obj[v], }; end);
end

--[[
* Removes structure members from a reflex structure.
*
* @param {table} rstruct - The reflex structure to modify.
* @param {table} names - The list of names of the members to be removed.
* @return {table} The modified reflex structure.
--]]
gui.remove_struct_members = function (rstruct, names)
    local members = T{};

    names:each(function (v)
        local kk, vv = rstruct:find_if(function (vv)
            return vv.name:trimend('_') == v;
        end);
        if (kk) then
            rstruct:delete(vv);
        end
    end);

    rstruct:each(function (v) members:append(v); end);

    return members;
end

--[[
* Reorders structure members within a reflex structure. (Moves the given members to the front of the structure.)
*
* @param {table} rstruct - The reflex structure to modify.
* @param {table} names - The list of names of the members to be reordered.
* @return {table} The modified reflex structure.
--]]
gui.reorder_struct_members = function (rstruct, names)
    local members = T{};

    names:each(function (v)
        local kk, vv = rstruct:find_if(function (vv)
            return vv.name:trimend('_') == v;
        end);
        if (kk) then
            members:append(rstruct:delete(vv));
        end
    end);

    rstruct:each(function (v) members:append(v); end);

    return members;
end

--[[
* Generates the default table header sizes for a given table.
*
* @param {table} objs - Table of data to determine a maximum width from.
* @param {table} props - The table properties. (Must contain a 'struct' member!)
--]]
gui.generate_table_header_sizes = function (objs, props)
    props.struct:each(function (v)
        local max = v.name:len() + 2;
        objs:each(function (vv)
            if (vv ~= nil) then
                pcall(function ()
                    local val = vv[v.name:trimend('_')];
                    if (val ~= nil) then
                        local cur = tostring(val):len();
                        if (cur > max) then
                            max = cur;
                        end
                    end
                end);
            end
         end);
        v.__table_header_width = (max + 1) * imgui.GetFontBaked():GetCharAdvance(' ');
    end);
end

--[[
* Returns a property  table with defaults populated.
*
* @param {table} props - The current property table.
* @return {table} The default properties table merged with the given props table.
--]]
gui.clone_default_properties = function (props)
    math.randomseed(os.time());

    local default_properties = T{
        -- Table properties..
        name                = (''):rep(24, '#'):gsub('#', function (v) return string.char(math.random(97, 122)); end),
        flags               = nil,
        width               = -1,
        height              = -1,
        freeze_columns      = nil,
        freeze_rows         = nil,
        property_width      = nil,
        show_filters        = false,
        show_selection      = false,
        is_editable         = false,
        readonly            = nil,

        -- Property filtering..
        filters             = T{
            p = T{ buffer = T{ '', }, size = 32, },
            v = T{ buffer = T{ '', }, size = 32, },
        },

        -- Display overrides..
        overrides           = T{},

        -- Callback functions..
        on_filters_popup    = nil, -- Callback invoked when opening the filters context menu.
        on_hover            = nil, -- Callback invoked when hovering a table row.
        on_select           = nil, -- Callback invoked when selecting a table row.

        -- Reflex structure..
        struct              = nil,

        -- Internals..
        __selected          = nil,
    };

    return default_properties:clone();
end

--[[
* Renders an array value editor.
*
* @param {cdata} array - The parent array that holds the value.
* @param {table} value - The array value table.
* @param {table} member - The reflex structure of the member.
* @param {table} props - The table properties.
--]]
gui.render_array_value_editor = function (array, value, member, props)
    local name = member.name:trimend('_');

    -- Handle: override
    if (props.overrides ~= nil and props.overrides[name] ~= nil) then
        props.overrides[name](array, value, member);
        return;
    end

    -- Handle: ptr (special case to reduce to base type..)
    if (member.is_ptr) then
        member.is_ptr = false;
        member.ctype = member.ctype:endswith('*') and member.ctype:sub(1, -2) or member.ctype;
    end

    -- Handle: ptr, struct, union
    if (member.is_ptr or member.is_struct or member.is_union) then
        imgui.Text(tostring(array[value.index]));
        return;
    end

    -- Handle: array
    if (member.is_array) then
        imgui.Text(('%s[%d] {'):fmt(member.ctype, member.element_count));

        if (member.element_count > 0) then

            local cnt = member.element_count:clamp(0, 10);

            local vals = T{};
            for x = 0, cnt - 1 do
                vals:append(array[value.index][x]);
            end
            imgui.SameLine();
            imgui.Text(('%s%s }'):fmt(vals:join(', '), cnt < member.element_count and ', ... ' or ''));
        end

        return;
    end

    -- Handle: floats, integers
    local is_f = gui.types.floats:contains(member.ctype);
    local is_i = gui.types.ints:contains(member.ctype);

    if (is_f or is_i) then
        if (member.is_const) then
            imgui.Text(tostring(array[value.index]));
            return;
        end

        local val = T{ array[value.index], };

        if (is_f) then
            if (imgui.InputFloat(('##%d_flt'):fmt(value.index), val)) then
                array[value.index] = val[1];
            end
        else
            local step = T{ 1 };
            if (imgui.InputScalar(('##%d_int'):fmt(value.index), member.is_unsigned and ImGuiDataType_U32 or ImGuiDataType_S32, val, step, nil, '%d')) then
                array[value.index] = val[1];
            end
            imgui.SameLine();
            if (member.is_unsigned) then
                imgui.Text(('%08X'):fmt(array[value.index]));
            else
                -- Note: This is a stupid hack to work around a 'bug' in LuaJIT..
                imgui.Text(('%08X'):fmt(ffi.new('uint32_t[1]', array[value.index])[0]));
            end
        end

        return;
    end

    -- Handle: (fallback)
    imgui.Text(tostring(array[value.index]));
end

--[[
* Renders a member editor.
*
* @param {cdata} obj - The parent object that holds the member.
* @param {table} member - The reflex structure of the member.
* @param {table} props - The table properties.
--]]
gui.render_member_editor = function (obj, member, props)
    local name = member.name:trimend('_');

    -- Handle: override
    if (props.overrides ~= nil and props.overrides[name] ~= nil) then
        props.overrides[name](obj, member);
        return;
    end

    -- Handle: ptr, struct, union
    if (member.is_ptr or member.is_struct or member.is_union) then
        imgui.Text(tostring(obj[name]));
        return;
    end

    -- Handle: array
    if (member.is_array) then
        local str = ('%s[%d] { '):fmt(member.ctype, member.element_count);
        if (member.element_count > 0) then
            local cnt = member.element_count:clamp(0, 10);
            local vals = T{};
            for x = 0, cnt - 1 do
                vals:append(tostring(obj[name][x]));
            end
            str = str .. vals:join(', ');
            if (cnt < member.element_count) then
                str = str .. ', ... ';
            else
                str = str .. '';
            end
        end
        str = str .. '}';

        imgui.Text(str);
        return;
    end

    -- Handle: floats, integers
    local is_f = gui.types.floats:contains(member.ctype);
    local is_i = gui.types.ints:contains(member.ctype);

    if ((is_f or is_i) and not member.is_const) then
        local val = T{ obj[name], };

        if (is_f) then
            if (imgui.InputFloat(('##%s_flt'):fmt(name), val)) then
                obj[name] = val[1];
            end
        else
            local step = T{ 1 };
            if (imgui.InputScalar(('##%s_int'):fmt(name), member.is_unsigned and ImGuiDataType_U32 or ImGuiDataType_S32, val, step, nil, '%d')) then
                obj[name] = val[1];
            end
            imgui.SameLine();
            if (member.is_unsigned) then
                imgui.Text(('%08X'):fmt(obj[name]));
            else
                -- Note: This is a stupid hack to work around a 'bug' in LuaJIT..
                imgui.Text(('%08X'):fmt(ffi.new('uint32_t[1]', obj[name])[0]));
            end
        end

        return;
    end

    -- Handle: (default)
    imgui.Text(tostring(obj[name]));
end

--[[
* Renders a property editor table.
*
* @param {cdata} obj - The parent object to be displayed.
* @param {table} props - The table properties. (Must contain a 'struct' member!)
*
* Callback parameters:
*
*       on_filters_popup(parent, props)
*               on_hover(parent, member, props)
*              on_select(parent, member, props)
*              overrides(parent, member, props)
--]]
gui.render_property_editor = function (obj, props)
    props:merge(gui.clone_default_properties(props), false);

    local freeze_cols = 1;
    local freeze_rows = props.show_filters and 2 or 1;

    freeze_cols = props.freeze_columns or freeze_cols;
    freeze_rows = props.freeze_rows or freeze_rows;

    local flags = props.flags or bit.bor(ImGuiTableFlags_RowBg, ImGuiTableFlags_Borders, ImGuiTableFlags_ScrollX, ImGuiTableFlags_ScrollY);
    if (not imgui.BeginTable(('%s_tbl'):fmt(props.name), 2, flags, { props.width or -1,  props.height or -1 })) then
        return;
    end

    imgui.TableSetupColumn('Property', ImGuiTableColumnFlags_WidthFixed, props.property_width or 250);
    imgui.TableSetupColumn('Value', ImGuiTableColumnFlags_WidthStretch);
    imgui.TableSetupScrollFreeze(freeze_cols, freeze_rows);
    imgui.TableHeadersRow();

    if (props.show_filters == true) then
        local filter_hovered = false;
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);
        imgui.TableNextColumn();
        imgui.PushItemWidth(-1);
        imgui.InputText('##txt_filter_p', props.filters.p.buffer, props.filters.p.size);
        imgui.PopItemWidth();
        if (imgui.IsItemHovered()) then
            filter_hovered = true;
        end
        imgui.TableNextColumn();
        imgui.PushItemWidth(-1);
        imgui.InputText('##txt_filter_v', props.filters.v.buffer, props.filters.v.size);
        imgui.PopItemWidth();
        if (imgui.IsItemHovered()) then
            filter_hovered = true;
        end
        if (filter_hovered and imgui.IsMouseReleased(1)) then
            imgui.OpenPopup(('%s_filter_popup'):fmt(props.name));
        end
        if (imgui.BeginPopup(('%s_filter_popup'):fmt(props.name))) then
            if (imgui.Selectable(ICON_FA_ERASER .. 'Clear Filters')) then
                props.filters.p.buffer[1] = '';
                props.filters.v.buffer[1] = '';
            end
            if (props.on_filters_popup) then
                props.on_filters_popup(obj, props);
            end
            imgui.EndPopup();
        end
    end

    local members = filters.filter_properties(obj, props);
    local clipper = ImGuiListClipper.new();
    clipper:Begin(#members, -1);

    while (clipper:Step()) do
        for x = clipper.DisplayStart, clipper.DisplayEnd - 1 do
            local m = members[x + 1];
            imgui.TableNextRow();
            imgui.TableNextColumn();
            imgui.PushID(x + 1);
            if (imgui.Selectable(('%s##prop_%d'):fmt(m.name:trimend('_'), x + 1), props.show_selection and props.__selected == m or false, bit.bor(ImGuiSelectableFlags_SpanAllColumns, ImGuiSelectableFlags_AllowOverlap), T{ 0, 0 })) then
                props.__selected = m;
                if (props.on_select) then
                    props.on_select(obj, m, props);
                end
            end
            if (imgui.IsItemHovered() and props.on_hover) then
                props.on_hover(obj, m, props);
            end
            imgui.TableNextColumn();
            imgui.PushStyleVar(ImGuiStyleVar_FramePadding, T{ 4, 0 });

            local pname = m.name:trimend('_');
            if (props.overrides ~= nil and props.overrides[pname] ~= nil) then
                props.overrides[pname](obj, m, props);
            else
                if (not props.is_editable or props.readonly ~= nil and props.readonly:contains(pname)) then
                    imgui.Text(tostring(obj[pname]));
                else
                    gui.render_member_editor(obj, m, props);
                end
            end

            imgui.PopStyleVar();
            imgui.PopID();
        end
    end

    imgui.EndTable();
end

--[[
* Renders an object list editor.
*
* @param {cdata} obj - The parent object to be displayed.
* @param {table} props - The table properties. (Must contain a 'struct' member!)
*
* Callback parameters:
*
*       on_filters_popup(parent, props)
*               on_hover(parent, member, props)
*              on_select(parent, member, props)
*              overrides(parent, member, props)
--]]
gui.render_object_list_editor = function (objs, props)
    props:merge(gui.clone_default_properties(props), false);
    props.struct:each(function (v)
        if (v.search_filter == nil) then
            v.search_filter = T{ buffer = T{ '', }, size = 32, };
        end
    end);

    local freeze_cols = 1;
    local freeze_rows = props.show_filters and 2 or 1;

    freeze_cols = props.freeze_columns or freeze_cols;
    freeze_rows = props.freeze_rows or freeze_rows;

    local flags = props.flags or bit.bor(ImGuiTableFlags_RowBg, ImGuiTableFlags_Borders, ImGuiTableFlags_ScrollX, ImGuiTableFlags_ScrollY);
    if (not imgui.BeginTable(('%s_tbl'):fmt(props.name), #props.struct, flags, { props.width or -1,  props.height or -1 })) then
        return;
    end

    props.struct:each(function (v)
        if (not props.is_editable) then
            imgui.TableSetupColumn(v.name:trimend('_'), ImGuiTableColumnFlags_WidthFixed, v.__table_header_width or 150);
        else
            imgui.TableSetupColumn(v.name:trimend('_'), ImGuiTableColumnFlags_WidthFixed, v.__table_header_width and (v.__table_header_width + 100) or 150);
        end
    end);
    imgui.TableSetupScrollFreeze(freeze_cols, freeze_rows);
    imgui.TableHeadersRow();

    if (props.show_filters == true) then
        local filter_hovered = false;
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);
        props.struct:each(function (v)
            imgui.TableNextColumn();
            imgui.PushItemWidth(-1);
            imgui.PushID(('filter_%s'):fmt(v.name));
            imgui.InputText(('##txt_filter_%s'):fmt(v.name), v.search_filter.buffer, v.search_filter.size);
            if (imgui.IsItemHovered()) then
                filter_hovered = true;
            end
            imgui.PopID();
        end);
        if (filter_hovered and imgui.IsMouseReleased(1)) then
            imgui.OpenPopup(('%s_filter_popup'):fmt(props.name));
        end
        if (imgui.BeginPopup(('%s_filter_popup'):fmt(props.name))) then
            if (imgui.Selectable(ICON_FA_ERASER .. 'Clear Filters')) then
                props.struct:each(function (vv)
                    vv.search_filter.buffer[1] = '';
                end);
            end
            if (props.on_filters_popup) then
                props.on_filters_popup(objs, props);
            end
            imgui.EndPopup();
        end
    end

    local members = filters.filter_members(objs, props);
    local clipper = ImGuiListClipper.new();
    clipper:Begin(#members, -1);

    while (clipper:Step()) do
        for x = clipper.DisplayStart, clipper.DisplayEnd - 1 do
            local m = members[x + 1];
            imgui.TableNextRow();
            imgui.PushID(('member_%d'):fmt(x));
            props.struct:each(function (v, k)
                local name = v.name:trim('_');
                imgui.TableNextColumn();
                if (props.overrides ~= nil and props.overrides[name] ~= nil) then
                    props.overrides[name](objs, m, props);
                else
                    if (not props.is_editable or props.readonly ~= nil and props.readonly:contains(name)) then
                        if (k == 1) then
                            if (imgui.Selectable(('%s'):fmt(m[name]), props.show_selection and props.__selected == m or false, bit.bor(ImGuiSelectableFlags_SpanAllColumns, ImGuiSelectableFlags_AllowOverlap), T{ 0, 0 })) then
                                props.__selected = m;
                                if (props.on_select) then
                                    props.on_select(objs, m, props);
                                end
                            end
                            if (imgui.IsItemHovered() and props.on_hover) then
                                props.on_hover(objs, m, props);
                            end
                        else
                            imgui.Text(tostring(m[name]));
                        end
                    else
                        imgui.PushStyleVar(ImGuiStyleVar_FramePadding, T{ 4, 0 });
                        gui.render_member_editor(m, v, props);
                        imgui.PopStyleVar();
                    end
                end
            end);
            imgui.PopID();
        end
    end

    imgui.EndTable();
end

--[[
* Renders an editor table for an array of values.
*
* @param {cdata} array - The parent array object.
* @param {table} values - The table of values to be displayed in the editor.
* @param {table} array_member - The reflex structure member of the array elements.
* @param {table} props - The table properties. (Must contain a 'struct' member!)
*
* Callback parameters:
*
*       on_filters_popup(parent, member, props)
*               on_hover(parent, member, props)
*              on_select(parent, member, props)
*              overrides(parent, member, props) [member = T{ index, value, }]
--]]
gui.render_array_editor = function (array, values, array_member, props)
    props:merge(gui.clone_default_properties(props), false);

    local freeze_cols = 1;
    local freeze_rows = props.show_filters and 2 or 1;

    freeze_cols = props.freeze_columns or freeze_cols;
    freeze_rows = props.freeze_rows or freeze_rows;

    local flags = props.flags or bit.bor(ImGuiTableFlags_RowBg, ImGuiTableFlags_Borders, ImGuiTableFlags_ScrollX, ImGuiTableFlags_ScrollY);
    if (not imgui.BeginTable(('%s_tbl'):fmt(props.name), 2, flags, { props.width or -1,  props.height or -1 })) then
        return;
    end

    imgui.TableSetupColumn('index', ImGuiTableColumnFlags_WidthFixed, props.property_width or 100);
    imgui.TableSetupColumn('value', ImGuiTableColumnFlags_WidthStretch);
    imgui.TableSetupScrollFreeze(freeze_cols, freeze_rows);
    imgui.TableHeadersRow();

    if (props.show_filters == true) then
        local filter_hovered = false;
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);
        imgui.TableNextColumn();
        imgui.PushItemWidth(-1);
        imgui.InputText('##txt_filter_p', props.filters.p.buffer, props.filters.p.size);
        imgui.PopItemWidth();
        if (imgui.IsItemHovered()) then
            filter_hovered = true;
        end
        imgui.TableNextColumn();
        imgui.PushItemWidth(-1);
        imgui.InputText('##txt_filter_v', props.filters.v.buffer, props.filters.v.size);
        imgui.PopItemWidth();
        if (imgui.IsItemHovered()) then
            filter_hovered = true;
        end
        if (filter_hovered and imgui.IsMouseReleased(1)) then
            imgui.OpenPopup(('%s_filter_popup'):fmt(props.name));
        end
        if (imgui.BeginPopup(('%s_filter_popup'):fmt(props.name))) then
            if (imgui.Selectable(ICON_FA_ERASER .. 'Clear Filters')) then
                props.filters.p.buffer[1] = '';
                props.filters.v.buffer[1] = '';
            end
            if (props.on_filters_popup) then
                props.on_filters_popup(values, props);
            end
            imgui.EndPopup();
        end
    end

    local vals = filters.filter_array(values, props);
    local clipper = ImGuiListClipper.new();
    clipper:Begin(#vals, -1);

    while (clipper:Step()) do
        for x = clipper.DisplayStart, clipper.DisplayEnd -1 do
            local m = vals[x + 1];
            imgui.TableNextRow();
            imgui.TableNextColumn();
            imgui.PushID(x + 1);
            if (imgui.Selectable(('%d##val_%d'):fmt(m.index, m.index), props.show_selection and props.__selected == m or false, bit.bor(ImGuiSelectableFlags_SpanAllColumns, ImGuiSelectableFlags_AllowOverlap), T{ 0, 0 })) then
                props.__selected = m;
                if (props.on_select) then
                    props.on_select(array, m, props);
                end
            end
            if (imgui.IsItemHovered() and props.on_hover) then
                props.on_hover(array, m, props);
            end
            imgui.TableNextColumn();
            imgui.PushStyleVar(ImGuiStyleVar_FramePadding, T{ 4, 0 });

            local pname = array_member.name:trimend('_');
            if (props.overrides ~= nil and props.overrides[pname] ~= nil) then
                props.overrides[pname](array, m, props);
            else
                if (not props.is_editable or props.readonly ~= nil and props.readonly:contains(pname)) then
                    imgui.Text(tostring(m.value));
                else
                    gui.render_array_value_editor(array, m, array_member, props);
                end
            end

            imgui.PopStyleVar();
            imgui.PopID();
        end
    end

    imgui.EndTable();
end

return gui;