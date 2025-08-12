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

    typedef struct CPlayerSub
    {
        void*           mouse_cursor_vfx;                           // The current mouse cursor vfx object. [Animation or image object.]
        uint32_t        unknown0004;                                // Unknown. [Mouse cursor related.]
        uint32_t        unknown0008;                                // Unknown. [Mouse cursor related.]
        uint32_t        mouse_x_prev;
        uint32_t        mouse_y_prev;
        uint32_t        mouse_ldown_prev;
        uint32_t        mouse_rdown_prev;
        uint32_t        mouse_mdown_prev;
        uint32_t        mouse_x;
        uint32_t        mouse_y;
        int32_t         item_tooltip_mouse_offset_x;                // Offset from the mouse cursor the item tooltip will show. (X) [Not used.]
        int32_t         item_tooltip_mouse_offset_y;                // Offset from the mouse cursor the item tooltip will show. (Y)
        uint32_t        mouse_down_lparam_x;
        uint32_t        mouse_down_lparam_y;
        uint32_t        unknown0038;                                // Unknown. [Flag set when the mouse is down and dragged.]
        uint32_t        mouse_ldown;
        uint32_t        mouse_rdown;
        uint32_t        mouse_mdown;
        uint32_t        mouse_lup;
        uint32_t        mouse_rup;
        uint32_t        hwnd;
        uint32_t        unknown0054;                                // Unknown. [Mouse button related. (Left-click up.)]
        uint32_t        mouse_ldown_start_time;
        uint32_t        mouse_rdown_start_time;
        uint32_t        mouse_moving_ldown;
        uint32_t        mouse_repeat_delay;
        uint32_t        mouse_ldown_repeating;
        uint32_t        mouse_rdown_repeating;
        uint32_t        mouse_rdown_repeating_prev;
        uint32_t        mouse_substate_1;
        uint32_t        mouse_substate_2;
        uint32_t        mouse_object_index;
        CObjectData     mouse_object_data;                          // The object data of the last object that was clicked on.
        int32_t         mouse_ldown_drag_image_index;               // The image index of the object being dragged.
        int32_t         mouse_ldown_drag_inventory_list_index;      // The inventory list index of the object being dragged.
        int32_t         mouse_ldown_drag_object_count;              // The amount of the given object being dragged.
        int32_t         mouse_ldown_drag_inventory_entry_index;     // The inventory list entry index of the object being dragged.
        int32_t         mouse_ldown_drag_container_object_x;        // The start position of the object being dragged. (X) [Only used when inside of containers!]
        int32_t         mouse_ldown_drag_container_object_y;        // The start position of the object being dragged. (Y) [Only used when inside of containers!]
        int32_t         mouse_ldown_drag_inventory_object_index;    // The inventory object index of the object being dragged.
        int32_t         mouse_ldown_drag_world_object_x;            // The start position of the object being dragged. (X) [Only used when outside of containers!]
        int32_t         mouse_ldown_drag_world_object_y;            // The start position of the object being dragged. (Y) [Only used when outside of containers!]
        int32_t         mouse_ldown_drag_world_object_data_flags;
        int32_t         mouse_ldown_drag_world_object_z_order;
        int32_t         unknown00C0;                                // Unknown. [Mouse cursor related.]
        uint32_t        unknown00C4;                                // Unknown. [Mouse cursor related.]
        uint32_t        cursor_animation_data[88];                  // Animation frame data.
        uint32_t        cursor_animation_index;                     // The current cursor animation index.
        uint32_t        unknown022C;                                // Unused?
        uint32_t        mouse_ldown_start_x;
        uint32_t        mouse_ldown_start_y;
        int32_t         mouse_pickup_object_offset_x;               // The offset from the mouse cursor the object will be adjusted by when picked up/dragged. (X)
        int32_t         mouse_pickup_object_offset_y;               // The offset from the mouse cursor the object will be adjusted by when picked up/dragged. (Y)
        int32_t         unknown0240;                                // Unknown. [Mouse cursor related. Current animation index for sub-cursor.]
        int32_t         unknown0244;                                // Unknown. [Mouse cursor related. Current animation frame index for sub-cursor.]
        int32_t         unknown0248;                                // Unknown. [Mouse cursor related. Unknown index.]
        uint32_t        unknown024C;                                // Unknown. [Mouse cursor related. Masking value for the cursor sprite?]
        uint32_t        unknown0250;                                // Unknown. [Mouse cursor related.]
        uint32_t        unknown0254;                                // Unknown. [Mouse cursor related.]
        int32_t         unknown0258;                                // Unknown. [Mouse cursor related.]
        int32_t         unknown025C;                                // Unknown. [Mouse cursor related.]
        int32_t         unknown0260;                                // Unknown. [Mouse cursor related.]
        uint32_t        unknown0264;                                // Unknown. [Mouse cursor related.]
        uint32_t        unknown0268;                                // Unknown. [Mouse cursor related.]
        uint32_t        unknown026C;                                // Unknown. [Mouse cursor related.]
        int32_t         unknown0270;                                // Unknown. [Camera position related. (Read-only?)]
        int32_t         unknown0274;                                // Unknown. [Camera position related. (Read-only?)]
        uint32_t        cursor_animation_delay;                     // The amount of time to wait before stepping to the next cursor animation frame.
        uint32_t        cursor_animation_timestamp;                 // The last time the cursor animation changed.;
        uint32_t        unknown0280;                                // Unused?
        int32_t         next_external_index;                        // The non-container objects external index + 1 when being picked up and dragged.
        uint32_t        unknown0288;                                // Unknown. [Mouse cursor related.]
    } CPlayerSub;

    typedef struct CPlayer
    {
        CPlayerSub*     unknown0000;

        void*           unknown0004;
        uint32_t        unknown0008;
        uint32_t        unknown000C;
        uint32_t        unknown0010;
        uint32_t        unknown0014;
        uint32_t        unknown0018;
        uint32_t        unknown001C;
        uint32_t        unknown0020;

        void*           unknown0024;
        uint32_t        unknown0028;
        uint32_t        unknown002C;
        uint32_t        unknown0030;
        uint32_t        unknown0034;
        uint32_t        unknown0038;
        uint32_t        unknown003C;
        uint32_t        unknown0040;

        uint32_t        is_equipment_enabled;               // Flag used to enable or disable the equipment button/menu.
        uint32_t        is_chests_enabled;                  // Flag used to enable or disable interactions with chests/containers. [Note: This is not implemented correctly so it doesn't work!]
        uint32_t        is_statistics_enabled;              // Flag used to enable or disable the statistics button/menu.
        uint32_t        game_difficulty;
        char            item_tooltip_[1024];                // Handled via metatype!
        int32_t         mouse_hover_object_index;
        int32_t         mouse_hover_agent_index;
        const char**    inventory_container_names;          // Pointer list to the names of the currently open container/inventory windows.
        uint32_t        inventory_container_names_size;     // Number of entries within the inventory_container_names array.
        uint32_t        is_region_blocked;
        uint32_t        show_save_dialog;
        uint32_t        quicksave_index;
        uint32_t        quicksave_load_path;
        uint32_t        unknown0474;                        // CAgentClass index. [Used with creature statues.]
        uint32_t        last_sleep_time;
        uint32_t        dialog_system_state;
        uint32_t        always_run;
        uint32_t        is_dead;
        int32_t         edge_distance_x;                    // The distance from the window edge to start moving the camera in free-view mode. (X)
        int32_t         edge_distance_y;                    // The distance from the window edge to start moving the camera in free-view mode. (Y)
        int32_t         edge_pan_speed_x;                   // The speed the camera moves in free-view mode. (X)
        int32_t         edge_pan_speed_y;                   // The speed the camera moves in free-view mode. (Y)
        int32_t         edge_pan_speed_multiplier;          // Multiplier applied to the edge pan speeds when moving the free-view camera.
        int32_t         edge_pan_speed_max;                 // The maximum speed the camera can move when using free-view mode.
        uint32_t        camera_map_x;
        uint32_t        camera_map_y;
        uint32_t        unknown04A8;                        // Unknown. [Camera view related. (Always set to 1.)]
        uint32_t        unknown04AC;                        // Unknown. [Flag that stops processing player interactions, movement, etc.]
        uint32_t        unknown04B0;
        CPartyManager*  party_manager;
        uint32_t        is_mouse_over_frame;                // Flag set if the mouse is currently over a game frame.
        uint32_t        unknown04BC;                        // Unknown. [Used when left mouse button is down and interacting with objects/containers.]
        uint32_t        camera_follow_agent_index;          // Agent index that the camera follows / is attached to.
        uint32_t        camera_attached_to_agent;           // Flag set if the camera is attached to an agent or not. [Set to 0 when free-cam mode is used.]
        uint32_t        unknown04C8;                        // Unused.
        uint32_t        unknown04CC;                        // Unknown. [Flag if set to 0 will cause the dialog system to not render.]
        uint32_t        prev_mouse_hover_object_index1;
        uint32_t        prev_mouse_hover_object_index2;
        uint32_t        unknown04D8;                        // Unknown. [Flag that stops processing player interactions, movement, etc.]
        int32_t         unknown04DC;                        // Unknown. [Set to -1 when the player is loaded.]
        int32_t         unknown04E0;                        // Unknown. [Set to -1 when the player is loaded.]
        uint32_t        targeted_cast_agent_index;          // Used for casts that require a target to be selected. [The caster agent index.]
        uint32_t        targeted_cast_spell_type;           // Used for casts that require a target to be selected. [The spell type.]
        uint32_t        is_story_scene_finished;            // Flag used to determine if a story scene has finished playing. [Used to monitor for stuck scenes.]
        uint32_t        story_scene_start_time;             // Timestamp set when the client begins viewing a story scene. [Used to monitor for stuck scenes.]
        int32_t         unknown04F4;                        // Unknown. [Set to -1 when the player is loaded.]
        uint32_t        unknown04F8;                        // Unknown. [Set to 0 when the player is loaded.]
        uint32_t        unknown04FC;                        // Unknown. [Mouse related.]
        uint32_t        unknown0500;                        // Unknown. [Set to 0 when the player is loaded.]
        uint32_t        can_resume_and_save_game;
        uint32_t        camera_follow_agent_index_freecam;  // Agent index that the camera locks to when in freecam mode.
        uint32_t        unknown050C;                        // Unused.
        uint32_t        prev_camera_map_x;
        uint32_t        prev_camera_map_y;
        uint32_t        unknown0518;                        // Unknown. [Set to 1 if left mouse is down, 2 if down and dragged.]
        uint32_t        mouse_x;
        uint32_t        mouse_y;
        int32_t         mouse_ldown_drag_agent_index;       // Agent index of the agent the mouse was held down and dragged on.
        int32_t         unknown0528;                        // Unknown. [Used as an object index.]
        int32_t         unknown052C;                        // Unknown. [Used as an agent index. Generally set to the local players agent index.]
        int32_t         unknown0530;                        // Unknown. [Used as an object index into the CPartyManager->members objects.]
        uint32_t        screen_shake_distance;
        void*           screen_shake_sfx;                   // Screen shake sound effect buffer.
        int32_t         screen_shake_channel_sfx;           // Screen shake sound effect channel.
        int32_t         alt_mouse_hover_object_index;       // Object index the mouse is hovering while ALT key is held down.
        int32_t         mouse_ldown_agent_index;            // Agent index set when mouse is down on an agent.
        int32_t         camera_screen_shake_map_x;          // The camera position to use to show shaking when detached from the player. (X)
        int32_t         camera_screen_shake_map_y;          // The camera position to use to show shaking when detached from the player. (Y)
        uint32_t        gender;                             // Set to 1 for male, 0 for female.
        uint32_t        unknown0554;                        // Unknown. [Used like a locking mechanism when dealing with character creation and save files.]
        void*           message_plate;                      // Message plate object. [CMessagePlate object used with story scene validation.]
    } CPlayer;

]];

ffi.metatype('CPlayer', T{
    __index = function (self, k)
        return switch(k, T{
            -- Properties
            [T{'item_tooltip'}] = function ()
                return ffi.string(self[k .. '_'], 1024):split('\0'):first();
            end,
            [switch.default] = function ()
                error(('struct \'CPlayer\' has no member: %s'):fmt(k));
            end,
        });
    end,
    __newindex = function (_, k, _)
        error(('struct \'CPlayer\' has no member: %s'):fmt(k));
    end
});

--[[
*
* Helper Functions
*
--]]

game = game or T{};

game.get_player = function ()
    local ptr = hook.memory.read_uint32(game.ptrs.player);
    if (ptr == 0) then return nil; end
    return ffi.cast('CPlayer*', hook.memory.read_uint32(ptr));
end

game.get_player_index = function ()
    local player = game.get_player();
    if (player == nil) then
        return 0;
    end
    if (player.party_manager == 0 or player.party_manager == nil) then
        return 0;
    end
    return player.party_manager.player_agent_index;
end

game.get_player_address = function ()
    return hook.memory.read_uint32(game.ptrs.player);
end

game.get_party_manager = function ()
    local player = game.get_player();
    if (player == nil) then
        return nil;
    end
    return player.party_manager;
end