package("webthing-cpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/bw-hro/webthing-cpp")
    set_description("Webthing-CPP is a modern CPP/C++17 implementation of the WebThings API.")
    set_license("MIT")

    add_urls("https://github.com/bw-hro/webthing-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/bw-hro/webthing-cpp.git")

    add_versions("v1.2.0", "95d527bf8e2cef9221a42519b4798fda7d0866abd7ccaf21d57a629168a94ccc")
    add_versions("v1.1.0", "7f32651813168b7a51f95005be626cfaf30868db134a5bf9ca491a9d07949f5a")

    add_configs("ssl", {description = "Build with SSL", default = true, type = "boolean"})

    if is_plat("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end

    add_deps("cmake", "mdns", "libuv", "zlib", "json-schema-validator")
    add_deps("uwebsockets", {configs = {zip = true}})
    add_deps("usockets", {configs = {ssl = "openssl"}})
    add_deps("nlohmann_json", {configs = {cmake = true}})

    on_load(function (package)
        if package:config("ssl") then
            package:add("deps", "openssl")
        end
    end)

    on_install("linux", "macosx", "windows", function (package)
        io.replace("CMakeLists.txt", "find_package(unofficial-uwebsockets CONFIG REQUIRED)", [[
            find_package(PkgConfig QUIET)
            pkg_check_modules(uwebsockets REQUIRED IMPORTED_TARGET uwebsockets)
        ]], {plain = true})
        io.replace("CMakeLists.txt", "unofficial::uwebsockets::uwebsockets", "PkgConfig::uwebsockets")
        local configs = {"-DWT_BUILD_EXAMPLES=OFF", "-DWT_BUILD_TESTS=OFF"}
        table.insert(configs, "-DWT_WITH_SSL=" .. (package:config("ssl") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace bw::webthing;
            void test() {
                auto thing = make_thing("urn:gui-thing-123", "The WebThing Slot Machine", "SLOT_MACHINE_THING", "A slot machine thing with GUI");
            }
        ]]}, {configs = {languages = "c++17"}, includes = "bw/webthing/webthing.hpp"}))
    end)
