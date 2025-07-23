package("expresscpp")
    set_homepage("https://github.com/expresscpp/expresscpp.git")
    set_description("Fast, unopinionated, minimalist web framework for C++ Perfect for building REST APIs.")
    set_license("MIT")

    set_urls("https://github.com/expresscpp/expresscpp/archive/$(version).tar.gz",
             "https://github.com/expresscpp/expresscpp.git")

    add_versions("v0.20.0", "55f10531e4ba162ec768cf9c745ccc7b5a0930c7ad9974b268ad40246276baa8")

    add_patches("v0.20.0", "patches/v0.20.0/fix-build.diff", "09bc180fd8b52f0323d16f1f96bb3a07e2b2fdbe2a48a7a6731637a940d13157")

    add_deps("cmake")
    add_deps("nlohmann_json", "fmt", {configs = {cmake = true}})
    add_deps("boost", {configs = {asio = true}})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    elseif is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "mswsock")
    end

    on_install("!wasm", function (package)
        io.replace("CMakeLists.txt", [[if(MSVC)]], [[if(MSVC)
add_definitions(-DBOOST_ALL_NO_LIB)]], {plain = true})
        local configs = {}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "expresscpp/expresscpp.hpp"
            void test() {
              auto expresscpp = std::make_shared<expresscpp::ExpressCpp>();
              expresscpp->Get("/", [](auto /*req*/, auto res) { res->Send("hello world!"); });
              constexpr uint16_t port = 3000u;
              expresscpp->Listen(port,[=](auto /*ec*/) { std::cout << "Listening on port " << port << std::endl; }).Run();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
