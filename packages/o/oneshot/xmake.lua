package("oneshot")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/ashtum/oneshot")
    set_description("A single-header scheduler aware C++ oneshot channel.")
    set_license("BSL-1.0")

    add_urls("https://github.com/ashtum/oneshot.git")

    add_versions("2025.11.14", "57ab00d924d6436e3ee649be1a14a349fb52a8d0")

    add_configs("asio_standalone", {description = "Use standalone asio.", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("asio_standalone") then
            package:add("defines", "ONESHOT_ASIO_STANDALONE")
            package:add("deps", "asio")
        else
            package:add("deps", "boost", {configs = {asio = true}})
        end
    end)

    on_install("!wasm", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <oneshot.hpp>
            void test() {
                auto [sender, receiver] = oneshot::create<std::string>();
            }
        ]]}, {configs = {languages = "cxx17"}}))
    end)
