package("boost_di")
    set_kind("library", {headeronly = true})
    set_homepage("https://boost-ext.github.io/di")
    set_description("DI: C++14 Dependency Injection Library")

    add_urls("https://github.com/boost-ext/di/archive/refs/tags/$(version).tar.gz",
             "https://github.com/boost-ext/di.git")

    add_versions("v1.3.0", "853e02ade9bf39f2863b470350c3ef55caffc3090d7d9a503724ff480c8d7eff")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <boost/di.hpp>
            namespace di = boost::di;
            class ctor {
            public:
                explicit ctor(int i) : i(i) {}
                int i;
            };
            struct aggregate {
                double d;
            };
            class example {
                public:
                example(aggregate a, const ctor& c) {}
            };
            void test() {
                const auto injector = di::make_injector(
                    di::bind<int>.to(42),
                    di::bind<double>.to(87.0)
                );
                injector.create<example>();
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
