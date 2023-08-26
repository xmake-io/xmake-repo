package("sobjectizer")
    set_homepage("https://stiffstream.com/en/products/sobjectizer.html")
    set_description("An implementation of Actor, Publish-Subscribe, and CSP models in one rather small C++ framework. With performance, quality, and stability proved by years in the production.")

    add_urls("https://github.com/Stiffstream/sobjectizer/archive/refs/tags/$(version).tar.gz"
    , {version = function (version) return "v." .. version end})
    add_urls("https://github.com/Stiffstream/sobjectizer.git")

    add_versions("5.8.0", "de2b4ae0e817a108dae6d6787c79ed84c33bd447842b5fdcb780f6697b4c2d49")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DBUILD_ALL=OFF", "-DBUILD_EXAMPLES=OFF", "-DBUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DSOBJECTIZER_BUILD_STATIC=OFF")
            table.insert(configs, "-DSOBJECTIZER_BUILD_SHARED=ON")
        else
            table.insert(configs, "-DSOBJECTIZER_BUILD_STATIC=ON")
            table.insert(configs, "-DSOBJECTIZER_BUILD_SHARED=OFF")
        end

        os.cd("dev")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <so_5/all.hpp>
            class hello_actor final : public so_5::agent_t {
            public:
                using so_5::agent_t::agent_t;
                void so_evt_start() override {
                    std::cout << "Hello, World!" << std::endl;
                    so_deregister_agent_coop_normally();
                }
            };
            void test() {
                so_5::launch([](so_5::environment_t & env) {
                        env.register_agent_as_coop( env.make_agent<hello_actor>() );
                    });
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
