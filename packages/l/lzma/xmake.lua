package("lzma")

    set_homepage("https://www.7-zip.org/sdk.html")
    set_description("LZMA SDK")

    add_urls("https://www.7-zip.org/a/lzma$(version).7z", {version = function (version) return version:gsub("%.", "") end})
    add_versions("21.07", "833888f03c6628c8a062ce5844bb8012056e7ab7ba294c7ea232e20ddadf0d75")
    add_versions("22.01", "35b1689169efbc7c3c147387e5495130f371b4bad8ec24f049d28e126d52d9fe")
    add_versions("23.01", "317dd834d6bbfd95433488b832e823cd3d4d420101436422c03af88507dd1370")
    add_versions("24.09", "79b39f10b7b69eea293caa90c3e7ea07faf8f01f8ae9db1bb1b90c092375e5f3")

    add_links("lzma")
    if is_plat("bsd") then
        add_syslinks("pthread")
    end
    on_install(function (package) 
        os.cd("C")
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("lzma")
                set_kind("$(kind)")
                add_files("*.c")
                add_headerfiles("*.h")
                if is_plat("windows") then
                    add_files("Util/LzmaLib/LzmaLib.def")
                end
        ]])
        local flags = ""
        if not package:is_plat("windows") and package:is_arch("arm.*") then
            flags = "-march=armv8-a+crc+crypto"
        end
        import("package.tools.xmake").install(package, {
            cxflags = flags,
            kind = package:config("shared") and "shared" or "static"
        })
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                // we only test links...
                LzmaCompress(
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                );
            }
        ]]}, {configs = {languages = "c99"}, includes = "LzmaLib.h"}))
    end)
