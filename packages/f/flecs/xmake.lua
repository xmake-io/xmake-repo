package("flecs")
    set_homepage("https://github.com/SanderMertens/flecs")
    set_description("A fast entity component system (ECS) for C & C++")
    set_license("MIT")

    add_urls("https://github.com/SanderMertens/flecs/archive/refs/tags/$(version).tar.gz",
             "https://github.com/SanderMertens/flecs.git")
    add_versions("v3.2.4", "0b65426053418911cae1c3f347748fba6eb7d4ae8860ce7fcc91ef25f386d4a1")
    add_versions("v3.0.0", "8715faf3276f0970b80c28c2a8911f4ac86633d25ebab3d3c69521942769d7d4")
    add_versions("v2.4.8", "9a8040a197e4b5e032524bc7183f68faa7b2f759c67b983b40018a7726561cac")

    add_patches("v3.2.4", path.join(os.scriptdir(), "patches", "v3.2.4", "freebsd_http_include.patch"), "39d7f2795b8c64b76d7f2aa6c3c5a10383df1234ff1bb441d62fd8fcaab8174b")

    add_deps("cmake")

    if is_plat("windows", "mingw") then
        add_syslinks("wsock32", "ws2_32")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("bsd") then
        add_syslinks("execinfo", "pthread")
    end

    on_load("windows", "mingw", function (package)
        if not package:config("shared") then
            package:add("defines", "flecs_STATIC")
        end
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DFLECS_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DFLECS_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DFLECS_PIC=" .. (package:config("pic") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                flecs::world ecs;
            }
        ]]}, {configs = {languages = "c++14"}, includes = "flecs.h"}))
    end)
