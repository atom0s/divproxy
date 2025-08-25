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
    icon = ICON_FA_USER_GROUP,
    tag = 'partymanager',
    name = 'Party Manager',
    window = T{
        is_open = T{ false, },
        title   = 'DbgView: Party Manager',
    },
    props = T{
        manager = T{
            show_filters    = true,
            show_selection  = true,
            is_editable     = true,
            struct          = reflex.reflect('CPartyManager'),
        },
        members = T{
            height          = -imgui.GetTextLineHeightWithSpacing() - 8,
            show_filters    = true,
            show_selection  = true,
            is_editable     = false,
            readonly        = T{ 'agent_index', },
            struct          = reflex.reflect('CPartyManagerEntry'),
            on_hover = function (parent, member, props)
                local agent = game.get_agent(member.agent_index);
                if (agent ~= nil) then
                    imgui.SetItemTooltip(('Agent Name: %s'):fmt(tostring(agent.name)));
                end
            end,
        },
    },
};

tool.load = function ()
    local mgr = game.get_party_manager();
    if (mgr == nil) then
        return false;
    end

    local members = table.range(0, mgr.members_size - 1):map(function (v) return mgr.members[v]; end);

    gui.generate_table_header_sizes(members, tool.props.members);

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

    local obj = game.get_party_manager();
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
        if (imgui.BeginTabItem('Party Members')) then
            local members = T{};
            for x = 0, obj.members_size - 1 do
                members:append(obj.members[x]);
            end

            gui.render_object_list_editor(members, tool.props.members);

            local val = T{ tool.props.members.is_editable, };
            if (imgui.Checkbox('Editable?', val)) then
                tool.props.members.is_editable = val[1];
            end

            imgui.EndTabItem();
        end
        imgui.EndTabBar();
    end

    imgui.End();
end

return tool;