package("asmtk")
    set_homepage("https://github.com/asmjit/asmtk")
    set_description("Assembler toolkit based on AsmJit")
    set_license("zlib")

    set_urls("https://github.com/asmjit/asmtk.git")
    add_versions("2023.07.18", "e2752c85d39da4b0c5c729737a6faa25286b8e0c")

    add_deps("asmjit")

    on_install("!iphoneos", function (package)
        if not package:config("shared") then
            package:add("defines", "ASMTK_STATIC")
        end
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("asmjit")
            target("asmtk")
                set_kind("$(kind)")
                add_files("src/**.cpp")
                add_headerfiles("src/(**.h)")
                set_languages("c++11")
                if is_kind("static") then
                    add_defines("ASMTK_STATIC")
                elseif is_kind("shared") then
                    add_defines("ASMTK_EXPORTS")
                end
                if is_plat("windows") then
                    add_cxxflags("/GR-", "/GF", "/Zc:inline", "/Zc:strictStrings", "/Zc:threadSafeInit-")
                    if is_mode("debug") then
                        add_cxxflags("/GS")
                    else
                        add_cxxflags("/GS-", "/Oi")
                    end
                else
                    add_cxxflags("-fno-math-errno", "-fno-threadsafe-statics")
                end
                add_packages("asmjit")
        ]])
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <asmtk/asmtk.h>
            #include <asmjit/asmjit.h>
            using namespace asmjit;
            using namespace asmtk;
            void test() {
                Environment env(Arch::kX64);
                CodeHolder code;
                code.init(env);
                x86::Assembler a(&code);
                AsmParser p(&a);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
