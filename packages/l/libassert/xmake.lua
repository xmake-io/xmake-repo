package("libassert")
    set_homepage("https://github.com/jeremy-rifkin/libassert")
    set_description("The most over-engineered and overpowered C++ assertion library.")
    set_license("MIT")

    add_urls("https://github.com/jeremy-rifkin/libassert/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jeremy-rifkin/libassert.git")

    add_versions("v1.2", "332F96181F4BDBD95EF5FCD6484782BA2D89B50FD5189BC2A33FD524962F6771")

    add_configs("decompose", {description = "Enables expression decomposition of && and || (this prevents short circuiting)", default = false, type = "boolean"})
    add_configs("lowercase", {description = "Enables assert alias for ASSERT", default = false, type = "boolean"})
    add_configs("magic_enum", {description = "Use the MagicEnum library to print better diagnostics for enum classes", default = true, type = "boolean"})

    add_deps("cpptrace")

    on_load(function (package)
        if package:config("magic_enum") then
            package:add("deps", "magic_enum")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_requires("cpptrace")
            if has_config("decompose") then
                add_defines("ASSERT_DECOMPOSE_BINARY_LOGICAL")
            end
            if has_config("lowercase") then
                add_defines("ASSERT_LOWERCASE")
            end
            if has_config("magic_enum") then
                add_requires("magic_enum")
                add_packages("magic_enum")
                add_defines("ASSERT_USE_MAGIC_ENUM")
            end
            add_rules("mode.debug", "mode.release")
            target("assert")
                set_kind("$(kind)")
                add_files("src/*.cpp")
                add_includedirs("include")
                add_headerfiles("include/*.hpp")
                set_languages("c++17")
                add_packages("cpptrace")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        if package:config("decompose") then
            package:add("defines", "ASSERT_DECOMPOSE_BINARY_LOGICAL")
        end
        if package:config("lowercase") then
            package:add("defines", "ASSERT_LOWERCASE")
        end
        if package:config("magic_enum") then
            package:add("defines", "ASSERT_USE_MAGIC_ENUM")
            io.replace("include/assert.hpp", "../third_party/magic_enum.hpp", "magic_enum.hpp", {plain = true})
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        local opt = {configs = {languages = "c++17"}}
        if package:config("lowercase") then
            assert(package:check_cxxsnippets({test = [[
                #include <assert.hpp>
                void test() {
                    int x = 0;
                    assert(x != 1, "", x);
                }
            ]]}, opt))
        else
            assert(package:check_cxxsnippets({test = [[
                #include <assert.hpp>
                void test() {
                    int x = 0;
                    ASSERT(x != 1, "", x);
                }
            ]]}, opt))
        end
    end)
