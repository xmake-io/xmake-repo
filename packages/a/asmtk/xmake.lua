package("asmtk")

    set_homepage("https://github.com/asmjit/asmtk")
    set_description("Assembler toolkit based on AsmJit")
    set_license("zlib")

    set_urls("https://github.com/asmjit/asmtk.git")
    add_versions("2023.6.14", "6e25b8983fbd8bf455c01ed7c5dd40c99b789565")

    add_deps("asmjit")

    on_install("windows", "linux", "macosx", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("asmjit")
            target("asmtk")
                set_kind("$(kind)")
                add_files("src/**.cpp")
                add_headerfiles("src/(**.h)")
                set_languages("c++11")
                if is_plat("windows") then
                    add_cxxflags("/GR-", "/GF", "/Zc:inline", "/Zc:strictStrings", "/Zc:threadSafeInit-")
                    if is_mode("debug") then
                        add_cxxflags("/GS")
                    else
                        add_cxxflags("/GS-", "/Oi")
                    end
                    if is_kind("shared") then
                        add_rules("utils.symbols.export_all", {export_classes = true})
                    end
                else
                    add_cxxflags("-fno-math-errno", "-fno-threadsafe-statics")
                end
                add_packages("asmjit")
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <asmtk/asmtk.h>
            using namespace asmjit;
            using namespace asmtk;
            void test() {
                Environment env(Arch::kX64);
                CodeHolder code;
                code.init(env);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
