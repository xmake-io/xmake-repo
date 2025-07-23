package("optional-lite")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/martinmoene/optional-lite")
    set_description("optional lite - A C++17-like optional, a nullable object for C++98, C++11 and later in a single-file header-only library")
    set_license("BSL-1.0")

    add_urls("https://github.com/martinmoene/optional-lite/archive/refs/tags/$(version).tar.gz",
             "https://github.com/martinmoene/optional-lite.git")

    add_versions("v3.6.0", "2be17fcfc764809612282c3e728cabc42afe703b9dc333cc87c48d882fcfc2c2")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <nonstd/optional.hpp>
            nonstd::optional<int> test() {
                return nonstd::nullopt;
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
