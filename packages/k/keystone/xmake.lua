package("keystone")
    set_homepage("http://www.keystone-engine.org")
    set_description("Keystone assembler framework: Core (Arm, Arm64, Hexagon, Mips, PowerPC, Sparc, SystemZ & X86) + bindings")
    set_license("GPL-2.0")

    add_urls("https://github.com/keystone-engine/keystone/archive/refs/tags/$(version).tar.gz",
             "https://github.com/keystone-engine/keystone.git")

    add_versions("0.9.2", "c9b3a343ed3e05ee168d29daf89820aff9effb2c74c6803c2d9e21d55b5b7c24")

    add_deps("cmake")

    if is_plat("windows") then
        add_syslinks("shell32")
    end

    add_configs("build_libs_only", { 
        description = "Only build Keystone library (no tools)", 
        default = true, 
        type = "boolean" 
    })


    on_load(function (package)
        package:addenv("PATH", "bin")
    end)


    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_LIBS_ONLY=" .. (package:config("build_libs_only") and "ON" or "OFF"))
        table.insert(configs, "-DKEYSTONE_BUILD_STATIC_RUNTIME=" .. (package:config("static") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        if package:config("static") and not package:is_cross() and not package:config("build_libs_only") then
            os.vrun('kstool -b x64 "mov rax, 1; ret"')
        end
        assert(package:has_cfuncs("ks_version", {includes = "keystone/keystone.h"}))
    end)
