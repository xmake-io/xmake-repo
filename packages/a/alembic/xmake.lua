package("alembic")
    set_homepage("https://alembic.io/")
    set_description("Open framework for storing and sharing scene data that includes a C++ library, a file format, and client plugins and applications.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/alembic/alembic/archive/refs/tags/$(version).tar.gz",
             "https://github.com/alembic/alembic.git")

    add_versions("1.8.10", "06c9172faf29e9fdebb7be99621ca18b32b474f8e481238a159c87d16b298553")
    add_versions("1.8.9", "8c59c10813feee917d262c71af77d6fa3db1acaf7c5fecfd4104167077403955")
    add_versions("1.8.8", "ba1f34544608ef7d3f68cafea946ec9cc84792ddf9cda3e8d5590821df71f6c6")
    add_versions("1.8.7", "6de0b97cd14dcfb7b2d0d788c951b6da3c5b336c47322ea881d64f18575c33da")
    add_versions("1.8.6", "c572ebdea3a5f0ce13774dd1fceb5b5815265cd1b29d142cf8c144b03c131c8c")
    add_versions("1.8.5", "180a12f08d391cd89f021f279dbe3b5423b1db751a9898540c8059a45825c2e9")

    add_configs("arnold", {description = "Include Arnold stuff", default = false, type = "boolean"})
    add_configs("hdf5", {description = "Include HDF5 stuff", default = false, type = "boolean"})
    add_configs("maya", {description = "Include maya stuff", default = false, type = "boolean"})
    add_configs("prman", {description = "Include prman stuff", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    end

    add_deps("cmake", "imath")

    on_load(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "ALEMBIC_DLL")
        end

        if package:config("tools") then
            package:config_set("hdf5", true)
        end

        if package:config("hdf5") then
            package:add("deps", "hdf5", {configs = {zlib = true}})
        end
    end)

    on_install(function (package)
        if package:is_plat("windows", "mingw") then
            io.replace("lib/Alembic/Ogawa/OStream.cpp", "#include <stdexcept>", "#include <stdexcept>\n#include <Windows.h>", {plain = true})
        end

        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DUSE_TESTS=OFF",
            "-DALEMBIC_DEBUG_WARNINGS_AS_ERRORS=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DALEMBIC_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
        end

        table.insert(configs, "-DUSE_ARNOLD=" .. (package:config("arnold") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_MAYA=" .. (package:config("maya") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_PRMAN=" .. (package:config("prman") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_BINARIES=" .. (package:config("tools") and "ON" or "OFF"))

        local hdf5 = package:dep("hdf5")
        if hdf5 then
            table.insert(configs, "-DUSE_HDF5=ON")
            table.insert(configs, "-DUSE_STATIC_HDF5=" .. (hdf5:config("shared") and "OFF" or "ON"))
        else
            table.insert(configs, "-DUSE_HDF5=OFF")
        end
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.vcp(path.join(package:buildir(), "lib/**.pdb"), dir)
            os.vcp(path.join(package:buildir(), "bin/**.pdb"), package:installdir("bin"))
        end
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
