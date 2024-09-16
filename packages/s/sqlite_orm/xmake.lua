package("sqlite_orm")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/fnc12/sqlite_orm")
    set_description("SQLite ORM light header only library for modern C++")

    add_urls("https://github.com/fnc12/sqlite_orm/archive/refs/tags/$(version).tar.gz",
             "https://github.com/fnc12/sqlite_orm.git")

    add_versions("v1.9", "a2fa433e24f6873a9e8cd9dd7e49d2d12640b458f3f6f941163cf60f6673b8a2")
    add_versions("v1.8.2", "56e0c7729800637a8061658d0fdad4424d2cdde77b063d23cc1b76aa20339072")

    add_deps("cmake")
    add_deps("sqlite3")

    on_install(function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "sqlite_orm/sqlite_orm.h"
            using namespace sqlite_orm;
            struct User{
                int id;
                std::string firstName;
                std::string lastName;
                int birthDate;
                std::unique_ptr<std::string> imageUrl;
                int typeId;
            };

            struct UserType {
                int id;
                std::string name;
            };
            void test() {
                auto storage = make_storage("db.sqlite",
                                            make_table("users",
                                                    make_column("id", &User::id, primary_key().autoincrement()),
                                                    make_column("first_name", &User::firstName),
                                                    make_column("last_name", &User::lastName),
                                                    make_column("birth_date", &User::birthDate),
                                                    make_column("image_url", &User::imageUrl),
                                                    make_column("type_id", &User::typeId)),
                                            make_table("user_types",
                                                    make_column("id", &UserType::id, primary_key().autoincrement()),
                                                    make_column("name", &UserType::name, default_value("name_placeholder"))));
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
