package("quickcpplib")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/ned14/quickcpplib")
    set_description("Eliminate all the tedious hassle when making state-of-the-art C++ 14 - 23 libraries!")
    set_license("Apache-2.0")

    add_urls("https://github.com/ned14/quickcpplib.git")
    add_versions("20221116", "52163d5a198f1d0a2583e683f090778686f9f998")

    add_configs("header_only", {description = "Use header only version. (not supported atm)", default = false, type = "boolean", readonly = true})

    add_deps("cmake")
    on_install(function (package)
        local configs = {"-DPROJECT_IS_DEPENDENCY=ON"}
        io.replace("CMakeLists.txt", "include(QuickCppLibMakeStandardTests)", "", {plain = true})
        io.replace("CMakeLists.txt", "include(QuickCppLibMakeDoxygen)", "", {plain = true})
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        local target = "quickcpplib_"
        if package:config("header_only") then
            target = target .. "hl" 
        else 
            target = target .. (package:config("shared") and "_dl" or "_sl")
        end
        import("package.tools.cmake").install(package, configs, { target = target })
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <quickcpplib/uint128.hpp>
            void test () {
                auto bar = QUICKCPPLIB_NAMESPACE::integers128::uint128{};
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)

