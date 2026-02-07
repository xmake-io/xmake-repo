package("gz-math")
    set_homepage("https://gazebosim.org/libs/math")
    set_description("General purpose math library for robot applications.")
    set_license("Apache-2.0")

    add_urls("https://github.com/gazebosim/gz-math/archive/refs/tags/gz-math9_$(version).tar.gz")
    add_urls("https://github.com/gazebosim/gz-math.git", {alias = "git"})

    add_versions("9.0.0", "e1eacfc2bf6b875ec270b6323cfaa8dfe043c9aaff9ceb8f87ff46e1cde9474a")

    add_versions("git:9.0.0", "gz-math9_9.0.0")

    add_includedirs("include", "include/gz/math9")

    add_deps("cmake", "gz-cmake 5.x")
    add_deps("eigen", "gz-utils 4.x")

    on_install(function (package)
        if not package:config("shared") then
            package:add("defines", "GZ_MATH_STATIC_DEFINE")
        end

        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                gz::math::Color a = gz::math::Color(0.3f, 0.4f, 0.5f);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "gz/math/Color.hh"}))
    end)
