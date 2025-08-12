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

    typedef struct TTransformCombinationParams
    {
        uint32_t                        target_object;
        uint32_t                        transform_code;
        uint32_t                        param0;
        uint32_t                        param1;
        uint32_t                        param2;
        uint32_t                        param3;
    } TTransformCombinationParams;

    typedef struct CTransformCode
    {
        uint32_t                        size;
        uint32_t*                       opcodes;
        uint32_t                        index;
    } CTransformCode;

    typedef struct CTransformCombination
    {
        uint32_t                        object_index;
        uint32_t                        size;
        TTransformCombinationParams*    data;
    } CTransformCombination;

    typedef struct COsirisNameEntry
    {
        int32_t                         index;
        char                            name_[32]; // Handled via metatype!
    } COsirisNameEntry;

    typedef struct CObjectManager
    {
        void*                           file_handle;
        COsirisObject*                  osiris_objects;
        int32_t                         osiris_objects_size;
        int32_t                         osiris_objects_count;
        int32_t                         osiris_objects_max;
        uint32_t*                       extfree_objects;
        int32_t                         extfree_objects_size;
        CObject*                        objects;
        CObjectInstance*                objects_instances;
        const char*                     object_file_name;
        int32_t                         objects_instances_size;
        int32_t                         objects_size;
        int32_t                         objects_instances_chunk_size;
        int32_t                         objects_instances_max;
        int32_t                         objects_max;
        void*                           image_list;
        void*                           cube_manager;
        void*                           animation_manager;
        void*                           traps;
        CWorld*                         world;
        uint32_t                        camera_map_x;
        uint32_t                        camera_map_y;
        uint32_t                        transform_combinations_max;
        uint32_t                        transform_combinations_size;
        CTransformCombination*          transform_combinations;
        CTransformCode*                 transforms;
        int32_t                         transforms_size;
        int32_t                         transforms_max;
        COsirisNameEntry*               osiris_names;
        int32_t                         osiris_names_size;
    } CObjectManager;

]];

ffi.metatype('COsirisNameEntry', T{
    __index = function (self, k)
        return switch(k, T{
            -- Properties
            ['name'] = function ()
                return ffi.string(self.name_, 32):split('\0'):first();
            end,
            [switch.default] = function ()
                error(('struct \'COsirisNameEntry\' has no member: %s'):fmt(k));
            end,
        });
    end,
    __newindex = function (_, k, _)
        error(('struct \'COsirisNameEntry\' has no member: %s'):fmt(k));
    end,
});

--[[
*
* Helper Functions
*
--]]

game = game or T{};

game.get_object_manager = function ()
    local ptr = hook.memory.read_uint32(game.ptrs.object_manager);
    if (ptr == 0) then return nil; end
    return ffi.cast('CObjectManager*', hook.memory.read_uint32(ptr));
end