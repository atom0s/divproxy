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

local game      = require 'game';
local gui       = require 'utils.gui';
local imgui     = require 'imgui';
local reflex    = require 'reflex';

local tool = T{
    icon = ICON_FA_SCALE_BALANCED,
    tag = 'alignmentmanager',
    name = 'Alignment Manager',
    window = T{
        is_open = T{ false, },
        title   = 'DbgView: Alignment Manager',
    },
    props = T{
        manager = T{
            show_filters    = true,
            show_selection  = true,
            is_editable     = false,
            struct          = reflex.reflect('CAlignmentManager'),
        },
        entries = T{
            height          = -imgui.GetTextLineHeightWithSpacing(),
            show_filters    = true,
            show_selection  = true,
            is_editable     = false,
            freeze_columns  = 3,
            struct          = reflex.reflect('CAlignmentEntry'),
        },
        alignments = T{
            height          = -imgui.GetTextLineHeightWithSpacing(),
            show_filters    = true,
            show_selection  = true,
            is_editable     = false,
            freeze_columns  = 3,
            struct          = reflex.reflect('CAlignment'),
        },
        calculations = T{
            height          = -imgui.GetTextLineHeightWithSpacing() - 28,
            show_filters    = true,
            show_selection  = true,
            is_editable     = false,
            struct          = reflex.reflect('CAlignmentCalculations'),
        },
        entries_subwindow = T{
            alignment_relations = T{
                height          = 200,
                show_filters    = true,
                show_selection  = true,
                is_editable     = true,
                struct          = reflex.reflect('CAlignmentRelations'),
            },
            alignment_entities = T{
                height          = 200,
                show_filters    = true,
                show_selection  = true,
                is_editable     = false,
                struct          = reflex.reflect('CAlignmentEntity'),
            },
            entity_relations = T{
                height          = 200,
                show_filters    = true,
                show_selection  = true,
                is_editable     = true,
                struct          = reflex.reflect('CAlignmentRelations'),
            },
        },
        alignments_subwindow = T{
            alignment_relations = T{
                height          = 200,
                show_filters    = true,
                show_selection  = true,
                is_editable     = true,
                struct          = reflex.reflect('CAlignmentRelations'),
            },
            alignment_entities = T{
                height          = 200,
                show_filters    = true,
                show_selection  = true,
                is_editable     = false,
                struct          = reflex.reflect('CAlignmentEntity'),
            },
        },
    },
};

tool.load = function ()
    local mgr = game.get_alignment_manager();
    if (mgr == nil) then
        return false;
    end

    tool.props.entries.struct = gui.reorder_struct_members(tool.props.entries.struct, T{ 'index', 'id', 'class_name', 'class_name_size', });
    tool.props.alignments.struct = gui.remove_struct_members(tool.props.alignments.struct, T{ 'vtbl', });
    tool.props.alignments.struct = gui.reorder_struct_members(tool.props.alignments.struct, T{ 'id', 'class_name', });
    tool.props.entries_subwindow.alignment_relations.struct = gui.reorder_struct_members(tool.props.entries_subwindow.alignment_relations.struct, T{ 'id', 'value', });
    tool.props.entries_subwindow.alignment_entities.struct = gui.remove_struct_members(tool.props.entries_subwindow.alignment_entities.struct, T{ 'vtbl', });
    tool.props.entries_subwindow.alignment_entities.struct = gui.reorder_struct_members(tool.props.entries_subwindow.alignment_entities.struct, T{ 'id', 'class_name', });
    tool.props.entries_subwindow.entity_relations.struct = gui.reorder_struct_members(tool.props.entries_subwindow.entity_relations.struct, T{ 'id', 'value', });
    tool.props.alignments_subwindow.alignment_relations.struct = gui.reorder_struct_members(tool.props.alignments_subwindow.alignment_relations.struct, T{ 'id', 'value', });
    tool.props.alignments_subwindow.alignment_entities.struct = gui.remove_struct_members(tool.props.alignments_subwindow.alignment_entities.struct, T{ 'vtbl', });
    tool.props.alignments_subwindow.alignment_entities.struct = gui.reorder_struct_members(tool.props.alignments_subwindow.alignment_entities.struct, T{ 'id', 'class_name', });

    gui.generate_table_header_sizes(gui.get_members(mgr, 'entries', 'entries_max'), tool.props.entries);
    gui.generate_table_header_sizes(gui.get_members(mgr, 'alignments', 'alignments_size'), tool.props.alignments);
    gui.generate_table_header_sizes(gui.get_members(mgr.entries[1].alignment, 'entities', 'entities_max'), tool.props.entries_subwindow.alignment_entities);
    gui.generate_table_header_sizes(gui.get_members(mgr.entries[4].alignment, 'relations', 'relations_max'), tool.props.entries_subwindow.alignment_relations);
    gui.generate_table_header_sizes(gui.get_members(mgr.entries[4].alignment, 'relations', 'relations_max'), tool.props.entries_subwindow.entity_relations);
    gui.generate_table_header_sizes(gui.get_members(mgr.alignments[1], 'entities', 'entities_max'), tool.props.alignments_subwindow.alignment_entities);
    gui.generate_table_header_sizes(gui.get_members(mgr.alignments[1], 'relations', 'relations_max'), tool.props.alignments_subwindow.alignment_relations);

    -- Callbacks..
    tool.props.entries.selected_index = nil;
    tool.props.entries.on_select = function (parent, member, props)
        tool.props.entries.selected_index = member.index;
    end

    tool.props.alignments.selected_index = nil;
    tool.props.alignments.on_select = function (parent, member, props)
        local idx = parent:find_if(function (v) return v.id == member.id; end);
        if (idx ~= nil) then
            tool.props.alignments.selected_index = idx - 1;
        end
    end

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
    if (not tool.window.is_open[1]) then
        return;
    end

    local obj = game.get_alignment_manager();
    if (obj == nil) then
        return;
    end

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
        if (imgui.BeginTabItem('Entries')) then
            gui.render_object_list_editor(gui.get_members(obj, 'entries', 'entries_max'), tool.props.entries);
            imgui.Text('Total Entries: ');
            imgui.SameLine(0, 0);
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.entries_max));
            imgui.SameLine();
            imgui.Text('| Next Index: ');
            imgui.SameLine(0, 0);
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.entries_index));
            imgui.SameLine();
            imgui.Text('| Next Id: ');
            imgui.SameLine(0, 0);
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.entries_id));

            if (tool.props.entries.selected_index ~= nil) then
                tool.render_entries_subwindow();
            end

            imgui.EndTabItem();
        end
        if (imgui.BeginTabItem('Alignments')) then
            gui.render_object_list_editor(gui.get_members(obj, 'alignments', 'alignments_size'), tool.props.alignments);
            imgui.Text('Total Alignments: ');
            imgui.SameLine(0, 0);
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.alignments_size));
            imgui.SameLine();
            imgui.Text('(size) |');
            imgui.SameLine();
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.alignments_max));
            imgui.SameLine();
            imgui.Text('(max)');

            if (tool.props.alignments.selected_index ~= nil) then
                tool.render_alignments_subwindow();
            end

            imgui.EndTabItem();
        end
        if (imgui.BeginTabItem('Calculations')) then
            if (obj.calculations == nil) then
                imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, 'No calculations currently available.');
            else
                gui.render_array_editor(
                    obj.calculations.cvalues,
                    gui.get_array_values(obj.calculations.cvalues, bit.rshift(obj.calculations.size * obj.calculations.max, 5) + 1),
                    tool.props.calculations.struct:filter(function (v) return v.name == 'cvalues'; end):first(),
                    tool.props.calculations);

                imgui.Text('Total Calculations: ');
                imgui.SameLine(0, 0);
                imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.calculations.size));
                imgui.SameLine();
                imgui.Text('(size) |');
                imgui.SameLine();
                imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.calculations.max));
                imgui.SameLine();
                imgui.Text('(max) |');
                imgui.SameLine();
                imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(bit.rshift(obj.calculations.size * obj.calculations.max, 5) + 1));
                imgui.SameLine();
                imgui.Text('(calculated size)');

                local is_editable = T{ tool.props.calculations.is_editable, };
                if (imgui.Checkbox('Editable?', is_editable)) then
                    tool.props.calculations.is_editable = is_editable[1];
                end
            end
            imgui.EndTabItem();
        end
        imgui.EndTabBar();
    end

    imgui.End();
end

tool.render_entries_subwindow = function ()
    local mgr = game.get_alignment_manager();
    local idx = tool.props.entries.selected_index;
    if (mgr == nil or idx == nil) then
        tool.props.entries.selected_index = nil;
        return;
    end

    local obj = mgr.entries[idx];
    if (obj == nil) then
        tool.props.entries.selected_index = nil;
        return;
    end

    local is_open = { true, };
    imgui.SetNextWindowSizeConstraints(T{ 675, 275 }, T{ FLT_MAX, FLT_MAX });
    if (not imgui.Begin(('DbgView: Alignment Entry - Idx: %d - %s###alignment_entries_subwindow'):fmt(obj.index, obj.class_name), is_open, ImGuiWindowFlags_AlwaysAutoResize)) then
        imgui.End();
        return;
    end

    if (imgui.BeginTabBar('alignment_entries_subwindow_tab_bar')) then
        if (imgui.BeginTabItem('Entry')) then
            if (imgui.BeginTable('entries_subwindow_entry_tbl', 2, bit.bor(ImGuiTableFlags_Borders, ImGuiTableFlags_SizingFixedFit, ImGuiTableFlags_RowBg))) then
                imgui.TableSetupColumn('Name', ImGuiTableColumnFlags_WidthFixed, 125);
                imgui.TableSetupColumn('Value', ImGuiTableColumnFlags_WidthStretch);
                imgui.TableHeadersRow();

                local fields = T{ 'index', 'id', 'class_name', };

                fields:each(function (v)
                    imgui.TableNextRow();
                    imgui.TableNextColumn();
                    imgui.Text(v:replace('_', ' '):proper());
                    imgui.TableNextColumn();
                    imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj[v]));
                end);

                imgui.EndTable();
            end

            imgui.EndTabItem();
        end

        if (imgui.BeginTabItem('Alignment')) then
            if (obj.alignment == nil) then
                imgui.TextColored(T{ 1.0, 0.6, 0.6, 1.0 }, 'No alignment currently set.');
            else
                if (imgui.BeginTable('entries_subwindow_alignment_tbl', 2, bit.bor(ImGuiTableFlags_Borders, ImGuiTableFlags_SizingFixedFit, ImGuiTableFlags_RowBg))) then
                    imgui.TableSetupColumn('Name', ImGuiTableColumnFlags_WidthFixed, 125);
                    imgui.TableSetupColumn('Value', ImGuiTableColumnFlags_WidthStretch);
                    imgui.TableHeadersRow();

                    local fields = T{ 'id', 'class_name', 'relations', 'relations_index', 'relations_max', 'entities', 'entities_size', 'entities_max', };

                    fields:each(function (v)
                        imgui.TableNextRow();
                        imgui.TableNextColumn();
                        imgui.Text(v:replace('_', ' '):proper());
                        imgui.TableNextColumn();
                        imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.alignment[v]));
                    end);

                    imgui.EndTable();
                end
            end

            imgui.NewLine();
            imgui.SeparatorText('Tools');

            local values = T{ 'None', };
            for x = 0, mgr.alignments_size - 1 do
                values:append(mgr.alignments[x].class_name);
            end
            local val = T{ -1, };
            if (imgui.Combo('Change Alignment', val, values:join('\0'):append('\0'))) then
                if (val[1] == 0) then
                    obj.alignment = nil;
                else
                    obj.alignment = mgr.alignments[val[1] - 1];
                end
            end

            if (obj.alignment ~= nil) then
                imgui.NewLine();
                imgui.SeparatorText('Relations');
                gui.render_object_list_editor(gui.get_members(obj.alignment, 'relations', 'relations_max'), tool.props.entries_subwindow.alignment_relations);
                imgui.Text('Total Relations: ');
                imgui.SameLine(0, 0);
                imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.alignment.relations_max));
                imgui.SameLine();
                imgui.Text('(max) |');
                imgui.SameLine();
                imgui.Text('Next Index: ');
                imgui.SameLine(0, 0);
                imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.alignment.relations_index));

                imgui.NewLine();
                imgui.SeparatorText('Entities');
                gui.render_object_list_editor(gui.get_members(obj.alignment, 'entities', 'entities_size'), tool.props.entries_subwindow.alignment_entities);
                imgui.Text('Total Entities: ');
                imgui.SameLine(0, 0);
                imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.alignment.entities_size));
                imgui.SameLine();
                imgui.Text('(size) |');
                imgui.SameLine();
                imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.alignment.entities_max));
                imgui.SameLine();
                imgui.Text('(max)');
            end

            imgui.EndTabItem();
        end

        if (imgui.BeginTabItem('Entity')) then
            if (obj.entity == nil) then
                imgui.TextColored(T{ 1.0, 0.6, 0.6, 1.0 }, 'No entity currently set.');
            else
                if (imgui.BeginTable('entries_subwindow_entity_tbl', 2, bit.bor(ImGuiTableFlags_Borders, ImGuiTableFlags_SizingFixedFit, ImGuiTableFlags_RowBg))) then
                    imgui.TableSetupColumn('Name', ImGuiTableColumnFlags_WidthFixed, 125);
                    imgui.TableSetupColumn('Value', ImGuiTableColumnFlags_WidthStretch);
                    imgui.TableHeadersRow();

                    local fields = T{ 'id', 'class_name', 'relations', 'relations_index', 'relations_max', };

                    fields:each(function (v)
                        imgui.TableNextRow();
                        imgui.TableNextColumn();
                        imgui.Text(v:replace('_', ' '):proper());
                        imgui.TableNextColumn();
                        imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.entity[v]));
                    end);

                    imgui.EndTable();
                end
            end

            if (obj.entity ~= nil) then
                imgui.NewLine();
                imgui.SeparatorText('Relations');
                gui.render_object_list_editor(gui.get_members(obj.entity, 'relations', 'relations_max'), tool.props.entries_subwindow.entity_relations);
                imgui.Text('Total Relations: ');
                imgui.SameLine(0, 0);
                imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.entity.relations_max));
                imgui.SameLine();
                imgui.Text('(max) |');
                imgui.SameLine();
                imgui.Text('Next Index: ');
                imgui.SameLine(0, 0);
                imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.entity.relations_index));
            end

            imgui.EndTabItem();
        end
        imgui.EndTabBar();
    end

    imgui.End();

    if (is_open[1] == false) then tool.props.entries.selected_index = nil; end
end

tool.render_alignments_subwindow = function ()
    local mgr = game.get_alignment_manager();
    local idx = tool.props.alignments.selected_index;
    if (mgr == nil or idx == nil) then
        tool.props.alignments.selected_index = nil;
        return;
    end

    local obj = mgr.alignments[idx];
    if (obj == nil) then
        tool.props.alignments.selected_index = nil;
        return;
    end

    local is_open = { true, };
    imgui.SetNextWindowSizeConstraints(T{ 675, 275 }, T{ FLT_MAX, FLT_MAX });
    if (not imgui.Begin(('DbgView: Alignment Id: %d - %s###alignments_subwindow'):fmt(obj.id, obj.class_name), is_open, ImGuiWindowFlags_AlwaysAutoResize)) then
        imgui.End();
        return;
    end

    if (imgui.BeginTable('alignments_subwindow_alignment_tbl', 2, bit.bor(ImGuiTableFlags_Borders, ImGuiTableFlags_SizingFixedFit, ImGuiTableFlags_RowBg))) then
        imgui.TableSetupColumn('Name', ImGuiTableColumnFlags_WidthFixed, 125);
        imgui.TableSetupColumn('Value', ImGuiTableColumnFlags_WidthStretch);
        imgui.TableHeadersRow();

        local fields = T{ 'id', 'class_name', 'relations', 'relations_index', 'relations_max', 'entities', 'entities_size', 'entities_max', };

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
    imgui.SeparatorText('Relations');
    gui.render_object_list_editor(gui.get_members(obj, 'relations', 'relations_max'), tool.props.alignments_subwindow.alignment_relations);
    imgui.Text('Total Relations: ');
    imgui.SameLine(0, 0);
    imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.relations_max));
    imgui.SameLine();
    imgui.Text('(max) |');
    imgui.SameLine();
    imgui.Text('Next Index: ');
    imgui.SameLine(0, 0);
    imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.relations_index));

    imgui.NewLine();
    imgui.SeparatorText('Entities');
    gui.render_object_list_editor(gui.get_members(obj, 'entities', 'entities_size'), tool.props.alignments_subwindow.alignment_entities);
    imgui.Text('Total Entities: ');
    imgui.SameLine(0, 0);
    imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.entities_size));
    imgui.SameLine();
    imgui.Text('(size) |');
    imgui.SameLine();
    imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.entities_max));
    imgui.SameLine();
    imgui.Text('(max)');

    imgui.End();

    if (is_open[1] == false) then tool.props.alignments.selected_index = nil; end
end

return tool;