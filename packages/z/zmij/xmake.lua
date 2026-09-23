package("zmij")
    set_homepage("https://github.com/vitaut/zmij")
    set_description("A fast floating-point-to-string conversion library for C and C++")
    set_license("MIT")

    add_urls("https://github.com/vitaut/zmij/archive/refs/tags/$(version).tar.gz",
             "https://github.com/vitaut/zmij.git")

    add_versions("v1.2", "13e11c9309fab358d5b6f656050e4f3efa1d20ecf15958ae9055382d07b0268f")
    add_versions("v1.1", "9d905fcc303e295aebd5ac06702e375264d22a5ed1219a9e52e5da06d2d34066")
    add_versions("v1.0", "cc0806afd47cf1ec2de99554030ce6b4cd69f76a8bc7e32adbe43434f22a7ee3")

    -- v1.0 passes a uint8x16_t to the signed vcgtzq_s8 NEON intrinsic; fixed in v1.1.
    add_patches("v1.0", path.join(os.scriptdir(), "patches", "v1.0", "fix-aarch64-neon.patch"), "aff0a30b4fd7edd511252ec3f8f3e070f334a74a3bd83370d0b3707863d77b9c")

    add_configs("simd", {description = "Use SIMD instructions.", default = true, type = "boolean"})

    on_install(function (package)
        local sources = {"zmij.cc"}
        local headers = {"zmij.h"}
        -- The C API (zmij.c + zmij-c.h) is only buildable from v1.1 on;
        -- the v1.0 zmij.c does not compile on its own.
        if os.isfile("zmij.c") and os.isfile("zmij-c.h") then
            table.insert(sources, "zmij.c")
            table.insert(headers, "zmij-c.h")
        end
        if os.isfile("zmij-to-chars.h") then
            table.insert(headers, "zmij-to-chars.h")
        end
        io.writefile("xmake.lua", string.format([[
            add_rules("mode.debug", "mode.release")
            target("zmij")
                set_kind("$(kind)")
                set_languages("c++14")
                add_files("%s")
                add_headerfiles("%s")
                %s
                if is_plat("windows", "mingw") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]], table.concat(sources, '", "'), table.concat(headers, '", "'),
            package:config("simd") and "" or 'add_defines("ZMIJ_USE_SIMD=0")'))
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                char buffer[zmij::double_buffer_size];
                zmij::write(buffer, sizeof(buffer), 5.0507837461e-27);
            }
        ]]}, {configs = {languages = "c++14"}, includes = "zmij.h"}))
    end)
package_end()
