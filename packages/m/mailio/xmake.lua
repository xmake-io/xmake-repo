package("mailio")
    set_homepage("https://github.com/karastojko/mailio")
    set_description("mailio is a cross platform C++ library for MIME format and SMTP, POP3 and IMAP protocols. It is based on standard C++ 17 and Boost library.")
    set_license("BSD")

    add_urls("https://github.com/karastojko/mailio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/karastojko/mailio.git")

    add_versions("0.23.0", "9fc3f1f803a85170c2081cbbef2e301473a400683fc1dffefa2d6707598206a5")

    if is_plat("linux") then
        add_syslinks("m")
    elseif is_plat("bsd") then
        add_syslinks("m", "pthread")
    end

    add_deps("cmake")
    add_deps("boost", {configs = {regex = true, date_time = true, system = true}})
    add_deps("openssl")

    on_install("windows", "linux", "macosx", "bsd", "mingw", "cross", function (package)
        local configs = {
            "-DMAILIO_BUILD_EXAMPLES=OFF",
            "-DMAILIO_BUILD_TESTS=OFF",
            "-DMAILIO_DYN_LINK_TESTS=OFF",
        }

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:version():le("0.23.0") then
            table.insert(configs, "-DMAILIO_BUILD_SHARED_LIBRARY=" .. (package:config("shared") and "ON" or "OFF"))
            io.replace("CMakeLists.txt", " unit_test_framework", "", {plain = true})
        end
        if package:is_plat("windows") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. (package:dep("boost"):config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
            io.replace("CMakeLists.txt", "if (MSVC)",
            "if (MSVC)\n    target_link_libraries(${PROJECT_NAME} crypt32)", {plain = true})
        elseif package:is_plat("mingw") then
            io.replace("CMakeLists.txt", "if(MINGW)",
            "if (MINGW)\n    target_link_libraries(${PROJECT_NAME} crypt32)", {plain = true})
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
