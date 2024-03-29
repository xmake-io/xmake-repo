package("xbyak")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/herumi/xbyak")
    set_description("JIT assembler for x86(IA-32)/x64(AMD64, x86-64) MMX/SSE/SSE2/SSE3/SSSE3/SSE4/FPU/AVX/AVX2/AVX-512")

    set_urls("https://github.com/herumi/xbyak/archive/$(version).zip",
             "https://github.com/herumi/xbyak.git")

    add_versions("v7.06", "2d4b312769d3ff12b26ede3e9b105d336ae2b6c7ad3175921acc1ed001213a63")
    add_versions("v6.73", "8cb9cc090f6123b35a2c554ae4cc80c9a2fb65ebf0b378463094fc62360fb13d")
    add_versions("v6.03", "e13ec1247a3a34f602434cf5075f0dfeea42bbd9bc4a73fd59dcf3e44907e68a")
    add_versions("v6.02", "cd3fe5ee15df6bfa73c721584b101c885096551124e6ded31b6f866ecb381cf0")

    on_install(function (package)
        os.cp("xbyak", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test()
            {
                class Sample : public Xbyak::CodeGenerator {
                    Sample() {
                      inc(eax);
                    }
                };
            }
        ]]}, {configs = {languages = "c++17"}, includes = { "xbyak/xbyak.h" } }))
    end)
