package("beman-execution")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/bemanproject/execution")
    set_description("Implementation of the std::execution (P2300, sender/receiver) proposal")
    set_license("Apache-2.0 WITH LLVM-exception")

    add_urls("https://github.com/bemanproject/execution/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/bemanproject/execution.git")
    add_versions("0.3.0", "0d39803334acca5177ce5bde306a4260eed5b4d1df8c690d4cd50144e793ac28")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    if on_check then
        on_check(function (package)
            import("core.base.semver")
            -- gcc 14 fails with an internal compiler error when connecting senders
            if package:has_tool("cxx", "gcc") then
                local gccver = try {function () return os.iorunv(package:tool("cxx"), {"-dumpfullversion"}):trim() end}
                assert(not gccver or semver.match(gccver):ge("15"),
                       "package(beman-execution): require gcc >= 15, gcc 14 fails with an internal compiler error")
            end
            -- clang with an old libstdc++ cannot instantiate std::forward_like in a deduced return type
            assert(package:check_cxxsnippets({test = [[
                #include <utility>
                struct s {};
                template <typename T, typename U>
                constexpr auto fwd(U&& u) noexcept -> decltype(auto) {
                    return std::forward_like<T>(std::forward<U>(u));
                }
                void test() {
                    s v;
                    (void)fwd<s&>(v);
                }
            ]]}, {configs = {languages = "c++23"}}),
                "package(beman-execution): require a C++23 standard library providing std::forward_like")
        end)
    end

    on_install("linux", "windows", "mingw", "msys", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <beman/execution.hpp>
            void test() {
                auto result = beman::execution::sync_wait(beman::execution::just(42));
                static_assert(std::is_same_v<decltype(result), std::optional<std::tuple<int>>>);
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)
