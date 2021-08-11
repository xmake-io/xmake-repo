package("farmhash")

    set_homepage("https://github.com/google/farmhash")
    set_description("FarmHash, a family of hash functions.")
    set_license("MIT")

    add_urls("https://github.com/google/farmhash.git")
    add_versions("2019.05.14", "0d859a811870d10f53a594927d0d0b97573ad06d")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    on_install("windows", "macosx", "linux", "mingw", function (package)
        os.cd("src")
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("farmhash")
                set_kind("static")
                set_languages("c++11")
                add_defines("FARMHASH_NO_BUILTIN_EXPECT")
                add_files("farmhash.cc")
                add_headerfiles("farmhash.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using namespace NAMESPACE_FOR_HASH_FUNCTIONS;
                char data[] = "hash";
                auto result = Hash(data, 4);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "farmhash.h"}))
    end)
