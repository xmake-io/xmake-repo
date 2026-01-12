package("sonyps5201314-wow64ext")
    set_homepage("https://github.com/sonyps5201314/wow64ext")
    set_description("Custom build for ARM support. Helper library for x86 programs that runs under WOW64 layer on x64 versions of Microsoft Windows operating systems.")
    set_license("LGPL-3.0-or-later")

    add_urls("https://github.com/sonyps5201314/wow64ext.git", {alias = "git"})

    add_versions("git:2026.01.01", "e51083dd7b60c68a103791d3d258547022d55ac8")
    add_resources("2026.01.01", "ntdll", "https://github.com/ladislav-zezula/Aaa.git", "3c8ff5d8648f569bfde536751981b0466942c222")

    on_install("windows", function (package)
        io.replace("wow64ext/wow64ext.h", [[#ifndef _WIN64]], [[]], {plain = true})
        io.replace("wow64ext/wow64ext.h", [[typedef XSAVE_FORMAT XMM_SAVE_AREA32, * PXMM_SAVE_AREA32;
#endif]], [[typedef XSAVE_FORMAT XMM_SAVE_AREA32, * PXMM_SAVE_AREA32;]], {plain = true})
        local ntdlldir = package:resourcefile("ntdll")
        os.cp(path.join(ntdlldir, "inc/ntdll.h"), "wow64ext/ntdll.h")
        if package:check_sizeof("void*") == "8" then
            os.cp(path.join(ntdlldir, "lib64/Ntdll.lib"), "wow64ext/ntdll.lib")
        else
            os.cp(path.join(ntdlldir, "lib32/Ntdll.lib"), "wow64ext/ntdll.lib")
        end
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")

            target("sonyps5201314-wow64ext")
                set_kind("$(kind)")
                set_languages("c++11")

                add_files("wow64ext/*.cpp")

                add_includedirs("wow64ext")
                add_linkdirs("wow64ext")
                add_links("ntdll")
                add_headerfiles("wow64ext/(*.h)")
                set_pcxxheader("wow64ext/pch.h")

                add_ldflags("/subsystem:windows")
                add_shflags("/subsystem:windows")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto handle = GetModuleHandle64(L"user32.dll");
            }
        ]]}, {configs = {languages = "c++11"}, includes = "wow64ext.h"}))
    end)
