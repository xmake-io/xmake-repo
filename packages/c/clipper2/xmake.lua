package("clipper2")
    set_homepage("https://github.com/AngusJohnson/Clipper2")
    set_description("Polygon Clipping and Offsetting - C++, C# and Delphi")
    set_license("BSL-1.0")

    add_urls("https://github.com/AngusJohnson/Clipper2/archive/refs/tags/Clipper2_$(version).tar.gz",
             "https://github.com/AngusJohnson/Clipper2.git")

    add_versions("1.3.0", "8e537ec320e140afaa8fba1f23120416693cc1d71b0f76ad801d24b88b5e0b3c")
    add_versions("1.2.4", "a013d391c25c5f665cdb5cbd75cdd842dcc28f6e1bd098454beb359f6f212f33")
    add_versions("1.2.3", "d65bd45f50331e9dd2de3c68137c6be069fe25732095bef0128d547c997b1fda")
    add_versions("1.2.2", "e893e3560383744a13b896225a1ae97cf910fa30125cad66264b18446b9f931e")

    add_configs("use_z", {description = "Build Clipper2Z", default = "OFF", type = "string", values = {"ON", "OFF", "ONLY"}})

    if is_plat("linux") then
        add_syslinks("m")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DCLIPPER2_UTILS=OFF", "-DCLIPPER2_EXAMPLES=OFF", "-DCLIPPER2_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCLIPPER2_USINGZ=" .. package:config("use_z"))
        if package:config("use_z") ~= "OFF" then
            package:add("defines", "USINGZ")
        end

        os.cd("CPP")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <clipper2/clipper.h>
            using namespace Clipper2Lib;
            void test() {
                Paths64 subject, clip, solution;
                subject.push_back(MakePath({100, 50, 10, 79, 65, 2, 65, 98, 10, 21}));
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
