package("sqlite_orm")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/fnc12/sqlite_orm")
    set_description("SQLite ORM light header only library for modern C++")

    add_urls("https://github.com/fnc12/sqlite_orm/archive/refs/tags/v$(version).zip")
    add_versions("1.8.2", "dd098fe06b46640384b77fd937b694af105dab221ab45f574e4ff9bb38bbeb90")

    add_deps("sqlite3")

    on_install(function (package)
        os.cp("include", package:installdir())
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
