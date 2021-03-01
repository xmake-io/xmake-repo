package("nana")

    set_homepage("http://nanapro.org")
    set_description("A modern C++ GUI library.")

    add_urls("https://github.com/cnjinhao/nana/archive/v$(version).tar.gz",
             "https://github.com/cnjinhao/nana.git")
    add_versions("1.6.2", "5f5cb791dff292e27bfa29d850b93f809a0d91d6044ea7e22ce7ae76a5d8b24e")
    add_versions("1.7.2", "e2efb3b7619e4ef3b6de93f8afc70ff477ec6cabf4f9740f0d786904c790613f")
    add_versions("1.7.4", "56f7b1ed006c750fccf8ef15ab1e83f96751f2dfdcb68d93e5f712a6c9b58bcb")
    add_patches("1.7.4", path.join(os.scriptdir(), "patches", "1.7.4", "cmake_policy_fix.patch"), "237a60d12eb2760c1010043686b1938b03e18791003d8ddfc639f458f0c7467d")
    if is_plat("linux") then
        add_patches("1.7.4", path.join(os.scriptdir(), "patches", "1.7.4", "u8string_fix.patch"), "c783588816664124ba3b4077e18696899c8389419a015773b5bfe988e3a73f6a")
    end

    add_configs("nana_filesystem_force", {description = "Force nana filesystem over ISO and boost?", default = is_plat("linux"), type = "boolean"})

    if is_plat("linux", "windows") then
        add_deps("cmake >=3.15")
    end

    if is_plat("windows") then
        add_syslinks("ole32", "shell32", "kernel32", "user32", "gdi32", "winspool", "comdlg32", "advapi32")
        add_defines("_SILENCE_EXPERIMENTAL_FILESYSTEM_DEPRECATION_WARNING")
    elseif is_plat("linux") then
        add_deps("libxcursor", "libxft", "fontconfig")
        add_syslinks("pthread")
    end

    on_load("linux", "windows", function (package)
        if package:config("nana_filesystem_force") then
            package:add("defines", "NANA_FILESYSTEM_FORCE")
        end
    end)

    on_install("linux", "windows", function (package)
        -- The 'and' operator, which is an equivalent of '&&', is not supported by MSVC
        if package:is_plat("windows") then
            local file_name = path.join(os.curdir(), "source", "system", "split_string.cpp")
            io.gsub(file_name, " and ", " && ")
        end

        local configs = {"-DNANA_CMAKE_ENABLE_JPEG=OFF", "-DNANA_CMAKE_ENABLE_PNG=OFF", "-DBUILD_SHARED_LIBS=OFF"}
        if package:config("nana_filesystem_force") then
            table.insert(configs, "-DNANA_CMAKE_NANA_FILESYSTEM_FORCE=ON")
        end
        import("package.tools.cmake").build(package, configs, {buildir = "build_xmake"})

        os.cp("include", package:installdir())
        if package:is_plat("windows") then
            os.trycp(path.join("build_xmake", "*", "*.lib"), package:installdir("lib"))
        else
            os.trycp(path.join("build_xmake", "*.a"), package:installdir("lib"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <nana/gui.hpp>
            #include <nana/gui/widgets/form.hpp>
            #include <nana/gui/widgets/label.hpp>
            using namespace nana;
            void test() {
                form    fm;
                label   lb(fm, rectangle(fm.size()));
                lb.caption("Hello, World");
                fm.show();
                exec();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
