package("praxo-core-cpp")
    set_homepage("https://github.com/axisvela/praxo-core")
    set_description("C++20 agent runtime with policy, tools, streaming, and plugin hosts")
    set_license("MIT")

    add_urls("https://github.com/axisvela/praxo-core/archive/refs/tags/cpp/v$(version).tar.gz")
    add_versions("0.9.0", "1aa9b3a2ec53572efb1c5c6f70c10f8ecb851a3d7aaeec926d6638c1deb7ff20")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("cmake")
    add_links("praxo_cpp")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_install(function (package)
        os.cd("language/cpp")
        if package:version() and package:version():eq("0.9.0") then
            -- Avoid an ADL collision with std::visit in older libc++ versions.
            io.replace("src/jsonschema.cpp", "visit(", "visit_schema(", {plain = true})
        end
        import("package.tools.cmake").install(package, {"-DBUILD_TESTING=OFF"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                praxo::ToolRegistry tools;
                tools.specs();
            }
        ]]}, {configs = {languages = "c++20"}, includes = "praxo/agent.hpp"}))
    end)
