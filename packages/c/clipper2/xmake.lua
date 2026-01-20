package("clipper2")
    set_homepage("https://github.com/AngusJohnson/Clipper2")
    set_description("Polygon Clipping and Offsetting - C++, C# and Delphi")
    set_license("BSL-1.0")

    add_urls("https://github.com/AngusJohnson/Clipper2/archive/refs/tags/Clipper2_$(version).tar.gz")
    add_urls("https://github.com/AngusJohnson/Clipper2.git", {alias = "git", includes = "CPP"})

    add_versions("1.5.4", "9d8a35a29d04cd1b7b45f542c0ba48015feece1210036ea9e4efaad3140af4b0")
    add_versions("1.4.0", "b83f71bb6a338f4f82116089c5ae867dbc43a2d651b5441380970dd966edd959")
    add_versions("1.3.0", "8e537ec320e140afaa8fba1f23120416693cc1d71b0f76ad801d24b88b5e0b3c")
    add_versions("1.2.4", "a013d391c25c5f665cdb5cbd75cdd842dcc28f6e1bd098454beb359f6f212f33")
    add_versions("1.2.3", "d65bd45f50331e9dd2de3c68137c6be069fe25732095bef0128d547c997b1fda")
    add_versions("1.2.2", "e893e3560383744a13b896225a1ae97cf910fa30125cad66264b18446b9f931e")

    add_versions("git:1.5.4", "Clipper2_1.5.4")

    add_configs("use_z", {description = "Build Clipper2Z", default = "OFF", type = "string", values = {"ON", "OFF", "ONLY"}})
    add_configs("hi_precision", {description = "Enable high precision (caution: will compromise performance)", default = false, type = "boolean"})
    add_configs("max_decimal_precision", {description = "Maximum decimal precision range", default = "8", type = "string"})

    if is_plat("linux") then
        add_syslinks("m")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("use_z") ~= "OFF" then
            package:add("defines", "USINGZ")
        end
        
        package:add("defines", "CLIPPER2_MAX_DECIMAL_PRECISION=" .. package:config("max_decimal_precision"))
        
        if package:config("hi_precision") then
            package:add("defines", "CLIPPER2_HI_PRECISION")
        end
    end)

    on_install(function (package)
        os.cd("CPP")
        io.replace("CMakeLists.txt", "-WX", "", {plain = true})
        io.replace("CMakeLists.txt", "-Werror", "", {plain = true})

        local configs = {"-DCLIPPER2_UTILS=OFF", "-DCLIPPER2_EXAMPLES=OFF", "-DCLIPPER2_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        table.insert(configs, "-DCLIPPER2_USINGZ=" .. package:config("use_z"))
        table.insert(configs, "-DCLIPPER2_HI_PRECISION=" .. (package:config("hi_precision") and "ON" or "OFF"))
        table.insert(configs, "-DCLIPPER2_MAX_DECIMAL_PRECISION=" .. package:config("max_decimal_precision"))
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
