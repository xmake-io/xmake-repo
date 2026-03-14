package("directxmath")

    set_kind("library", { headeronly = true })
    set_homepage("https://github.com/microsoft/DirectXMath")
    set_description("DirectXMath is an all inline SIMD C++ linear algebra library for use in games and graphics apps.")
    set_license("MIT")

    local tag = {
        ["2022.12"] = "dec2022",
        ["2024.02"] = "feb2024",
        ["2024.08"] = "oct2024",
        ["2025.04"] = "apr2025",
    }
    add_urls("https://github.com/microsoft/DirectXMath/archive/refs/tags/$(version).zip", { version = function (version) return tag[tostring(version)] end })
    add_urls("https://github.com/microsoft/DirectXMath.git")
    add_versions("2022.12", "2ed0ae7d7fe5d11ad11f6d3d9b31ce686024a551cf82ade723de86aa7b4b57e1")
    add_versions("2024.02", "214d71420107249dfb4bbc37a573f288b0951cc9ffe323dbf662101f3df4d766")
    add_versions("2024.08", "b215087ddd085381839c6fc6f51185579f3a1c55804190b2ccc5969e9520b0bd")
    add_versions("2025.04", "cef977ceb1ddb07cd864ba8498e4b205ce2ba9b45a215aad32e9d1a1e7bf00ae")

    if is_plat("linux", "macosx") then
        add_resources(">=2022.12", "headers", "https://raw.githubusercontent.com/dotnet/runtime/main/src/coreclr/pal/inc/rt/sal.h")
    end

    add_deps("cmake")
    add_includedirs("include/directxmath")

    on_install("windows", "mingw|x86_64", "linux", "macosx", function (package)
        if package:is_plat("linux", "macosx") then
            os.cp("../resources/headers/sal.h", package:installdir("include", "directxmath"))
        end

        local configs = { "-DBUILD_TESTING=OFF" }

        -- apr2025+ changed cmake install destination from include/directxmath to include
        if package:version():ge("2025.04") then
            table.insert(configs, "-DCMAKE_INSTALL_INCLUDEDIR=include/directxmath")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test( function (package)
        assert(package:check_cxxsnippets({ test = [[
            void test() {
                DirectX::XMVECTOR v = DirectX::XMVectorSet(1.0f, 2.0f, 3.0f, 4.0f);
                DirectX::XMMATRIX m = DirectX::XMMatrixIdentity();
                DirectX::XMVECTOR vResult = DirectX::XMVector4Transform(v, m);
            }
        ]] }, { configs = { languages = "cxx17" }, includes = "DirectXMath.h" }))
    end)
