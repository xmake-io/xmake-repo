package("msgpack-cxx")

    set_homepage("https://msgpack.org/")
    set_description("MessagePack implementation for C++")
    set_license("BSL-1.0")

    add_urls("https://github.com/msgpack/msgpack-c/releases/download/cpp-$(version)/msgpack-cxx-$(version).tar.gz")
    add_versions("4.1.1", "8115c5edcf20bc1408c798a6bdaec16c1e52b1c34859d4982a0fb03300438f0b")

    add_configs("std", {description = "Choose C++ standard version.", default = "cxx17", type = "string", values = {"cxx98", "cxx11", "cxx14", "cxx17", "cxx20"}})

    add_deps("cmake", "boost")
    on_install("windows", "macosx", "linux", "mingw", function (package)
        local configs = {"-DMSGPACK_BUILD_EXAMPLES=OFF", "-DMSGPACK_BUILD_TESTS=OFF", "-DMSGPACK_BUILD_DOCS=OFF", "-DMSGPACK_USE_STATIC_BOOST=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("std") ~= "cxx98" then
            table.insert(configs, "-DMSGPACK_" .. package:config("std"):upper() .. "=ON")
        end
        if package:is_plat("windows") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
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
