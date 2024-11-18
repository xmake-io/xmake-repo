package("alembic")

    set_homepage("https://alembic.io/")
    set_description("Open framework for storing and sharing scene data that includes a C++ library, a file format, and client plugins and applications.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/alembic/alembic/archive/refs/tags/$(version).tar.gz",
             "https://github.com/alembic/alembic.git")
    add_versions("1.8.7", "6de0b97cd14dcfb7b2d0d788c951b6da3c5b336c47322ea881d64f18575c33da")
    add_versions("1.8.6", "c572ebdea3a5f0ce13774dd1fceb5b5815265cd1b29d142cf8c144b03c131c8c")
    add_versions("1.8.5", "180a12f08d391cd89f021f279dbe3b5423b1db751a9898540c8059a45825c2e9")

    add_deps("cmake", "imath")
    if is_plat("linux") then
        add_syslinks("m")
    end
    on_load("windows", function (package)
        if package:config("shared") then
            package:add("defines", "ALEMBIC_DLL")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DALEMBIC_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <Alembic/Abc/All.h>
            void test() {
                Alembic::Abc::OArchive archive;
                Alembic::Abc::OObject object = archive.getTop();
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
