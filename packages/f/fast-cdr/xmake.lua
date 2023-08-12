package("fast-cdr")
    set_homepage("https://www.eprosima.com")
    set_description("eProsima FastCDR library provides two serialization mechanisms. One is the standard CDR serialization mechanism, while the other is a faster implementation of it.")
    set_license("Apache-2.0")

    add_urls("https://github.com/eProsima/Fast-CDR/archive/refs/tags/$(version).tar.gz",
             "https://github.com/eProsima/Fast-CDR.git")

    add_versions("v1.1.0", "5c4b2ad5493abd30b9475b14856641a8944c98077a36bd0760c1d83c65216e67")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("include/fastcdr/eProsima_auto_link.h", "        #pragma \\\n    comment(lib, EPROSIMA_LIB_PREFIX EPROSIMA_STRINGIZE(EPROSIMA_LIB_NAME) EPROSIMA_LIB_DEBUG_TAG \"-\" EPROSIMA_STRINGIZE(FASTCDR_VERSION_MAJOR) \".\" EPROSIMA_STRINGIZE(FASTCDR_VERSION_MINOR) \".lib\")", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <fastcdr/FastBuffer.h>
            void test() {
                auto buffer = eprosima::fastcdr::FastBuffer();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
