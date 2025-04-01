package("khaledhosny-ots")
    set_homepage("https://github.com/khaledhosny/ots")
    set_description("Sanitizer for OpenType")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/khaledhosny/ots/archive/refs/tags/$(version).tar.gz",
             "https://github.com/khaledhosny/ots.git")

    add_versions("v9.2.0", "c2b786a334d79a7841549c4f10a49cb62389431fd38d63aeeb98a0bcdb50ad11")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    add_configs("colr_check", {description = "Reject fonts with cycles in COLRv1 paint graph", default = true, type = "boolean"})
    add_configs("graphite", {description = "Sanitize Graphite tables", default = true, type = "boolean"})
    add_configs("synthesize_gvar", {description = "Synthesize an empty gvar if fvar is present", default = true, type = "boolean"})

    add_deps("meson", "ninja")

    if is_plat("windows") then
        add_syslinks("gdi32")
    elseif is_plat("macosx") then
        add_frameworks("ApplicationServices")
    end

    add_deps("freetype", {configs = {woff2 = false, png = false, zlib = false, bzip2 = false}})
    add_deps("zlib")
    add_deps("woff2", {configs = {shared = false}})

    on_load(function (package)
        if package:config("graphite") then
            package:add("deps", "lz4")
        end
    end)

    on_install("!iphoneos and !mingw and !android", function (package)
        io.replace("src/ots.h", "#ifdef HAVE_CONFIG_H", "#if 1", {plain = true})
        os.cp("include", package:installdir())
        os.cp("src/*.h", package:installdir("include"))
        io.replace("meson.build", "subdir('tests')", "", {plain = true})
        io.replace("meson.build", "ots_sanitize = executable('ots-sanitize',", [[
if false
ots_sanitize = executable('ots-sanitize',
]], {plain = true})

        io.replace("meson.build", "test('cff_charstring', cff_charstring)", [[
test('cff_charstring', cff_charstring)
endif
]], {plain = true})

        io.replace("meson.build", "foreach file_name : bad_fonts", [[
if false
foreach file_name : bad_fonts
]], {plain = true})

        io.replace("meson.build", "foreach file_name : fuzzing_fonts", [[
if false
foreach file_name : fuzzing_fonts
]], {plain = true})

        io.replace("meson.build", [[
  )
endforeach
]], [[
  )
endforeach
endif
]], {plain = true})

        io.replace("meson.build", "dependencies: ots_deps,", [[
dependencies: ots_deps, install: true
]], {plain = true})
        io.replace("meson.build", "configuration: conf", "configuration: conf, install: true, install_dir: 'include'", {plain = true})
        local configs = {}
        table.insert(configs, "-Dcolr-cycle-check=" .. (package:config("colr_check") and "true" or "false"))
        table.insert(configs, "-Dgraphite=" .. (package:config("graphite") and "true" or "false"))
        table.insert(configs, "-Dsynthesize-gvar=" .. (package:config("synthesize_gvar") and "true" or "false"))
        table.insert(configs, "-Ddebug=" .. (package:debug() and "true" or "false"))
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vector>
            #include "cff_charstring.h"
            #include "opentype-sanitiser.h"
            void test() {
                std::vector<uint8_t> buffer;
                ots::CFFIndex global_subrs_index;
                ots::Buffer ots_buffer(&buffer[0], buffer.size());
                ots::FontFile* file = new ots::FontFile();
                file->context = new ots::OTSContext();
                ots::Font* font = new ots::Font(file);
                ots::OpenTypeCFF* cff = new ots::OpenTypeCFF(font, OTS_TAG_CFF);
                ots::CFFIndex* char_strings_index = new ots::CFFIndex;
                cff->charstrings_index = char_strings_index;
                ots::CFFIndex* local_subrs_index = new ots::CFFIndex;
                cff->local_subrs = local_subrs_index;
                bool ret = ots::ValidateCFFCharStrings(*cff, global_subrs_index, &ots_buffer);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
