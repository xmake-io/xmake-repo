package("msgpack-cxx")
    set_kind("library", {headeronly = true})
    set_homepage("https://msgpack.org/")
    set_description("MessagePack implementation for C++")
    set_license("BSL-1.0")

    add_urls("https://github.com/msgpack/msgpack-c/releases/download/cpp-$(version)/msgpack-cxx-$(version).tar.gz")
    add_versions("6.1.1", "5fd555742e37bbd58d166199e669f01f743c7b3c6177191dd7b31fb0c37fa191")
    add_versions("6.1.0", "23ede7e93c8efee343ad8c6514c28f3708207e5106af3b3e4969b3a9ed7039e7")
    add_versions("4.1.1", "8115c5edcf20bc1408c798a6bdaec16c1e52b1c34859d4982a0fb03300438f0b")

    add_configs("boost", {description = "Use Boost", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("boost") then
            package:add("deps", "boost")
        else
            package:add("defines", "MSGPACK_NO_BOOST")
        end
    end)

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets([[
            #include <sstream>
            void test() {
                msgpack::type::tuple<int, bool, std::string> src(1, true, "example");
                std::stringstream buffer;
                msgpack::pack(buffer, src);
            }
        ]], {configs = {languages = "cxx11"}, includes = "msgpack.hpp"}))
    end)
