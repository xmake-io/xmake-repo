package("asmjit")

    set_homepage("https://asmjit.com/")
    set_description("AsmJit is a lightweight library for machine code generation written in C++ language.")
    set_license("zlib")

    add_urls("https://github.com/asmjit/asmjit.git")
    add_versions("2022.01.18", "9a92d2f97260749f6f29dc93e53c743448f0137a")
    add_versions("2021.06.27", "d02235b83434943b52a6d7c57118205c5082de08")

    add_deps("cmake")
    if is_plat("linux") then
        add_syslinks("rt")
    end
    on_load("windows", "macosx", "linux", function (package)
        if not package:config("shared") then
            package:add("defines", "ASMJIT_STATIC")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DASMJIT_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
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
