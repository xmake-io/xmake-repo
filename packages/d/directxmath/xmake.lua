package("directxmath")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/microsoft/DirectXMath")
    set_description("DirectXMath is an all inline SIMD C++ linear algebra library for use in games and graphics apps.")
    set_license("MIT")

    local tag = {
        ["2022.12"] = "dec2022",
    }
    add_urls("https://github.com/microsoft/DirectXMath/archive/refs/tags/$(version).zip", {version = function (version) return tag[tostring(version)] end})
    add_urls("https://github.com/microsoft/DirectXMath.git")
    add_versions("2022.12", "2ed0ae7d7fe5d11ad11f6d3d9b31ce686024a551cf82ade723de86aa7b4b57e1")

    add_resources("2022.12", "headers", "https://raw.githubusercontent.com/dotnet/runtime/2201016c1e13bdb9abf49e2e38cadf4ee0568df2/src/coreclr/pal/inc/rt/sal.h", "7dae281adc3a09a691291fb90526f05e4f9ef8b16d7f33d716ba690f7241a492")

    add_deps("cmake")
    add_includedirs("include/directxmath")

    on_install("windows", "mingw", "linux", function (package)
        if package:is_plat("linux") then
            os.cp("../resources/headers/sal.h", package:installdir("include"))
        end
        import("package.tools.cmake").install(package, {"-DBUILD_TESTING=OFF"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                DirectX::XMVECTOR v = DirectX::XMVectorSet(1.0f, 2.0f, 3.0f, 4.0f);
                DirectX::XMMATRIX m = DirectX::XMMatrixIdentity();
                DirectX::XMVECTOR vResult = DirectX::XMVector4Transform(v, m);
            }
        ]]}, {configs = {languages = "cxx17"}, includes = "DirectXMath.h"}))
    end)
