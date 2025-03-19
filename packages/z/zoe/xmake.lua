package("zoe")
    set_homepage("https://github.com/winsoft666/zoe")
    set_description("C++ File Download Library.")
    set_license("MIT")

    add_urls("https://github.com/winsoft666/zoe/archive/refs/tags/$(version).tar.gz",
             "https://github.com/winsoft666/zoe.git")

    add_versions("v3.6", "5cae2a51bbac0bfa54aab78a4d2b534a66bea7bc2d72764cfb5bc8e02a751927")

    add_deps("cmake", "libcurl")

    add_configs("openssl",      {description = "Enable openssl support", default = true, type = "boolean"})

    if is_plat("windows") then
        add_syslinks("ws2_32", "crypt32")
    elseif is_plat("linux", "bsd", "cross") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:config("openssl") then
            package:add("deps", "openssl")
        end
        if not package:config("shared") and package:is_plat("windows") then
            package:add("defines", "ZOE_STATIC")
        end
    end)

    on_install("!bsd and !wasm", function (package)
        io.replace("CMakeLists.txt", "set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)", "include(GNUInstallDirs)\nset(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})", {plain = true})
        io.replace("CMakeLists.txt", [[set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)]], [[set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})]], {plain = true})
        io.replace("CMakeLists.txt", [[set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)]], [[set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})]], {plain = true})
        local configs = {"-DZOE_BUILD_TESTS=OFF", "-DZOE_USE_STATIC_CRT=OFF"}
        table.insert(configs, "-DZOE_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                zoe::Zoe::GlobalInit();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "zoe/zoe.h"}))
    end)
