package("iguana")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/qicosmos/iguana")
    set_description("universal serialization engine")
    set_license("Apache-2.0")

    add_urls("https://github.com/qicosmos/iguana/archive/refs/tags/$(version).tar.gz",
             "https://github.com/qicosmos/iguana.git")

    add_versions("1.0.4", "b584cd26e65902a14a3a349ebc480beb7b4502fd5a5ffa3cb7c6102d857958b1")
    add_versions("v1.0.3", "7dcb21a36bd64a63a9ea857f3563ac61e965c49ec60ad7b99a2bfb9192f3e4c3")

    add_deps("frozen")

    on_install(function (package)
        if package:is_plat("android") and package:is_arch("arm.*") then
            import("core.tool.toolchain")

            local ndk = toolchain.load("ndk", {plat = package:plat(), arch = package:arch()})
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) > 22, "package(iguana): need c++20 stl for arm android")
        end

        os.vcp("iguana", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iguana/json_reader.hpp>
            struct some_obj {
                std::string_view name;
                iguana::numeric_str age;
            };
            REFLECTION(some_obj, name, age);
            void test() {
                some_obj obj;
                std::string_view str = "{\"name\":\"tom\", \"age\":20}";
                iguana::from_json(obj, str);
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
