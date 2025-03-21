package("slang")
    set_homepage("https://github.com/shader-slang/slang")
    set_description("Making it easier to work with shaders")
    set_license("MIT")

    add_urls("https://github.com/shader-slang/slang/archive/refs/tags/$(version).tar.gz",
             "https://github.com/shader-slang/slang.git")

    add_versions("v2025.6.2", "024fc3de73598ef00222ec71ae59382afaf761fc97e47d63420dfc2ff4c1f761")

    add_configs("shared", { description = "Build shared library", default = true, type = "boolean", readonly = true })
    add_configs("embed_stdlib_source", { description = "Embed stdlib source in the binary", default = true, type = "boolean" })
    add_configs("embed_stdlib", { description = "Build slang with an embedded version of the stdlib", default = false, type = "boolean" })
    add_configs("full_ir_validation", { description = "Enable full IR validation (SLOW!)", default = false, type = "boolean" })
    add_configs("gfx", { description = "Enable gfx targets", default = false, type = "boolean" })
    add_configs("slangd", { description = "Enable language server target", default = false, type = "boolean" })
    add_configs("slangc", { description = "Enable standalone compiler target", default = false, type = "boolean" })
    add_configs("slangrt", { description = "Enable runtime target", default = false, type = "boolean" })
    add_configs("slang_glslang", { description = "Enable glslang dependency and slang-glslang wrapper target", default = false, type = "boolean" })
    add_configs("slang_llvm_flavor", { description = "How to get or build slang-llvm (available options: FETCH_BINARY, USE_SYSTEM_LLVM, DISABLE)", default = "DISABLE", type = "string" })

    add_deps("cmake")

    on_install("windows|x64", "macosx", "linux|x86_64", function (package)
        local configs = {"-DSLANG_ENABLE_TESTS=OFF", "-DSLANG_ENABLE_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DSLANG_LIB_TYPE=" .. (package:config("shared") and "SHARED" or "STATIC"))
        table.insert(configs, "-DSLANG_EMBED_STDLIB_SOURCE=" .. (package:config("embed_stdlib_source") and "ON" or "OFF"))
        table.insert(configs, "-DSLANG_EMBED_STDLIB=" .. (package:config("embed_stdlib") and "ON" or "OFF"))
        table.insert(configs, "-DSLANG_ENABLE_FULL_IR_VALIDATION=" .. (package:config("full_ir_validation") and "ON" or "OFF"))
        table.insert(configs, "-DSLANG_ENABLE_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DSLANG_ENABLE_GFX=" .. (package:config("gfx") and "ON" or "OFF"))
        table.insert(configs, "-DSLANG_ENABLE_SLANGD=" .. (package:config("slangd") and "ON" or "OFF"))
        table.insert(configs, "-DSLANG_ENABLE_SLANGC=" .. (package:config("slangc") and "ON" or "OFF"))
        table.insert(configs, "-DSLANG_ENABLE_SLANGRT=" .. (package:config("slangrt") and "ON" or "OFF"))
        table.insert(configs, "-DSLANG_ENABLE_SLANG_GLSLANG=" .. (package:config("slang_glslang") and "ON" or "OFF"))
        table.insert(configs, "-DSLANG_SLANG_LLVM_FLAVOR=" .. package:config("slang_llvm_flavor"))

        import("package.tools.cmake").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({ test = [[
            #include <slang-com-ptr.h>
            #include <slang.h>

            void test() {
                Slang::ComPtr<slang::IGlobalSession> global_session;
                slang::createGlobalSession(global_session.writeRef());
            }
        ]] }, {configs = {languages = "c++17"}}))
    end)
