package("flecs")

    set_homepage("https://github.com/SanderMertens/flecs")
    set_description("A fast entity component system (ECS) for C & C++")
    set_license("MIT")

    add_urls("https://github.com/SanderMertens/flecs.git")
    add_versions("v3.0.0", "8715faf3276f0970b80c28c2a8911f4ac86633d25ebab3d3c69521942769d7d4")
    add_versions("v2.4.8", "8b24c11b0513ee6ad3904165ed0927d59cbff2acc9bce0f8f989f493891d7deb")

    add_deps("cmake")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_install("windows", "macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DFLECS_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DFLECS_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            if package:config("shared") then
                package:add("defines", "flecs_EXPORTS")
            else
                package:add("defines", "flecs_STATIC")
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                flecs::world ecs;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "flecs.h"}))
    end)
