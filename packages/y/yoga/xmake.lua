package("yoga")
    set_homepage("https://yogalayout.com/")
    set_description("Yoga is a cross-platform layout engine which implements Flexbox. Follow https://twitter.com/yogalayout for updates.")
    set_license("MIT")

    add_urls("https://github.com/facebook/yoga/archive/refs/tags/$(version).tar.gz",
             "https://github.com/facebook/yoga.git")

    add_versions("v3.2.1", "86b399ac31fd820d8ffa823c3fae31bb690b6fc45301b2a8a966c09b5a088b55")
    add_versions("v3.2.0", "a963392c6c120a35f097b5b793d2b9b6684b94443ff873b0e521649a69a0b607")
    add_versions("v3.1.0", "06ff9e6df9b2388a0c6ef8db55ba9bc2ae75e716e967cd12cf18785f6379159e")
    add_versions("v3.0.4", "ef3ce5106eed03ab2e40dcfe5b868936a647c5f02b7ffd89ffaa5882dca3ef7f")
    add_versions("v3.0.3", "0ae44f7d30f8130cdf63e91293e11e34803afbfd12482fe4ef786435fc7fa8e7")
    add_versions("v3.0.2", "73a81c51d9ceb5b95cd3abcafeb4c840041801d59f5048dacce91fbaab0cc6f9")
    add_versions("v3.0.0", "da4739061315fd5b6442e0658c2541db24ded359f41525359d5e61edb2f45297")
    add_versions("v2.0.1", "4c80663b557027cdaa6a836cc087d735bb149b8ff27cbe8442fc5e09cec5ed92")

    add_configs("shared", {description = "Build shared binaries", default = false, type = "boolean", readonly = true})

    add_deps("cmake")

    if on_check then
        on_check(function (package)
            assert(package:check_cxxsnippets({test = [[
                #include <bit>
                #include <cstdint>
                void test() {
                    constexpr double f64v = 19880124.0; 
                    constexpr auto u64v = std::bit_cast<std::uint64_t>(f64v);
                }
            ]]}, {configs = {languages = "c++20"}}), "package(yoga) Require at least C++20.")
        end)
    end

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", "add_subdirectory(tests)", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("YGNodeNew", {includes = "yoga/Yoga.h"}))
    end)
