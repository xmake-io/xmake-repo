package("msgpack-cxx")
    set_kind("library", {headeronly = true})
    set_homepage("https://msgpack.org/")
    set_description("MessagePack implementation for C++")
    set_license("BSL-1.0")

    add_urls("https://github.com/msgpack/msgpack-c/releases/download/cpp-$(version)/msgpack-cxx-$(version).tar.gz")
    add_versions("7.0.0", "7504b7af7e7b9002ce529d4f941e1b7fb1fb435768780ce7da4abaac79bb156f")
    add_versions("6.1.1", "5fd555742e37bbd58d166199e669f01f743c7b3c6177191dd7b31fb0c37fa191")
    add_versions("6.1.0", "23ede7e93c8efee343ad8c6514c28f3708207e5106af3b3e4969b3a9ed7039e7")
    add_versions("4.1.1", "8115c5edcf20bc1408c798a6bdaec16c1e52b1c34859d4982a0fb03300438f0b")

    add_configs("std", {description = "Choose C++ standard version.", default = "cxx17", type = "string", values = {"cxx98", "cxx11", "cxx14", "cxx17", "cxx20"}})
    add_configs("boost", {description = "Use Boost", default = is_plat("macosx", "linux", "windows", "bsd", "mingw", "cross"), type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("boost") then
            package:add("deps", "boost")
        else
            package:add("defines", "MSGPACK_NO_BOOST")
        end
    end)

    on_install(function (package)
        local configs = {"-DMSGPACK_BUILD_EXAMPLES=OFF", "-DMSGPACK_BUILD_TESTS=OFF", "-DMSGPACK_BUILD_DOCS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("std") ~= "cxx98" then
            table.insert(configs, "-DMSGPACK_" .. package:config("std"):upper() .. "=ON")
        end
        if package:config("boost") then
            table.insert(configs, "-DMSGPACK_USE_STATIC_BOOST=ON")
            table.insert(configs, "-DMSGPACK_USE_BOOST=ON")
        else
            table.insert(configs, "-DMSGPACK_USE_BOOST=OFF")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets([[
            #include <sstream>
            void test() {
                msgpack::type::tuple<int, bool, std::string> src(1, true, "example");
                std::stringstream buffer;
                msgpack::pack(buffer, src);
            }
        ]], {configs = {languages = package:config("std")}, includes = "msgpack.hpp"}))
    end)
