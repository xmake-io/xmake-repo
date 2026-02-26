package("flecs")
    set_homepage("https://github.com/SanderMertens/flecs")
    set_description("A fast entity component system (ECS) for C & C++")
    set_license("MIT")

    add_urls("https://github.com/SanderMertens/flecs/archive/refs/tags/$(version).tar.gz",
             "https://github.com/SanderMertens/flecs.git")

    add_versions("v4.1.4", "1ecd4b2b463388d1243c15a900dd62096b28cebba48ad76c204b562304945f0d")
    add_versions("v4.1.2", "9820e965339cca4659dc3b4547059d56889c707e9947e7cdae71847b00dafa9c")
    add_versions("v4.1.1", "4b3f2c073dcdbd2a62ce3e9fc5409504ab65acedacd9e3e650fd9a64ceac5881")
    add_versions("v4.1.0", "6eef84204d87f6eb2afc62fa6d11abece0cc051ba7a56d6775346ef8d9ebc88c")
    add_versions("v4.0.5", "9a129284b2e79d61bf855e8aa627fe04464aa58a4fb3ce92bd47f7080dbc878d")
    add_versions("v4.0.4", "a3b6238a913f65d90db18759ab5442393901da914e4a9bfe30aa8823687dce86")
    add_versions("v4.0.3", "feb5185bca93eeadeb641329bfa88adedf4bd7aea5a4d89ade055b65c3af0517")
    add_versions("v4.0.2", "131b703c30f53e08e30f2bac8da657276350b3f324a3321f753c3a9eccaa3f63")
    add_versions("v4.0.1", "d88928226b3a6e7ebc7c818db50b2fb5828021ed3bcd206c4e2a3b0406472d2b")
    add_versions("v4.0.0", "6c9826c8602f797acd775269d143763adfb3d3a93031cc81bced2b6d267469d2")
    add_versions("v3.2.12", "976551dabeecf3ae109648034b8dbc47f39f50226b6d71d76bace1d0b6e2d8ae")
    add_versions("v3.2.11", "8ebc5f6f3ec7bbba30b0afe9d22f157437925772857ea1c6e4201eb5d31b4fe5")
    add_versions("v3.2.10", "b799e85d47b3e5c2e631ebbd3b81cc6af4be574fccbe07099c58252182827a88")
    add_versions("v3.2.9", "65d50d6058cd38308a0ad2a971afa9f64aef899ebf78d6a074d905922ec5fdf8")
    add_versions("v3.2.8", "b40453a77b66e220408c50b119da54b153c248cf6f7025575e3fd1a8ff79f748")
    add_versions("v3.2.7", "45691b6d5f05f76d5f895b2f3b4efac9491be7eb2b21112f02381e2c5dfb853e")
    add_versions("v3.2.6", "ce3843eecfab359c8293366149bb0c0068ae8140583dd43d8337a8feccd7cb28")
    add_versions("v3.2.5", "d487aa39818978b5aaf94d96bdffe14ddee68c2fd969a765ce0b3561d6d574df")
    add_versions("v3.2.4", "0b65426053418911cae1c3f347748fba6eb7d4ae8860ce7fcc91ef25f386d4a1")
    add_versions("v3.0.0", "8715faf3276f0970b80c28c2a8911f4ac86633d25ebab3d3c69521942769d7d4")
    add_versions("v2.4.8", "9a8040a197e4b5e032524bc7183f68faa7b2f759c67b983b40018a7726561cac")

    add_patches("v3.2.4", path.join(os.scriptdir(), "patches", "v3.2.4", "freebsd_http_include.patch"), "39d7f2795b8c64b76d7f2aa6c3c5a10383df1234ff1bb441d62fd8fcaab8174b")

    add_deps("cmake")

    if is_plat("windows", "mingw") then
        add_syslinks("wsock32", "ws2_32", "Dbghelp")
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

        local pdb = path.join(package:buildir(), "flecs.pdb")
        os.trycp(pdb, package:installdir(package:config("shared") and "bin" or "lib"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                flecs::world ecs;
            }
        ]]}, {configs = {languages = "c++17"}, includes = "flecs.h"}))
    end)
