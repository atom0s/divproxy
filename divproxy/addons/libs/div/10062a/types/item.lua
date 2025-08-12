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

-- Item Quality
ItemQuality_White   = 0;
ItemQuality_Grey    = 1;
ItemQuality_Blue    = 2;
ItemQuality_Green   = 3;
ItemQuality_Lime    = 4;
ItemQuality_Gold    = 5;

-- Slot Types
SlotType_Head       = 0;
SlotType_Neck       = 1;
SlotType_Weapon     = 2;
SlotType_Body       = 3;
SlotType_Legs       = 4;
SlotType_Ring       = 5;
SlotType_Feet       = 6;
SlotType_Shield     = 7;
SlotType_Waist      = 8;
SlotType_Hands      = 9;

--[[
* Class Object Definitions
--]]

ffi.cdef[[

    typedef struct CItem
    {
        uintptr_t       vtbl;
        int32_t         damage_range_min;
        int32_t         damage_range_max;
        int32_t         damage_range_base;
        int32_t         armor;
        int32_t         charm_quality;
        int32_t         durability_max;
        int32_t         durability_current;
        uint32_t        unknown0020;            // Unknown.
        uint32_t        unknown0024;            // Unknown.
        uint32_t        unknown0028;            // Unknown.
        int32_t         vitality;
        int32_t         magic;
        int32_t         offense;
        int32_t         defense;
        int32_t         sight;
        int32_t         hearing;
        int32_t         resistance_to_lightning;
        int32_t         resistance_to_poison;
        int32_t         resistance_to_fire;
        int32_t         resistance_to_spirit;
        int32_t         id_level;
        uint8_t         is_identified;
        uint8_t         padding0059[3];
        int32_t         speed;
        int32_t         unknown0060;            // Used with object property: ObjectDataProperty_SbValue
        int32_t         required_strength;
        int32_t         required_agility;
        int32_t         required_intelligence;
        int32_t         required_constitution;
        int32_t         strength;
        int32_t         agility;
        int32_t         intelligence;
        int32_t         constitution;
        void*           itemstats_;             // CItemStatistics link. [Handled via metatype!]

        void*           unknown0088;
        uint32_t        unknown008C;
        uint32_t        unknown0090;
        int32_t         unknown0094;
        int32_t         unknown0098;
        uint32_t        unknown009C;

        void*           unknown00A0;
        uint32_t        unknown00A4;
        uint32_t        unknown00A8;
        int32_t         unknown00AC;
        int32_t         unknown00B0;
        uint32_t        unknown00B4;

        int32_t         unknown00B8;
        void*           unknown00BC;
    } CItem;

    typedef struct CItemStatistics
    {
        void*           unknown0000;
        uint32_t        unknown0004;
        uint32_t        unknown0008;
        int32_t         unknown000C;
        int32_t         unknown0010;
        uint32_t        unknown0014;

        void*           unknown0018;
        uint32_t        unknown001C;
        uint32_t        unknown0020;
        int32_t         unknown0024;
        int32_t         unknown0028;
        uint32_t        unknown002C;

        void*           unknown0030;
        uint32_t        unknown0034;
        uint32_t        unknown0038;
        int32_t         unknown003C;
        int32_t         unknown0040;
        uint32_t        unknown0044;

        std_string      tag;                    // The item tag. [Handled via metatype!]
        std_string      name;                   // The item name. [Handled via metatype!]
        int32_t         unknown0080;            // Unknown. [Potentially visual_effect.]
        uint32_t        slot_type;
        uint8_t         is_prevent_offhand1;    // Flag set if the item prevents a shield from being equipped. (Used for two-hand weapons.)
        uint8_t         is_prevent_offhand2;    // Flag set if the item prevents a shield from being equipped. (Used for bows/crossbows.)
        uint8_t         padding008A[2];
        uint32_t        unknown008C;            // Unknown.
        uint32_t        item_quality;           // The item quality. [Used to also color the item name.]
        CItem           item;
        uint32_t        unknown0154;            // Unknown.
        uint32_t        unknown0158;            // Unknown.
        void*           unknown015C;            // Unknown. [Unknown pointer. Points back to the item.]
        void*           unknown0160;            // Unknown. [Unknown pointer.]
        void*           unknown0164;            // Unknown. [Unknown pointer.]
        uint8_t         use_generated_name;     // Flag set if the item should use the 'name' field when displaying its name. (If not set, uses the stock name for the item.)
        uint8_t         padding0169[3];
    } CItemStatistics;

]];

ffi.metatype('CItem', T{
    __index = function (self, k)
        return switch(k, T{
            -- Properties
            ['itemstats'] = function ()
                return ffi.cast('CItemStatistics*', self[k .. '_']);
            end,
            [switch.default] = function ()
                error(('struct \'CItem\' has no member: %s'):fmt(k));
            end,
        });
    end,
    __newindex = function (_, k, _)
        error(('struct \'CItem\' has no member: %s'):fmt(k));
    end
});

inheritance.proxy(0, 'CItemStatistics');