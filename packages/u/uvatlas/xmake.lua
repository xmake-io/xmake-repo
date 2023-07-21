package("uvatlas")

    set_homepage("https://github.com/Microsoft/UVAtlas")
    set_description("UVAtlas - isochart texture atlasing")
    set_license("MIT")

    local tag = {
        ["2023.06"] = "jun2023",
    }
    add_urls("https://github.com/microsoft/UVAtlas/archive/refs/tags/$(version).zip", {version = function (version) return tag[tostring(version)] end})
    add_urls("https://github.com/microsoft/UVAtlas.git")
    add_versions("2023.06", "b3ac09b88a26179a91822ff3f3b15df574803c94641fd6cf694ea44cb91ad75f")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    add_configs("tools",  {description = "Build UVAtlasTool", default = false, type = "boolean"})

    add_deps("cmake")
    on_install("windows", function (package)
        local configs = {"-DUVATLAS_USE_OPENMP=OFF", "-DBUILD_TESTING=OFF"}
        local vs_sdkver = import("core.tool.toolchain").load("msvc"):config("vs_sdkver")
        if vs_sdkver then
            local build_ver = string.match(vs_sdkver, "%d+%.%d+%.(%d+)%.?%d*")
            assert(tonumber(build_ver) >= 18362, "UVAtlas requires Windows SDK to be at least 10.0.18362.0")
            table.insert(configs, "-DCMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION=" .. vs_sdkver)
            table.insert(configs, "-DCMAKE_SYSTEM_VERSION=" .. vs_sdkver)
        end
        table.insert(configs, "-DBUILD_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vector>
            void test() {
                std::vector<DirectX::UVAtlasVertex> meshVBO;
            }
        ]]}, {configs = {languages = "cxx17"}, includes = "UVAtlas.h"}))
    end)
