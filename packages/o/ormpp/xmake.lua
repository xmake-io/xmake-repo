package("ormpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/qicosmos/ormpp")
    set_description("modern C++ ORM, C++17, support mysql, postgresql,sqlite")
    set_license("Apache-2.0")

    set_urls("https://github.com/qicosmos/ormpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/qicosmos/ormpp.git")

    add_versions("0.1.3", "671f2f19965d630d7147f94dd12f4212a9cce58c5455f892f321f2243acb8ea4")
    add_versions("v0.1.2", "990e88eb176d996cdbbbdfa3e1522b48d135d809f14094771f8d6f02e94573c4")
    add_versions("v0.1.1", "a3c93599950a4c5822ebd0750ac7964c59c9b3f84f638525f01578bac6d898c2")

    add_configs("mysql", {description = "Using mysql", default = false, type = "boolean"})
    add_configs("postgresql", {description = "Using postgresql", default = false, type = "boolean"})
    add_configs("sqlite3", {description = "Using sqlite3", default = false, type = "boolean"})

    on_load(function (package)
        local iguana_vers = {
            ["0.1.3"] = "1.0.5",
            ["v0.1.2"] = "1.0.5",
            ["v0.1.1"] = "1.0.5",
        }
        if package:gitref() then
            package:add("deps", "iguana")
        else
            package:add("deps", "iguana " .. iguana_vers[package:version_str()])
        end

        local configs = {
            mysql = "ORMPP_ENABLE_MYSQL",
            postgresql = "ORMPP_ENABLE_PG",
            sqlite3 = "ORMPP_ENABLE_SQLITE3"
        }
    
        for config, define in pairs(configs) do
            if package:config(config) then
                package:add("deps", config)
                package:add("defines", define)
            end
        end
    end)

    on_install(function (package)
        if package:version() and package:version():lt("0.1.2") then
            os.vcp("include/*", package:installdir("include"))
        else
            os.vcp("ormpp/*", package:installdir("include"))
        end
    end)

    on_test(function (package)
        local languages = "c++17"
        if package:is_plat("windows") and package:is_arch("arm.*") then
            languages = "c++20"
        end

        local snippets
        if package:gitref() or package:version():gt("0.1.3") then
            snippets = [[
                #include <algorithm>
                #include <dbng.hpp>
                using namespace ormpp;
                struct person {
                    std::string name;
                    int age;
                    int id;
                };
                REGISTER_AUTO_KEY(person, id)
                YLT_REFL(person, id, name, age)
            ]]
        else
            snippets = [[
                #include <algorithm>
                #include <dbng.hpp>
                using namespace ormpp;
                struct student {
                    std::string name;
                    int age;
                    int id;
                };
                REGISTER_AUTO_KEY(student, id)
                REFLECTION_WITH_NAME(student, "t_student", id, name, age)
            ]]
        end
        assert(package:check_cxxsnippets({test = snippets}, {configs = {languages = languages}}))
    end)
