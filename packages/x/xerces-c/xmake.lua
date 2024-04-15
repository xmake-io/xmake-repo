package("xerces-c")

    set_homepage("https://xerces.apache.org/xerces-c/")
    set_description("Xerces-C++ is a validating XML parser written in a portable subset of C++.")
    set_license("Apache-2.0")

    add_urls("https://archive.apache.org/dist/xerces/c/3/sources/xerces-c-$(version).zip")
    add_versions("3.2.5", "4aa0f7ed265a45d253f900fa145cc8cae10414d085695f1de03a2ec141a3358b")

    add_deps("cmake")
    if is_plat("windows") then
        add_syslinks("advapi32")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation", "CoreServices")
    end
    on_install("windows", "macosx", "linux", "android", function (package)
        if package:is_plat("android") then
            import("core.tool.toolchain")
            local ndk = toolchain.load("ndk", {plat = package:plat(), arch = package:arch()})
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) >= 26, "package(xerces-c): need ndk api level >= 26 for android")
        end

        local configs = {"-Dnetwork=OFF", "-DCMAKE_DISABLE_FIND_PACKAGE_ICU=ON", "-DCMAKE_DISABLE_FIND_PACKAGE_CURL=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace xercesc;
            void test() {
                try {
                    XMLPlatformUtils::Initialize();
                }
                catch (const XMLException& toCatch) {
                    return;
                }
                XMLPlatformUtils::Terminate();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "xercesc/util/PlatformUtils.hpp"}))
    end)
