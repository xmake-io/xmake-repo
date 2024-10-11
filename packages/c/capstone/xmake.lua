package("capstone")
    set_homepage("http://www.capstone-engine.org")
    set_description("Capstone disassembly/disassembler framework for ARM, ARM64 (ARMv8), Alpha, BPF, Ethereum VM, HPPA, LoongArch, M68K, M680X, Mips, MOS65XX, PPC, RISC-V(rv32G/rv64G), SH, Sparc, SystemZ, TMS320C64X, TriCore, Webassembly, XCore and X86.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/capstone-engine/capstone/archive/refs/tags/$(version).tar.gz",
             "https://github.com/capstone-engine/capstone.git")

    add_versions("5.0.3", "3970c63ca1f8755f2c8e69b41432b710ff634f1b45ee4e5351defec4ec8e1753")

    add_deps("cmake")

    on_install("!iphoneos", function (package)
        package:addenv("PATH", "bin")

        local configs = {
            "-DCAPSTONE_BUILD_CSTOOL=ON",
            "-DCAPSTONE_BUILD_STATIC_RUNTIME=OFF", -- Use our pass CMAKE_MSVC_RUNTIME_LIBRARY
            "-DCAPSTONE_BUILD_LEGACY_TESTS=OFF",
            "-DCAPSTONE_BUILD_TESTS=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.trycp(path.join(package:buildir(), "capstone.pdb"), dir)
            os.trycp(path.join(package:buildir(), "cstool.pdb"), package:installdir("bin"))
        end
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("cstool -v")
        end
        assert(package:has_cfuncs("cs_version", {includes = "capstone/capstone.h"}))
    end)
