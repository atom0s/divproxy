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
    icon = ICON_FA_USERS_GEAR,
    tag = 'agentmanager',
    name = 'Agent Manager',
    window = T{
        is_open = T{ false, },
        title   = 'DbgView: Agent Manager',
    },
    props = T{
        manager = T{
            show_filters    = true,
            show_selection  = true,
            is_editable     = false,
            struct          = reflex.reflect('CAgentManager'),
        },
        visual_agents = T{
            height          = -imgui.GetTextLineHeightWithSpacing(),
            show_filters    = true,
            struct          = reflex.reflect('CAgentManager'),
        },
        agents = T{
            height          = -imgui.GetTextLineHeightWithSpacing() - 28,
            freeze_columns  = 2,
            show_filters    = true,
            show_selection  = true,
            is_editable     = false,
            readonly        = T{ 'index', },
            struct          = reflex.reflect('CAgent'),
        },
        agents_subwindow = T{
            agent = T{
                height          = 600,
                show_filters    = true,
                show_selection  = true,
                is_editable     = true,
                readonly        = T{ 'index', },
                struct          = reflex.reflect('CAgent'),
            },
            statistics = T{
                height          = 600,
                show_filters    = true,
                show_selection  = true,
                is_editable     = true,
                struct          = reflex.reflect('CAgentStatistics'),
            },
            statistics_structs = T{
                agent       = reflex.reflect('CAgentStatistics'),
                agentnpc    = reflex.reflect('CMonsterStatistics'),
                player      = reflex.reflect('CPlayerStatistics'),
            },
            alignment = T{
                height          = 600,
                show_filters    = true,
                show_selection  = true,
                struct          = reflex.reflect('CAlignmentEntry'),
            },
            agent_class = T{
                height          = 600,
                show_filters    = true,
                show_selection  = true,
                struct          = reflex.reflect('CAgentClass'),
            },
        },
    },
    agent_overrides = T{
        statistics          = function () imgui.Text('[statistics]'); end,
        alignment           = function () imgui.Text('[alignment]'); end,
        spell_knowledge     = function () imgui.Text('[spell_knowledge]'); end,
        spell_learned       = function () imgui.Text('[spell_learned]'); end,
        image_index         = function () imgui.Text('[image_index]'); end,
        skill_data          = function () imgui.Text('[skill_data]'); end,
        padding0219         = function () imgui.Text('[padding]'); end,
        agent_class         = function () imgui.Text('[agent_class]'); end,
        inventory           = function () imgui.Text('[inventory]'); end,
        fighting            = function () imgui.Text('[fighting]'); end,
        seeing              = function () imgui.Text('[seeing]'); end,
        magic               = function () imgui.Text('[magic]'); end,
        behavior            = function () imgui.Text('[behavior]'); end,
        tactics             = function () imgui.Text('[tactics]'); end,
        padding0299         = function () imgui.Text('[padding]'); end,
        program_data        = function () imgui.Text('[program_data]'); end,
        region_list_content = function () imgui.Text('[region_list_content]'); end,
        behaviors           = function () imgui.Text('[behaviors]'); end,
        loop_points         = function () imgui.Text('[loop_points]'); end,
    },
};

tool.load = function ()
    local mgr = game.get_agent_manager();
    if (mgr == nil) then
        return false;
    end

    tool.props.agents.struct = gui.remove_struct_members(tool.props.agents.struct, T{ 'vtbl', });
    tool.props.agents.struct = gui.reorder_struct_members(tool.props.agents.struct, T{ 'index', 'name', });
    tool.props.agents_subwindow.agent.struct = gui.remove_struct_members(tool.props.agents_subwindow.agent.struct, T{ 'vtbl', });
    tool.props.agents_subwindow.agent.struct = gui.reorder_struct_members(tool.props.agents_subwindow.agent.struct, T{ 'index', 'name', });
    tool.props.agents_subwindow.statistics_structs.agent = gui.remove_struct_members(tool.props.agents_subwindow.statistics_structs.agent, T{ 'vtbl', });
    tool.props.agents_subwindow.statistics_structs.agentnpc = gui.remove_struct_members(tool.props.agents_subwindow.statistics_structs.agentnpc, T{ 'vtbl', });
    tool.props.agents_subwindow.statistics_structs.player = gui.remove_struct_members(tool.props.agents_subwindow.statistics_structs.player, T{ 'vtbl', });

    gui.generate_table_header_sizes(gui.get_members(mgr, 'agents', 'agents_size'):filter(function (v) return v ~= nil; end), tool.props.agents);

    -- Callbacks..
    tool.props.agents.selected_index = nil;
    tool.props.agents.on_select = function (parent, member, props)
        tool.props.agents.selected_index = member.index;
    end
    tool.props.agents_subwindow.statistics.on_hover = function (parent, member)
        if (not member.name:contains('equipment')) then
            return;
        end

        local colors    = T{T{ 0.0, 1.0, 0.0, 1.0 }, T{ 1.0, 0.0, 0.0, 1.0 }, };
        local slots     = T{'Head', 'Neck', 'Body', 'Weapon', 'Shield', 'RingL', 'RingR', 'Legs', 'Waist', 'Feet', 'Hands', };

        local has_equipment = table.range(1, #slots):any(function (v) return parent['equipment'][v] ~= nil; end);
        if (not has_equipment) then
            return;
        end

        if (not imgui.BeginTooltip()) then
            return;
        end

        switch(member.name, T{
            equipment_broken_status = function ()
                imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, 'Equipment Status:');
                slots:each(function (v, k)
                    if (parent['equipment'][k - 1] ~= nil) then
                        imgui.TextColored(colors[parent[member.name][k - 1] + 1], '  - ' .. v);
                    end
                end);
            end,
            equipment = function ()
                imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, 'Currently Equipped:');
                slots:each(function (v, k)
                    if (parent['equipment'][k - 1] ~= nil) then
                        imgui.Text('  - ' .. v);
                    end
                end);
            end,
        });

        imgui.EndTooltip();
    end

    -- Overrides..
    tool.props.agents.overrides = tool.agent_overrides;
    tool.props.agents_subwindow.agent.overrides = tool.agent_overrides;
    tool.props.visual_agents.overrides = T{
        visual_agents_indexes = function (parent, member, props)
            if (parent == nil or member == nil) then
                imgui.Text('(invalid_arguments_detected)');
                return;
            end
            local agent = game.get_agent(member.value);
            imgui.Text(('%d - %s'):fmt(member.value, agent ~= nil and agent.name or '(invalid_agent_index)'));
        end
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
    if (not tool.window.is_open[1]) then
        return;
    end

    local obj = game.get_agent_manager();
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
        if (imgui.BeginTabItem('Visual Agents')) then
            gui.render_array_editor(
                obj.visual_agents_indexes,
                gui.get_array_values(obj.visual_agents_indexes, obj.visual_agents_indexes_size),
                tool.props.visual_agents.struct:filter(function (v) return v.name == 'visual_agents_indexes'; end):first(),
                tool.props.visual_agents);

            imgui.Text('Total Visual Agents: ');
            imgui.SameLine(0, 0);
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.visual_agents_indexes_size));
            imgui.SameLine();
            imgui.Text('(size) |');
            imgui.SameLine();
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(obj.visual_agents_indexes_max));
            imgui.SameLine();
            imgui.Text('(max)');

            imgui.EndTabItem();
        end
        if (imgui.BeginTabItem('Agents')) then
            gui.render_object_list_editor(gui.get_members(obj, 'agents', 'agents_size'):filter(function (v) return v ~= nil; end), tool.props.agents);

            imgui.Text('Total Agents: ');
            imgui.SameLine(0, 0);
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, ('%d'):fmt(obj.agents_size));
            imgui.SameLine();
            imgui.Text("(size) |");
            imgui.SameLine();
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, ('%d'):fmt(obj.agents_max));
            imgui.SameLine();
            imgui.Text("(max) |");
            imgui.SameLine();
            imgui.Text("Hovered Agent Index: ");
            imgui.SameLine(0, 0);
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, ('%d'):fmt(game.get_player().mouse_hover_agent_index));

            local is_editable = T{ tool.props.agents.is_editable, };
            if (imgui.Checkbox('Editable?', is_editable)) then
                tool.props.agents.is_editable = is_editable[1];
            end

            if (tool.props.agents.selected_index ~= nil) then
                tool.render_agent_subwindow();
            end

            imgui.EndTabItem();
        end
        imgui.EndTabBar();
    end

    imgui.End();
end

tool.render_agent_subwindow = function ()
    local mgr = game.get_agent_manager();
    local idx = tool.props.agents.selected_index;
    if (mgr == nil or idx == nil) then
        tool.props.agents.selected_index = nil;
        return;
    end

    local obj = game.get_agent(idx);
    if (obj == nil) then
        tool.props.agents.selected_index = -1;
        return;
    end

    tool.props.agents_subwindow.statistics.struct = switch(obj:get_type(), T{
        [AgentType_AgentNpc]    = function () return tool.props.agents_subwindow.statistics_structs.agentnpc; end,
        [AgentType_PartyMember] = function () return tool.props.agents_subwindow.statistics_structs.player; end,
        [switch.default]        = function () return tool.props.agents_subwindow.statistics_structs.agent; end,
    });

    local is_open = { true, };
    imgui.SetNextWindowSizeConstraints(T{ 675, 275 }, T{ FLT_MAX, FLT_MAX });
    if (not imgui.Begin(('DbgView: Agent - Idx: %d - %s###agent_subwindow'):fmt(obj.index, obj.name), is_open, ImGuiWindowFlags_AlwaysAutoResize)) then
        imgui.End();
        return;
    end

    if (imgui.BeginTabBar('agents_subwindow_tab_bar')) then
        if (imgui.BeginTabItem('Agent')) then
            gui.render_property_editor(obj, tool.props.agents_subwindow.agent);
            imgui.EndTabItem();
        end
        if (imgui.BeginTabItem('Statistics')) then
            gui.render_property_editor(obj.statistics, tool.props.agents_subwindow.statistics);
            imgui.Text('Agent Type: ');
            imgui.SameLine(0, 0);
            imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, switch(obj:get_type(), T{
                [AgentType_AgentNpc] = function () return 'CAgentNpc'; end,
                [AgentType_PartyMember] = function () return 'CPartyMember'; end,
                [switch.default] = function () return 'CAgent'; end,
            }));
            imgui.EndTabItem();
        end
        if (imgui.BeginTabItem('Alignment')) then
            gui.render_property_editor(obj.alignment, tool.props.agents_subwindow.alignment);
            imgui.EndTabItem();
        end
        if (imgui.BeginTabItem('Agent Class')) then
            gui.render_property_editor(obj.agent_class, tool.props.agents_subwindow.agent_class);
            imgui.EndTabItem();
        end
        imgui.EndTabBar();
    end

    imgui.End();

    if (is_open[1] == false) then tool.props.agents.selected_index = nil; end
end

return tool;