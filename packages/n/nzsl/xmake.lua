package("nzsl")
    set_homepage("https://github.com/NazaraEngine/ShaderLang")
    set_description("NZSL is a shader language inspired by Rust and C++ which compiles to GLSL or SPIRV")
    set_license("MIT")

    add_urls("https://github.com/NazaraEngine/ShaderLang/archive/refs/tags/$(version).tar.gz",
             "https://github.com/NazaraEngine/ShaderLang.git")

    add_versions("v1.1.2", "48b3e5ce18f0c3d4bf22c0201ab41664b30c1d40f7df31b776d2d37a1559c0fb")
    add_versions("v1.1.1", "e4e37d3274936d8f040d4ed29d2aa20b6cc93de755aa070309fd01cc17140525")
    add_versions("v1.1.0", "8b401a199c6ee7b2cc3b24871bbec2857a70ff47a25f043e35db54fa1f4129ef")
    add_versions("v1.0.0", "ef434fec5d32ddf64f2f7c7691a4d96a6ac24cab4cc6c091d46a542c86825359")

    set_policy("package.strict_compatibility", true)

    add_deps("nazarautils")
    add_deps("fast_float", "frozen", "ordered_map", {private = true})

    add_configs("cbinding", {description = "Builds the C binding library (CNZSL)", default = false, type = "boolean"})
    add_configs("nzsla", {description = "Includes standalone archiver", default = true, type = "boolean"})
    add_configs("nzslc", {description = "Includes standalone compiler", default = true, type = "boolean"})
    add_configs("symbols", {description = "Enable debug symbols in release", default = false, type = "boolean"})

    if is_plat("windows", "linux", "mingw", "macosx", "bsd") then
        add_configs("fs_watcher", {description = "Includes filesystem watcher", default = true, type = "boolean"})
    end

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_load(function (package)
        package:addenv("PATH", "bin")
        if not package:config("shared") then
            package:add("defines", "NZSL_STATIC")
            package:add("deps", "fmt")
        end
        if package:config("fs_watcher") then
            package:add("deps", "efsw")
        end
        if package:config("nzsla") then
            package:add("deps", "lz4", {private = package:config("shared")})
        end
        if package:config("nzslc") then
            package:add("deps", "cxxopts >=3.1.1", "nlohmann_json", {private = true})
        end
    end)

    on_install(function (package)
        local configs = {}
        configs.asan = package:config("asan")
        configs.cbinding = package:config("cbinding")
        configs.fs_watcher = package:config("fs_watcher") or false
        configs.erronwarn = false
        configs.examples = false
        configs.tests = false
        configs.with_nzsla = package:config("nzsla") or false
        configs.with_nzslc = package:config("nzslc") or false

        -- enable unitybuild for faster compilation except on MinGW (doesn't like big object even with /bigobj)
        if not os.getenv("NAZARA_DISABLE_UNITYBUILD") then
            configs.unitybuild = not package:is_plat("mingw")
        end

        if package:is_debug() then
            configs.mode = "debug"
        elseif package:config("symbols") then
            configs.mode = "releasedbg"
        else
            configs.mode = "release"
        end

        import("package.tools.xmake").install(package, configs)
        package:add("linkorders", "cnzsl", "nzsl")
    end)

    on_test(function (package)
        if (package:config("nzsla") or package:config("nzslc")) and not package:is_cross() then
            local envs
            if package:is_plat("windows") then
                import("core.tool.toolchain")
                local msvc = package:toolchain("msvc")
                if msvc and msvc:check() then
                    envs = msvc:runenvs()
                end
            elseif package:is_plat("mingw") then
                import("core.tool.toolchain")
                local mingw = package:toolchain("mingw")
                if mingw and mingw:check() then
                    envs = mingw:runenvs()
                end
            end
            if package:config("nzsla") then
                os.vrunv("nzsla", {"--version"}, {envs = envs})
            end
            if package:config("nzslc") then
                os.vrunv("nzslc", {"--version"}, {envs = envs})
            end
        end
        if not package:is_binary() then
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    nzsl::Ast::ModulePtr shaderModule = nzsl::Parse(R"(
                        [nzsl_version("1.0")]
                        module;

                        struct FragOut
                        {
                            value: vec4[f32]
                        }

                        [entry(frag)]
                        fn fragShader() -> FragOut
                        {
                            let output: FragOut;
                            output.value = vec4[f32](0.0, 0.0, 1.0, 1.0);
                            return output;
                        }
                    )");
                }
            ]]}, {configs = {languages = "c++17"}, includes = "NZSL/Parser.hpp"}))
        end
    end)
