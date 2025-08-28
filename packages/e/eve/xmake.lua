package("eve")
    set_kind("library", {headeronly = true})
    set_homepage("https://jfalcou.github.io/eve/")
    set_description("Expressive Vector Engine - SIMD in C++ Goes Brrrr")
    set_license("BSL-1.0")

    add_urls("https://github.com/jfalcou/eve/archive/refs/tags/$(version).tar.gz", {excludes = {"*.paxheader", "*.data"}})
    add_urls("https://github.com/jfalcou/eve.git")

    add_versions("v2023.02.15", "7a5fb59c0e6ef3bef3e8b36d62e138d31e7f2a9f1bdfe95a8e96512b207f84c5")

    add_deps("cmake")

    on_install(function (package)
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
