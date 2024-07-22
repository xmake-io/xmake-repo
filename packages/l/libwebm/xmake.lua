package("libwebm")
    set_homepage("https://chromium.googlesource.com/webm/libwebm")
    set_description("Library for muxing and demuxing WebM media container files")
    set_license("BSD-3-Clause")

    add_urls("https://chromium.googlesource.com/webm/libwebm.git")
    add_urls("https://chromium.googlesource.com/webm/libwebm/+archive/libwebm-$(version).tar.gz", {
        version = function (version)
            return version:gsub("+", ".")
        end
    })

    add_versions("1.0.0+31", "60caf5776124db463d6f98bc216bd48d8b4e73d9034b65168b801f031dfcfc55")

    add_configs("webmts", {description = "Enables WebM PES/TS support.", default = false, type = "boolean"})
    add_configs("webm_info", {description = "Enables building webm_info.", default = false, type = "boolean"})
    add_configs("parser", {description = "Enables new parser API.", default = false, type = "boolean"})

    add_deps("cmake")

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    on_install(function (package)
        local configs = {"-DENABLE_SAMPLE_PROGRAMS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        table.insert(configs, "-DENABLE_WEBMTS=" .. (package:config("webmts") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_WEBMINFO=" .. (package:config("webm_info") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_WEBM_PARSER=" .. (package:config("parser") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #ifdef UNPREFIXED_HEADERS
            #include <webm/mkvmuxerutil.h>
            #include <webm/mkvparser.h>
            #else
            #include <webm/mkvmuxer/mkvmuxerutil.h>
            #include <webm/mkvparser/mkvparser.h>
            #endif // UNPREFIXED_HEADERS
            void test() {
                int32_t major, minor, build, revision;
                mkvparser::GetVersion(major, minor, build, revision);
                mkvmuxer::GetVersion(&major, &minor, &build, &revision);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
