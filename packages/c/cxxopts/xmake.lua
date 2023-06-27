package("cxxopts")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/jarro2783/cxxopts")
    set_description("Lightweight C++ command line option parser")
    set_license("MIT")

    add_urls("https://github.com/jarro2783/cxxopts.git")
    add_urls("https://github.com/jarro2783/cxxopts/archive/$(version).tar.gz")
    add_versions("v3.1.1", "523175f792eb0ff04f9e653c90746c12655f10cb70f1d5e6d6d9491420298a08")
    add_versions("v3.0.0", "36f41fa2a46b3c1466613b63f3fa73dc24d912bc90d667147f1e43215a8c6d00")
    add_versions("v2.2.0", "447dbfc2361fce9742c5d1c9cfb25731c977b405f9085a738fbd608626da8a4d")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::cxxopts")
    elseif is_plat("linux") then
        add_extsources("pacman::cxxopts-git", "apt::libcxxopts-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::cxxopts")
    end

    add_deps("cmake")
    on_install(function (package)
        local configs = {"-DCXXOPTS_BUILD_EXAMPLES=OFF", "-DCXXOPTS_BUILD_TESTS=OFF"}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            static void test() {
                cxxopts::Options options("MyProgram", "One line description of MyProgram");
                options.add_options()
                  ("d,debug", "Enable debugging") // a bool parameter
                  ("i,integer", "Int param", cxxopts::value<int>())
                  ("f,file", "File name", cxxopts::value<std::string>())
                  ("v,verbose", "Verbose output", cxxopts::value<bool>()->default_value("false"));
            }
        ]]}, {configs = {languages = "c++11"}, includes = "cxxopts.hpp"}))
    end)

