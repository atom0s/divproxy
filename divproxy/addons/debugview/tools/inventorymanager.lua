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
    icon = ICON_FA_BOX,
    tag = 'inventorymanager',
    name = 'Inventory Manager',
    window = T{
        is_open = T{ false, },
        title   = 'DbgView: Inventory Manager',
    },
    props = T{
        manager = T{
            show_filters    = true,
            show_selection  = true,
            struct          = reflex.reflect('CInventoryManager'),
        },
        lists = T{
            [0] = T{ height = 175, show_filters = true, show_selection = true, struct = reflex.reflect('CInventoryList'), },
            [1] = T{ height = 175, show_filters = true, show_selection = true, struct = reflex.reflect('CInventoryList'), },
            [2] = T{ height = 175, show_filters = true, show_selection = true, struct = reflex.reflect('CInventoryList'), },
        },
    },
};

tool.load = function ()
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

    local obj = game.get_inventory_manager();
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
        if (imgui.BeginTabItem('Lists')) then
            for x = 0, 2 do
                local list = obj.lists[x];
                imgui.SeparatorText(('List: %d'):fmt(x));
                gui.render_property_editor(list, tool.props.lists[x]);

                imgui.Text('Entries: ');
                imgui.SameLine(0, 0);
                imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(list.entries.size));
                imgui.SameLine();
                imgui.Text('(size) | ');
                imgui.SameLine(0, 0);
                imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(list.entries.element_size));
                imgui.SameLine();
                imgui.Text('(max) | ');
                imgui.SameLine(0, 0);
                imgui.TextColored(T{ 1.0, 1.0, 0.0, 1.0 }, tostring(list.entries.element_size));
                imgui.SameLine();
                imgui.Text('(element size)');
                imgui.NewLine();
            end
            imgui.EndTabItem();
        end
        imgui.EndTabBar();
    end

    imgui.End();
end

return tool;