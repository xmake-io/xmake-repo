package("symengine")
    set_homepage("https://symengine.org")
    set_description("SymEngine is a fast symbolic manipulation library, written in C++")
    set_license("MIT")

    add_urls("https://github.com/symengine/symengine/archive/refs/tags/$(version).tar.gz",
             "https://github.com/symengine/symengine.git")

    add_versions("v0.14.0", "11c5f64e9eec998152437f288b8429ec001168277d55f3f5f1df78e3cf129707")
    add_versions("v0.13.0", "f46bcf037529cd1a422369327bf360ad4c7d2b02d0f607a62a5b09c74a55bb59")
    add_versions("v0.12.0", "1b5c3b0bc6a9f187635f93585649f24a18e9c7f2167cebcd885edeaaf211d956")
    add_versions("v0.11.2", "f6972acd6a65354f6414e69460d2e175729470632bdac05919bc2f7f32e48cbd")

    add_configs("integer_class", {description = "Integer class for symengine. Either gmp, gmpxx, flint or piranha", default = "boost", type = "string", values = {"boost", "gmp"}})
    add_configs("teuchos", {description = "Build with teuchos", default = false, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("m")
    end

    add_deps("cmake")

    on_load(function (package)
        local integer_class = package:config("integer_class")
        if is_subhost("windows") and integer_class == "gmp" then
            raise("Unsupported integer_class(gmp) config on windows subhost")
        end

        local opt = {configs = {}}
        if integer_class == "boost" then
            opt.configs.cmake = false
            opt.configs.serialization = true
            opt.configs.iostreams = true
        end
        package:add("deps", integer_class, opt)
    end)

    on_install("windows", "linux", "macosx", "bsd", "mingw", "cross", function (package)
        local configs = {"-DBUILD_TESTS=OFF", "-DBUILD_BENCHMARKS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_SYMENGINE_TEUCHOS=" .. (package:config("teuchos") and "ON" or "OFF"))
        if package:config("integer_class") == "boost" then
            table.insert(configs, "-DINTEGER_CLASS=boostmp")
        else
            table.insert(configs, "-DINTEGER_CLASS=gmp")
        end
        if package:is_plat("windows") then
            table.insert(configs, "-DMSVC_USE_MT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)

        if os.isfile(package:installdir("lib/libteuchos.a")) then
            package:add("links", "symengine", "teuchos")
        end
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
