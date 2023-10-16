package("uuid_v4")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/crashoz/uuid_v4")
    set_description("Super fast C++ library to generate and parse UUIDv4")
    set_license("MIT")

    add_urls("https://github.com/crashoz/uuid_v4/archive/refs/tags/$(version).tar.gz",
             "https://github.com/crashoz/uuid_v4.git")

    add_versions("v1.0.0", "0d858bc8e7466be693332f4f16768b29f605ff386443f37a07b1f872db29ff2d")

    on_load(function (package)
        if package:version():gt("1.0.0") then
            package:add("deps", "cmake")
        end
    end)

    on_install("windows|x64", "windows|x86", "linux", "macosx", "bsd", "mingw", "msys", function (package)
        if package:version():gt("1.0.0") then
            import("package.tools.cmake").install(package)
        else
            os.cp("uuid_v4.h", package:installdir("include"))
            os.cp("endianness.h", package:installdir("include"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <uuid_v4.h>
            void test() {
                UUIDv4::UUIDGenerator<std::mt19937_64> uuidGenerator;
                UUIDv4::UUID uuid = uuidGenerator.getUUID();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
