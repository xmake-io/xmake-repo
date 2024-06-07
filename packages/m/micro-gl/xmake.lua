package("micro-gl")
    set_kind("library", {headeronly = true})
    set_homepage("http://micro-gl.github.io/docs/microgl")
    set_description("Realtime, Embeddable, Modular, Headers Only C++11 CPU vector graphics. no STD lib, no FPU and no GPU required !")

    add_urls("https://github.com/micro-gl/micro-gl.git")
    add_versions("2023.08.30", "1cc67998795a810ca721b09815cc18e29f9f291f")

    add_deps("cmake")

    on_install(function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(examples)", "", {plain = true})
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <microgl/color.h>
            using RGB_5650 = microgl::rgba_t<5,6,5,0>;
            void test() {
                auto r_bits = RGB_5650::r;
                auto g_bits = RGB_5650::g;
                auto b_bits = RGB_5650::b;
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
