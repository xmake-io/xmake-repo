package("libassert")
    set_homepage("https://github.com/jeremy-rifkin/libassert")
    set_description("The most over-engineered and overpowered C++ assertion library.")
    set_license("MIT")

    add_urls("https://github.com/jeremy-rifkin/libassert/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jeremy-rifkin/libassert.git")

    add_versions("v2.0.0", "d4b2da2179a94637b34d18813a814531a1eceb0ddc6dd6db6098050dd638f4a1")
    add_versions("v1.2.2", "68206b43bc4803357ba7d366574b4631bd327c46ab76ddef6ff9366784fa6b3c")
    add_versions("v1.2", "332f96181f4bdbd95ef5fcd6484782ba2d89b50fd5189bc2a33fd524962f6771")

    add_configs("decompose", {description = "Enables expression decomposition of && and || (this prevents short circuiting)", default = false, type = "boolean"})
    add_configs("lowercase", {description = "Enables assert alias for ASSERT", default = false, type = "boolean"})
    add_configs("magic_enum", {description = "Use the MagicEnum library to print better diagnostics for enum classes", default = true, type = "boolean"})

    on_load(function (package)
        if package:config("magic_enum") then
            package:add("deps", "magic_enum")
        end

        package:add("deps", "cpptrace " .. (package:version():lt("2.0.0") and "<=0.4.0" or ""))
    end)

    on_install("windows", "linux", "macosx", function (package)
        if package:version():lt("2.0.0") then
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

            local configs = {}
            configs.decompose = package:config("decompose")
            configs.lowercase = package:config("lowercase")
            configs.magic_enum = package:config("magic_enum")
            os.cp(path.join(package:scriptdir(), "port", "v1", "xmake.lua"), "xmake.lua")
            import("package.tools.xmake").install(package, configs)
        else
            local configs = {
                "-DLIBASSERT_USE_EXTERNAL_CPPTRACE=ON",
                "-DLIBASSERT_USE_MAGIC_ENUM=ON",
                "-DLIBASSERT_BUILD_TESTING=OFF",
                "-DLIBASSERT_SANITIZER_BUILD=OFF",
            }
            io.replace("CMakeLists.txt", "/WX", "", {plain = true})
            if not package:config("shared") then
                package:add("defines", "LIBASSERT_STATIC_DEFINE")
            end
            if package:config("magic_enum") then
                package:add("defines", "LIBASSERT_USE_MAGIC_ENUM")
            end

            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DLIBASSERT_USE_MAGIC_ENUM=" .. (package:config("magic_enum") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)
        end
    end)

    on_test(function (package)
        local includes = (package:version():lt("2.0.0") and "assert.hpp" or "libassert/assert.hpp")
        local opt = {configs = {languages = "c++17"}, includes = includes}
        if package:config("lowercase") then
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    int x = 0;
                    assert(x != 1, "", x);
                }
            ]]}, opt))
        else
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    int x = 0;
                    ASSERT(x != 1, "", x);
                }
            ]]}, opt))
        end
    end)
