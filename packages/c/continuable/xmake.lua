package("continuable")
    set_kind("library", {headeronly = true})
    set_homepage("https://naios.github.io/continuable/")
    set_description("C++14 asynchronous allocation aware futures (supporting then, exception handling, coroutines and connections)")
    set_license("MIT")

    add_urls("https://github.com/Naios/continuable/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Naios/continuable.git", {submodules = false})

    add_versions("4.2.2", "49bf82a349b26c01194631e4fe5d1dbad080b3b4a347eebc5cf95326ea130fba")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")
    add_deps("function2")

    on_install(function (package)
        local configs =
        {
            "-DCTI_CONTINUABLE_WITH_INSTALL=ON",
            "-DCTI_CONTINUABLE_WITH_TESTS=OFF",
            "-DCTI_CONTINUABLE_WITH_EXAMPLES=OFF"
        }
        io.replace("CMakeLists.txt", "add_subdirectory(dep)", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <string>
            #include <continuable/continuable.hpp>
            cti::continuable<std::string> http_request(std::string /*url*/) {
                return cti::make_ready_continuable<std::string>("<html>...</html>");
            }
            void test() {
                http_request("github.com") && http_request("atom.io");
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
