package("actor-framework")
    set_homepage("http://actor-framework.org/")
    set_description("An Open Source Implementation of the Actor Model in C++")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/actor-framework/actor-framework/archive/refs/tags/$(version).tar.gz",
             "https://github.com/actor-framework/actor-framework.git")

    add_versions("1.0.2", "ef4dd00ca7c59cd61dc336b6a8efbd6150ca85c404d213ecb61f6bcee4094ffc")
    add_versions("1.0.1", "635bdd6e3b70886f1d9aa75c48e5bdb4084afae1f159bbfe5ea91f99b0460f6b")
    add_versions("1.0.0", "602018239d23a1805d35ebda704fd5c969a0693fc513fcf7459063b628459e5b")
    add_versions("0.19.6", "48dc4c4abf5ab5a7c6f84b9259cc8be1b02c601d31893647ab44e143cdc4b6d5")
    add_versions("0.19.2", "aa3fcc494424e0e20b177125458a6a6ed39c751a3d3d5193054e88bdf8a146d2")

    add_configs("profiler", {description = "Enable experimental profiler API", default = false, type = "boolean"})
    add_configs("runtime_checks", {description = "Build CAF with extra runtime assertions", default = false, type = "boolean"})
    add_configs("exceptions", {description = "Build CAF with support for exceptions", default = true, type = "boolean"})
    add_configs("io", {description = "Build legacy networking I/O module", default = false, type = "boolean"})
    add_configs("net", {description = "Build networking I/O module", default = false, type = "boolean"})
    add_configs("openssl", {description = "Build OpenSSL module", default = false, type = "boolean"})

    if is_plat("windows") then
        add_syslinks("iphlpapi")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    elseif is_plat("macosx") then
        add_extsources("brew::caf")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("net") or package:config("openssl") then
            package:add("deps", "openssl")
        end
    end)

    on_install("windows", "linux", "macosx", "bsd", function (package)
        io.replace("CMakeLists.txt", "add_library(libcaf_test)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(libcaf_test)", "", {plain = true})

        local configs =
        {
            "-DCAF_ENABLE_EXAMPLES=OFF",
            "-DCAF_ENABLE_TESTING=OFF",
            "-DCAF_ENABLE_TOOLS=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCAF_ENABLE_ACTOR_PROFILER=" .. (package:config("profiler") and "ON" or "OFF"))
        table.insert(configs, "-DCAF_ENABLE_RUNTIME_CHECKS=" .. (package:config("runtime_checks") and "ON" or "OFF"))
        table.insert(configs, "-DCAF_ENABLE_EXCEPTIONS=" .. (package:config("exceptions") and "ON" or "OFF"))
        table.insert(configs, "-DCAF_ENABLE_IO_MODULE=" .. (package:config("io") and "ON" or "OFF"))
        table.insert(configs, "-DCAF_ENABLE_NET_MODULE=" .. (package:config("net") and "ON" or "OFF"))
        table.insert(configs, "-DCAF_ENABLE_OPENSSL_MODULE=" .. (package:config("openssl") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <caf/actor_ostream.hpp>
            #include <caf/actor_system.hpp>
            #include <caf/event_based_actor.hpp>
            using namespace caf;
            void test(event_based_actor* self, const actor& buddy) {
                self->request(buddy, std::chrono::seconds(10), "Hello World!")
                    .then([=](const std::string& what) {
                        aout(self) << what << std::endl;
                    });
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
