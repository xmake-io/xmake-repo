package("ormpp")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/qicosmos/ormpp")
    set_description("modern C++ ORM, C++17, support mysql, postgresql,sqlite")
    set_license("Apache-2.0")

    set_urls("https://github.com/qicosmos/ormpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/qicosmos/ormpp.git")

    add_versions("v0.1.1", "a3c93599950a4c5822ebd0750ac7964c59c9b3f84f638525f01578bac6d898c2")

    add_configs("mysql", {description = "Using mysql", default = false, type = "boolean"})
    add_configs("postgresql", {description = "Using postgresql", default = false, type = "boolean"})
    add_configs("sqlite", {description = "Using sqlite", default = false, type = "boolean"})

    on_load("windows", "macosx", "linux", function(package) 
        local configs = {
            mysql = "ORMPP_ENABLE_MYSQL",
            postgresql = "ORMPP_ENABLE_PG",
            sqlite = "ORMPP_ENABLE_SQLITE3"
        }
    
        for config, define in pairs(configs) do
            if package:config(config) then
                package:add("deps", config)
                package:add("defines", define)
            end
        end
    end)

    on_install(function (package)
        os.cp("include/*", package:installdir("include"))
        os.cp("frozen/**", package:installdir("include/frozen"), {rootdir = "frozen"})
        os.cp("iguana/**", package:installdir("include/iguana"), {rootdir = "iguana"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace ormpp;
            struct student {
                std::string name;
                int age;
                int id;
            };
            REGISTER_AUTO_KEY(student, id)
            REFLECTION_WITH_NAME(student, "t_student", id, name, age)        
        ]]}, {configs = {languages = "c++17"}, includes = { "dbng.hpp"} }))
    end)
