package("trantor")

    set_homepage("https://github.com/an-tao/trantor/")
    set_description("a non-blocking I/O tcp network lib based on c++14/17")
    set_license("BSD-3-Clause")
    add_urls("https://github.com/an-tao/trantor/archive/refs/tags/$(version).tar.gz",
             "https://github.com/an-tao/trantor.git")

    add_versions("v1.5.22", "2f870b016a592228d617ef51eec4e9a9ab7dc56c066923af9bf6dd42fefb63de")
    add_versions("v1.5.21", "c267e8d3657a85751554a6877efd1199f6766a9fd6418d2c72839ad0a8943988")
    add_versions("v1.5.20", "4d3b98c228aafde1001cff581cf8d1a4a9f71f7b2a85a28978b560aefc21c038")
    add_versions("v1.5.19", "a2f55a98fd4b0737ba0e2cd77d2f237253e607b2047071be04a9ea76587bb608")
    add_versions("v1.5.18", "f8227eb5307671496db435736e0b856529afae420b148c60a2b36839d6738707")
    add_versions("v1.5.17", "10689dc1864a3fdb08cba824475996346a1bfb083575fd3d62858aaefa9044d9")
    add_versions("v1.3.0", "524589dc9258e1ace3b2f887b835cfbeccab3c5efc4ba94963c59f3528248d9b")
    add_versions("v1.4.1", "aa3f4dddfd3fd1a6e04f79744e69f23bb6472c314724eaa3051872a2a03bbda9")
    add_versions("v1.5.0", "8704df75b783089d7e5361174054e0e46a09cc315b851dbc2ab6736e631b090b")
    add_versions("v1.5.2", "6ccd781b3a2703b94689d7da579a38a78bc5c89616cce18ec27fcb6bc0b1620f")
    add_versions("v1.5.5", "5a549c6efebe7ecba73a944cfba4a9713130704d4ccc82af534a2e108b9a0e71")
    add_versions("v1.5.6", "827aca30e120244a8ede9d07446481328d9a3869228f01fc4978b19301d66e65")
    add_versions("v1.5.7", "42576563afbf1e58c7d68f758cf3fca4d193496d4e3f82c80069d8389a7839d5")
    add_versions("v1.5.8", "705ec0176681be5c99fcc7af37416ece9d65ff4d907bca764cb11471b104fbf8")
	add_versions("v1.5.14", "80775d65fd49dfb0eb85d70cd9c0f0cff38a7f46c90db918862c46e03ae63810")
	
    add_patches("v1.5.8", path.join(os.scriptdir(), "patches", "1.5.8", "skip_doc.patch" ), "4124f3cc1e486ad75bc5ec2fa454ea5319d68287d0b1d8cfa3b5ab865f8ca5fd")

    add_configs("spdlog", {description = "Allow using the spdlog logging library", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("openssl", "c-ares", {optional = true})
    if is_plat("windows", "mingw") then
	    add_patches("v1.5.8", path.join(os.scriptdir(), "patches", "1.5.8", "fix-win-off_t.patch" ),"f0d7fbfc98085ed8b5f6c7504be29b18ddcd6fe4e14e3551396a643fc4574dc0")
        add_syslinks("ws2_32")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:version():le("v1.5.15") then
            package:config_set("spdlog", false)
        end
        if package:config("spdlog") then
            package:add("deps", "spdlog", {configs = {header_only = false, fmt_external_ho = true}})
        end
    end)

    on_install("windows", "macosx", "linux", "mingw@windows", function (package)
        io.replace("CMakeLists.txt", "\"${CMAKE_CURRENT_SOURCE_DIR}/cmake_modules/Findc-ares.cmake\"", "", {plain = true})
        io.replace("CMakeLists.txt", "find_package(c-ares)", "find_package(c-ares CONFIG)", {plain = true})
        io.replace("CMakeLists.txt", "c-ares_lib", "c-ares::cares", {plain = true})
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        if package:config("spdlog") then
            table.insert(configs, "-DUSE_SPDLOG=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <thread>
            #include <chrono>
            using namespace std::chrono_literals;
            void test() {
                trantor::SerialTaskQueue queue("");
                queue.runTaskInQueue([&]() {
                    for (int i = 0; i < 5; ++i)
                        std::this_thread::sleep_for(0.1s);
                });
                queue.waitAllTasksFinished();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "trantor/utils/SerialTaskQueue.h"}))
    end)
