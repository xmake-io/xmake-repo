package("asmjit")
    set_homepage("https://asmjit.com/")
    set_description("AsmJit is a lightweight library for machine code generation written in C++ language.")
    set_license("zlib")

    add_urls("https://github.com/asmjit/asmjit.git")
    add_versions("2024.05.21", "55c5d6cef59619fb81014531b32f434a793cfb18")
    add_versions("2024.03.09", "268bce7952883dec5015ae539906e9e9d7fb65a0")
    add_versions("2022.01.18", "9a92d2f97260749f6f29dc93e53c743448f0137a")
    add_versions("2021.06.27", "d02235b83434943b52a6d7c57118205c5082de08")
    add_versions("2014.12.01", "48da90ded775fa2ba0fd3f15522890ad631ad6de")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "rt", "m")
    end

    add_deps("cmake")

    on_check(function (package)
        if package:version() and package:version():eq("2014.12.01") then
            assert(not package:is_arch("arm.*"), "package(asmjit == 2014.12.01): does not support arm.")
            assert(not package:is_plat("wasm"), "package(asmjit == 2014.12.01): does not support wasm.")
        end
    end)

    on_install("!iphoneos", function (package)
        if not package:config("shared") then
            package:add("defines", "ASMJIT_STATIC")
        end

        local configs = {}
        if package:version() and package:version():eq("2014.12.01") then
            -- This API supports remote code generation for both x86 and x64.
            io.replace("src/asmjit/config.h", "#define _ASMJIT_CONFIG_H",
                       "#define _ASMJIT_CONFIG_H\n#define ASMJIT_BUILD_X86\n#define ASMJIT_BUILD_X64", {plain = true})
            table.insert(configs, "-DCMAKE_POLICY_VERSION_MINIMUM=3.5")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DASMJIT_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        if package:version() and package:version():eq("2014.12.01") then
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    asmjit::JitRuntime runtime;
                    asmjit::X86Assembler x86(&runtime, asmjit::kArchX86);
                    asmjit::X86Assembler x64(&runtime, asmjit::kArchX64);
                    x86.ret();
                    x64.ret();
                }
            ]]}, {configs = {languages = "c++11"}, includes = "asmjit/asmjit.h"}))
            return
        end
        assert(package:check_cxxsnippets({test = [[
            typedef int (*Func)(void);
            void test() {
                using namespace asmjit;
                JitRuntime rt;
                CodeHolder code;
                code.init(rt.environment());
                x86::Assembler a(&code);
                a.mov(x86::eax, 1);  // Emits 'mov eax, 1' - moves one to 'eax' register.
                a.ret();             // Emits 'ret'        - returns from a function.
                Func fn;
                rt.add(&fn, &code);
                int result = fn();
                rt.release(fn);
                return;
            }
        ]]}, {configs = {languages = "c++17"}, includes = "asmjit/asmjit.h"}))
    end)
