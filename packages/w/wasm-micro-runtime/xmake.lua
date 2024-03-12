package("wasm-micro-runtime")
    set_homepage("https://github.com/bytecodealliance/wasm-micro-runtime")
    set_description("WebAssembly Micro Runtime (WAMR)")
    set_license("Apache-2.0")

    add_urls("https://github.com/bytecodealliance/wasm-micro-runtime/archive/refs/tags/WAMR-$(version).tar.gz", {excludes = {"*/language-bindings/python/LICENSE"}})
    add_urls("https://github.com/bytecodealliance/wasm-micro-runtime.git")

    -- add_versions("1.3.2", "58961ba387ed66ace2dd903597f1670a42b8154a409757ae6f06f43fe867a98c")
    add_versions("1.2.3", "85057f788630dc1b8c371f5443cc192627175003a8ea63c491beaff29a338346")

    -- add_patches("1.3.2", path.join(os.scriptdir(), "patches", "1.3.2", "cmake.patch"), "cf0e992bdf3fe03f7dc03624fd757444291a5286b1ceef6532bbf3f9567f394b")
    add_patches("1.2.3", path.join(os.scriptdir(), "patches", "1.2.3", "cmake.patch"), "97d99509997b86d24a84cd1b2eca0d4dace7b460d5cb85bc23881d02e7ef08ed")

    if is_plat("windows", "linux", "macosx") then
        add_patches("1.2.3", path.join(os.scriptdir(), "patches", "libc_uvwasi.patch"), "e83ff42588cc112588c7fde48a1bd9df7ffa8fa41f70dd99af5d6b0325ce46f7")
    end

    add_configs("interp", {description = "Enable interpreter", default = true, type = "boolean"})
    add_configs("fast_interp", {description = "Enable fast interpreter", default = false, type = "boolean"})
    add_configs("aot", {description = "Enable AOT", default = false, type = "boolean"})
    -- TODO: improve llvm
    add_configs("jit", {description = "Enable JIT", default = false, type = "boolean", readonly = true})
    add_configs("fast_jit", {description = "Enable Fast JIT", default = false, type = "boolean", readonly = true})
    add_configs("libc", {description = "Choose libc", default = "uvwasi", type = "string", values = {"builtin", "wasi", "uvwasi"}})
    add_configs("libc_builtin", {description = "Enable builtin libc", default = false, type = "boolean"})
    add_configs("libc_wasi", {description = "Enable wasi libc", default = false, type = "boolean"})
    add_configs("libc_uvwasi", {description = "Enable uvwasi libc", default = true, type = "boolean"})
    add_configs("multi_module", {description = "Enable multiple modules", default = false, type = "boolean"})
    add_configs("mini_loader", {description = "Enable wasm mini loader", default = false, type = "boolean"})
    add_configs("wasi_threads", {description = "Enable wasi threads library", default = false, type = "boolean"})
    add_configs("simd", {description = "Enable SIMD", default = false, type = "boolean"})
    add_configs("ref_types", {description = "Enable reference types", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("ntdll", "ws2_32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("m", "dl", "pthread")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:is_plat("windows", "linux", "macosx") and
            (package:config("libc_uvwasi") or package:config("libc") == "uvwasi") then
            package:add("deps", "uvwasi")
        end
        if package:config("jit", "fast_jit") then
            package:add("deps", "llvm")
        end
    end)

    on_install("windows", "linux", "macosx", "bsd", "android", function (package)
        local configs = {"-DWAMR_BUILD_INVOKE_NATIVE_GENERAL=1"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") and (not package:config("shared")) then
            package:add("defines", "COMPILING_WASM_RUNTIME_API=1")
        end

        table.insert(configs, "-DWAMR_BUILD_INTERP=" .. (package:config("interp") and "1" or "0"))
        table.insert(configs, "-DWAMR_BUILD_FAST_INTERP=" .. (package:config("fast_interp") and "1" or "0"))
        table.insert(configs, "-DWAMR_BUILD_AOT=" .. (package:config("aot") and "1" or "0"))
        table.insert(configs, "-DWAMR_BUILD_JIT=" .. (package:config("jit") and "1" or "0"))
        table.insert(configs, "-DWAMR_BUILD_FAST_JIT=" .. (package:config("fast_jit") and "1" or "0"))

        table.insert(configs, "-DWAMR_BUILD_LIBC_BUILTIN=" .. ((package:config("libc_builtin") or package:config("libc") == "builtin" ) and "1" or "0"))
        table.insert(configs, "-DWAMR_BUILD_LIBC_WASI=" .. ((package:config("libc_wasi") or package:config("libc") == "wasi" ) and "1" or "0"))
        table.insert(configs, "-DWAMR_BUILD_LIBC_UVWASI=" .. ((package:config("libc_uvwasi") or package:config("libc") == "uvwasi" ) and "1" or "0"))

        table.insert(configs, "-DWAMR_BUILD_MULTI_MODULE=" .. (package:config("multi_module") and "1" or "0"))
        table.insert(configs, "-DWAMR_BUILD_MINI_LOADER=" .. (package:config("mini_loader") and "1" or "0"))
        table.insert(configs, "-DWAMR_BUILD_LIB_WASI_THREADS=" .. (package:config("wasi_threads") and "1" or "0"))
        table.insert(configs, "-DWAMR_BUILD_SIMD=" .. (package:config("simd") and "1" or "0"))
        table.insert(configs, "-DWAMR_BUILD_REF_TYPES=" .. (package:config("ref_types") and "1" or "0"))

        local packagedeps
        if package:is_plat("windows", "linux", "macosx") and
            (package:config("libc_uvwasi") or package:config("libc") == "uvwasi") then
            packagedeps = {"uvwasi", "libuv"}
        end
        if package:is_plat("android") then
            table.insert(configs, "-DWAMR_BUILD_PLATFORM=android")
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("wasm_engine_new", {includes = "wasm_c_api.h"}))
    end)
