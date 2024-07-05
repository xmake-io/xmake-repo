package("libatomic_ops")
    set_homepage("https://github.com/ivmai/libatomic_ops")
    set_description("The atomic_ops project (Atomic memory update operations portable implementation)")
    set_license("GPL-2.0")

    add_urls("https://github.com/ivmai/libatomic_ops/releases/download/v$(version)/libatomic_ops-$(version).tar.gz",
             "https://github.com/ivmai/libatomic_ops.git")

    add_versions("7.8.2", "d305207fe207f2b3fb5cb4c019da12b44ce3fcbc593dfd5080d867b1a2419b51")

    add_configs("gpl", {description = "Build atomic_ops_gpl library", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-Denable_docs=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        table.insert(configs, "-Denable_gpl=" .. (package:config("gpl") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        if package:config("shared") and package:is_plat("windows", "mingw", "cygwin") then
            package:add("defines", "AO_DLL")
        end
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                AO_t atomic_var;
            }
        ]]}, {includes = "atomic_ops.h"}))
    end)
