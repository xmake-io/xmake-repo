package("libassert")
    set_homepage("https://github.com/jeremy-rifkin/libassert")
    set_description("The most over-engineered and overpowered C++ assertion library.")
    set_license("MIT")

    add_urls("https://github.com/jeremy-rifkin/libassert/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jeremy-rifkin/libassert.git")

    add_versions("v2.2.1", "a7882ff2922c6d57f955f5ea9418014619e0855e936eb92e5443914dd1a8f724")
    add_versions("v2.2.0", "c1f6fc06012ca70dc20c7cec80b998ff8f1d8001071fc280d4460850511a5984")
    add_versions("v2.1.5", "0812721d4bbc0193ef2509909b05bb0226d5718284ad9419d478e091ed2101de")
    add_versions("v2.1.4", "9fa5f5b69e24d020a72b706f05802bf0028587b93a43b59bc99b5bef305b0c72")
    add_versions("v2.1.2", "a7220ca354270deca08a7a162b93523c738ba3c8037a4df1a46ababfdc664196")
    add_versions("v2.1.1", "2bdf27523f964f41668d266cfdbd7f5f58988af963d976577195969ed44359d1")
    add_versions("v2.1.0", "e42405b49cde017c44c78aacac35c6e03564532838709031e73d10ab71f5363d")
    add_versions("v2.0.2", "4a0b52e6523bdde0116231a67583131ea1a84bb574076fad939fc13fc7490443")
    add_versions("v2.0.1", "405a44c14c5e40de5b81b01538ba12ef9d7c1f57e2c29f81b929e7e179847d4c")
    add_versions("v2.0.0", "d4b2da2179a94637b34d18813a814531a1eceb0ddc6dd6db6098050dd638f4a1")
    add_versions("v1.2.2", "68206b43bc4803357ba7d366574b4631bd327c46ab76ddef6ff9366784fa6b3c")
    add_versions("v1.2", "332f96181f4bdbd95ef5fcd6484782ba2d89b50fd5189bc2a33fd524962f6771")

    add_patches("v2.1.0", "https://github.com/jeremy-rifkin/libassert/commit/aff047da702316b10219a967f78da352f847b8d0.patch", "acdf2e1c7529774be581e7dbab3bbca828743bba8b8f9d6ac9dd4585b2245c58")

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
        if package:version() and package:version():lt("2.0.0") then
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
                "-DLIBASSERT_USE_EXTERNAL_MAGIC_ENUM=ON",
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
