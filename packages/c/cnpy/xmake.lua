package("cnpy")

    set_homepage("https://github.com/rogersce/cnpy")
    set_description("library to read/write .npy and .npz files in C/C++")
    set_license("MIT")

    add_urls("https://github.com/rogersce/cnpy.git")
    add_versions("2018.06.01", "4e8810b1a8637695171ed346ce68f6984e585ef4")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("zlib")
    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++11")
            add_requires("zlib")
            target("cnpy")
                set_kind("static")
                add_files("cnpy.cpp")
                add_headerfiles("cnpy.h")
                add_packages("zlib")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                double myVar1 = 1.2;
                char myVar2 = 'a';
                cnpy::npz_save("out.npz","myVar1",&myVar1,{1},"w");
                cnpy::npz_save("out.npz","myVar2",&myVar2,{1},"a");
            }
        ]]}, {configs = {languages = "c++11"}, includes = "cnpy.h"}))
    end)
