package("capstone")
    set_homepage("http://www.capstone-engine.org")
    set_description("Capstone disassembly/disassembler framework for ARM, ARM64 (ARMv8), Alpha, BPF, Ethereum VM, HPPA, LoongArch, M68K, M680X, Mips, MOS65XX, PPC, RISC-V(rv32G/rv64G), SH, Sparc, SystemZ, TMS320C64X, TriCore, Webassembly, XCore and X86.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/capstone-engine/capstone/archive/refs/tags/$(version).tar.gz",
             "https://github.com/capstone-engine/capstone.git", {submodules = false})

    add_versions("5.0.5", "3bfd3e7085fbf0fab75fb1454067bf734bb0bebe9b670af7ce775192209348e9")
    add_versions("5.0.3", "3970c63ca1f8755f2c8e69b41432b710ff634f1b45ee4e5351defec4ec8e1753")

    add_deps("cmake")

    on_install("!iphoneos", function (package)
        if not package:is_cross() then
            package:addenv("PATH", "bin")
        end

        io.replace("CMakeLists.txt", "include(CPackConfig.txt)", "", {plain = true})

        local configs = {
            "-DCAPSTONE_BUILD_CSTOOL=ON",
            "-DCAPSTONE_BUILD_LEGACY_TESTS=OFF",
            "-DCAPSTONE_BUILD_TESTS=OFF",
            -- xmake will pass CMAKE_MSVC_RUNTIME_LIBRARY
            "-DCAPSTONE_BUILD_STATIC_RUNTIME=OFF",
            "-DCAPSTONE_BUILD_STATIC_MSVC_RUNTIME=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCAPSTONE_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DCAPSTONE_BUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DENABLE_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("cstool -v")
        end
        assert(package:has_cfuncs("cs_version", {includes = "capstone/capstone.h"}))
    end)
