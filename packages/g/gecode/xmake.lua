package("gecode")
    set_homepage("https://www.gecode.dev")
    set_description("Generic Constraint Development Environment")

    add_urls("https://github.com/Gecode/gecode/archive/refs/tags/release-$(version).tar.gz",
             "https://github.com/Gecode/gecode.git")

    add_versions("6.4.0", "4cc0e4f440f821a643e637801094cd42ccb5946caf5248c905f29f5f3a16f260")

    add_deps("cmake")

    add_configs("thread", {description = "Enable thread support", type = "boolean", default = true})
    add_configs("cpprofiler", {description = "Enable CPProfiler support", type = "boolean", default = true})
    add_configs("cbs", {description = "Enable counting-based search support", type = "boolean", default = false})
    add_configs("search", {description = "Build search module", type = "boolean", default = true})
    add_configs("int_vars", {description = "Build int variables module", type = "boolean", default = true})
    add_configs("set_vars", {description = "Build set variables module", type = "boolean", default = true})
    add_configs("float_vars", {description = "Build float variables module", type = "boolean", default = true})
    add_configs("minimodel", {description = "Build minimodel module", type = "boolean", default = true})
    add_configs("driver", {description = "Build driver module", type = "boolean", default = true})
    add_configs("flatzinc", {description = "Build FlatZinc module", type = "boolean", default = true})
    add_configs("mpfr", {description = "Enable MPFR support", type = "boolean", default = is_plat("linux")})
    add_configs("allocator", {description = "Enable default allocator", type = "boolean", default = true})
    add_configs("audit", {description = "Enable audit code", type = "boolean", default = false})
    add_configs("fault_injection", {description = "Enable deterministic test-only failpoints", type = "boolean", default = false})
    add_configs("gcc_visibility", {description = "Enable GCC visibility attributes", type = "boolean", default = true})
    add_configs("osx_unfair_mutex", {description = "Enable macOS unfair mutexes", type = "boolean", default = true})

    on_load(function(package)
        if package:config("mpfr") then
            package:add("deps", "mpfr")
        end
        package:add("linkorders", "gecodekernel", "gecodesupport")
        package:add("linkorders", "gecodedriver", "gecodekernel")
        package:add("linkorders", "gecodedriver", "gecodesupport")
        package:add("linkorders", "gecodeint", "gecodesupport")
        package:add("linkorders", "gecodeset", "gecodesupport")
        package:add("linkorders", "gecodeflatzinc", "gecodeset")
        package:add("linkorders", "gecodeflatzinc", "gecodesupport")
    end)

    on_install("linux", "windows|!arm*", "cross", "android", function (package)
        local configs = {}
        table.insert(configs, "-DGECODE_INSTALL=ON")
        table.insert(configs, "-DGECODE_ENABLE_EXAMPLES=OFF")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_CXX_FLAGS=/bigobj")
        end

        for name, enabled in table.orderpairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "-DGECODE_ENABLE_" .. string.upper(name) .. "=" .. (enabled and "ON" or "OFF"))
            end
        end

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <gecode/driver.hh>

            using namespace Gecode;

            void test(int argc, char* argv[]){
              SizeOptions opt("Test");
              opt.size(0);
              opt.parse(argc, argv);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
