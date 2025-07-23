package("kdbindings")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/KDAB/KDBindings")
    set_description("Reactive programming & data binding in C++")
    set_license("MIT")

    add_urls("https://github.com/KDAB/KDBindings/archive/refs/tags/$(version).tar.gz",
             "https://github.com/KDAB/KDBindings.git")

    add_versions("v1.1.0", "0ee07cb3e2ec4f5688b4b2971c42e5a4f4a41c7bf4aa130e6b118bea4b6340ab")
    add_versions("v1.0.5", "4d001419809a719f8c966e9bc73f457180325655deca0a11c07c47ee112447a3")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package, {
            "-DKDBindings_TESTS=OFF",
            "-DKDBindings_EXAMPLES=OFF"
        })
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                KDBindings::Signal<int, int> signal;
                signal.connect([](int arg1, int arg2) {});
                signal.emit(0, 1);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "kdbindings/signal.h"}))
    end)
