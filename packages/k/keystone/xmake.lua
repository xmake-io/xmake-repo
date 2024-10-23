package("keystone")
    set_homepage("http://www.keystone-engine.org")
    set_description("Keystone assembler framework: Core (Arm, Arm64, Hexagon, Mips, PowerPC, Sparc, SystemZ & X86) + bindings")
    set_license("GPL-2.0")

    add_urls("https://github.com/keystone-engine/keystone/archive/refs/tags/$(version).tar.gz",
             "https://github.com/keystone-engine/keystone.git")

    add_versions("0.9.2", "c9b3a343ed3e05ee168d29daf89820aff9effb2c74c6803c2d9e21d55b5b7c24")

    add_deps("cmake", "python 3.x", {kind = "binary"})

    if is_plat("windows", "mingw") then
        add_syslinks("shell32", "ole32", "uuid")
    end

    on_load(function (package)
        if package:is_cross() or package:is_plat("mingw") or (package:is_plat("windows") and package:config("shared")) then
            package:data_set("build_libs_only", true)
        end
        if not package:data("build_libs_only") then
            package:addenv("PATH", "bin")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(suite/fuzz)", "", {plain = true})
        io.replace("llvm/keystone/CMakeLists.txt",
            "install(TARGETS keystone DESTINATION lib${LLVM_LIBDIR_SUFFIX})", [[
            install(TARGETS keystone
                RUNTIME DESTINATION bin
                LIBRARY DESTINATION lib
                ARCHIVE DESTINATION lib
            )
            install(DIRECTORY ${CMAKE_SOURCE_DIR}/include/ DESTINATION include)
        ]], {plain = true})

        local configs = {"-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_LIBS_ONLY=" .. (package:data("build_libs_only") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DKEYSTONE_BUILD_STATIC_RUNTIME=" .. (package:has_runtime("MT", "MTd") and "ON" or "OFF"))
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
        end
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.vcp(path.join(package:buildir(), "llvm/**.pdb"), dir)
            os.trycp(path.join(package:buildir(), "kstool/kstool.pdb"), package:installdir("bin"))
        end
    end)

    on_test(function (package)
        if not package:data("build_libs_only") then
            os.vrun('kstool -b x64 "mov rax, 1; ret"')
        end
        assert(package:has_cfuncs("ks_version", {includes = "keystone/keystone.h"}))
    end)
