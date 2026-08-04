package("libbcrypt")
    set_homepage("https://github.com/trusch/libbcrypt")
    set_description("A c++ wrapper around bcrypt password hashing")
    set_license("MIT")

    add_urls("https://github.com/trusch/libbcrypt.git")

    add_versions("2021.06.22", "d6523c370de6e724ce4ec703e2449b5b028ea3b1")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                std::string password = "test";
                std::string hash = BCrypt::generateHash(password);

                BCrypt::validatePassword(password,hash);
                BCrypt::validatePassword("test1",hash);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "bcrypt/BCrypt.hpp"}))
    end)
