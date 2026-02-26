package("entt")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/skypjack/entt")
    set_description("Gaming meets modern C++ - a fast and reliable entity component system (ECS) and much more.")
    set_license("MIT")

    set_urls("https://github.com/skypjack/entt/archive/refs/tags/$(version).tar.gz",
             "https://github.com/skypjack/entt.git")

    add_versions("v3.16.0", "7d7b4037b737992342049ffab14f22fa10243e01664f8c3a0657aa247ac52f71")
    add_versions("v3.15.0", "01466fcbf77618a79b62891510c0bbf25ac2804af5751c84982b413852234d66")
    add_versions("v3.14.0", "e31f6e95a30e2977a50449ef9a607a9ff40febe6f9da2a8144a183f8606f7719")
    add_versions("v3.13.2", "cb556aa543d01177b62de41321759e02d96078948dda72705b3d7fe68af88489")
    add_versions("v3.13.1", "a4f290b601a70333126abd2cec7b0c232c74a4f85dcf1e04d969e8122dae8652")
    add_versions("v3.13.0", "dc0ab3ee136a1fe7f92df8898ff215dff1fe4d05d81b60144c7c0468446540a9")
    add_versions("v3.12.2", "3f3e43988218daecc0530ccaf45e960f7f7416e1fcf2c69799160c18b6a2fee3")
    add_versions("v3.12.1", "7dc4fc74cc32c1ec74b37419140d9334563bb22ab1b92ad9be580703da05b8ac")
    add_versions("v3.11.1", "0ac010f232d3089200c5e545bcbd6480cf68b705de6930d8ff7cdb0a29f5b47b")
    add_versions("v3.11.0", "7cca2bd4d4aeef6c5bdbe06b9e047e7f2519ebaff901207cc81ac71a2bbe185e")
    add_versions("v3.10.3", "315918fc678e89a326ce1c13b0e9d3e53882dd9c58a63fef413325917a5c753b")
    add_versions("v3.10.1", "f7031545130bfc06f5fe6b2f8c87dcbd4c1254fab86657e2788b70dfeea57965")
    add_versions("v3.10.0", "4c716cebf4f2964824da158dd58cc81d9f1e056a083538e22fb03ae2d64805ee")
    add_versions("v3.9.0", "1b06f1f6627c3702486855877bdeab6885f5d821d3dd78862126d4308c627c23")
    add_versions("v3.8.1", "a2b767f06bca67a73a4d71fb9ebb6ed823bb5146faad3c282b9dbbbdae1aa01b")
    add_versions("v3.8.0", "71c8ff5a604e8e214571a8b2218dfeaf61be59e2fe2ff5b550b4810c37d4da3c")
    add_versions("v3.7.1", "fe3ce773c17797c0c57ffa97f73902854fcc8e7afc7e09bea373e0c64fa24a23")
    add_versions("v3.7.0", "39ad5c42acf3434f8c37e0baa18a8cb562c0845383a6b4da17fdbacc9f0a7695")
    add_versions("v3.6.0", "94b7dc874acd0961cfc28cf6b0342eeb0b7c58250ddde8bdc6c101e84b74c190")

    -- https://github.com/skypjack/entt/issues/1188
    add_patches("v3.14.0", "https://github.com/xmake-mirror/entt/releases/download/v3.14.0/0a3c2cc4006157241665c6ccefc8b9676c1c752e.patch", "3f059d322244d64233ff2f37e9c80c8b28d92bf5b1bbef39e95cbc4d9ef0b132")

    add_deps("cmake")
    
    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::entt")
    end

    if on_check then
        on_check("android", function (package)
            if package:version():ge("3.14.0") then
                local ndk = package:toolchain("ndk"):config("ndkver")
                assert(ndk and tonumber(ndk) > 22, "package(entt) require ndk version > 22")
            end
        end)
    end

    on_install(function (package)
        local configs = {"-DENTT_BUILD_TESTING=OFF", "-DENTT_INSTALL=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
        os.cp("natvis/entt/*.natvis", package:installdir("include", "entt", "natvis"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <entt/entt.hpp>
            void test() {
                entt::registry r;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
