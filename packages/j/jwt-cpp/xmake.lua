package("jwt-cpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://thalhammer.github.io/jwt-cpp/")
    set_description("A header only library for creating and validating json web tokens in c++")
    set_license("MIT")

    add_urls("https://github.com/Thalhammer/jwt-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Thalhammer/jwt-cpp.git")

    add_versions("v0.6.0", "0227bd6e0356b211341075c7997c837f0b388c01379bd256aa525566a5553f03")

    add_configs("picojson", {description = "Use picojson", default = true, type = "boolean"})

    add_deps("openssl")

    on_load(function (package)
        if package:config("picojson") then
            package:add("deps", "picojson")
        else
            package:add("defines", "JWT_DISABLE_PICOJSON")
        end
    end)

    on_install("windows", "linux", "macosx", "bsd", "mingw", "msys", "android", "cross", function (package)
        if package:config("picojson") then
            io.replace("include/jwt-cpp/jwt.h", "picojson/picojson.h", "picojson.h", {plain = true})
            io.replace("include/jwt-cpp/traits/kazuho-picojson/traits.h", "picojson/picojson.h", "picojson.h", {plain = true})
        end
        os.cp("include/jwt-cpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <jwt-cpp/jwt.h>
            void test() {
                std::string token;
                auto decoded = jwt::decode(token);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
