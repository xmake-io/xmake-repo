package("foxglove-sdk")

    set_homepage("https://github.com/foxglove/foxglove-sdk")
    set_description("SDK for connecting live robotics and embodied AI data to Foxglove")
    set_license("MIT")

    add_configs("remote_access", {description = "Enable Foxglove Remote Access.", default = false, type = "boolean"})

    add_deps("cmake")
    set_policy("package.precompiled", false)

    if is_plat("linux") and is_arch("x86_64") then
        set_urls("https://github.com/foxglove/foxglove-sdk/releases/download/sdk/v$(version)/foxglove-v$(version)-cpp-x86_64-unknown-linux-gnu.zip")
        add_versions("0.25.2", "ac001974aa0e3ac5b8159bcd698007c0661715c4a0201c99353e8a8dfe03bd44")
    elseif is_plat("linux") and is_arch("arm64") then
        set_urls("https://github.com/foxglove/foxglove-sdk/releases/download/sdk/v$(version)/foxglove-v$(version)-cpp-aarch64-unknown-linux-gnu.zip")
        add_versions("0.25.2", "72d403cc2ee90e84bd803c08e7dcaa2ddf5175d381f9668b595357a9445c39b6")
    elseif is_plat("macosx") and is_arch("x86_64") then
        set_urls("https://github.com/foxglove/foxglove-sdk/releases/download/sdk/v$(version)/foxglove-v$(version)-cpp-x86_64-apple-darwin.zip")
        add_versions("0.25.2", "3ef620496dde842bc35201f87c33cf94e3b3b2b5b5fb8f057ad64bcf0b12238b")
    elseif is_plat("macosx") and is_arch("arm64") then
        set_urls("https://github.com/foxglove/foxglove-sdk/releases/download/sdk/v$(version)/foxglove-v$(version)-cpp-aarch64-apple-darwin.zip")
        add_versions("0.25.2", "8839bde7c4e1142e7cbbf57756d87d2e36a683fad6fb32cbc240038d6e781ad8")
    elseif is_plat("windows") and is_arch("x64") then
        set_urls("https://github.com/foxglove/foxglove-sdk/releases/download/sdk/v$(version)/foxglove-v$(version)-cpp-x86_64-pc-windows-msvc.zip")
        add_versions("0.25.2", "02b27c7ecb5a0124eebb6e925586a45487d56da708d0088dedb770007fb4a849")
    elseif is_plat("windows") and is_arch("arm64") then
        set_urls("https://github.com/foxglove/foxglove-sdk/releases/download/sdk/v$(version)/foxglove-v$(version)-cpp-aarch64-pc-windows-msvc.zip")
        add_versions("0.25.2", "d0688eb49aea912035225a5077a5fce7f2300bc05b2bdabf637016d418063f8a")
    end

    if on_check then
        on_check(function (package)
            assert(package:is_plat("linux", "macosx", "windows"), "foxglove-sdk only supports Linux, macOS, and Windows")
            if package:is_plat("windows") then
                assert(package:is_arch("x64", "arm64"), "foxglove-sdk only supports x64 and arm64 on Windows")
            else
                assert(package:is_arch("x86_64", "arm64"), "foxglove-sdk only supports x86_64 and arm64 on this platform")
            end
            assert(not package:config("remote_access") or package:config("shared"), "foxglove-sdk remote_access requires shared=true")
        end)
    end

    on_load(function (package)
        package:add("links", "foxglove_cpp")
        if package:config("remote_access") then
            package:add("defines", "FOXGLOVE_REMOTE_ACCESS")
        elseif not package:config("shared") then
            package:add("links", "foxglove")
            if package:is_plat("windows") then
                package:add("syslinks", "Bcrypt", "SChannel", "Crypt32", "Ncrypt")
            elseif package:is_plat("macosx") then
                package:add("frameworks", "Security", "CoreFoundation")
            else
                package:add("syslinks", "pthread", "dl", "m")
            end
        end
        if package:is_plat("windows") and package:config("shared") then
            package:addenv("PATH", "bin")
        end
    end)

    on_install("linux", "macosx", "windows", function (package)
        local source_root = os.isdir("foxglove") and "foxglove" or "."
        os.cp(path.join(package:scriptdir(), "port", "CMakeLists.txt"), path.join(source_root, "CMakeLists.txt"))
        os.cd(source_root)

        local configs = {
            "-DFOXGLOVE_WRAPPER_SHARED=" .. (package:config("shared") and "ON" or "OFF"),
            "-DFOXGLOVE_REMOTE_ACCESS=" .. (package:config("remote_access") and "ON" or "OFF")
        }
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <foxglove/websocket.hpp>
            #include <utility>
            void test() {
                foxglove::WebSocketServerOptions options;
                auto server = foxglove::WebSocketServer::create(std::move(options));
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
