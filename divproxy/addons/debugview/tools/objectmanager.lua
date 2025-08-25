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

local ffi       = require 'ffi';
local game      = require 'game';
local gui       = require 'utils.gui';
local imgui     = require 'imgui';
local reflex    = require 'reflex';

local tool = T{
    icon = ICON_FA_DIAGRAM_PROJECT,
    tag = 'objectmanager',
    name = 'Object Manager',
    window = T{
        is_open = T{ false, },
        title   = 'DbgView: Object Manager',
    },
    props = T{
        manager = T{
            show_filters    = true,
            show_selection  = true,
            is_editable     = false,
            struct          = reflex.reflect('CObjectManager'),
        },
        osiris_objects = T{
            height          = -imgui.GetTextLineHeightWithSpacing(),
            show_filters    = true,
            show_selection  = true,
            is_editable     = false,
            struct          = reflex.reflect('COsirisObject'),
        },
        extfree_objects = T{
            height          = -imgui.GetTextLineHeightWithSpacing(),
            property_width  = 55,
            show_filters    = true,
            show_selection  = true,
            is_editable     = false,
            struct          = reflex.reflect('CObjectManager'),
        },
        objects = T{
            height          = -imgui.GetTextLineHeightWithSpacing() - 28,
            freeze_columns  = 2,
            show_filters    = true,
            show_selection  = true,
            is_editable     = false,
            readonly        = T{ 'index', },
            struct          = reflex.reflect('CObject'),
        },
        object_instances = T{
            height          = -imgui.GetTextLineHeightWithSpacing() - 28,
            freeze_columns  = 2,
            show_filters    = true,
            show_selection  = true,
            is_editable     = false,
            readonly        = T{ 'index', 'object_index', },
            struct          = reflex.reflect('CObjectInstance'),
            cobject_struct  = reflex.reflect('CObject'),
            -- Custom properties..
            show_hovered    = false,
        },
        object_subwindow = T{
            object = T{
                height          = 400,
                show_filters    = true,
                show_selection  = true,
                is_editable     = true,
                struct          = reflex.reflect('CObject'),
            },
            -- Custom properties..
            selected_flag = T{ 0, },
            flag_value = T{ 0, },
        },
        object_instance_subwindow = T{
            object = T{
                height          = 400,
                show_filters    = true,
                show_selection  = true,
                is_editable     = true,
                readonly        = T{ 'index', },
                struct          = reflex.reflect('CObjectInstance'),
            },
            -- Custom properties..
            selected_flag = T{ 0, },
            flag_value = T{ 0, },
        },
    },
};

tool.load = function ()
    local mgr = game.get_object_manager();
    if (mgr == nil) then
        return false;
    end

    tool.props.objects.struct = gui.reorder_struct_members(tool.props.objects.struct, T{ 'index', 'name', });
    tool.props.object_instances.struct = gui.reorder_struct_members(tool.props.object_instances.struct, T{ 'index', 'object_index', });
    tool.props.object_instances.cobject_struct = gui.reorder_struct_members(tool.props.object_instances.cobject_struct, T{ 'index', 'name', });
    tool.props.object_subwindow.object.struct = gui.reorder_struct_members(tool.props.object_subwindow.object.struct, T{ 'index', 'name', });
    tool.props.object_instance_subwindow.object.struct = gui.reorder_struct_members(tool.props.object_instance_subwindow.object.struct, T{ 'index', 'object_index', });

    gui.generate_table_header_sizes(gui.get_members(mgr, 'osiris_objects', 'osiris_objects_size'), tool.props.osiris_objects);
    gui.generate_table_header_sizes(gui.get_members(mgr, 'extfree_objects', 'extfree_objects_size'), tool.props.extfree_objects);
    gui.generate_table_header_sizes(gui.get_members(mgr, 'objects', 'objects_size'), tool.props.objects);
    gui.generate_table_header_sizes(gui.get_members(mgr, 'objects_instances', 'objects_instances_size'), tool.props.object_instances);

    tool.props.objects.struct:filter(function (v) return v.name == 'data'; end):each(function (v) v.__table_header_width = 405; end);
    tool.props.object_instances.struct:filter(function (v) return v.name == 'data'; end):each(function (v) v.__table_header_width = 405; end);

    -- Callbacks..
    tool.props.objects.selected_index = nil;
    tool.props.objects.on_select = function (parent, member, props)
        tool.props.objects.selected_index = member.index;
    end;

    tool.props.object_instances.on_hover = function (parent, member, props)
        local mgr = game.get_object_manager();
        if (mgr == nil or member == nil or
            not imgui.IsKeyDown(ImGuiKey_LeftCtrl) or
            not imgui.BeginTooltip()) then
            return;
        end

        local obj = game.get_object_manager().objects[member.object_index];
        if (obj == nil) then
            imgui.TextColored(T{ 1.0, 0.4, 0.4, 1.0 }, 'Failed to obtain CObject entry for object!');
        else
            tool.props.object_instances.cobject_struct:each(function (v)
                local name = v.name:trimend('_');
                imgui.Text(('%s: '):fmt(name));
                imgui.SameLine(0, 0);
                if (tool.props.objects.overrides ~= nil and tool.props.objects.overrides[name]) then
                    imgui.PushStyleColor(ImGuiCol_Text, T{ 1.0, 1.0, 0.0, 1.0 });
                    tool.props.objects.overrides[name](obj, obj, nil);
                    imgui.PopStyleColor();
                else
                    imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, obj[name]);
                end
            end);
        end

        imgui.EndTooltip();
    end;
    tool.props.object_instances.selected_index = nil;
    tool.props.object_instances.on_select = function (parent, member, props)
        tool.props.object_instances.selected_index = member.index;
    end;

    -- Overrides
    tool.props.manager.overrides = T{
        object_file_name = function (parent, member, props)
            local name = parent[member.name];
            if (name ~= nil) then
                imgui.Text(ffi.string(name));
            else
                imgui.Text('(nil)');
            end
        end,
    };
    tool.props.objects.overrides = T{
        name = function (parent, member, props) imgui.Text(member.name); end,
        data = function (parent, member, props)
            imgui.Text(('F: %08X B: %08X %08X %08X %08X'):fmt(member.data.flags,
                member.data.bits1,
                member.data.bits2,
                member.data.bits3,
                member.data.bits4));
        end,
        clothing_code = function (parent, member, props)
            local codes = T{};
            for x = 0, 7 do
                codes:append(string.char(member.clothing_code[x]));
            end
            imgui.Text(codes:join());
        end,
        sfx = function (parent, member, props) imgui.Text('[sfx]'); end,
    };
    tool.props.object_instances.overrides = T{
        data = function (parent, member, props)
            imgui.Text(('F: %08X B: %08X %08X %08X %08X'):fmt(member.data.flags,
                member.data.bits1,
                member.data.bits2,
                member.data.bits3,
                member.data.bits4));
        end,
        tile_image_frame = function (parent, member, props) imgui.Text('[tile_image_frame]'); end,
        sorted_sprite = function (parent, member, props) imgui.Text('[sorted_sprite]'); end,
    };

    tool.props.object_subwindow.object.overrides = T{
        name = function (parent, member, props)
            local name = parent[member.name];
            if (name ~= nil) then
                imgui.Text(ffi.string(name));
            else
                imgui.Text('(nil)');
            end
        end,
        data = function (parent, member, props)
            local data = parent[member.name];
            if (data == nil) then
                imgui.Text('[data]');
            else
                imgui.Text(('F: %08X B: %08X %08X %08X %08X'):fmt(data.flags,
                    data.bits1,
                    data.bits2,
                    data.bits3,
                    data.bits4));
            end
        end,
        clothing_code = function (parent, member, props)
            local codes = T{};
            for x = 0, 7 do
                codes:append(string.char(parent[member.name][x]));
            end
            imgui.Text(codes:join());
        end,
        sfx = function (parent, member, props) imgui.Text('[sfx]'); end,
    };

    tool.props.object_instance_subwindow.object.overrides = T{
        data = function (parent, member, props)
            imgui.Text(('F: %08X B: %08X %08X %08X %08X'):fmt(parent[member.name].flags,
                parent[member.name].bits1,
                parent[member.name].bits2,
                parent[member.name].bits3,
                parent[member.name].bits4));
        end,
        tile_image_frame = function (parent, member, props) imgui.Text('[tile_image_frame]'); end,
        sorted_sprite = function (parent, member, props) imgui.Text('[sorted_sprite]'); end,
    };

    return true;
end

tool.unload = function ()
end

tool.menu = function ()
    if (imgui.MenuItemEx(('Tool: %s'):fmt(tool.name), tool.icon, nil, tool.window.is_open[1], true)) then
        tool.window.is_open[1] = not tool.window.is_open[1];
    end
end

tool.render = function ()
    tool.render_hover_window();

    if (not tool.window.is_open[1]) then
        return;
    end

    local obj = game.get_object_manager();
    if (obj == nil) then return; end

    imgui.SetNextWindowSize(T{ 675, 275 }, ImGuiCond_Once);
    imgui.SetNextWindowSizeConstraints(T{ 675, 275 }, T{ FLT_MAX, FLT_MAX });
    if (not imgui.Begin(tool.icon .. tool.window.title, tool.window.is_open)) then
        imgui.End();
        return;
    end

    if (imgui.BeginTabBar(('%s_tab_bar'):fmt(tool.tag))) then
        if (imgui.BeginTabItem('Manager')) then
            gui.render_property_editor(obj, tool.props.manager);
            imgui.EndTabItem();
        end
        if (imgui.BeginTabItem('Osiris Objects')) then
            gui.render_object_list_editor(gui.get_members(obj, 'osiris_objects', 'osiris_objects_size'), tool.props.osiris_objects);

            imgui.Text('Total Objects: ');
            imgui.SameLine(0, 0);
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, ('%d'):fmt(obj.osiris_objects_size));
            imgui.SameLine();
            imgui.Text("(size) |");
            imgui.SameLine();
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, ('%d'):fmt(obj.osiris_objects_count));
            imgui.SameLine();
            imgui.Text("(count) |");
            imgui.SameLine();
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, ('%d'):fmt(obj.osiris_objects_max));
            imgui.SameLine();
            imgui.Text("(max)");
            imgui.EndTabItem();
        end
        if (imgui.BeginTabItem('Extfree Objects')) then
            gui.render_array_editor(
                obj.extfree_objects,
                gui.get_array_values(obj.extfree_objects, obj.extfree_objects_size),
                tool.props.extfree_objects.struct:filteri(function (v) return v.name == 'extfree_objects'; end):first(),
                tool.props.extfree_objects);

            imgui.Text('Total Objects: ');
            imgui.SameLine(0, 0);
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.extfree_objects_size));
            imgui.SameLine();
            imgui.Text('(size)');

            imgui.EndTabItem();
        end
        if (imgui.BeginTabItem('Objects (CObject)')) then
            gui.render_object_list_editor(gui.get_members(obj, 'objects', 'objects_size'), tool.props.objects);

            imgui.Text('Total Objects: ');
            imgui.SameLine(0, 0);
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, ('%d'):fmt(obj.objects_size));
            imgui.SameLine();
            imgui.Text("(size) |");
            imgui.SameLine();
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, ('%d'):fmt(obj.objects_max));
            imgui.SameLine();
            imgui.Text("(max)");

            local is_editable = T{ tool.props.objects.is_editable, };
            if (imgui.Checkbox('Editable?', is_editable)) then
                tool.props.objects.is_editable = is_editable[1];
            end

            if (tool.props.objects.selected_index ~= nil) then
                tool.render_object_subwindow();
            end

            imgui.EndTabItem();
        end
        if (imgui.BeginTabItem('Objects (CObjectInstance)')) then
            gui.render_object_list_editor(gui.get_members(obj, 'objects_instances', 'objects_instances_size'), tool.props.object_instances);

            imgui.Text('Total Objects: ');
            imgui.SameLine(0, 0);
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, ('%d'):fmt(obj.objects_instances_size));
            imgui.SameLine();
            imgui.Text("(size) |");
            imgui.SameLine();
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, ('%d'):fmt(obj.objects_instances_max));
            imgui.SameLine();
            imgui.Text("(max) |");
            imgui.SameLine();
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, ('%d'):fmt(obj.objects_instances_chunk_size));
            imgui.SameLine();
            imgui.Text("(chunk size) |");
            imgui.SameLine();
            imgui.Text("Hovered Object Index: ");
            imgui.SameLine(0, 0);
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, ('%d'):fmt(game.get_player().mouse_hover_object_index));
            imgui.SameLine();
            imgui.Text('|');
            imgui.SameLine();
            imgui.TextColored(T{ 0.0, 1.0, 1.0, 1.0 }, 'Hint: ');
            imgui.SameLine(0, 0);
            imgui.Text("Press and hold CTRL while hovering entries to view more details!");

            local is_editable = T{ tool.props.object_instances.is_editable, };
            if (imgui.Checkbox('Editable?', is_editable)) then
                tool.props.object_instances.is_editable = is_editable[1];
            end

            imgui.SameLine();
            imgui.Text('|');
            imgui.SameLine();

            local show_hovered = T{ tool.props.object_instances.show_hovered, };
            if (imgui.Checkbox('Show Hovered Infobox?', show_hovered)) then
                tool.props.object_instances.show_hovered = show_hovered[1];
            end

            imgui.ShowHelp('Hover your mouse over an object in-game to see more info.', true);

            if (tool.props.object_instances.selected_index ~= nil) then
                tool.render_object_instance_subwindow();
            end

            imgui.EndTabItem();
        end
        imgui.EndTabBar();
    end

    imgui.End();
end

tool.render_hover_window = function ()
    if (not tool.props.object_instances.show_hovered) then
        return;
    end

    local player = game.get_player();
    if (player == nil or player.mouse_hover_object_index == -1) then
        return;
    end

    local mgr = game.get_object_manager();
    if (mgr == nil) then
        return;
    end

    local inst  = mgr.objects_instances[player.mouse_hover_object_index];
    local obj   = mgr.objects[inst.object_index];

    if (inst == nil or obj == nil) then
        return;
    end

    imgui.SetNextWindowPos(T{ 2, 30 });
    imgui.SetNextWindowSizeConstraints(T{ 450, 100 }, T{ FLT_MAX, FLT_MAX });

    local flags = bit.bor(ImGuiWindowFlags_AlwaysAutoResize, ImGuiWindowFlags_NoCollapse, ImGuiWindowFlags_NoResize);
    if (not imgui.Begin(tool.icon .. ('Hovered Object: [%d] %s###hovered_object'):fmt(player.mouse_hover_object_index, obj.name), {}, flags)) then
        imgui.End();
        return;
    end

    imgui.SeparatorText('Object Information');

    if (imgui.BeginTable('object_info_tbl', 2, bit.bor(ImGuiTableFlags_Borders, ImGuiTableFlags_SizingFixedFit, ImGuiTableFlags_RowBg))) then
        imgui.TableSetupColumn('Name', ImGuiTableColumnFlags_WidthFixed, 125);
        imgui.TableSetupColumn('Value', ImGuiTableColumnFlags_WidthStretch);
        imgui.TableHeadersRow();

        local fields = T{ 'index', 'name', 'object_class', 'weight', };

        fields:each(function (v)
            imgui.TableNextRow();
            imgui.TableNextColumn();
            imgui.Text(v:replace('_', ' '):proper());
            imgui.TableNextColumn();
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj[v]));
        end);

        imgui.EndTable();
    end

    imgui.NewLine();
    imgui.Text('Flags: ');
    imgui.SameLine(0, 0);
    imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, ('%08X'):fmt(obj.flags));

    local data = T{ 'flags', 'bits1', 'bits2', 'bits3', 'bits4', };
    imgui.Text('Data');

    data:each(function (v)
        imgui.Text(' - ');
        imgui.SameLine(0, 0);
        imgui.TextColored(T{ 0.0, 1.0, 1.0, 1.0 }, v:proper() .. ': ');
        imgui.SameLine(0, 0);
        imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, ('%08X'):fmt(obj.data[v]));
    end);

    imgui.NewLine();
    imgui.SeparatorText('Instance Information');

    if (imgui.BeginTable('object_instance_info_tbl', 2, bit.bor(ImGuiTableFlags_Borders, ImGuiTableFlags_SizingFixedFit, ImGuiTableFlags_RowBg))) then
        imgui.TableSetupColumn('Name', ImGuiTableColumnFlags_WidthFixed, 125);
        imgui.TableSetupColumn('Value', ImGuiTableColumnFlags_WidthStretch);
        imgui.TableHeadersRow();

        local fields = T{ 'index', 'x', 'y', };

        fields:each(function (v)
            imgui.TableNextRow();
            imgui.TableNextColumn();
            imgui.Text(v:replace('_', ' '):proper());
            imgui.TableNextColumn();
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(inst[v]));
        end);

        imgui.EndTable();
    end

    imgui.NewLine();
    imgui.Text('Flags: ');
    imgui.SameLine(0, 0);
    imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, ('%08X'):fmt(inst.flags));

    local data = T{ 'flags', 'bits1', 'bits2', 'bits3', 'bits4', };
    imgui.Text('Data');

    data:each(function (v)
        imgui.Text(' - ');
        imgui.SameLine(0, 0);
        imgui.TextColored(T{ 0.0, 1.0, 1.0, 1.0 }, v:proper() .. ': ');
        imgui.SameLine(0, 0);
        imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, ('%08X'):fmt(inst.data[v]));
    end);

    imgui.NewLine();
    imgui.SeparatorText('Object Bits');

    if (imgui.BeginTable('object_bits_tbl', 3, bit.bor(ImGuiTableFlags_Borders, ImGuiTableFlags_SizingFixedFit, ImGuiTableFlags_RowBg))) then
        imgui.TableSetupColumn('Bit', ImGuiTableColumnFlags_WidthFixed, 50);
        imgui.TableSetupColumn('Name', ImGuiTableColumnFlags_WidthFixed, 150);
        imgui.TableSetupColumn('Value', ImGuiTableColumnFlags_WidthStretch);
        imgui.TableHeadersRow();

        for x = 0, 31 do
            if (bit.band(bit.lshift(1, x), inst.data.flags) ~= 0) then
                imgui.TableNextRow();
                imgui.TableNextColumn();
                imgui.Text(tostring(x));
                imgui.TableNextColumn();
                imgui.PushStyleColor(ImGuiCol_Text, T{ 1.0, 1.0, 0.0, 1.0 });
                imgui.Text(ObjectDataFlagNames[x + 1]);
                imgui.PopStyleColor();
                imgui.TableNextColumn();
                imgui.PushStyleColor(ImGuiCol_Text, T{ 0.0, 1.0, 1.0, 1.0 });
                imgui.Text(tostring(inst.data:get_property(x)));
                imgui.PopStyleColor();
            end
        end

        imgui.EndTable();
    end

    imgui.End();
end

tool.render_object_subwindow = function ()
    local mgr = game.get_object_manager();
    local idx = tool.props.objects.selected_index;
    if (mgr == nil or idx == nil) then
        tool.props.objects.selected_index = nil;
        return;
    end

    local obj = mgr.objects[idx];
    if (obj == nil) then
        tool.props.objects.selected_index = nil;
        return;
    end

    local is_open = T{ true, };
    imgui.SetNextWindowSizeConstraints(T{ 675, 275 }, T{ FLT_MAX, FLT_MAX });
    if (not imgui.Begin(('DbgView: Object - Idx: %d - %s###object_subwindow'):fmt(obj.index, obj.name), is_open, ImGuiWindowFlags_AlwaysAutoResize)) then
        imgui.End();
        return;
    end

    if (imgui.BeginTabBar('object_subwindow_tab_bar')) then
        if (imgui.BeginTabItem('Object')) then
            gui.render_property_editor(obj, tool.props.object_subwindow.object);
            imgui.EndTabItem();
        end
        if (imgui.BeginTabItem('Data')) then
            imgui.SeparatorText('Data Information');
            if (imgui.BeginTable('objects_subwindow_data_tbl', 2, bit.bor(ImGuiTableFlags_Borders, ImGuiTableFlags_SizingFixedFit, ImGuiTableFlags_RowBg))) then
                imgui.TableSetupColumn('Name', ImGuiTableColumnFlags_WidthFixed, 75);
                imgui.TableSetupColumn('Value', ImGuiTableColumnFlags_WidthStretch);
                imgui.TableHeadersRow();

                local fields = T{ 'flags', 'bits1', 'bits2', 'bits3', 'bits4', };

                fields:each(function (v)
                    imgui.TableNextRow();
                    imgui.TableNextColumn();
                    imgui.Text(v:replace('_', ' '):proper());
                    imgui.TableNextColumn();
                    imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, ('%08X'):fmt(obj.data[v]));
                end);

                imgui.EndTable();
            end

            imgui.SeparatorText('Data Bits');

            if (imgui.BeginTable('objects_subwindow_bits_tbl', 5, bit.bor(ImGuiTableFlags_Borders, ImGuiTableFlags_SizingFixedFit, ImGuiTableFlags_RowBg))) then
                imgui.TableSetupColumn('Flag', ImGuiTableColumnFlags_WidthFixed, 75);
                imgui.TableSetupColumn('Name', ImGuiTableColumnFlags_WidthFixed, 150);
                imgui.TableSetupColumn('Size', ImGuiTableColumnFlags_WidthFixed, 75);
                imgui.TableSetupColumn('Value', ImGuiTableColumnFlags_WidthFixed, 100);
                imgui.TableSetupColumn('Actions', ImGuiTableColumnFlags_WidthStretch);
                imgui.TableHeadersRow();

                for x = 0, 31 do
                    if (bit.band(bit.lshift(1, x), obj.data.flags) ~= 0) then
                        imgui.PushID(x);
                        imgui.TableNextRow();
                        imgui.TableNextColumn();
                        imgui.Text(tostring(x));
                        imgui.TableNextColumn();
                        imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, ObjectDataFlagNames[x + 1]);
                        imgui.TableNextColumn();
                        imgui.Text(tostring(game.get_object_property_byte_size(x)));
                        imgui.TableNextColumn();
                        imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.data:get_property(x)));
                        imgui.TableNextColumn();
                        imgui.PushStyleVar(ImGuiStyleVar_FramePadding, T{ 4, 2 });
                        if (imgui.Button('Remove')) then
                            obj.data:remove_property(x);
                        end
                        imgui.PopStyleVar();
                        imgui.PopID();
                    end
                end

                imgui.EndTable();
            end

            imgui.Text('Total Size: ');
            imgui.SameLine(0, 0);
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.data:get_properties_size()));

            imgui.SeparatorText('Editor');

            local flags = ObjectDataFlagNames:clone():imap(function (v, k) return ('%d - %s - [Size: %d]'):fmt(k - 1, v, game.get_object_property_byte_size(k - 1)); end):join('\0'):append('\0');
            local size = game.get_object_property_byte_size(tool.props.object_subwindow.selected_flag[1]);

            imgui.PushItemWidth(350);
            imgui.Combo('Flag', tool.props.object_subwindow.selected_flag, flags);
            if (size > 0) then
                imgui.InputScalar('Value', size == 1 and ImGuiDataType_U8 or ImGuiDataType_U16, tool.props.object_subwindow.flag_value, T{ 1 }, nil, '%d');
            else
                tool.props.object_subwindow.flag_value[1] = 0;
            end
            imgui.PopItemWidth();

            if (imgui.Button('Add Flag')) then
                obj.data:set_property(tool.props.object_subwindow.selected_flag[1], tool.props.object_subwindow.flag_value[1]);
            end

            imgui.EndTabItem();
        end
        imgui.EndTabBar();
    end

    imgui.End();

    if (is_open[1] == false) then tool.props.objects.selected_index = nil; end
end

tool.render_object_instance_subwindow = function ()
    local mgr = game.get_object_manager();
    local idx = tool.props.object_instances.selected_index;
    if (mgr == nil or idx == nil) then
        tool.props.object_instances.selected_index = nil;
        return;
    end

    if (idx >= mgr.objects_instances_size) then
        tool.props.object_instances.selected_index = nil;
        return;
    end

    local obj = mgr.objects_instances[idx];
    if (obj == nil) then
        tool.props.object_instances.selected_index = nil;
        return;
    end

    local name = '';
    if (obj.object_index ~= nil) then
        local o = mgr.objects[obj.object_index];
        if (o ~= nil) then
            name = o.name;
        end
    end

    local is_open = T{ true, };
    imgui.SetNextWindowSizeConstraints(T{ 675, 275 }, T{ FLT_MAX, FLT_MAX });
    if (not imgui.Begin(('DbgView: Object Instance - Idx: %d - %s###object_instance_subwindow'):fmt(obj.index, name), is_open, ImGuiWindowFlags_AlwaysAutoResize)) then
        imgui.End();
        return;
    end

    if (imgui.BeginTabBar('object_subwindow_tab_bar')) then
        if (imgui.BeginTabItem('Object')) then
            gui.render_property_editor(obj, tool.props.object_instance_subwindow.object);
            imgui.EndTabItem();
        end
        if (imgui.BeginTabItem('Data')) then
            imgui.SeparatorText('Data Information');
            if (imgui.BeginTable('objects_subwindow_data_tbl', 2, bit.bor(ImGuiTableFlags_Borders, ImGuiTableFlags_SizingFixedFit, ImGuiTableFlags_RowBg))) then
                imgui.TableSetupColumn('Name', ImGuiTableColumnFlags_WidthFixed, 75);
                imgui.TableSetupColumn('Value', ImGuiTableColumnFlags_WidthStretch);
                imgui.TableHeadersRow();

                local fields = T{ 'flags', 'bits1', 'bits2', 'bits3', 'bits4', };

                fields:each(function (v)
                    imgui.TableNextRow();
                    imgui.TableNextColumn();
                    imgui.Text(v:replace('_', ' '):proper());
                    imgui.TableNextColumn();
                    imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, ('%08X'):fmt(obj.data[v]));
                end);

                imgui.EndTable();
            end

            imgui.SeparatorText('Data Bits');

            if (imgui.BeginTable('objects_subwindow_bits_tbl', 5, bit.bor(ImGuiTableFlags_Borders, ImGuiTableFlags_SizingFixedFit, ImGuiTableFlags_RowBg))) then
                imgui.TableSetupColumn('Flag', ImGuiTableColumnFlags_WidthFixed, 75);
                imgui.TableSetupColumn('Name', ImGuiTableColumnFlags_WidthFixed, 150);
                imgui.TableSetupColumn('Size', ImGuiTableColumnFlags_WidthFixed, 75);
                imgui.TableSetupColumn('Value', ImGuiTableColumnFlags_WidthFixed, 100);
                imgui.TableSetupColumn('Actions', ImGuiTableColumnFlags_WidthStretch);
                imgui.TableHeadersRow();

                for x = 0, 31 do
                    if (bit.band(bit.lshift(1, x), obj.data.flags) ~= 0) then
                        imgui.PushID(x);
                        imgui.TableNextRow();
                        imgui.TableNextColumn();
                        imgui.Text(tostring(x));
                        imgui.TableNextColumn();
                        imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, ObjectDataFlagNames[x + 1]);
                        imgui.TableNextColumn();
                        imgui.Text(tostring(game.get_object_property_byte_size(x)));
                        imgui.TableNextColumn();
                        imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.data:get_property(x)));
                        imgui.TableNextColumn();
                        imgui.PushStyleVar(ImGuiStyleVar_FramePadding, T{ 4, 2 });
                        if (imgui.Button('Remove')) then
                            obj.data:remove_property(x);
                        end
                        imgui.PopStyleVar();
                        imgui.PopID();
                    end
                end

                imgui.EndTable();
            end

            imgui.Text('Total Size: ');
            imgui.SameLine(0, 0);
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.data:get_properties_size()));

            imgui.SeparatorText('Editor');

            local flags = ObjectDataFlagNames:clone():imap(function (v, k) return ('%d - %s - [Size: %d]'):fmt(k - 1, v, game.get_object_property_byte_size(k - 1)); end):join('\0'):append('\0');
            local size = game.get_object_property_byte_size(tool.props.object_subwindow.selected_flag[1]);

            imgui.PushItemWidth(285);
            imgui.Combo('Flag', tool.props.object_subwindow.selected_flag, flags);
            if (size > 0) then
                imgui.InputScalar('Value', size == 1 and ImGuiDataType_U8 or ImGuiDataType_U16, tool.props.object_subwindow.flag_value, T{ 1 }, nil, '%d');
            else
                tool.props.object_subwindow.flag_value[1] = 0;
            end
            imgui.PopItemWidth();

            if (imgui.Button('Add Flag')) then
                obj.data:set_property(tool.props.object_subwindow.selected_flag[1], tool.props.object_subwindow.flag_value[1]);
            end

            imgui.EndTabItem();
        end
        imgui.EndTabBar();
    end

    imgui.End();

    if (is_open[1] == false) then tool.props.object_instances.selected_index = nil; end
end

return tool;