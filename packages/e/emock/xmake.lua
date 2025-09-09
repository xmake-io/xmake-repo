package("emock")
    set_homepage("https://github.com/ez8-co/emock")
    set_description("Next generation cross-platform mock library for C/C++")
    set_license("Apache-2.0")

    add_urls("https://github.com/ez8-co/emock/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ez8-co/emock.git")

    add_versions("v0.9.0", "376b3584e95642b10947da8244c9b592f62ac267c23949d875a0d5ffe5d32cf5")

    add_patches("v0.9.0", "patches/v0.9.0/support_multiplat_and_fix_install.diff", "18af7bccff9849958cfc90f3210bfa73259ad2ebf462c41515ccce4478dbdb98")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    add_configs("namespace", {description = "Build with the `emock::` namespace.", default = true, type = "boolean"})
    add_configs("test_framework", {description = "Choose the unit test framework for failure reporting", default = "STDEXCEPT", type = "string", values = {"STDEXCEPT", "gtest", "cpputest", "cppunit"}})

    if is_plat("mingw", "windows") then
        add_syslinks("dbghelp")
    end

    add_deps("cmake")

    on_load(function (package)
        local test_framework = package:config("test_framework")
        if test_framework == "gtest" then
            package:add("deps", "gtest")
        elseif test_framework == "cpputest" then
            package:add("deps", "cpputest")
        elseif test_framework == "cppunit" then
            package:add("deps", "cppunit")
        end
    end)

    on_install("!iphoneos", function (package)
        io.replace("src/CMakeLists.txt", "-fPIC", "", {plain = true})
        io.replace("src/CMakeLists.txt", "IF(MSVC OR MINGW)\nINSTALL", "if(0)\nINSTALL", {plain = true})

        -- gtest require c++17
        local configs = {"-DCMAKE_CXX_STANDARD=17"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DEMOCK_NO_NAMESPACE=" .. (package:config("namespace") and "OFF" or "ON"))

        local test_framework = package:config("test_framework")
        table.insert(configs, "-DEMOCK_XUNIT=" .. test_framework)
        if test_framework ~= "STDEXCEPT" then
            local dir = package:dep(test_framework):installdir()
            table.insert(configs, "-DEMOCK_XUNIT_HOME=" .. dir)
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            int foobar(int x) {
                return x;
            }

            void test() {
                EMOCK(foobar)
                    .stubs()
                    .with(any())
                    .will(returnValue(1));
            }
        ]]}, {configs = {languages = "c++17"}, includes = "emock/emock.hpp"}))
    end)
