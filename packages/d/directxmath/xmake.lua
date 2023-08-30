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

    add_deps("cmake")
    add_includedirs("include/directxmath")
    on_install("windows", "mingw", "linux", function (package)
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
