package("nzsl")
    set_homepage("https://github.com/NazaraEngine/ShaderLang")
    set_description("NZSL is a shader language inspired by Rust and C++ which compiles to GLSL or SPIRV")
    set_license("MIT")

    add_urls("https://github.com/NazaraEngine/ShaderLang/archive/refs/tags/$(version).tar.gz",
             "https://github.com/NazaraEngine/ShaderLang.git")

    add_versions("v1.0.0", "1e3110ffaeed57d2ac42b85771c25e71719c62218776ad159696ff3583a59715")

    set_policy("package.strict_compatibility", true)

    add_deps("nazarautils")
    add_deps("fast_float", "frozen", "ordered_map", {private = true})

    add_configs("nzsla", {description = "Includes standalone archiver", default = true, type = "boolean"})
    add_configs("nzslc", {description = "Includes standalone compiler", default = true, type = "boolean"})
    add_configs("symbols", {description = "Enable debug symbols in release", default = false, type = "boolean"})

    if is_plat("windows", "linux", "mingw", "macosx", "bsd") then
        add_configs("fs_watcher", {description = "Includes filesystem watcher", default = true, type = "boolean"})
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
        configs.fs_watcher = package:config("fs_watcher") or false
        configs.erronwarn = false
        configs.examples = false
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
