package("nativefiledialog")

    set_homepage("https://github.com/mlabbe/nativefiledialog")
    set_description("A tiny, neat C library that portably invokes native file open and save dialogs.")
    set_license("zlib")

    add_urls("https://github.com/mlabbe/nativefiledialog/archive/refs/tags/release_$(version).tar.gz", {version = function (version) return version:gsub("%.", "") end})
    add_urls("https://github.com/mlabbe/nativefiledialog.git")
    add_versions("1.1.6", "1bbaed79b9c499c8d2a54f40f89277e721c0894bf3048bb247d826b96db6bc08")

    if is_plat("windows") then
        add_syslinks("shell32", "ole32")
    elseif is_plat("macosx") then
        add_frameworks("AppKit")
    end
    on_install("windows", "macosx", "linux", function (package)
        os.cd("src")
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("nfd")
                set_kind("static")
                set_values("objc.build.arc", false)
                add_includedirs("include")
                add_files("nfd_common.c")
                if is_plat("windows") then
                    add_defines("_CRT_SECURE_NO_WARNINGS")
                    add_files("nfd_win.cpp")
                elseif is_plat("macosx") then
                    add_files("nfd_cocoa.m")
                elseif is_plat("linux") then
                    add_files("nfd_zenity.c")
                end
                add_headerfiles("include/nfd.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                nfdchar_t *outPath = NULL;
                nfdresult_t result = NFD_OpenDialog( NULL, NULL, &outPath );
            }
        ]]}, {includes = "nfd.h"}))
    end)
