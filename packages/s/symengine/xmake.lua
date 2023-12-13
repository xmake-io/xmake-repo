package("symengine")
    set_homepage("https://symengine.org")
    set_description("SymEngine is a fast symbolic manipulation library, written in C++")
    set_license("MIT")

    add_urls("https://github.com/symengine/symengine/archive/refs/tags/$(version).tar.gz",
             "https://github.com/symengine/symengine.git")

    add_versions("v0.11.2", "f6972acd6a65354f6414e69460d2e175729470632bdac05919bc2f7f32e48cbd")

    add_configs("integer_class", {description = "Integer class for symengine. Either gmp, gmpxx, flint or piranha", default = "boost", type = "string", values = {"boost", "gmp"}})

    if is_plat("linux") then
        add_syslinks("m")
    end

    add_deps("cmake")

    on_load(function (package)
        -- Unsupported gmp now
        if package:is_plat("windows") then
            package:config_set("integer_class", "boost")
        end
        package:add("deps", package:config("integer_class"))
    end)

    on_install("windows", "linux", "macosx", "bsd", "mingw", "cross", function (package)
        local configs = {"-DBUILD_TESTS=OFF", "-DBUILD_BENCHMARKS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("integer_class") == "boost" then
            table.insert(configs, "-DINTEGER_CLASS=boostmp")
        else
            table.insert(configs, "-DINTEGER_CLASS=gmp")
        end
        if package:is_plat("windows") then
            table.insert(configs, "-DMSVC_USE_MT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <symengine/expression.h>
            using SymEngine::Expression;
            void test() {
                Expression x("x");
                auto ex = pow(x+sqrt(Expression(2)), 6);
            }
        ]]}, {configs = {languages = "c++14"}}))
        assert(package:has_cfuncs("basic_new_stack", {includes = "symengine/cwrapper.h"}))
    end)
