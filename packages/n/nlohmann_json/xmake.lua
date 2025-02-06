package("nlohmann_json")
    set_kind("library", { headeronly = true })
    set_homepage("https://nlohmann.github.io/json/")
    set_description("JSON for Modern C++")
    set_license("MIT")

    add_urls("https://github.com/nlohmann/json/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nlohmann/json.git")

    add_versions("v3.11.3", "0d8ef5af7f9794e3263480193c491549b2ba6cc74bb018906202ada498a79406")
    add_versions("v3.11.2", "d69f9deb6a75e2580465c6c4c5111b89c4dc2fa94e3a85fcd2ffcd9a143d9273")
    add_versions("v3.10.5", "5daca6ca216495edf89d167f808d1d03c4a4d929cef7da5e10f135ae1540c7e4")
    add_versions("v3.10.0", "eb8b07806efa5f95b349766ccc7a8ec2348f3b2ee9975ad879259a371aea8084")
    add_versions("v3.9.1", "4cf0df69731494668bdd6460ed8cb269b68de9c19ad8c27abc24cd72605b2d5b")

    add_configs("cmake", {description = "Use cmake buildsystem", default = false, type = "boolean"})

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::nlohmann-json")
    elseif is_plat("linux") then
        add_extsources("pacman::nlohmann-json", "apt::nlohmann-json3-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::nlohmann-json")
    end

    on_load(function (package)
        if package:config("cmake") then
            package:add("deps", "cmake")
        end
    end)

    on_install(function (package)
        if package:config("cmake") then
            local configs = {"-DJSON_BuildTests=OFF"}
            import("package.tools.cmake").install(package, configs)
        else
            if os.isdir("include") then
                os.cp("include", package:installdir())
            else
                os.cp("*", package:installdir("include"))
            end
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using json = nlohmann::json;
            void test() {
                json data;
                data["name"] = "world";
            }
        ]]}, {configs = {languages = "c++14"}, includes = {"nlohmann/json.hpp"}}))
    end)
