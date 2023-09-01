package("fruit")
    set_homepage("https://github.com/google/fruit/wiki")
    set_description("Fruit, a dependency injection framework for C++")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/fruit/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/fruit.git")

    add_versions("v3.7.0", "134d65c8e6dff204aeb771058c219dcd9a353853e30a3961a5d17a6cff434a09")
    add_versions("v3.7.1", "ed4c6b7ebfbf75e14a74e21eb74ce2703b8485bfc9e660b1c36fb7fe363172d0")

    add_configs("boost", {description = "Whether to use Boost (specifically, boost::unordered_set and boost::unordered_map).If this is false, Fruit will use std::unordered_set and std::unordered_map instead (however this causes injection to be a bit slower).", default = false, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("m")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("boost") then
            package:add("deps", "boost")
        end
    end)

    on_install(function (package)
        local configs = {"-DFRUIT_ENABLE_COVERAGE=OFF", "-DRUN_TESTS_UNDER_VALGRIND=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DFRUIT_USES_BOOST=" .. (package:config("boost") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <fruit/fruit.h>
            class Writer {
            public:
                virtual void write(std::string s) = 0;
            };

            class StdoutWriter : public Writer {
            public:
                INJECT(StdoutWriter()) = default;
                virtual void write(std::string s) override {}
            };

            class Greeter {
            public:
                virtual void greet() = 0;
            };

            class GreeterImpl : public Greeter {
            private:
                Writer* writer;
            public:
                INJECT(GreeterImpl(Writer* writer)) : writer(writer) {}
                virtual void greet() override {
                    writer->write("Hello world!\n");
                }
            };
            fruit::Component<Greeter> test() {
                return fruit::createComponent()
                    .bind<Writer, StdoutWriter>()
                    .bind<Greeter, GreeterImpl>();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
