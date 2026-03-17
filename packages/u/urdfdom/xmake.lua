package("urdfdom")
    set_homepage("https://wiki.ros.org/urdf")
    set_description("A C++ parser for the Unified Robot Description Format (URDF)")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/ros/urdfdom/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ros/urdfdom.git")

    add_versions("5.0.4", "f47165c5f4d321216dbcd50d79bfccc459993b113400f507d8d72196388f9c7b")
    add_versions("5.0.3", "c98412daaa7498ecea2f2c68ce1c27767113d137468eb26b7dcfa291cba615b4")
    add_versions("5.0.2", "f929a33ec6171a57d4ff7d4c0eff6fb79d4725c279189d4f4c8806c4aa4e71ac")
    add_versions("4.0.1", "46b122c922f44ec32674a56e16fd4b5d068b53265898cbea2c3e1939ecccc62a")
    add_versions("4.0.0", "9848d106dc88dc0b907d5667c09da3ca53241fbcf17e982d8c234fe3e0d6ddcc")
    add_versions("1.0.4", "8f3d56b0cbc4b84436d8baf4c8346cd2ee7ffb257bba5ddd9892c41bf516edc4")

    add_patches("1.0.4", path.join(os.scriptdir(), "patches", "1.0.4", "build.patch"), "1f51148afccef7b9bf079ef4137c12d578fb7a76f7aed6e282ca2ceaf4a188ba")

    add_deps("cmake")
    add_deps("console-bridge")

    add_includedirs("include", "include/urdfdom")

    on_check("android|armeabi-v7a", function (package)
        local ndk = package:toolchain("ndk")
        local ndk_sdkver = ndk:config("ndk_sdkver")
        if tonumber(ndk_sdkver) < 24 then
            raise("package(urdfdom) unsupported this platform")
        end
    end)

    on_load(function (package)
        local version = package:version()
        if version then
            if version:ge("4.0.0") then
                package:add("deps", "tinyxml2")
            else
                package:add("deps", "tinyxml")
            end
            if version:ge("5.0.3") then
                package:add("deps", "urdfdom-headers")
            elseif version:gt("1.0.4") and version:lt("5.0.3") then
                package:add("deps", "urdfdom-headers <2.0.1")
            else
                package:add("deps", "urdfdom-headers 1.0.5")
            end
        end
        if not package:config("shared") then
            package:add("defines", "URDFDOM_STATIC")
        end
    end)

    on_install("!mingw and !iphoneos", function (package)
        io.replace("urdf_parser/CMakeLists.txt", "SHARED", "", {plain = true})
        io.replace("urdf_parser/include/urdf_parser/urdf_parser.h", "#include <string>", "#include <cstdint>\n#include <string>", {plain = true})
        io.replace("CMakeLists.txt", "find_package(urdfdom_headers 1.0 REQUIRED)", "find_package(urdfdom_headers REQUIRED)", {plain = true})
        io.replace("CMakeLists.txt", "find_package(urdfdom_headers 1.0.3 REQUIRED)", "find_package(urdfdom_headers REQUIRED)", {plain = true})

        local configs = {"-DBUILD_TESTING=OFF", "-DAPPEND_PROJECT_NAME_TO_INCLUDEDIR=OFF", "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        local opt = {}
        if not package:config("shared") then
            opt.cxflags = "-DURDFDOM_STATIC"
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                std::string xml_string;
                urdf::parseURDF(xml_string);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "urdf_parser/urdf_parser.h"}))
    end)
