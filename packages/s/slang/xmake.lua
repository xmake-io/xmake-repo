package("slang")
    set_homepage("https://github.com/shader-slang/slang")
    set_description("Making it easier to work with shaders")
    set_license("MIT")

    if is_host("windows") and os.arch() == "x64" then
        add_urls("https://github.com/shader-slang/slang/releases/download/v$(version)/slang-$(version)-win64.zip", {version = function (version) return version:gsub("v", "") end})
        
        add_versions("v2024.1.22", "a5fac1c090c09872711d59176dad86622b895b694302fbbbbda589e8af5ca98a")
        add_versions("v2024.1.18", "eca08ead4a37813961c12db291c7c191c1b4e5a57d9f08d0b23f8b5865a23f8c")
    elseif is_host("linux") and os.arch() == "x86_64" then
        add_urls("https://github.com/shader-slang/slang/releases/download/v$(version)/slang-$(version)-linux-x86_64.tar.gz", {version = function (version) return version:gsub("v", "") end})

        add_versions("v2024.1.22", "35455785c4220815958771ed7d21c99cf00a6b039c1018183e54193ee609e687")
        add_versions("v2024.1.18", "384a01a56c5da353997876910a852f9d18a4923daf00f673f409bd696b7544e2")
    elseif is_host("linux") and os.arch() == "arm64" then
        add_urls("https://github.com/shader-slang/slang/releases/download/v$(version)/slang-$(version)-linux-aarch64.tar.gz", {version = function (version) return version:gsub("v", "") end})
        
        add_versions("v2024.1.22", "69c67d95dc096601a07d7f02f987d6e3af469d4a6422216a80154aeda6a79be7")
        add_versions("v2024.1.18", "f1817beb67c5792fce7229971e5a53172ea54c6dc759e6b782cc719cfac537a2")
    elseif is_host("macosx") and os.arch() == "x64" then
        add_urls("https://github.com/shader-slang/slang/releases/download/v$(version)/slang-$(version)-macos-x64.zip", {version = function (version) return version:gsub("v", "") end})

        add_versions("v2024.1.22", "1c09e797601e08dedd5443ae718ce2e3f5f1fdc5bc6198bcd5862e03b14139eb")
        add_versions("v2024.1.18", "992adcdee7ee987b4d445383f1cf2b20c779da81e374fef3116688ebe48c876c")
    elseif is_host("macosx") and os.arch() == "arm64" then
        add_urls("https://github.com/shader-slang/slang/releases/download/v$(version)/slang-$(version)-macos-aarch64.zip", {version = function (version) return version:gsub("v", "") end})

        add_versions("v2024.1.22", "bf9c9736f7143eb2caf42f9997688c08af58a7aa32941ac5d2467a5db5b6c9a8")
        add_versions("v2024.1.18", "298f6a1eee3d174278f2660beee5519eebbe214d198253117d8674275ef6a320")
    end

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
