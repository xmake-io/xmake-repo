package("pegtl")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/taocpp/PEGTL")
    set_description("Parsing Expression Grammar Template Library")
    set_license("BSL-1.0")

    add_urls("https://github.com/taocpp/PEGTL/archive/refs/tags/$(version).tar.gz",
             "https://github.com/taocpp/PEGTL.git")

    add_versions("2.8.3", "88b8e4ded6ea1f3f2223cc3e37072e2db1e123b90d36c309816341ae9d966723")
    add_versions("3.2.2", "c6616275e78c618c016b79054eed0a0bdf4c1934f830d3ab33d3c3dac7320b03")
    add_versions("3.2.5", "4ecefe4151b14684a944dde57e68c98e00224e5fea055c263e1bfbed24a99827")
    add_versions("3.2.7", "d6cd113d8bd14e98bcbe7b7f8fc1e1e33448dc359e8cd4cca30e034ec2f0642d")
    add_versions("3.2.8", "319e8238daebc3a163f60c88c78922a8012772076fdd64a8dafaf5619cd64773")

    add_deps("cmake")

    if is_plat("linux") then
        add_extsources("apt::tao-pegtl-dev", "pacman::pegtl")
    elseif is_plat("macosx") then
        add_extsources("brew::pegtl")
    elseif is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::pegtl")
    end

    on_install(function (package)
        import("package.tools.cmake").install(package, {"-DPEGTL_BUILD_TESTS=OFF", "-DPEGTL_BUILD_EXAMPLES=OFF"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <tao/pegtl.hpp>
            void test(int argc, char *argv[]) {
                tao::pegtl::argv_input in(argv, 1);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
