package("cpu-features")
    set_homepage("https://github.com/google/cpu_features")
    set_description("A cross platform C99 library to get cpu features at runtime.")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/cpu_features/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/cpu_features.git")

    add_versions("v0.6.0", "95a1cf6f24948031df114798a97eea2a71143bd38a4d07d9a758dda3924c1932")
    add_versions("v0.7.0", "df80d9439abf741c7d2fdcdfd2d26528b136e6c52976be8bd0cd5e45a27262c0")
    add_versions("v0.9.0", "bdb3484de8297c49b59955c3b22dba834401bc2df984ef5cfc17acbe69c5018e")

    if is_plat("macosx") then
        add_extsources("brew::cpu_features")
    end

    add_deps("cmake")

    on_install("!wasm", function (package)
        if package:is_cross() then
            local arch
            if package:is_arch("arm.*") then
                arch = (package:is_arch64() and "set(PROCESSOR_IS_AARCH64 TRUE)" or "set(PROCESSOR_IS_ARM TRUE)")
                io.replace("CMakeLists.txt", "set(PROCESSOR_IS_X86 TRUE)", arch, {plain = true})
            end
        end

        local configs = {"-DBUILD_TESTING=OFF", "-DENABLE_INSTALL=ON", "-DBUILD_EXECUTABLE=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=" .. (package:config("pic") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_PIC=" .. (package:config("pic") and "ON" or "OFF"))
        if package:is_plat("cross", "iphoneos") then
            table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=" .. package:arch())
        end
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs)
        package:addenv("PATH", "bin")

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.vcp(path.join(package:buildir(), "*.pdb"), dir)
        end
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("list_cpu_features")
        end
        assert(package:check_csnippets({test = [[
            #include <cpu_features/cpu_features_macros.h>
            #if defined(CPU_FEATURES_ARCH_X86)
            #include <cpu_features/cpuinfo_x86.h>
            #elif defined(CPU_FEATURES_ARCH_ARM)
            #include <cpu_features/cpuinfo_arm.h>
            #elif defined(CPU_FEATURES_ARCH_AARCH64)
            #include <cpu_features/cpuinfo_aarch64.h>
            #elif defined(CPU_FEATURES_ARCH_MIPS)
            #include <cpu_features/cpuinfo_mips.h>
            #elif defined(CPU_FEATURES_ARCH_PPC)
            #include <cpu_features/ccpuinfo_ppc.h>
            #endif
            void test() {
                #if defined(CPU_FEATURES_ARCH_X86)
                    X86Features features = GetX86Info().features;
                #elif defined(CPU_FEATURES_ARCH_ARM)
                    ArmFeatures features = GetArmInfo().features;
                #elif defined(CPU_FEATURES_ARCH_AARCH64)
                    Aarch64Features features = GetAarch64Info().features;
                #elif defined(CPU_FEATURES_ARCH_MIPS)
                    MipsFeatures features = GetMipsInfo().features;
                #elif defined(CPU_FEATURES_ARCH_PPC)
                    PPCFeatures features = GetPPCInfo().features;
                #endif
            }
        ]]}))
    end)
