package("jwt-cpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://thalhammer.github.io/jwt-cpp/")
    set_description("A header only library for creating and validating json web tokens in c++")
    set_license("MIT")

    add_urls("https://github.com/Thalhammer/jwt-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Thalhammer/jwt-cpp.git")

    add_versions("v0.7.2", "6e815d86c168eb521a27937d603747dec0ca3c39ffc12d6fa72e2cf78a5b02d2")
    add_versions("v0.7.1", "e52f247d5e62fac5da6191170998271a70ce27f747f2ce8fde9b09f96a5375a4")
    add_versions("v0.7.0", "b9eb270e3ba8221e4b2bc38723c9a1cb4fa6c241a42908b9a334daff31137406")
    add_versions("v0.6.0", "0227bd6e0356b211341075c7997c837f0b388c01379bd256aa525566a5553f03")

    add_configs("picojson", {description = "Provide the picojson template specialiaze", default = false, type = "boolean"})
    add_configs("base64", {description = "Include the base64 implementation from this library", default = true, type = "boolean"})
    add_configs("ssl", {description = "Select ssl library", default = "openssl", type = "string", values = {"openssl", "openssl3", "libressl", "wolfssl"}})

    add_deps("cmake")

    on_load(function (package)
        package:add("deps", package:config("ssl"))
        if package:gitref() or package:version():le("0.7.0") then
            package:add("deps", "nlohmann_json", {configs = {cmake = true}})
        end

        if package:config("picojson") then
            package:add("deps", "picojson")
        else
            package:add("defines", "JWT_DISABLE_PICOJSON")
        end

        if not package:config("base64") then
            package:add("defines", "JWT_DISABLE_BASE64")
        end
    end)

    on_install("windows", "linux", "macosx", "bsd", "mingw", "msys", "android", "cross", function (package)
        if package:config("picojson") then
            io.replace("include/jwt-cpp/jwt.h", "picojson/picojson.h", "picojson.h", {plain = true})
            io.replace("include/jwt-cpp/traits/kazuho-picojson/traits.h", "picojson/picojson.h", "picojson.h", {plain = true})
            io.replace("CMakeLists.txt", "find_package(picojson 1.3.0 REQUIRED)", "", {plain = true})
        end

        local configs = {"-DJWT_BUILD_EXAMPLES=OFF", "-DJWT_EXTERNAL_NLOHMANN_JSON=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DJWT_DISABLE_PICOJSON=" .. (package:config("picojson") and "OFF" or "ON"))
        table.insert(configs, "-DJWT_EXTERNAL_PICOJSON=" .. (package:config("picojson") and "ON" or "OFF"))
        table.insert(configs, "-DJWT_DISABLE_BASE64=" .. (package:config("base64") and "OFF" or "ON"))

        local ssl = package:config("ssl")
        if ssl:startswith("openssl") then
            local openssl = package:dep(ssl)
            if not openssl:is_system() then
                table.insert(configs, "-DOPENSSL_ROOT_DIR=" .. openssl:installdir())
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        if package:config("picojson") then
            assert(package:check_cxxsnippets({test = [[
                #include <jwt-cpp/jwt.h>
                void test() {
                    std::string token;
                    auto decoded = jwt::decode(token);
                }
            ]]}, {configs = {languages = "c++11"}}))
        else
            assert(package:has_cxxincludes("jwt-cpp/jwt.h", {configs = {languages = "c++11"}}))
        end
    end)
