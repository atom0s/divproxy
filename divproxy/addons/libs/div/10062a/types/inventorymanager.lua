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

-- Inventory List Types
InventoryList_AgentInventories      = 0x00; -- Agent Inventories (When active.)
InventoryList_ObjectContainers      = 0x01; -- Object Containers (Barrels, Bookcases, Bookshelves, Chests, etc.)
InventoryList_Unknown0002           = 0x02; -- Unknown.

ffi.cdef[[

    typedef struct CInventoryObject
    {
        uint32_t                        x;                  // The object x position.
        uint32_t                        y;                  // The object y position.
        int32_t                         object_index;       // The index into the CObjectManager::objects array.
        int16_t                         equipment_index;    // The index into the CPlayerStatistics::equipment array, if the item is equipped. (-1 if not.)
        int16_t                         is_trading;         // Flag set when the given object is being traded.
        int16_t                         count_multiplier;   // Multiplier used for items that have the sb_count property.
        uint16_t                        unknown0012;        // Unused/padding?
        CObjectData                     data;
    } CInventoryObject;

    typedef struct TArray_CInventoryObject
    {
        CInventoryObject*               entries;            // The array of entries.
        int32_t                         size;               // The number of items within the entries array.
        int32_t                         element_size;       // The per-element size of each entry within the entries array.
        int32_t                         unknown000C;        // Unknown. [Used as a flag to mark if this array can resize dynamically.]
        int32_t                         max;                // The maximum number of elements the entries array can hold.
        uint32_t                        unknown0014;        // Unknown.
    } TArray_CInventoryObject;

    typedef struct CInventoryContainer
    {
        uint32_t                        step;               // The number of times this container has been touched.
        TArray_CInventoryObject*        objects;            // TArray<CInventoryObject*>
        void*                           file;               // The TBufferedRamFile object used with this container.
        int32_t                         size;               // The number of items within the container array.
        int32_t                         index;              // The container index. [This will usually be the agent index or object index +1.]
        const char*                     name_;              // The container name. [Handled via metatype!]
        void*                           list_;              // The CInventoryList object that owns this container. [Handled via metatype!]
    } CInventoryContainer;

    typedef struct CInventoryListEntry
    {
        CInventoryContainer*            container;          // The inventory container object.
        int32_t                         ref_count;          // The number of references using this entry. [When 0, this entry will be removed from the array.]
    } CInventoryListEntry;

    // Implements: TArray<CInventoryListEntry*>
    typedef struct TArray_CInventoryListEntry
    {
        CInventoryListEntry*            entries;            // The array of entries.
        int32_t                         size;               // The number of items within the entries array.
        int32_t                         element_size;       // The per-element size of each entry within the entries array.
        int32_t                         unknown000C;        // Unknown. [Used as a flag to mark if this array can resize dynamically.]
        int32_t                         max;                // The maximum number of elements the entries array can hold.
        uint32_t                        unknown0014;        // Unknown.
    } TArray_CInventoryListEntry;

    typedef struct CInventoryListLink
    {
        int32_t                         list_index;         // The CInventoryList index that owns the container.
        int32_t                         container_index;    // The CInventoryContainer index of the container.
    } CInventoryListLink;

    typedef struct CInventoryList
    {
        TArray_CInventoryListEntry*     entries;            // TArray<CInventoryListEntry*>
        void*                           file_;              // TBufferedRamFile* [Handled via metatype!]
        CInventoryListLink*             container_links;    // List of container links between different CInventoryLists.
        void*                           object_manager_;    // Handled via metatype!
        uint32_t                        unknown0010;        // Unknown.
        int32_t                         index;              // The index within the CInventoryManager::lists array this list belongs to.
    } CInventoryList;

    typedef struct CInventoryManager
    {
        CInventoryList*                 lists[3];
    } CInventoryManager;

]];

ffi.metatype('CInventoryContainer', T{
    __index = function (self, k)
        return switch(k, T{
            -- Properties
            ['name'] = function ()
                return game.safe_read_string(self.name_, '');
            end,
            ['list'] = function ()
                -- Note: It is possible for this object value to become invalid between loading saved games.
                local ptr = ffi.cast('uint32_t', self.list_);
                if (ptr == 0 or ptr == 0xFFFFFFFF) then
                    return nil;
                end
                if (game.use_memory_checks == true and not game.is_valid_ptr(ptr)) then
                    return nil;
                end
                return ffi.cast('CInventoryList*', self.list_);
            end,
            [switch.default] = function ()
                error(('struct \'CInventoryContainer\' has no member: %s'):fmt(k));
            end,
        });
    end,
    __newindex = function (_, k, _)
        error(('struct \'CInventoryContainer\' has no member: %s'):fmt(k));
    end,
});

ffi.metatype('CInventoryList', T{
    __index = function (self, k)
        return switch(k, T{
            -- Properties
            ['file'] = function ()
                return ffi.cast('TBufferedRamFile*', self.file_);
            end,
            ['object_manager'] = function ()
                return ffi.cast('CObjectManager*', self.object_manager_);
            end,
            [switch.default] = function ()
                error(('struct \'CInventoryList\' has no member: %s'):fmt(k));
            end,
        });
    end,
    __newindex = function (_, k, _)
        error(('struct \'CInventoryList\' has no member: %s'):fmt(k));
    end,
});

--[[
*
* Helper Functions
*
--]]

game = game or T{};

game.get_inventory_manager = function ()
    local ptr = hook.memory.read_uint32(game.ptrs.inventory_manager);
    if (ptr == 0) then return nil; end
    return ffi.cast('CInventoryManager*', hook.memory.read_uint32(ptr));
end