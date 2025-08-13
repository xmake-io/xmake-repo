package("mailio")
    set_homepage("https://github.com/karastojko/mailio")
    set_description("mailio is a cross platform C++ library for MIME format and SMTP, POP3 and IMAP protocols. It is based on standard C++ 17 and Boost library.")
    set_license("BSD")

    add_urls("https://github.com/karastojko/mailio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/karastojko/mailio.git")

    add_versions("0.25.3", "12b79d8a8211033d7e59be2e30521a8109ed83bda86c86437ebe7e04298a5aa5")
    add_versions("0.24.1", "52d5ced35b6a87677d897010fb2e7c2d2ddbd834d59aab991c65c0c6627af40f")
    add_versions("0.23.0", "9fc3f1f803a85170c2081cbbef2e301473a400683fc1dffefa2d6707598206a5")

    if is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    end

    add_deps("cmake")
    add_deps("boost", {configs = {regex = true, date_time = true, system = true, exception = true, container = true}})
    add_deps("openssl")

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "MAILIO_STATIC_DEFINE")
        end
    end)

    on_install("!iphoneos and !wasm", function (package)
        local version = package:version()
        io.replace("CMakeLists.txt", "/WX", "", {plain = true})
        io.replace("CMakeLists.txt", "set(Boost_USE_STATIC_LIBS ON)", "", {plain = true})

        if package:gitref() or version:le("0.24.1") then
            io.replace("CMakeLists.txt", " unit_test_framework", "", {plain = true})
            if package:is_plat("windows") then
                io.replace("CMakeLists.txt", "if (MSVC)",
                "if (MSVC)\n    target_link_libraries(${PROJECT_NAME} crypt32)", {plain = true})
            elseif package:is_plat("mingw") then
                io.replace("CMakeLists.txt", "if(MINGW)",
                "if (MINGW)\n    target_link_libraries(${PROJECT_NAME} crypt32)", {plain = true})
            end
        end

        local configs = {
            "-DMAILIO_BUILD_EXAMPLES=OFF",
            "-DMAILIO_BUILD_TESTS=OFF",
            "-DMAILIO_DYN_LINK_TESTS=OFF",
            "-DMAILIO_BUILD_DOCUMENTATION=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if version and version:le("0.23.0") then
            table.insert(configs, "-DMAILIO_BUILD_SHARED_LIBRARY=" .. (package:config("shared") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <mailio/message.hpp>
            using namespace mailio;
            void test() {
                message msg;
                msg.header_codec(message::header_codec_t::QUOTED_PRINTABLE);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
