package("daemonpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/baderouaich/daemonpp")
    set_description("Simple C++ header only template for creating Linux daemons")
    set_license("MIT")

    add_urls("https://github.com/baderouaich/daemonpp.git")
    add_versions("2023.05.01", "0989a8296e1f8b4075db7deb0c3474a5d3780954")

    on_install("linux", function (package)
        os.cp("include/*", package:installdir("include/daemonpp"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <chrono>
            #include <daemonpp/daemon.hpp>

            using namespace daemonpp;

            class my_daemon : public daemon
            {
            public:
                void on_start(const dconfig& cfg) override {
                    dlog::info("my_daemon::on_start(): my_daemon version: " + cfg.get("version") + " started successfully!");
                }
                void on_update() override {
                    dlog::info("my_daemon::on_update()");
                }
                void on_stop() override {
                    dlog::info("my_daemon::on_stop()");
                }
                void on_reload(const dconfig& cfg) override {
                    dlog::info("my_daemon::on_reload(): new daemon version from updated config: " + cfg.get("version"));
                }
            };

            int test(int argc, const char* argv[]) {
                my_daemon dmn;
                dmn.set_name("my_daemon");
                dmn.set_update_duration(std::chrono::seconds(3));
                dmn.set_cwd("/");
                dmn.run(argc, argv);
                return 0;
            }
        ]]}, {configs = {languages = "cxx11"}}))
    end)
