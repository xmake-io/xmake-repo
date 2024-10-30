package("bddisasm")
    set_homepage("https://github.com/bitdefender/bddisasm")
    set_description("bddisasm is a fast, lightweight, x86/x64 instruction decoder.  The project also features a fast, basic, x86/x64 instruction emulator, designed specifically to detect shellcode-like behavior.")
    set_license("Apache-2.0")

    add_urls("https://github.com/bitdefender/bddisasm/archive/refs/tags/$(version).tar.gz",
             "https://github.com/bitdefender/bddisasm.git")

    add_versions("v2.2.0", "b1aa8749ef1d61ecdc4e5469a823b40e06cf1d077a518995bf86bcac09ba530d")

    add_configs("isagenerator", {description = "Include the x86 isagenerator target", default = false, type = "boolean"})
    add_configs("vsnprintf", {description = "Expect nd_vsnprintf_s implementation from the integrator", default = false, type = "boolean"})
    add_configs("memset", {description = "Expect nd_memset implementation from the integrator", default = false, type = "boolean"})
    add_configs("no_mnemonics", {description = "Exclude mnemonics - this option involves setting the BDDISASM_NO_FORMAT flag", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_links("bddisasm", "bdshemu")

    add_deps("cmake")

    on_load(function (package)
        if package:config("isagenerator") then
            package:add("deps", "python 3.x", {kind = "binary"})
        end
        if package:config("no_mnemonics") then
            package:add("defines", "BDDISASM_NO_MNEMONIC", "BDDISASM_NO_FORMAT")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "STATIC", "", {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBDD_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DBDD_UBSAN=" .. (package:config("ubsan") and "ON" or "OFF"))
        table.insert(configs, "-DBDD_LTO=" .. (package:config("lto") and "ON" or "OFF"))

        table.insert(configs, "-DBDD_INCLUDE_ISAGENERATOR_X86=" .. (package:config("isagenerator") and "ON" or "OFF"))
        table.insert(configs, "-DBDD_USE_EXTERNAL_VSNPRINTF=" .. (package:config("vsnprintf") and "ON" or "OFF"))
        table.insert(configs, "-DBDD_USE_EXTERNAL_MEMSET=" .. (package:config("memset") and "ON" or "OFF"))
        table.insert(configs, "-DBDD_NO_MNEMONIC=" .. (package:config("no_mnemonics") and "ON" or "OFF"))
        table.insert(configs, "-DBDD_INCLUDE_TOOL=" .. (package:config("tools") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
            if package:config("shared") then
                table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
            end
        end
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.vcp(path.join(package:buildir(), "*.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("NdDecodeEx", {includes = "bddisasm/bddisasm.h"}))
    end)
