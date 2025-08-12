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

    typedef struct CAlignmentRelations
    {
        int32_t                 value;
        int32_t                 id;
    } CAlignmentRelations;

    /**
     * The information that is stored within the CAlignmentCalculations::values array
     * is bit packed per-alignment entry. These values are calculated doing some bitwise
     * operations to allow for a large amount of data to be stoerd in a smaller space.
     *
     * The size of the values pointer buffer is calculated as follows:
     *
     *      val  = ((entries_index * entries_index) >> 5) + 1;
     *      size = val >> 30 != 0 ? -1 : 4 * val;
     *
     * When doing lookups, the game will make use of two CAlignmentEntry->index values
     * and the calculations size in the following manner:
     *
     *      idx = entry1->index + entry2->index * calc->size;
     *      val = (calc->values[idx >> 5] & (1 << (idx & 0x1F))) != 0;
     */

    typedef struct CAlignmentCalculations
    {
        uint32_t*               cvalues;            // Bit values used per-alignment.
        int32_t                 size;
        int32_t                 max;
    } CAlignmentCalculations;

    typedef struct CAlignment
    {
        // Note: This object base is: CHasRelationsObject
        uintptr_t               vtbl;
        int32_t                 relations_index;
        int32_t                 relations_max;
        CAlignmentRelations*    relations;

        int32_t                 entities_size;
        void*                   entities_;          // Handled via metatype!
        int32_t                 entities_max;
        const char*             class_name_;        // Handled via metatype!
        int32_t                 id;
        uint32_t                unknown0024;        // Unknown. [Relation or alignment default weight/value?]
    } CAlignment;

    typedef struct CAlignmentEntity
    {
        // Note: This object base is: CHasRelationsObject
        uintptr_t               vtbl;
        int32_t                 relations_index;
        int32_t                 relations_max;
        CAlignmentRelations*    relations;

        int32_t                 id;                 // Secondary index incremented with CAlignmentEntry::id.
        const char*             class_name_;        // Handled via metatype!
    } CAlignmentEntity;

    typedef struct CAlignmentEntry
    {
        int32_t                 index;
        int32_t                 id;                 // Secondary index incremented with CAlignmentEntity::id.
        const char*             class_name_;        // Handled via metatype!
        CAlignment*             alignment;
        CAlignmentEntity*       entity;
        int32_t                 class_name_size;
    } CAlignmentEntry;

    typedef struct CAlignmentManager
    {
        int32_t                 entries_index;
        int32_t                 entries_max;
        CAlignmentEntry**       entries;
        int32_t                 entries_id;         // The current id value.
        int32_t                 unknown0010[256];   // Array of starting entry indexes used when obtaining alignments by class name.
        CAlignment**            alignments;
        int32_t                 alignments_size;
        int32_t                 alignments_max;
        CAlignmentEntry*        editor_entry;       // Alignment entry used when in editor mode.
        CAlignment*             editor_alignment;   // Alignment used when in editor mode.
        CAlignmentCalculations* calculations;
    } CAlignmentManager;

]];

ffi.metatype('CAlignment', T{
    __index = function (self, k)
        return switch(k, T{
            -- Properties
            ['entities'] = function ()
                return ffi.cast('CAlignmentEntity**', self.entities_);
            end,
            ['class_name'] = function ()
                return game.safe_read_string(self.class_name_, '');
            end,
            [switch.default] = function ()
                error(('struct \'CAlignment\' has no member: %s'):fmt(k));
            end,
        });
    end,
    __newindex = function (_, k, _)
        error(('struct \'CAlignment\' has no member: %s'):fmt(k));
    end,
});

ffi.metatype('CAlignmentEntity', T{
    __index = function (self, k)
        return switch(k, T{
            -- Properties
            ['class_name'] = function ()
                return game.safe_read_string(self.class_name_, '');
            end,
            [switch.default] = function ()
                error(('struct \'CAlignmentEntity\' has no member: %s'):fmt(k));
            end,
        });
    end,
    __newindex = function (_, k, _)
        error(('struct \'CAlignmentEntity\' has no member: %s'):fmt(k));
    end,
});

ffi.metatype('CAlignmentEntry', T{
    __index = function (self, k)
        return switch(k, T{
            -- Properties
            ['class_name'] = function ()
                return game.safe_read_string(self.class_name_, '');
            end,
            [switch.default] = function ()
                error(('struct \'CAlignmentEntry\' has no member: %s'):fmt(k));
            end,
        });
    end,
    __newindex = function (_, k, _)
        error(('struct \'CAlignmentEntry\' has no member: %s'):fmt(k));
    end,
});

--[[
*
* Helper Functions
*
--]]

game = game or T{};

game.get_alignment_manager = function ()
    return ffi.cast('CAlignmentManager*', hook.memory.read_uint32(game.ptrs.alignment_manager));
end