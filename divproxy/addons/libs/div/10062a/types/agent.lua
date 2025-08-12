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

local inheritance   = require 'inheritance';
local ffi           = require 'ffi';

-- Parameter (1) Flags
Parameter1_None                 = 0x00000000; -- None.
Parameter1_Unknown_0x00000001   = 0x00000001; -- Unknown. [Stops walking animations when set.]
Parameter1_IsPeaceful           = 0x00000002; -- Agent is not attacking and weapon is not drawn.
Parameter1_IsPathing            = 0x00000004; -- Agent is walking to a path point.
Parameter1_Unknown_0x00000008   = 0x00000008; -- Unknown.
Parameter1_IsBusy               = 0x00000010; -- Agent is busy. [Set for interactions or dialog usage. Agent becomes ignored by enemies etc.]
Parameter1_IsCrouching          = 0x00000020; -- This is also used for jumping?
Parameter1_IsPartyMember        = 0x00000040; -- Agent is a party member type.
Parameter1_IsDying              = 0x00000080; -- Agent is dying. [Plays the death animation.]
Parameter1_IsDead               = 0x00000100; -- Agent is dead.
Parameter1_Unknown_0x00000200   = 0x00000200; -- Unknown. [Stops the agent from rendering.]
Parameter1_Unknown_0x00000400   = 0x00000400; -- Unknown.
Parameter1_Unknown_0x00000800   = 0x00000800; -- Unknown.
Parameter1_Unknown_0x00001000   = 0x00001000; -- Unknown.
Parameter1_Unknown_0x00002000   = 0x00002000; -- Unknown.
Parameter1_Unknown_0x00004000   = 0x00004000; -- Unknown.
Parameter1_Unknown_0x00008000   = 0x00008000; -- Unknown.
Parameter1_Unknown_0x00010000   = 0x00010000; -- Unknown.
Parameter1_Unknown_0x00020000   = 0x00020000; -- Unknown. [Dynamically spawned agent?]
Parameter1_Unknown_0x00040000   = 0x00040000; -- Unknown.
Parameter1_Unknown_0x00080000   = 0x00080000; -- Unknown.
Parameter1_Unknown_0x00100000   = 0x00100000; -- Unknown. [Animation related.]
Parameter1_Unknown_0x00200000   = 0x00200000; -- Unknown.
Parameter1_Unknown_0x00400000   = 0x00400000; -- Unknown.
Parameter1_Unknown_0x00800000   = 0x00800000; -- Unknown.
Parameter1_Unknown_0x01000000   = 0x01000000; -- Unknown.
Parameter1_Unknown_0x02000000   = 0x02000000; -- Unknown.
Parameter1_Unknown_0x04000000   = 0x04000000; -- Unknown.
Parameter1_IsRunning            = 0x08000000; -- Agent is running.
Parameter1_Unknown_0x10000000   = 0x10000000; -- Unknown.
Parameter1_Unknown_0x20000000   = 0x20000000; -- Unknown. [Agent animations are slow-motion.]
Parameter1_IsEncumbered         = 0x40000000; -- Agent is encumbered. [Agent is close to max carrying weight.]
Parameter1_Unknown_0x80000000   = 0x80000000; -- Unknown.

-- Parameter (2) Flags
Parameter2_None                 = 0x00000000; -- None.
Parameter2_IsTooHeavy           = 0x00000001; -- Agent inventory is too heavy. [Agent carrying weight limit exceeded.]
Parameter2_Unknown_0x00000002   = 0x00000002; -- Unknown.
Parameter2_IsBoss               = 0x00000004; -- Agent is a boss.
Parameter2_Unknown_0x00000008   = 0x00000008; -- Unknown.
Parameter2_Unknown_0x00000010   = 0x00000010; -- Unknown. [Agent stops animations if set.]
Parameter2_Unknown_0x00000020   = 0x00000020; -- Unknown.
Parameter2_IsStrongNpc          = 0x00000040; -- Agent is a strong npc.
Parameter2_Unknown_0x00000080   = 0x00000080; -- Unknown.
Parameter2_IsInvisible          = 0x00000100; -- Agent is invisible.
Parameter2_Unknown_0x00000200   = 0x00000200; -- Unknown. [Agent stops animations if set.]
Parameter2_Unknown_0x00000400   = 0x00000400; -- Unknown.
Parameter2_Unknown_0x00000800   = 0x00000800; -- Unknown.
Parameter2_Unknown_0x00001000   = 0x00001000; -- Unknown.
Parameter2_HideShadow           = 0x00002000; -- Agent shadow is hidden.
Parameter2_IsRegionSensitive    = 0x00004000; -- Agent is region sensitive.
Parameter2_IsSlave              = 0x00008000; -- Agent is slave. [Agent will not attack on its own.]
Parameter2_IsInvulnerable       = 0x00010000; -- Agent is invulnerable. [Agent cannot be killed.]
Parameter2_Unknown_0x00020000   = 0x00020000; -- Unknown.
Parameter2_Unknown_0x00040000   = 0x00040000; -- Unknown.
Parameter2_Unknown_0x00080000   = 0x00080000; -- Unknown.
Parameter2_IsFloating           = 0x00100000; -- Agent is floating.
Parameter2_Unknown_0x00200000   = 0x00200000; -- Unknown.
Parameter2_IsTrueSight          = 0x00400000; -- Agent can see everything.
Parameter2_Unknown_0x00800000   = 0x00800000; -- Unknown.
Parameter2_Unknown_0x01000000   = 0x01000000; -- Unknown.
Parameter2_Unknown_0x02000000   = 0x02000000; -- Unknown.
Parameter2_Unknown_0x04000000   = 0x04000000; -- Unknown.
Parameter2_IsPreprocessed       = 0x08000000; -- Agent is preprocessed. [Scripting related.]
Parameter2_Unknown_0x10000000   = 0x10000000; -- Unknown. [Agent is hidden when set.]
Parameter2_IsDebugging          = 0x20000000; -- Agent is being debugged.
Parameter2_IsRepulsive          = 0x40000000; -- Agent is repulsive.
Parameter2_Unknown_0x80000000   = 0x80000000; -- Unknown.

Parameter2_Unknown_0x00840000   = 0x00840000; -- NPC event trigger when seeing, remembers what was seen.

-- Agent Type Enumeration
AgentType_Invalid               = 0;
AgentType_Agent                 = 1;
AgentType_AgentNpc              = 2;
AgentType_PartyMember           = 3;

-- Damage Flags [Used with TakeDamage1.]
DamageFlag_None                 = 0x00000000;
DamageFlag_Lightning            = 0x00000001;
DamageFlag_Fire                 = 0x00000002;
DamageFlag_Poison               = 0x00000004;
DamageFlag_Spirit               = 0x00000008;

ffi.cdef[[

    typedef struct CAgentVtbl
    {
        /**
         * CAgent VTable Functions
         */

        void*   __thiscall (*Deleter)(void* this, uint32_t flags);                                                                  // Deconstructor and deleter.
        void    __thiscall (*VFunc1)(void* this);                                                                                   // Unknown. [Update style call. Ticks fighting and program objects.]
        int32_t __thiscall (*PathToCellPosition)(void* this, int32_t cell_x, int32_t cell_y);                                       // Causes the agent to walk to the given cell position on the current map.
        int32_t __thiscall (*WarpToCellPosition)(void* this, int32_t cell_x, int32_t cell_y, int32_t map);                          // Causes the agent to warp to the given cell position on the given map.
        int32_t __thiscall (*UpdatePath)(void* this);                                                                               // Updates the agents pathing information, dialog candidates, and some movement related things.
        void    __thiscall (*UpdateAction)(void* this);                                                                             // Updates the agents current action.
        void    __thiscall (*UpdateProgram)(void* this, int32_t frame);                                                             // Updates the agents program.
        void    __thiscall (*UpdateMovement)(void* this);                                                                           // Updates the agents movement, dialog candidates, region information, etc.
        void    __thiscall (*TakeDamage1)(void* this, int32_t dmg, int32_t flags, int32_t unused1, int32_t unused2);                // Causes the agent to take damage.
        void    __thiscall (*TakeDamage2)(void* this, void* caster, int32_t dmg, int32_t flag, int32_t param);                      // Causes the agent to take damage.
        void    __thiscall (*TakeDamage3)(void* this, void* caster, int32_t dmg, int32_t param1, int32_t param2, int32_t param3);   // Causes the agent to take damage.
        int32_t __thiscall (*Knockback1)(void* this, int32_t x, int32_t y, int32_t effect);                                         // Causes the agent to be knocked back.
        int32_t __thiscall (*Knockback2)(void* this, void* arg1);                                                                   // Causes the agent to be knocked back.
        void    __thiscall (*Kill)(void* this, int32_t no_sfx);                                                                     // Kills the agent.
        void    __thiscall (*Revive)(void* this);                                                                                   // Revives the agent.
        void    __thiscall (*Synch)(void* this, void* arg1);                                                                        // Synchronizes the agent.
        void    __thiscall (*SetWalkRun)(void* this, int32_t is_running, int32_t arg2);                                             // Sets the agents running/walking status.
        void    __thiscall (*VFunc17)(void* this);                                                                                  // Unknown. [Updates the agents visual information and current action.]
        void    __thiscall (*SetLocked)(void* this, int32_t time_locked);                                                           // Sets the agents locked value.
        int32_t __thiscall (*VFunc19)(void* this);                                                                                  // Unkonwn. [CubeManager related. Returns 64 by default.]
        void    __thiscall (*GiveExp)(void* this, int32_t exp, int32_t granter_index);                                              // Gives the agent experience points.
        int32_t __thiscall (*PathToAgent)(void* this, int32_t index);                                                               // Causes the agent to run or warp to the given agent, if valid. [Will warp to the agent if too far to run.]
        void    __thiscall (*UpdateDialog)(void* this);                                                                             // Called while the agent is talking to another agent.
        void    __thiscall (*Roam)(void* this);                                                                                     // Causes the agent to roam a short distance.
        int32_t __thiscall (*RoamSteps)(void* this, int32_t walk_count);                                                            // Causes the agent to roam the given walk_count amount of steps.
        void    __thiscall (*WriteToFile)(void* this);                                                                              // Serializes the agent to disk. [Uses a global file pointer.]
        void    __thiscall (*ReadFromFile)(void* this, int32_t arg1);                                                               // Serializes the agent from disk. [Uses a global file pointer.]
        void    __thiscall (*SetIsBusy)(void* this, int32_t flag);                                                                  // Sets the agents busy flag when interacting with anotehr agent. (ie. Opening a dialog.)
        void    __thiscall (*VFunc28)(void* this, int32_t arg1, int32_t arg2);                                                      // Unknown. [Used to change an agents class and reinitialize its statistics in some manner.]
        void    __thiscall (*Dump)(void* this, void* file);                                                                         // Dumps the agents information into a text file on disk. [Note: Must use the file operations from the game to function properly!]

        /**
         * CAgentNpc VTable Functions
         */

        int32_t __thiscall (*ForcePathToCellPosition)(void* this, int32_t cell_x, int32_t cell_y);                                  // Causes the agent to walk to the given cell position on the current map. [Ignores terrain / collision, ignores proper animation handling.]
        int32_t __thiscall (*VFunc31)(void* this, int32_t arg1, int32_t arg2);                                                      // Unknown. [Pathing related.]

        /**
         * CPartyMember VTable Functions
         */

        int32_t __thiscall (*InteractWithObject)(void* this, int32_t x, int32_t y, int32_t arg3);                                   // Causes the agent to interact with an object.
        void    __thiscall (*SetRunning)(void* this, int32_t is_running);                                                           // Sets the agent running status.

    } CAgentVtbl;

]];

ffi.cdef[[

    /**
     * Note:    The client makes use of three separate 'fight' structures. The main base structure is 'CAgentFight' while the other two
     *          inherit from it. The other two structures, CPartyFight and CClientFight, do not add other properties, they only change
     *          the vtable to override some function calls.
     *
     *          CAgentFight     - Base class.
     *          CPartyFight     - Used for agents that are of CPartyMember type.
     *          CClientFight    - Used when the client is running in server mode.
     */

    typedef struct CAgentFight
    {
        uintptr_t           vtbl;
        int32_t             target_index;               // The agent index of the target.
        void*               target_;                    // The agent targeted for the attack(s). [Handled via metatype!]
        void*               caster_;                    // The agent casting the attack(s). [Handled via metatype!]
        int32_t             fight_speed;                // The time between attacks. [Counts down to 0 then attacks.]
        int32_t             unknown0014;                // Unknown.
        void*               tactics;                    // Pointer to tactic object. [There are multiple types of tactics based on the kind of attack or skill being used.]
        uint32_t            unknown001C;                // Unknown.
    } CAgentFight;

    typedef struct CSeeingLastSeen
    {
        int32_t             agent_index;
        int32_t             time;
    } CSeeingLastSeen;

    typedef struct CSeeing
    {
        int32_t             agent_index[16];            // The list of agent indexes that are currently seen. [Has a means of priority and scope.]
        int32_t             agent_index_size;           // The number of agent_index entries in use.
        CSeeingLastSeen     last_seen[16];              // The list of last seen agents that were previously seen.
        int32_t             last_seen_size;             // The number of last_seen entries in use.
        int32_t             last_seen_delay;            // The last_seen time value that is set when an entry is first added.
        int32_t             unknown00CC;                // Unknown. [This is always set to 128.]
        int32_t             unknown00D0;                // Unknown. [This is some kind of counter that is incremented when the seeing object is created.]
        void*               owner_;                     // The parent agent that owns this object. [Handled via metatype!]
    } CSeeing;

    typedef struct CMagic
    {
        void*               owner_;                     // The parent agent that owns this object. [Handled via metatype!]
        uint32_t            flags;                      // The flags of the magic. [0x01 set when casting.]
        int32_t             spell_type;                 // The spell type. [Treated like an id. If -1, special move is used.]
    } CMagic;

    typedef struct CInventory
    {
        int32_t             inventory1;
        int32_t             inventory2;
        uint32_t            gold;                       // The total amount of gold in the actors inventory.
        int32_t             index;
    } CInventory;

    typedef struct CAgent
    {
        CAgentVtbl*         vtbl_;                      // Handled via metatype!
        int32_t             x;
        int32_t             y;
        float               fx;
        float               fy;
        int32_t             unknown0014;                // Unknown. [Height related.]
        int32_t             delta_height;
        int32_t             width;
        int32_t             height;
        int32_t             midpoint_valid;

        uint32_t            is_npc;
        void*               statistics_;                // Handled via metatype!
        CAlignmentEntry*    alignment;                  // Pointer to object.
        int8_t              ai_class;
        int8_t              fight_walk_speed;
        int16_t             fight_walk_counter;
        int16_t             fight_walk_steps;
        int16_t             fight_walk_steps_counter;
        int16_t             fight_speed1;
        int16_t             fight_speed2;
        int32_t             unknown0040;                // Unknown. [Speed related.]
        int32_t             unknown0044;                // Unknown. [Speed related.]
        int16_t             magic_speed1;
        int16_t             magic_speed2;
        uint16_t            unknown004C;                // Unknown. [Speed related.]
        uint16_t            unknown004E;                // Unknown. [Speed related.]
        uint32_t            unknown0050;
        uint32_t            unknown0054;                // Unknown. [Spell related.]
        uint32_t            spell_knowledge[3];         // Treated as bits.
        uint32_t            spell_learned[3];           // Treated as bits.
        int16_t             runaway;
        uint16_t            padding0072;
        uint32_t            ai_parameter;
        int16_t             image_index[5];
        uint8_t             skill_data[290];            // Holds information related to what spells are learned and their level of upgrades.
        int32_t             current_weight;
        int32_t             arrow_animation_index;
        int32_t             unknown01AC;                // Unknown. [Location or teleporting related.]
        int32_t             summoned_by;
        int32_t             treasure_type;
        uint32_t            identify_cost;
        uint32_t            heal_cost;
        float               repair_cost;
        uint32_t            attitude;
        int32_t             damage_min;                 // Monster damage low-value.
        int32_t             damage_add;                 // Monster damage add-value. [damage_max = damage_min + damage_add]
        int32_t             unknown01D0;                // Unused?
        int32_t             unknown01D4;                // Unknown. [Damage related.]
        int32_t             unknown01D8;                // Unknown. [Damage related.]
        int32_t             unknown01DC;                // Unused?
        int32_t             unknown01E0;                // Unknown. [Damage related. Used as a rand() compare for damage value enhancement.]
        int32_t             unknown01E4;                // Unknown. [Damage related. Used as an additive value.]
        int32_t             unknown01E8;                // Unknown. [Damage related. Used as an additive value.]
        int32_t             unknown01EC;                // Unknown. [Damage related.]
        int32_t             unknown01F0;                // Unknown. [Damage related. Used as a rand() compare for damage value enhancement.]
        int32_t             damage_arrow_min;           // Monster damage (arrows/ranged) low-value.
        int32_t             damage_arrow_add;           // Monster damage (arrows/ranged) add-value. [damage_arrow_max = damage_arrow_min + damage_arrow_add]
        uint32_t            unknown01FC;                // Unused?
        uint32_t            unknown0200;                // Unused?
        uint32_t            unknown0204;                // Unused?
        float               relative_sell_price;
        float               relative_buy_price;
        int32_t             reputation;

        uint16_t            index;
        uint8_t             current_action;
        uint8_t             walk_speed;
        uint8_t             priority_ring;
        uint8_t             padding0219[3];
        const char*         name_;                      // Handled via metatype!
        uint32_t            parameter1;
        uint32_t            parameter2;
        CAgentClass*        agent_class;
        float               cell_dx;
        float               cell_dy;
        int32_t             cell_destination_x;
        int32_t             cell_destination_y;
        CInventory*         inventory;
        int32_t             inventory1;
        int32_t             inventory2;
        uint32_t            inventory_type;
        uint32_t            inventory_level;
        uint32_t            synch_parameter;
        CAgentFight*        fighting;                   // Pointer to object.
        CSeeing*            seeing;                     // Pointer to object.
        CMagic*             magic;                      // Pointer to object.
        void*               behavior;                   // Pointer to object.
        int32_t             current_dialog;
        int32_t             talking_to;
        int32_t             group;
        int32_t             group_index;
        int32_t             source_egg;
        int32_t             walk_count;
        int32_t             old_cell_x;
        int32_t             old_cell_y;
        int32_t             current_map;
        uint32_t            tactics[2];
        uint32_t            unknown0290;                // Unknown. [Used as a total of money spent.]
        uint32_t            pickpocket_count;           // The number of times the agent has been pickpocketed.
        uint8_t             unknown0298;                // Unknown. [Mouse / object related.]
        uint8_t             padding0299[3];
        uint32_t            unknown029C;                // Unknown. [Inventory related.]
        uint32_t            unknown02A0;                // Unknown. [Inventory related.]
        uint32_t            unknown02A4;                // Unknown. [Inventory related.]
        uint32_t            this_size;
        int32_t             locked;
        uint32_t            unknown02B0;                // Unknown. [Pointer to object. First entry in the object is the model type for CPartyMember agent types.]
        uint16_t*           program_data;
        int16_t             program_size;
        int16_t             program_counter;
        uint16_t            program_loop_point;
        uint16_t            padding02BE;
        uint32_t*           region_list_content;
        int32_t             region_count;
        int32_t             region_list_real_size;
        int32_t             behaviors[3];
        int32_t             loop_points_size;
        uint32_t*           loop_points;
    } CAgent;

    typedef struct CAgentNpc
    {
        CAgent              BaseClass;                  // C++ inheritance workaround.
        void*               actor;                      // Pointer to object.
        void*               visual;                     // Pointer to object.
        uint32_t            unknown02E8;                // Unused?
        void*               path;                       // Pointer to object.
        int32_t             unknown02F0;                // Path node count? (The number of nodes checked when building the path?)
        int32_t             path_step_count;            // Potentially wrong naming.
        int32_t             path_step_current;          // Potentially wrong naming.
        int32_t             path_position_x;
        int32_t             path_position_y;
    } CAgentNpc;

    typedef struct CPartyMember
    {
        CAgentNpc           BaseClass;                  // C++ inheritance workaround.
        int32_t             panic_positions[16];
        int32_t             panic_position_counter;
        int32_t             weapon_sound;
        int32_t             unknown034C;                // Unknown. [Monster region related.]
        int32_t             stamina_direction;
        int32_t             stamina_counter;
        uint32_t            party_parameter;
        int32_t             armed_skill;
        int32_t             last_used_skill;
        uint32_t            nutrition[20];
        int32_t             arrow_skill_index;          // Skill index when the player is using an arrow skill.
        int32_t             arrow_skill_mana_cost;      // Skill mana cost when the player is using an arrow skill.
        int32_t             dont_interrup_twalking;
        int32_t             walk_object[4];
        int32_t             dialog_distance_candidates[16];
        int32_t             dialog_distance_candidate_count;
        void*               special_move;               // Pointer to object.
        int32_t             unknown0418;                // Unknown. [Dungeon / visual agent related.]
        uint32_t            bonus_points_temp;          // Used as temp storage for bonus points when loading/saving game.

        /**
         * Note:    The below block of data is used when the player is currently transformed into another agent
         *          type. (ie. casting Spirit Form, using creature statues, etc.) When the player is transformed,
         *          the member variable 'is_transformed' will be set to 1 and the below block will be populated
         *          by copying part of the existing agent information into it. Additional members are also manually
         *          copied from the agent and nulled from their original variable. Partial example of this:
         *
         *              this->is_transformed = 1;
         *
         *              qmemcpy(&this->transform_is_npc, &this->is_npc, 0x1ECu);
         *              this->transform_visual          = this->visual;
         *              this->transform_special_move    = this->special_move;
         *              this->transform_unknown0614     = this->unknown02B0;
         *
         *              this->visual        = 0;
         *              this->special_move  = 0;
         *              this->unknown02B0   = 0;
         *
         *          The below members prefixed with 'transform' and are unknown are named based on the original member they
         *          inherit their value from instead of their true position in the structure.
         */

        void*               transform_visual;               // The original visual pointer before transforming.
        uint32_t            transform_is_npc;
        CPlayerStatistics*  transform_statistics;
        CAlignmentEntry*    tarnsform_alignment;
        int8_t              transform_ai_class;
        int8_t              transform_fight_walk_speed;
        int16_t             transform_fight_walk_counter;
        int16_t             transform_fight_walk_steps;
        int16_t             transform_fight_walk_steps_counter;
        int16_t             transform_fight_speed1;
        int16_t             transform_fight_speed2;
        int32_t             transform_unknown0040;
        int32_t             transform_unknown0044;
        int16_t             transform_magic_speed1;
        int16_t             transform_magic_speed2;
        uint16_t            transform_unknown004C;
        uint16_t            transform_unknown004E;
        uint32_t            transform_unknown0050;
        uint32_t            transform_unknown0054;
        uint32_t            transform_spell_knowledge[3];
        uint32_t            transform_spell_learned[3];
        int16_t             transform_runaway;
        uint16_t            transform_padding0072;
        uint32_t            transform_ai_parameter;
        int16_t             transform_image_index[5];
        uint8_t             transform_skill_data[290];
        int32_t             transform_current_weight;
        int32_t             transform_arrow_animation_index;
        uint32_t            transform_unknown01AC;
        int32_t             transform_summoned_by;
        int32_t             transform_treasure_type;
        uint32_t            transform_identify_cost;
        uint32_t            transform_heal_cost;
        float               transform_repair_cost;
        uint32_t            transform_attitude;
        int32_t             transform_damage_min;
        int32_t             transform_damage_add;
        int32_t             transform_unknown01D0;
        int32_t             transform_unknown01D4;
        int32_t             transform_unknown01D8;
        int32_t             transform_unknown01DC;
        int32_t             transform_unknown01E0;
        int32_t             transform_unknown01E4;
        int32_t             transform_unknown01E8;
        int32_t             transform_unknown01EC;
        int32_t             transform_unknown01F0;
        int32_t             transform_damage_arrow_min;
        int32_t             transform_damage_arrow_add;
        uint32_t            transform_unknown01FC;
        uint32_t            transform_unknown0200;
        uint32_t            transform_unknown0204;
        float               transform_relative_sell_price;
        float               transform_relative_buy_price;
        int32_t             transform_reputation;
        uint32_t            is_transformed;                 // Flag set when the player is transformed. (ie. casting Spirit Form, using creature statues.)
        uint32_t            transform_unknown0614;          // The original unknown02B0 pointer before transforming.
        void*               transform_special_move;         // The original special_move pointer before transforming.
        int32_t             transform_agent_class_index;    // The original agent class index before transforming.
    } CPartyMember;

]];

local function get_agent_type(agent)
    return switch(agent.this_size, T{
        [ffi.sizeof('CAgent')]      = function () return AgentType_Agent; end,
        [ffi.sizeof('CAgentNpc')]   = function () return AgentType_AgentNpc; end,
        [ffi.sizeof('CPartyMember')]= function () return AgentType_PartyMember; end,
        [switch.default]            = function () return AgentType_Invalid; end,
    });
end

ffi.metatype('CAgentFight', T{
    __index = function (self, k)
        return switch(k, T{
            -- Properties
            [T{'target', 'caster'}] = function ()
                local agent = ffi.cast('CAgent*', self[k .. '_']);
                return switch(agent.this_size, T{
                    [ffi.sizeof('CAgentNpc')]   = function () return ffi.cast('CAgentNpc*', agent); end,
                    [ffi.sizeof('CPartyMember')]= function () return ffi.cast('CPartyMember*', agent); end,
                    [switch.default]            = function () return ffi.cast('CAgent*', agent); end,
                });
            end,
            [switch.default] = function ()
                error(('struct \'CAgentFight\' has no member: %s'):fmt(k));
            end,
        });
    end,
    __newindex = function (_, k, _)
        error(('struct \'CAgentFight\' has no member: %s'):fmt(k));
    end,
});

ffi.metatype('CSeeing', T{
    __index = function (self, k)
        return switch(k, T{
            -- Properties
            ['owner'] = function ()
                local agent = ffi.cast('CAgent*', self[k .. '_']);
                return switch(agent.this_size, T{
                    [ffi.sizeof('CAgentNpc')]   = function () return ffi.cast('CAgentNpc*', agent); end,
                    [ffi.sizeof('CPartyMember')]= function () return ffi.cast('CPartyMember*', agent); end,
                    [switch.default]            = function () return ffi.cast('CAgent*', agent); end,
                });
            end,
            [switch.default] = function ()
                error(('struct \'CSeeing\' has no member: %s'):fmt(k));
            end,
        });
    end,
    __newindex = function (_, k, _)
        error(('struct \'CSeeing\' has no member: %s'):fmt(k));
    end,
});

ffi.metatype('CMagic', T{
    __index = function (self, k)
        return switch(k, T{
            -- Properties
            ['owner'] = function ()
                local agent = ffi.cast('CAgent*', self[k .. '_']);
                return switch(agent.this_size, T{
                    [ffi.sizeof('CAgentNpc')]   = function () return ffi.cast('CAgentNpc*', agent); end,
                    [ffi.sizeof('CPartyMember')]= function () return ffi.cast('CPartyMember*', agent); end,
                    [switch.default]            = function () return ffi.cast('CAgent*', agent); end,
                });
            end,
            [switch.default] = function ()
                error(('struct \'CMagic\' has no member: %s'):fmt(k));
            end,
        });
    end,
    __newindex = function (_, k, _)
        error(('struct \'CMagic\' has no member: %s'):fmt(k));
    end,
});

ffi.metatype('CAgent', T{
    __index = inheritance.index:bindn(0, function (self, k)
        return switch(k, T{
            -- Properties
            ['vtbl'] = function ()
                return ffi.cast('CAgentVtbl*', self.vtbl_);
            end,
            ['statistics'] = function ()
                return ffi.cast(self.is_npc == 0 and 'CPlayerStatistics*' or 'CMonsterStatistics*', self.statistics_);
            end,
            ['name'] = function ()
                return game.safe_read_string(self.name_, nil);
            end,
            -- Functions
            ['get_type'] = function ()
                return get_agent_type;
            end,
            [switch.default] = function ()
                error(('struct \'CAgent\' has no member: %s'):fmt(k));
            end,
        });
    end),
    __newindex = inheritance.newindex:bindn(0, function (_, k, _)
        error(('struct \'CAgent\' has no member: %s'):fmt(k));
    end),
});

inheritance.proxy(1, 'CAgentNpc');
inheritance.proxy(2, 'CPartyMember');