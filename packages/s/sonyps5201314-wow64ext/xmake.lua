package("sonyps5201314-wow64ext")
    set_homepage("https://github.com/sonyps5201314/wow64ext")
    set_description("Custom build for ARM support. Helper library for x86 programs that runs under WOW64 layer on x64 versions of Microsoft Windows operating systems.")
    set_license("LGPL-3.0-or-later")

    add_urls("https://github.com/sonyps5201314/wow64ext.git", {alias = "git"})
    
    add_versions("git:2026.01.01", "e51083dd7b60c68a103791d3d258547022d55ac8")

    on_install("windows", "mingw", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")

            target("rewolf-wow64ext")
                set_kind("$(kind)")
                set_languages("c++11")

                add_files("wow64ext/*.cpp")

                add_includedirs("wow64ext")
                add_headerfiles("wow64ext/(*.h)")
                set_pcxxheader("wow64ext/pch.h")

                if is_plat("mingw") then
                    add_shflags("-mwindows")
                    add_asflags("-masm=intel")
                elseif is_plat("windows") then
                    add_shflags("/subsystem:windows")
                end
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
