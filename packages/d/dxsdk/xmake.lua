package("dxsdk")
    set_homepage("https://www.nuget.org/packages/Microsoft.DXSDK.D3DX")
    set_description("This package contains the headers, import libraries, and runtime DLLs for the deprecated D3DX9, D3DX10, and D3DX11 utilities libraries")
    set_license("Microsoft")

    local version_map = {
        ["9.29.9528"] = "9.29.952.8"
    }
    set_urls("https://www.nuget.org/api/v2/package/Microsoft.DXSDK.D3DX/$(version)/#Microsoft.DXSDK.D3DX-$(version).zip", {version = function(version)
        local ver = version_map[tostring(version)]
        return ver and ver or version
    end})
    add_versions("9.29.9528", "ead0906ae8a26c18a7525da7490127a2110f7c58f18293738283e30e97c6ea4b")

    add_configs("shared", { description = "Only shared binaries.", default = true, type = "boolean", readonly = true })

    on_install("windows|x64", "windows|x86", function(package)
        os.cp("build/native/include", package:installdir())
        os.cp(path.join("build/native", package:debug() and "debug" or "release", "lib/$(arch)/*.lib"), package:installdir("lib"))
        os.cp(path.join("build/native", package:debug() and "debug" or "release", "bin/$(arch)/*.dll"), package:installdir("bin"))
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            static void test() {
                std::cout << D3DXCreateSprite(nullptr,nullptr) << "\n";
            }
        ]]}, { includes = "d3dx9.h" }))
    end)
