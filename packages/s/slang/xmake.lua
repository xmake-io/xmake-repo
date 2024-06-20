package("slang")
    set_homepage("https://github.com/shader-slang/slang")
    set_description("Making it easier to work with shaders")
    set_license("MIT")

    if is_host("windows") and os.arch() == "x64" then
        add_urls("https://github.com/shader-slang/slang/releases/download/v$(version)/slang-$(version)-win64.zip",
            {version = function (version) return version:gsub("v", "") end})
    elseif is_host("linux") and os.arch() == "x86_64" then
        add_urls("https://github.com/shader-slang/slang/releases/download/v$(version)/slang-$(version)-linux-x86_64.tar.gz",
            {version = function (version) return version:gsub("v", "") end})
    elseif is_host("linux") and os.arch() == "arm64" then
        add_urls("https://github.com/shader-slang/slang/releases/download/v$(version)/slang-$(version)-linux-aarch64.tar.gz",
            {version = function (version) return version:gsub("v", "") end})
    elseif is_host("macosx") and os.arch() == "x64" then
        add_urls("https://github.com/shader-slang/slang/releases/download/v$(version)/slang-$(version)-macos-x64.zip",
            {version = function (version) return version:gsub("v", "") end})
    elseif is_host("macosx") and os.arch() == "arm64" then
        add_urls("https://github.com/shader-slang/slang/releases/download/v$(version)/slang-$(version)-macos-aarch64.zip",
            {version = function (version) return version:gsub("v", "") end})
    end

    add_versions("v2024.1.22", "c00f461aad3d997a2e1c59559421275d6339ae6f")
    add_versions("v2024.1.21", "8ea3854d94eb1ff213be716a38493d601784810b")
    add_versions("v2024.1.20", "89c1fd0dd1581221f583653a9dfa6d1cf990577c")
    add_versions("v2024.1.19", "753a524be885cf463fa6e60734aa739fcce1396f")
    add_versions("v2024.1.18", "efdbb954c57b89362e390f955d45f90e59d66878")
    add_versions("v2024.1.17", "62b7219e715bd4c0f984bcd98c9767fb6422c78f")

    add_configs("shared", { description = "Build shared library", default = true, type = "boolean", readonly = true })
    add_configs("gfx", { description = "Enable gfx targets", default = false, type = "boolean" })
    add_configs("slang_glslang", { description = "Enable glslang dependency and slang-glslang wrapper target", default = false, type = "boolean" })
    add_configs("slang_llvm_flavor", { description = "How to get or build slang-llvm (available options: FETCH_BINARY, USE_SYSTEM_LLVM, DISABLE)", default = "DISABLE", type = "string" })

    on_install("windows|x64", "linux|x86_64", "linux|arm64", "macosx", function (package)
        local plat_cp_lib = function (src)
            os.trycp("bin/*/release/" .. src .. ".dll", package:installdir("bin"))
            os.trycp("bin/*/release/" .. src .. ".lib", package:installdir("lib"))
            os.trycp("bin/*/release/lib" .. src .. ".so", package:installdir("lib"))
        end
        
        os.cp("*.h", package:installdir("include"))

        plat_cp_lib("slang")
        if package:config("gfx") then plat_cp_lib("gfx") end
        if package:config("slang_glslang") then plat_cp_lib("slang-glslang") end
        if package:config("slang_llvm_flavor") then plat_cp_lib("slang-llvm") end

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
