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

    typedef struct CConfigLcl
    {
        const char*     game_path_;             // Handled via metatype!
        const char*     game_exe_name_;         // Handled via metatype!
        const char*     game_exe_path_;         // Handled via metatype!
        const char*     str_sav_;               // Handled via metatype!
        uint8_t         unknown0010;
        uint8_t         unknown0011;
        uint8_t         unknown0012;
        uint8_t         unknown0013;
        const char*     str_mapgen_divinity_;   // Handled via metatype!
        const char*     str_mapgen_trans_;      // Handled via metatype!
        void*           record000;
        const char*     str_record000_;         // Handled via metatype!
        uint32_t        rgb_mode;
        uint32_t        debug_mode;
        uint32_t        is_seeing_validation;
        uint32_t        sound_play_voices;
        uint32_t        should_map_fix;
        uint32_t        display_width;
        uint32_t        display_height;
        uint32_t        smoothness_value;
        uint32_t        unknown0044;
        uint32_t        unknown0048;
        uint32_t        unknown004C;
        uint32_t        unknown0050;
        uint32_t        unknown0054;
        uint32_t        unknown0058;
        uint32_t        unknown005C;
        uint32_t        update_speed;
        uint32_t        strong_debug;
        uint32_t        memory_limit;
        uint32_t        direct_move;
        uint32_t        direct_input;
        uint32_t        smoothness;
        uint32_t        explain_verbose;
        uint32_t        role;
        const char*     str_anybody_;           // Handled via metatype!
        uint32_t        use_xslash_module;
        uint32_t        ztunnel;
        uint32_t        use_rttm_library;
        uint32_t        monster_generation;
        float           contrast;
        float           gamma;
        uint32_t        exhibition;
        uint32_t        no_decompress;
        uint32_t        no_fog;
        uint32_t        no_warning;
        uint32_t        egg_editing;
        uint32_t        merge_maps;
        uint32_t        merge_eggs;
        uint32_t        images_compressed;
        uint32_t        compile_start;          // WARNING: DO NOT EDIT THIS YOU WILL CORRUPT YOUR GAME FILES!
        uint32_t        flat_files;
        uint32_t        should_write_memory_log_startup;
        uint32_t        should_track_memory;
        uint32_t        startup_logo;
        uint32_t        resolution_switch;
        uint32_t        generate_monster_regions;
        uint32_t        fog_speed;
        uint32_t        merge_inventories;
        uint32_t        unknown00E0;
        uint32_t        startthrough;
        uint8_t         voice_comments;
        uint8_t         padding00E9[3];
        uint32_t        force_mac_id;
        uint32_t        compress_reports;
        uint32_t        alpha_bit;
        uint32_t        queue_sounds;
        uint32_t        patching;
        uint32_t        roofs;
        uint32_t        use_unpacked_roofs;
        uint32_t        skip_render_hero;
        uint32_t        splotch_problem;
        uint32_t        max_quicksave_amount;
        uint32_t        unknown0114;
        const char*     quickstart_;            // Handled via metatype!
        const char*     quicksave_;             // Handled via metatype!
        uint8_t         use_8bit_font;
        uint8_t         unknown0121[3];
        uint32_t        language;
        const char*     str_language2_;         // Handled via metatype!
        const char*     str_language_;          // Handled via metatype!
        uint8_t         is_unicode;
        uint8_t         unknown0131;
        uint8_t         padding0132[2];
        uint32_t        use_female_monologues;
        uint32_t        unknown0138;
        uint8_t         unknown013C;
        uint8_t         unknown013D;
        uint8_t         unknown013E;
        uint8_t         unknown013F;
        uint32_t        unknown0140;
        uint32_t        unknown0144;
        uint32_t        unknown0148;
        uint32_t        unknown014C;
        uint32_t        unknown0150;

        uint32_t        unknown0154;
        uint32_t        unknown0158;
        uint32_t        unknown015C;
        uint32_t        unknown0160;
        uint32_t        unknown0164;
        uint32_t        unknown0168;
        uint32_t        unknown016C;
        uint32_t        unknown0170;
    } CConfigLcl;

]];

local string_members = T{
    'game_path',
    'game_exe_name',
    'game_exe_path',
    'str_sav',
    'str_mapgen_divinity',
    'str_mapgen_trans',
    'str_record000',
    'str_anybody',
    'quickstart',
    'quicksave',
    'str_language2',
    'str_language',
};

ffi.metatype('CConfigLcl', T{
    __index = function (self, k)
        return switch(k, T{
            -- Properties
            [string_members] = function ()
                return game.safe_read_string(self[k .. '_'], '');
            end,
            [switch.default] = function ()
                error(('struct \'CConfigLcl\' has no member: %s'):fmt(k));
            end,
        });
    end,
    __newindex = function (_, k, _)
        error(('struct \'CConfigLcl\' has no member: %s'):fmt(k));
    end,
});

--[[
*
* Helper Functions
*
--]]

game = game or T{};

game.get_configlcl = function ()
    local ptr = hook.memory.read_uint32(game.ptrs.configlcl);
    if (ptr == 0) then return nil; end
    return ffi.cast('CConfigLcl*', hook.memory.read_uint32(ptr));
end