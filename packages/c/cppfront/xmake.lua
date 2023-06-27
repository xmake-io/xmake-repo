package("cppfront")
    set_kind("binary")
    set_homepage("https://github.com/hsutter/cppfront")
    set_description("A personal experimental C++ Syntax 2 -> Syntax 1 compiler")

    add_urls("https://github.com/hsutter/cppfront.git")
    add_versions("2022.09.23", "fa65d346996ec472e16c61838fbc7a47736d7872")

    on_install("windows", "linux", function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("cppfront")
               set_kind("binary")
               add_files("source/*.cpp")
               add_includedirs("include")
               set_languages("c++20")
        ]])
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        os.touch("test.cpp2")
        os.vrun("cppfront test.cpp2")
    end)
