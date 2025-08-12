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

    typedef struct CAgentClass
    {
        uint32_t        animations[19];
        uint8_t         animation_steps[19];
        uint8_t         animation_looping[19];
        uint8_t         animation_start_frame[19];
        uint8_t         padding0085[3];
        uint32_t        action_parameters[19];
        uint32_t        tactics[2];
        uint32_t        behaviors[4];
        uint32_t        magic_color_r;
        uint32_t        magic_color_g;
        uint32_t        magic_color_b;
        int32_t         death_fx;
        int32_t         death_transmute;
        int32_t         agent_light;
        uint8_t         fight_range;
        uint8_t         padding0105[3];
        uint32_t        killed_counter;
        uint32_t        has_given_expbomb;
        uint32_t        dialog_intelligence;
        const char*     class_name_;            // Handled via metatype!
        const char*     animation_name_;        // Handled via metatype!

        uint32_t        is_npc;
        void*           statistics_;            // Handled via metatype!
        void*           alignment_;             // Handled via metatype!
        uint8_t         ai_class;
        uint8_t         fight_walk_speed;
        uint16_t        padding012A;
        uint16_t        fight_walk_steps;
        uint16_t        padding012E;
        uint16_t        fightspeed_val1;
        uint16_t        fightspeed_val2;
        uint32_t        unused0134;
        uint32_t        unused0138;
        uint16_t        magicspeed_val1;
        uint16_t        magicspeed_val2;
        uint32_t        unused0140;
        uint32_t        unused0144;
        uint32_t        unused0148;
        uint32_t        spell_knowledge_bits1;
        uint32_t        spell_knowledge_bits2;
        uint32_t        spell_knowledge_bits3;
        uint32_t        spell_knowledge_bits1_copy;
        uint32_t        spell_knowledge_bits2_copy;
        uint32_t        spell_knowledge_bits3_copy;
        uint16_t        runaway;
        uint16_t        padding0166;
        uint32_t        ai_parameter;
        int16_t         head;
        int16_t         shield;
        int16_t         status;
        int16_t         blood;
        uint16_t        trade_image_index;
        uint8_t         spell_levels[96];
        uint8_t         unknown01D6[198];
        int32_t         weapon_animation;
        int32_t         unknown02A0;
        int32_t         unknown02A4;
        int32_t         treasure_type;
        uint32_t        unknown02AC;
        uint32_t        unknown02B0;
        float           unknown02B4;
        uint32_t        unknown02B8;
        int32_t         damage_val1;
        uint32_t        unknown02C0;
        int32_t         damage_val2;
        int32_t         damage2_val1;
        uint32_t        unknown02CC;
        int32_t         damage2_val2;
        int32_t         damage2_chance;
        int32_t         special_damage_val1;
        int32_t         special_damage_val2;
        int32_t         special_damage_val3;
        int32_t         special_damage_chance;
        int32_t         arrow_damage_val1;
        uint32_t        unknown02EC;
        int32_t         arrow_damage_val2;
        int32_t         hitpoints_val1;
        int32_t         hitpoints_val2;
        float           unknown02FC;
        float           unknown0300;
        uint32_t        unknown0304;

        uint32_t        index;
        uint8_t         clothing_char;
        uint8_t         slow_motion;
        uint8_t         walk_speed;
        uint8_t         unknown030F;
        uint32_t        parameters1;
        uint32_t        unknown0314;
    } CAgentClass;

]];

ffi.metatype('CAgentClass', T{
    __index = function (self, k)
        return switch(k, T{
            -- Properties
            ['class_name'] = function ()
                return game.safe_read_string(self.class_name_, '');
            end,
            ['animation_name'] = function ()
                return game.safe_read_string(self.animation_name_, '');
            end,
            ['statistics'] = function ()
                return ffi.cast(self.is_npc == 0 and 'CPlayerStatistics*' or 'CMonsterStatistics*', self.statistics_);
            end,
            ['alignment'] = function ()
                return ffi.cast('CAlignmentEntry*', self.alignment_);
            end,
            [switch.default] = function ()
                error(('struct \'CAgentClass\' has no member: %s'):fmt(k));
            end,
        });
    end,
    __newindex = function (_, k, _)
        error(('struct \'CAgentClass\' has no member: %s'):fmt(k));
    end,
});