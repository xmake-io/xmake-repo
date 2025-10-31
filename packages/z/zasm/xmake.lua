package("zasm")
    set_homepage("https://github.com/zyantific/zasm")
    set_description("x86-64 Assembler based on Zydis")

    set_urls("https://github.com/zyantific/zasm.git")

    add_versions("2025.03.02", "c239a78b51c1b0060296193174d78b802f02a618")
    add_versions("2024.05.14", "bea8af2c68f0cbe8a02e93ab79a8b5c596d2b232")
    add_versions("2023.06.21", "19a642518eccbb1740865642eaf3ce79d5d5b884")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    on_load(function (package)
        local map = {
            ["2025.03.02"] = "4.1.0",
            ["2024.05.14"] = "4.1.0",
            ["2023.06.21"] = "4.0.0",
        }
        local zydis_version = map[package:version()]
        if zydis_version then
            package:add("deps", "zydis " .. zydis_version)
        else
            package:add("deps", "zydis")
        end
    end)

    on_install("!wasm and !iphoneos", function (package)
        local old_layout = false
        local commit = package:commit()
        if commit then
            local git = import("lib.detect.find_tool")("git")
            local result = os.iorunv(git.program, {"rev-list", "bea8af2c68f0cbe8a02e93ab79a8b5c596d2b232" .. ".." .. commit, "--count"}):trim()
            if result == "0" then
                old_layout = true
            end
        else
            old_layout = (package:version() and package:version():lt("2024.05.14"))
        end

        local src_include
        if old_layout then
            src_include = [[
                add_files("src/zasm/**.cpp")
                add_includedirs("include", "src/zasm/src")
                add_headerfiles("include/(**.hpp)")
            ]]
        else
            src_include = [[
                add_files("zasm/**.cpp")
                add_includedirs("zasm/include")
                add_headerfiles("zasm/include/(**.hpp)")
            ]]
        end

        io.writefile("xmake.lua", format([[
            add_rules("mode.debug", "mode.release")
            add_requires("zydis")
            target("zasm")
                set_kind("$(kind)")
                set_languages("c++17")
                %s
                if is_plat("windows") then
                    add_cxxflags("/bigobj", "/MP", "/W3", "/permissive-")
                    if is_kind("shared") then
                        add_rules("utils.symbols.export_all", {export_classes = true})
                    end
                end
                add_packages("zydis")
        ]], src_include))
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <zasm/serialization/serializer.hpp>
            #include <zasm/zasm.hpp>
            using namespace zasm;
            void test() {
                Program program(MachineMode::AMD64);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
