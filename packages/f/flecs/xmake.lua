package("flecs")

    set_homepage("https://github.com/SanderMertens/flecs")
    set_description("A fast entity component system (ECS) for C & C++")
    set_license("MIT")

    add_urls("https://github.com/SanderMertens/flecs.git")
    add_versions("v3.0.1-alpha", "9d9a2fbea143a7237ae7020748180d896839e328a5d34bb769808abf904fcbf0")
    add_versions("v2.4.8", "8b24c11b0513ee6ad3904165ed0927d59cbff2acc9bce0f8f989f493891d7deb")

    add_deps("cmake")

    on_install("windows", "macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
				flecs::world ecs;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "flecs.h"}))
    end)