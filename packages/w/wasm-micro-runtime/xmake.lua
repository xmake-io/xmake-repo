package("wasm-micro-runtime")
    set_homepage("https://github.com/bytecodealliance/wasm-micro-runtime")
    set_description("WebAssembly Micro Runtime (WAMR)")
    set_license("Apache-2.0")

    add_urls("https://github.com/bytecodealliance/wasm-micro-runtime/archive/refs/tags/WAMR-$(version).tar.gz",
             "https://github.com/bytecodealliance/wasm-micro-runtime.git")

    add_versions("1.2.3", "85057f788630dc1b8c371f5443cc192627175003a8ea63c491beaff29a338346")

    add_configs("interp", {description = "Enable interpreter", default = true, type = "boolean"})
    add_configs("fast_interp", {description = "Enable fast interpreter", default = false, type = "boolean"})
    add_configs("aot", {description = "Enable AOT", default = false, type = "boolean"})
    add_configs("jit", {description = "Enable JIT", default = false, type = "boolean"})
    add_configs("fast_jit", {description = "Enable Fast JIT", default = false, type = "boolean"})
    add_configs("libc", {description = "Choose libc", default = "builtin", type = "string", values = {"builtin", "wasi", "uvwasi"}})
    add_configs("multi_module", {description = "Enable multiple modules", default = false, type = "boolean"})
    add_configs("mini_loader", {description = "Enable wasm mini loader", default = false, type = "boolean"})
    add_configs("pthread", {description = "Enable pthread library", default = false, type = "boolean"})
    add_configs("wasi_threads", {description = "Enable wasi threads library", default = false, type = "boolean"})
    add_configs("simd", {description = "Enable SIMD", default = false, type = "boolean"})
    add_configs("ref_types", {description = "Enable reference types", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("ws_32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        -- table.insert(configs, "-DWAMR_BUILD_INTERP=" .. (package:config("interp") and "ON" or "OFF"))
        -- table.insert(configs, "-DWAMR_BUILD_FAST_INTERP=" .. (package:config("fast_interp") and "ON" or "OFF"))
        -- table.insert(configs, "-DWAMR_BUILD_AOT=" .. (package:config("aot") and "ON" or "OFF"))
        -- table.insert(configs, "-DWAMR_BUILD_JIT=" .. (package:config("jit") and "ON" or "OFF"))
        -- table.insert(configs, "-DWAMR_BUILD_FAST_JIT=" .. (package:config("fast_jit") and "ON" or "OFF"))

        -- table.insert(configs, "-DWAMR_BUILD_LIBC_BUILTIN=" .. ((package:config("libc") == "builtin") and "ON" or "OFF"))
        -- table.insert(configs, "-DWAMR_BUILD_LIBC_WASI=" .. ((package:config("libc") == "wasi") and "ON" or "OFF"))
        -- table.insert(configs, "-DWAMR_BUILD_LIBC_UVWASI=" .. ((package:config("libc") == "uvwasi") and "ON" or "OFF"))

        -- table.insert(configs, "-DWAMR_BUILD_MULTI_MODULE=" .. (package:config("multi_module") and "ON" or "OFF"))
        -- table.insert(configs, "-DWAMR_BUILD_MINI_LOADER=" .. (package:config("mini_loader") and "ON" or "OFF"))
        -- table.insert(configs, "-DWAMR_BUILD_LIB_PTHREAD=" .. (package:config("pthread") and "ON" or "OFF"))
        -- table.insert(configs, "-DWAMR_BUILD_LIB_WASI_THREADS=" .. (package:config("wasi_threads") and "ON" or "OFF"))
        -- table.insert(configs, "-DWAMR_BUILD_SIMD=" .. (package:config("simd") and "ON" or "OFF"))
        -- table.insert(configs, "-DWAMR_BUILD_REF_TYPES=" .. (package:config("ref_types") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("wasm_engine_new", {includes = "wasm_c_api.h", {configs = {languages = "c99"}}}))
    end)
