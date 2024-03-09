package("wasm-micro-runtime")
    set_homepage("https://github.com/bytecodealliance/wasm-micro-runtime")
    set_description("WebAssembly Micro Runtime (WAMR)")
    set_license("Apache-2.0")

    add_urls("https://github.com/bytecodealliance/wasm-micro-runtime/archive/refs/tags/WAMR-$(version).tar.gz", {excludes = {"*/language-bindings/python/LICENSE"}})
    add_urls("https://github.com/bytecodealliance/wasm-micro-runtime.git")

    add_versions("1.2.3", "85057f788630dc1b8c371f5443cc192627175003a8ea63c491beaff29a338346")

    add_configs("interp", {description = "Enable interpreter", default = true, type = "boolean"})
    add_configs("fast_interp", {description = "Enable fast interpreter", default = false, type = "boolean"})
    add_configs("aot", {description = "Enable AOT", default = false, type = "boolean"})
    -- TODO: improve llvm
    add_configs("jit", {description = "Enable JIT", default = false, type = "boolean", readonly = true})
    add_configs("fast_jit", {description = "Enable Fast JIT", default = false, type = "boolean", readonly = true})
    add_configs("libc", {description = "Choose libc", default = "builtin", type = "string", values = {"builtin", "wasi", "uvwasi"}})
    add_configs("libc_builtin", {description = "Enable builtin libc", default = true, type = "boolean"})
    add_configs("libc_wasi", {description = "Enable wasi libc", default = true, type = "boolean"})
    add_configs("libc_uvwasi", {description = "Enable uvwasi libc", default = true, type = "boolean"})
    add_configs("multi_module", {description = "Enable multiple modules", default = false, type = "boolean"})
    add_configs("mini_loader", {description = "Enable wasm mini loader", default = false, type = "boolean"})
    add_configs("wasi_threads", {description = "Enable wasi threads library", default = false, type = "boolean"})
    add_configs("simd", {description = "Enable SIMD", default = false, type = "boolean"})
    add_configs("ref_types", {description = "Enable reference types", default = false, type = "boolean"})

    add_patches("1.2.3", path.join(os.scriptdir(), "patches", "1.2.3", "cmake-uvwasi.patch"), "e83ff42588cc112588c7fde48a1bd9df7ffa8fa41f70dd99af5d6b0325ce46f7")

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("libc") == "uvwasi" or package:config("libc_uvwasi") then
            package:add("deps", "uvwasi")
        end
        if package:config("jit", "fast_jit") then
            package:add("deps", "llvm")
        end
    end)

    on_install("windows|x64", "windows|x86", "linux", "macosx", "bsd", "android", function (package)
        local configs = {}
        local packagedeps = {}
        if package:config("libc_uvwasi") then
            packagedeps = {"uvwasi", "libuv"}
            if not package:is_plat("windows") then
                local uvwasi = package:dep("uvwasi"):fetch().links[1]
                local libuv = package:dep("libuv"):fetch().links[1]
                if uvwasi and libuv then
                    table.insert(configs, "-DUV_A_LIBS=" .. uvwasi .. " " .. libuv)
                end
            end
        end

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        table.insert(configs, "-DWAMR_BUILD_INTERP=" .. (package:config("interp") and "1" or "0"))
        table.insert(configs, "-DWAMR_BUILD_FAST_INTERP=" .. (package:config("fast_interp") and "1" or "0"))
        table.insert(configs, "-DWAMR_BUILD_AOT=" .. (package:config("aot") and "1" or "0"))
        table.insert(configs, "-DWAMR_BUILD_JIT=" .. (package:config("jit") and "1" or "0"))
        table.insert(configs, "-DWAMR_BUILD_FAST_JIT=" .. (package:config("fast_jit") and "1" or "0"))

        table.insert(configs, "-DWAMR_BUILD_LIBC_BUILTIN=" .. (((package:config("libc") == "builtin") or package:config("libc_builtin")) and "1" or "0"))
        table.insert(configs, "-DWAMR_BUILD_LIBC_WASI=" .. (((package:config("libc") == "wasi") or package:config("libc_wasi")) and "1" or "0"))
        table.insert(configs, "-DWAMR_BUILD_LIBC_UVWASI=" .. (((package:config("libc") == "uvwasi") or package:config("libc_uvwasi")) and "1" or "0"))

        table.insert(configs, "-DWAMR_BUILD_MULTI_MODULE=" .. (package:config("multi_module") and "1" or "0"))
        table.insert(configs, "-DWAMR_BUILD_MINI_LOADER=" .. (package:config("mini_loader") and "1" or "0"))
        table.insert(configs, "-DWAMR_BUILD_LIB_WASI_THREADS=" .. (package:config("wasi_threads") and "1" or "0"))
        table.insert(configs, "-DWAMR_BUILD_SIMD=" .. (package:config("simd") and "1" or "0"))
        table.insert(configs, "-DWAMR_BUILD_REF_TYPES=" .. (package:config("ref_types") and "1" or "0"))

        local plat
        if package:is_plat("windows", "mingw") then
            plat = "windows"
        elseif package:is_plat("linux") then
            plat = "linux"
        elseif package:is_plat("macosx") then
            plat = "darwin"
        elseif package:is_plat("bsd") then
            plat = "freebsd"
        elseif package:is_plat("android") then
            plat = "android"
        elseif package:is_plat("iphoneos") then
            plat = "ios"
        end

        os.cp("core/iwasm/include", package:installdir())
        os.cd("product-mini/platforms/" .. plat)
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})

        os.trymv(package:installdir("lib", "*.dll"), package:installdir("bin"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("wasm_engine_new", {includes = "wasm_c_api.h", {configs = {languages = "c99"}}}))
    end)
