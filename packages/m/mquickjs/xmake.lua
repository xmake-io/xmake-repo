package("mquickjs")
    set_homepage("https://github.com/bellard/mquickjs")
    set_description("Public repository of the Micro QuickJS Javascript Engine")

    add_urls("https://github.com/bellard/mquickjs.git")
    add_versions("2025.12.22", "17ce6fe54c1ea4f500f26636bd22058fce2ce61a")

    add_configs("cli", {description = "Build mqjs command line tool", default = false, type = "boolean"})

    if is_plat("linux", "macosx", "bsd") then
        add_syslinks("m")
    end

    on_install(function (package)
        io.replace("mquickjs.h", "#include <inttypes.h>", "#include <inttypes.h>\n#include <stddef.h>", {plain = true})
        io.replace("libm.c", "#define NDEBUG", "", {plain = true})

        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")

            option("cli", {default = false, description = "Enable cli command."})

            target("mqjs_stdlib_gen")
                set_kind("binary")
                set_plat(os.host())
                set_arch(os.arch())
                add_files("mqjs_stdlib.c", "mquickjs_build.c")
                add_defines("_GNU_SOURCE")
                set_policy("build.fence", true)

            target("mquickjs")
                set_kind("$(kind)")
                add_deps("mqjs_stdlib_gen")
                add_files("mquickjs.c", "libm.c", "dtoa.c", "cutils.c")
                add_headerfiles("mquickjs.h")
                add_defines("_GNU_SOURCE")
                if is_plat("linux", "macosx", "bsd") then
                    add_syslinks("m")
                end
                before_build(function (target)
                    local mqjs_stdlib_gen = target:dep("mqjs_stdlib_gen"):targetfile()
                    local flags = {}
                    if not target:is_arch64() then
                        table.insert(flags, "-m32")
                    end
                    os.vrunv(mqjs_stdlib_gen, table.join({"-a"}, flags), {stdout = "mquickjs_atom.h"})
                    os.vrunv(mqjs_stdlib_gen, flags, {stdout = "mqjs_stdlib.h"})
                end)

            if has_config("cli") then
                target("mqjs")
                    set_kind("binary")
                    add_files("mqjs.c", "readline.c")
                    if is_plat("linux", "macosx") then
                        add_files("readline_tty.c")
                    end
                    add_deps("mquickjs")
            end
        ]])
        local configs = {}
        if package:config("cli") then
            configs.cli = true
            package:add("bindirs", "bin")
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("JS_NewContext", {includes = "mquickjs.h"}))
        if package:config("cli") then
            os.vrun("mqjs -e \"var a = 1; console.log(a);\"")
        end
    end)
