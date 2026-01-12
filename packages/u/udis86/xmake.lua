package("udis86")
    set_homepage("http://udis86.sourceforge.net")
    set_description("Disassembler Library for x86 and x86-64")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/vmt/udis86.git")

    add_versions("2014.12.25", "56ff6c87c11de0ffa725b14339004820556e343d")

    add_patches("2014.12.25", "patches/2014.12.25/python3.patch", "984fd910f5270382df3e48dbb4bb05f4bd7a8aeb0e9d517333a845330bcd8950")
    add_patches("2014.12.25", "patches/2014.12.25/fix-macbuild.patch", "94813a80e7204872d5d8987bc6993528aefc89598dcaba9262e99dcd85b1ee68")

    add_configs("tools", {description = "Build the udcli executable tool", default = true, type = "boolean"})

    add_deps("python", {kind = "binary"})

    on_install(function (package)
        if package:config("tools") then
            package:addenv("PATH", "bin")
        end

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {tools = package:config("tools")})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ud_init", {includes = "udis86.h"}))
        if not package:is_cross() and package:config("tools") then
            os.vrun("udcli --version")
        end
    end)
