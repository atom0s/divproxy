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

-- Object Data Property Indexes
ObjectDataProperty_SbFunctionParamter   = 0;    -- Value Byte Size: 2
ObjectDataProperty_SbSlot               = 1;    -- Value Byte Size: 1
ObjectDataProperty_SbTreasure           = 2;    -- Value Byte Size: 1
ObjectDataProperty_SbCount              = 3;    -- Value Byte Size: 2
ObjectDataProperty_SbKey                = 4;    -- Value Byte Size: 2
ObjectDataProperty_SbDoor               = 5;    -- Value Byte Size: 2
ObjectDataProperty_SbLever              = 6;    -- Value Byte Size: 2
ObjectDataProperty_SbInside             = 7;    -- Value Byte Size: 0
ObjectDataProperty_SbOsiris             = 8;    -- Value Byte Size: 2
ObjectDataProperty_SbDisappears         = 9;    -- Value Byte Size: 0
ObjectDataProperty_SbChest              = 10;   -- Value Byte Size: 2
ObjectDataProperty_SbLight              = 11;   -- Value Byte Size: 1
ObjectDataProperty_SbTransforms         = 12;   -- Value Byte Size: 2
ObjectDataProperty_SbWtUse              = 13;   -- Value Byte Size: 0
ObjectDataProperty_SbUseOn              = 14;   -- Value Byte Size: 0
ObjectDataProperty_SbGenerated          = 15;   -- Value Byte Size: 0
ObjectDataProperty_SbValue              = 16;   -- Value Byte Size: 2
ObjectDataProperty_SbFunction           = 17;   -- Value Byte Size: 1
ObjectDataProperty_SbMove               = 18;   -- Value Byte Size: 0
ObjectDataProperty_SbItemClass1         = 19;   -- Value Byte Size: 2
ObjectDataProperty_SbItemClass2         = 20;   -- Value Byte Size: 2
ObjectDataProperty_SbLocked             = 21;   -- Value Byte Size: 0
ObjectDataProperty_SbBroken             = 22;   -- Value Byte Size: 0
ObjectDataProperty_SbCanCarry           = 23;   -- Value Byte Size: 2
ObjectDataProperty_SbWalkThrough        = 24;   -- Value Byte Size: 0
ObjectDataProperty_SbClosed             = 25;   -- Value Byte Size: 0
ObjectDataProperty_SbProperty           = 26;   -- Value Byte Size: 2
ObjectDataProperty_SbStolen             = 27;   -- Value Byte Size: 2
ObjectDataProperty_SbPlayerBlock        = 28;   -- Value Byte Size: 0
ObjectDataProperty_SbInvisible          = 29;   -- Value Byte Size: 0
ObjectDataProperty_SbInventory          = 30;   -- Value Byte Size: 2
ObjectDataProperty_SbStrength           = 31;   -- Value Byte Size: 2

-- Object Data Flags
ObjectDataFlag_SbFunctionParamter       = bit.lshift(1, 0);
ObjectDataFlag_SbSlot                   = bit.lshift(1, 1);
ObjectDataFlag_SbTreasure               = bit.lshift(1, 2);
ObjectDataFlag_SbCount                  = bit.lshift(1, 3);
ObjectDataFlag_SbKey                    = bit.lshift(1, 4);
ObjectDataFlag_SbDoor                   = bit.lshift(1, 5);
ObjectDataFlag_SbLever                  = bit.lshift(1, 6);
ObjectDataFlag_SbInside                 = bit.lshift(1, 7);
ObjectDataFlag_SbOsiris                 = bit.lshift(1, 8);
ObjectDataFlag_SbDisappears             = bit.lshift(1, 9);
ObjectDataFlag_SbChest                  = bit.lshift(1, 10);
ObjectDataFlag_SbLight                  = bit.lshift(1, 11);
ObjectDataFlag_SbTransforms             = bit.lshift(1, 12);
ObjectDataFlag_SbWtUse                  = bit.lshift(1, 13);
ObjectDataFlag_SbUseOn                  = bit.lshift(1, 14);
ObjectDataFlag_SbGenerated              = bit.lshift(1, 15);
ObjectDataFlag_SbValue                  = bit.lshift(1, 16);
ObjectDataFlag_SbFunction               = bit.lshift(1, 17);
ObjectDataFlag_SbMove                   = bit.lshift(1, 18);
ObjectDataFlag_SbItemClass1             = bit.lshift(1, 19);
ObjectDataFlag_SbItemClass2             = bit.lshift(1, 20);
ObjectDataFlag_SbLocked                 = bit.lshift(1, 21);
ObjectDataFlag_SbBroken                 = bit.lshift(1, 22);
ObjectDataFlag_SbCanCarry               = bit.lshift(1, 23);
ObjectDataFlag_SbWalkThrough            = bit.lshift(1, 24);
ObjectDataFlag_SbClosed                 = bit.lshift(1, 25);
ObjectDataFlag_SbProperty               = bit.lshift(1, 26);
ObjectDataFlag_SbStolen                 = bit.lshift(1, 27);
ObjectDataFlag_SbPlayerBlock            = bit.lshift(1, 28);
ObjectDataFlag_SbInvisible              = bit.lshift(1, 29);
ObjectDataFlag_SbInventory              = bit.lshift(1, 30);
ObjectDataFlag_SbStrength               = bit.lshift(1, 31);

-- Object Data Flag Names
ObjectDataFlagNames = T{
    'sb_func_paramter',
    'sb_slot',
    'sb_treasure',
    'sb_count',
    'sb_key',
    'sb_door',
    'sb_lever',
    'sb_inside',
    'sb_osiris',
    'sb_disappears',
    'sb_chest',
    'sb_light',
    'sb_transforms',
    'sb_wt_use',
    'sb_use_on',
    'sb_generated',
    'sb_value',
    'sb_function',
    'sb_move',
    'sb_item_class',
    'sb_item_class',
    'sb_locked',
    'sb_broken',
    'sb_can_carry',
    'sb_walk_through',
    'sb_closed',
    'sb_property',
    'sb_stolen',
    'sb_player_block',
    'sb_invisible',
    'sb_inventory',
    'sb_strength',
};

ffi.cdef[[

    typedef bool    (__cdecl* CObjectData_HasPropertySpace_f)(uint32_t, uint32_t);
    typedef int32_t (__cdecl* CObjectData_GetPropertiesSize_f)(uint32_t);
    typedef int32_t (__cdecl* CObjectData_GetProperty_f)(uint32_t, int32_t);
    typedef void    (__cdecl* CObjectData_SetProperty_f)(uint32_t, int32_t, int32_t);
    typedef int32_t (__cdecl* CObjectData_RemoveProperty_f)(uint32_t, uint32_t, int32_t);

    typedef struct COsirisObject
    {
        int32_t         index1;
        int32_t         index2;
    } COsirisObject;

    typedef struct CObjectData
    {
        uint32_t        flags;              // The object flags.
        uint32_t        bits1;              // The object bits. (bits1) [Lower-word holds the item quantity in big-endian.]
        uint32_t        bits2;              // The object bits. (bits2)
        uint32_t        bits3;              // The object bits. (bits3)
        uint32_t        bits4;              // The object bits. (bits4)
    } CObjectData;

    typedef struct CObject
    {
        CObjectData     data;
        int32_t         weight;
        int32_t         animation_index;
        uint32_t        flags;
        char            name_[16];                  // Handled via metatype!
        uint32_t        index;
        int32_t         object_class;
        int32_t         break_animation_index;
        char            clothing_code[8];
        int32_t         transform_combination_index;
        void*           sfx;
        int32_t         floating_image_index;
        int32_t         floating_list_index;
        int32_t         floating_highlight_index;
        int32_t         floating_pressed_index;
        int32_t         floating_disabled_index;
        int32_t         unknown0060;                // Unknown.
        int16_t         unknown0064;                // Unknown. [Cell related.]
        int16_t         unknown0066;                // Unknown. [Cell related.]
        int32_t         weapon_animation;
        int32_t         trade_priority;
        int32_t         floating_group;
        int32_t         unknown0074;                // Unknown.
        int32_t         shadow_offset;
        int32_t         automap_entry;
        int16_t         bridge_patch_x_offset;
        int16_t         bridge_patch_y_offset;
        int16_t         bridge_patch_x_size;
        int16_t         bridge_patch_y_size;
        uint32_t        unknown0088;                // Unknown.
        uint32_t        unknown008C;                // Unknown.
        uint32_t        unknown0090;                // Unknown.
    } CObject;

    typedef struct CObjectInstance
    {
        uint32_t        index;
        uint8_t         lerp_speed;                 // The amount to increase the objects height each frame.
        uint8_t         lerp_step;                  // The amount to increase the lerp_speed each frame by. (Default is 0.)
        uint16_t        padding0006;
        int32_t         x;
        int32_t         y;
        int32_t         last_visual_x;
        int32_t         last_visual_y;
        int16_t         height;
        uint16_t        padding001A;
        int32_t         visual_x;
        int32_t         visual_y;
        uint32_t        object_index;
        uint32_t        z_order;
        uint32_t        flags;
        CObjectData     data;
        int16_t         animation_frame;
        uint16_t        padding0046;
        int32_t         animated_tile_image_index;
        int16_t         animation_frame_prev;       // The previous animation_frame value.
        uint16_t        blink_timer;                // Timer used to blink the object sprite and show a shimmer effect.
        uint32_t        data_flags;
        uint32_t        external_index;             // Used with highlighting and Osiris object indexes.
        int32_t         tile_image_index;
        int16_t         height_lerp;                // The desired height the object should move to. (Requires lerp_speed to be set to at least 1 to start moving.)
        uint16_t        padding005E;
        void*           tile_image_frame;
        uint32_t        unknown0064;                // sfx related.
        void*           sorted_sprite;
    } CObjectInstance;

]];

-- Returns if there is space to add more properties.
local function CObjectData_HasPropertySpace(data)
    local func = ffi.cast('CObjectData_HasPropertySpace_f', 0x0591B80);
    local optr = tonumber(ffi.cast('uint32_t', ffi.cast('uint32_t*', data)));
    return func(optr + 4, data.flags);
end

-- Returns the total byte size of the current set properties.
local function CObjectData_GetPropertiesSize(data)
    local func = ffi.cast('CObjectData_GetPropertiesSize_f', game.ptrs.cobjectdata_get_properties_size);
    return func(data.flags);
end

-- Returns the value of the given property.
local function CObjectData_GetProperty(data, idx)
    local func = ffi.cast('CObjectData_GetProperty_f', game.ptrs.cobjectdata_get_property);
    local optr = tonumber(ffi.cast('uint32_t', ffi.cast('uint32_t*', data)));
    return func(optr, idx);
end

-- Sets the value of the given property.
local function CObjectData_SetProperty(data, idx, val)
    local func = ffi.cast('CObjectData_SetProperty_f', game.ptrs.cobjectdata_set_property);
    local optr = tonumber(ffi.cast('uint32_t', ffi.cast('uint32_t*', data)));
    func(optr, idx, val);
end

-- Removes the given property.
local function CObjectData_RemoveProperty(data, idx)
    local func = ffi.cast('CObjectData_RemoveProperty_f', game.ptrs.cobjectdata_remove_property);
    local optr = tonumber(ffi.cast('uint32_t', ffi.cast('uint32_t*', data)));
    return func(optr + 4, optr, idx);
end

ffi.metatype('CObjectData', T{
    __index = function (_, k)
        return switch(k, T{
            -- Functions
            ['has_property_space']  = function () return CObjectData_HasPropertySpace; end,
            ['get_properties_size'] = function () return CObjectData_GetPropertiesSize; end,
            ['get_property']        = function () return CObjectData_GetProperty; end,
            ['set_property']        = function () return CObjectData_SetProperty; end,
            ['remove_property']     = function () return CObjectData_RemoveProperty; end,
            [switch.default] = function ()
                error(('struct \'CObjectData\' has no member: %s'):fmt(k));
            end,
        });
    end,
    __newindex = function (_, k, _)
        error(('struct \'CObjectData\' has no member: %s'):fmt(k));
    end,
});

ffi.metatype('CObject', T{
    __index = function (self, k)
        return switch(k, T{
            -- Properties
            ['name'] = function ()
                return ffi.string(self.name_, 16):split('\0'):first();
            end,
            [switch.default] = function ()
                error(('struct \'CObject\' has no member: %s'):fmt(k));
            end,
        });
    end,
    __newindex = function (_, k, _)
        error(('struct \'CObject\' has no member: %s'):fmt(k));
    end,
});

--[[
*
* Helper Functions
*
--]]

game = game or T{};

-- Returns the number of bytes given property value makes use of.
game.get_object_property_byte_size = function (idx)
    if (idx < 0 or idx > ObjectDataProperty_SbStrength) then
        return 0;
    end

    local sizes = T{
        2, 1, 1, 2, 2, 2, 2, 0, 2, 0, 2, 1, 2, 0, 0, 0,
        2, 1, 0, 2, 2, 0, 0, 2, 0, 0, 2, 2, 0, 0, 2, 2,
    };

    return sizes[idx + 1];
end