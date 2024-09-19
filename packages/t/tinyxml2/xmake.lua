package("tinyxml2")
    set_homepage("http://www.grinninglizard.com/tinyxml2/")
    set_description("simple, small, efficient, C++ XML parser that can be easily integrating into other programs.")
    set_license("zlib")

    add_urls("https://github.com/leethomason/tinyxml2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/leethomason/tinyxml2.git")

    add_versions("8.0.0", "6ce574fbb46751842d23089485ae73d3db12c1b6639cda7721bf3a7ee862012c")
    add_versions("9.0.0", "cc2f1417c308b1f6acc54f88eb70771a0bf65f76282ce5c40e54cfe52952702c")
    add_versions("10.0.0", "3bdf15128ba16686e69bce256cc468e76c7b94ff2c7f391cc5ec09e40bff3839")

    add_deps("cmake")

    on_install(function (package)
        if package:is_debug() then
            package:add("defines", "TINYXML2_DEBUG")
        end
        if package:config("shared") and package:is_plat("windows") then
            package:add("defines", "TINYXML2_IMPORT")
        end

        if package:is_plat("android") and package:is_arch("armeabi-v7a") then
            local ndk_sdkver = package:toolchain("ndk"):config("ndk_sdkver")
            if ndk_sdkver and tonumber(ndk_sdkver) < 24 then
                io.replace("tinyxml2.cpp", "ftello", "ftell", {plain = true})
                io.replace("tinyxml2.cpp", "fseeko", "fseek", {plain = true})
            end
        end

        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int argc, char** argv) {
                static const char* xml = "<element/>";
                tinyxml2::XMLDocument doc;
                doc.Parse(xml);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "tinyxml2.h"}))
    end)
