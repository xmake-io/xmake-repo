package("lsp-framework")
    set_homepage("https://github.com/leon-bckl/lsp-framework")
    set_description("Language Server Protocol implementation in C++")
    set_license("MIT")

    add_urls("https://github.com/leon-bckl/lsp-framework/archive/refs/tags/$(version).tar.gz",
             "https://github.com/leon-bckl/lsp-framework.git")

    add_versions("1.0.1", "07f924d851896a2d424d554d20820483f8458aa1ff907bb68657b0d2d0bd0d13")

    add_patches("1.0.1", "patches/1.0.1/fix-install.diff", "bb5e4436091ba1846144ffa80fb8afd4d0213760bce45dd6fd31662905cb4bc3")
    add_patches("1.0.1", "patches/1.0.1/fix-missing-ios.diff", "8447605c2ed14cfbf394b29ffe2348e2179424504100aa01cd88b3d054e5ceb1")

    add_deps("cmake")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    elseif is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    end

    if on_check then
        on_check("windows|arm64", function (package)
            import("core.base.semver")
            local vs = package:toolchain("msvc"):config("vs")
            assert(tonumber(vs) >= 2022, "lsp-framework requires Visual Studio 2022 and later for arm64 targets")
            assert(os.arch() == "arm64", "package(lsp-framework): requires host arch to be arm64.")
        end)
    end

    on_install("windows", "linux", "macosx", "mingw@windows", "bsd", function (package)
        local configs = {}
        table.insert(configs, "-DLSP_USE_SANITIZERS=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <lsp/messages.h>
            #include <lsp/connection.h>
            #include <lsp/io/standardio.h>
            #include <lsp/messagehandler.h>
            void test() {
                auto connection     = lsp::Connection(lsp::io::standardIO());
                auto messageHandler = lsp::MessageHandler(connection);
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
