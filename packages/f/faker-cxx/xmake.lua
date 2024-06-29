package("faker-cxx")
    set_homepage("https://cieslarmichal.github.io/faker-cxx/")
    set_description("C++ Faker library for generating fake (but realistic) data.")
    set_license("MIT")

    add_urls("https://github.com/cieslarmichal/faker-cxx/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cieslarmichal/faker-cxx.git")

    add_versions("v2.0.0", "8a7f5441f4453af868444675878a2d9a74918c1595caa65d537d3ea327e46a49")

    add_deps("cmake")
    add_deps("fmt")

    on_install(function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DUSE_SYSTEM_DEPENDENCIES=ON", "-DUSE_STD_FORMAT=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        local cxflags
        if package:has_tool("cxx", "cl") then
            cxflags = "/utf-8"
            if package:config("shared") then
                table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
            end
        end
        import("package.tools.cmake").install(package, configs, {cxflags = cxflags})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                const auto id = faker::string::uuid();
            }
        ]]}, {configs = {languages = "c++20"}, includes = "faker-cxx/String.h"}))
    end)
