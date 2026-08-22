package("libatomic_ops")
    set_homepage("https://github.com/bdwgc/libatomic_ops/wiki/Download")
    set_description("The atomic_ops project (Atomic memory update operations portable implementation)")
    set_license("GPL-2.0")

    add_urls("https://github.com/bdwgc/libatomic_ops/archive/refs/tags/$(version).tar.gz",
             "https://github.com/bdwgc/libatomic_ops.git")

    add_versions("v7.10.0", "96443e58a6bb6c0ada61660ccb547254aaa97e44bceb10a340937f6ba3ba8243")
    add_versions("v7.8.4", "ea8295ac627646e37fd194d31535bbc02da60b908c8166c5e04d2461a53cb059")
    add_versions("v7.8.2", "ad8428a40e01d41bc4ddad3166afa1fc175c9e58d8ef7ddbd7ef3298e32ac37b")

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
