package("eve")
    set_kind("library", {headeronly = true})
    set_homepage("https://jfalcou.github.io/eve/")
    set_description("Expressive Vector Engine - SIMD in C++ Goes Brrrr")
    set_license("BSL-1.0")

    add_urls("https://github.com/jfalcou/eve.git")
    add_versions("v2025.09.01", "b777741e9e9aa2902f91a2022d643db57b7d2de6")

    add_deps("cmake")

    if on_check then
        on_check(function (package)
            if package:is_plat("windows") and package:has_tool("cxx", "cl") then
                raise("package(eve) unsupported msvc toolchain now, you can use clang toolchain\nadd_requires(\"eve\", {configs = {toolchains = \"clang-cl\"}}))")
            elseif package:is_plat("android") then
                local ndk = package:toolchain("ndk"):config("ndkver")
                assert(ndk and tonumber(ndk) > 22, "package(eve) require ndk version > 22")
            end
        end)
    end

    on_install("!mingw", function (package)
        io.replace("cmake/config/eve-install.cmake", [[set(MAIN_DEST     "${CMAKE_INSTALL_LIBDIR}/eve-${PROJECT_VERSION}")]], [[set(MAIN_DEST     "${CMAKE_INSTALL_LIBDIR}/eve")]], {plain = true})
        io.replace("cmake/config/eve-install.cmake", [[set(INSTALL_DEST  "${CMAKE_INSTALL_INCLUDEDIR}/eve-${PROJECT_VERSION}")]], [[set(INSTALL_DEST  "${CMAKE_INSTALL_INCLUDEDIR}")]], {plain = true})
        io.replace("cmake/config/eve-install.cmake", [[set(DOC_DEST      "${CMAKE_INSTALL_DOCDIR}-${PROJECT_VERSION}")]], [[set(DOC_DEST      "${CMAKE_INSTALL_DOCDIR}")]], {plain = true})

        local configs = {"-DEVE_BUILD_TEST=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <eve/wide.hpp>
            void test() {
                eve::wide<float> x( [](auto i, auto) { return 1.f+i; } );
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
