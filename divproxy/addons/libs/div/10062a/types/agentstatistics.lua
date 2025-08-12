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

-- Boost Types
BoostType_MaxHitPoints          = 0x00;
BoostType_MaxMana               = 0x01;
BoostType_Offense               = 0x02;
BoostType_Defense               = 0x03;
BoostType_Sight                 = 0x04;
BoostType_Hearing               = 0x05;
BoostType_ResistanceToLightning = 0x06;
BoostType_ResistanceToPoison    = 0x07;
BoostType_ResistanceToFire      = 0x08;
BoostType_ResistanceToSpirit    = 0x09;
BoostType_Strength              = 0x0A;
BoostType_Dexterity             = 0x0B;
BoostType_Intelligence          = 0x0C;
BoostType_MaxStamina            = 0x0D;
BoostType_Armor                 = 0x0E;
BoostType_Damage                = 0x0F;

-- Equipment Slots
EquipSlot_Head                  = 0x00;
EquipSlot_Neck                  = 0x01;
EquipSlot_Body                  = 0x02;
EquipSlot_Weapon                = 0x03;
EquipSlot_Shield                = 0x04;
EquipSlot_RingL                 = 0x05;
EquipSlot_RingR                 = 0x06;
EquipSlot_Legs                  = 0x07;
EquipSlot_Waist                 = 0x08;
EquipSlot_Feet                  = 0x09;
EquipSlot_Hands                 = 0x0A;

ffi.cdef[[

    /**
     * Note:    Boost ids are unique and are set using a globally incremented counter. Each time a new boost
     *          is created, the counter is incremented to ensure a new id is used. This counter is also
     *          preserved within the current save file.
     */

    typedef struct CBoost
    {
        uint32_t        type;
        int32_t         value;
        int32_t         duration;
        int32_t         time_started;
        uint32_t        id;
    } CBoost;

    typedef struct CAgentStatistics
    {
        uintptr_t       vtbl;
        int32_t         hp;
        int32_t         mana;
        int32_t         max_hit_points;
        int32_t         max_mana;
        int32_t         offense;
        int32_t         defense;
        int32_t         level;
        int32_t         sight;
        int32_t         hearing;
        int32_t         resistance_to_lightning;
        int32_t         resistance_to_poison;
        int32_t         resistance_to_fire;
        int32_t         resistance_to_spirit;
        int32_t         hp_2;
        int32_t         max_hit_points_2;
        int32_t         mana_2;
        int32_t         max_mana_2;
        int32_t         offense_2;
        int32_t         defense_2;
        int32_t         level_2;
        int32_t         sight_2;
        int32_t         hearing_2;
        int32_t         resistance_to_lightning_2;
        int32_t         resistance_to_poison_2;
        int32_t         resistance_to_fire_2;
        int32_t         resistance_to_spirit_2;
        uint32_t        unknown006C;
        uint32_t        back_reference; // The agent index that owns this statistics object.
        CBoost**        boosts;
        int32_t         boosts_size;
        int32_t         boosts_max;
    } CAgentStatistics;

    typedef struct CMonsterStatistics
    {
        uintptr_t       vtbl;
        int32_t         hp;
        int32_t         mana;
        int32_t         max_hit_points;
        int32_t         max_mana;
        int32_t         offense;
        int32_t         defense;
        int32_t         level;
        int32_t         sight;
        int32_t         hearing;
        int32_t         resistance_to_lightning;
        int32_t         resistance_to_poison;
        int32_t         resistance_to_fire;
        int32_t         resistance_to_spirit;
        int32_t         hp_2;
        int32_t         max_hit_points_2;
        int32_t         mana_2;
        int32_t         max_mana_2;
        int32_t         offense_2;
        int32_t         defense_2;
        int32_t         level_2;
        int32_t         sight_2;
        int32_t         hearing_2;
        int32_t         resistance_to_lightning_2;
        int32_t         resistance_to_poison_2;
        int32_t         resistance_to_fire_2;
        int32_t         resistance_to_spirit_2;
        uint32_t        unknown006C;
        uint32_t        back_reference;                 // The agent index that owns this statistics object.
        CBoost**        boosts;
        int32_t         boosts_size;
        int32_t         boosts_max;
        int32_t         gain;
        int32_t         armor;
        int32_t         internal_gain;
    } CMonsterStatistics;

    typedef struct CPlayerStatistics
    {
        uintptr_t       vtbl;
        int32_t         hp;
        int32_t         mana;
        int32_t         max_hit_points;
        int32_t         max_mana;
        int32_t         offense;
        int32_t         defense;
        int32_t         level;
        int32_t         sight;
        int32_t         hearing;
        int32_t         resistance_to_lightning;
        int32_t         resistance_to_poison;
        int32_t         resistance_to_fire;
        int32_t         resistance_to_spirit;
        int32_t         hp_2;
        int32_t         max_hit_points_2;
        int32_t         mana_2;
        int32_t         max_mana_2;
        int32_t         offense_2;
        int32_t         defense_2;
        int32_t         level_2;
        int32_t         sight_2;
        int32_t         hearing_2;
        int32_t         resistance_to_lightning_2;
        int32_t         resistance_to_poison_2;
        int32_t         resistance_to_fire_2;
        int32_t         resistance_to_spirit_2;
        uint32_t        unknown006C;
        uint32_t        back_reference;                 // The agent index that owns this statistics object.
        CBoost**        boosts;
        int32_t         boosts_size;
        int32_t         boosts_max;
        int32_t         strength;
        int32_t         dexterity;
        int32_t         intelligence;
        int32_t         stamina;
        int32_t         max_stamina;
        int32_t         experience;
        int32_t         armor;
        int32_t         damage;
        int32_t         stat_multiplier_index;
        int32_t         strength_2;
        int32_t         dexterity_2;
        int32_t         intelligence_2;
        int32_t         stamina_2;
        int32_t         max_stamina_2;
        int32_t         experience_2;
        int32_t         armor_2;
        int32_t         damage_2;
        uint32_t        equipment_broken_status[11];
        CItem*          equipment[11];
    } CPlayerStatistics;

]];