package("xerces-c")

    set_homepage("https://xerces.apache.org/xerces-c/")
    set_description("Xerces-C++ is a validating XML parser written in a portable subset of C++.")
    set_license("Apache-2.0")

    add_urls("https://dlcdn.apache.org//xerces/c/3/sources/xerces-c-$(version).zip")
    add_versions("3.2.4", "563a668b331ca5d1fc08ed52e5f62a13508b47557f88a068ad1db6f68e1f2eb2")

    add_deps("cmake")
    if is_plat("windows") then
        add_syslinks("advapi32")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation", "CoreServices")
    end
    on_install("windows", "macosx", "linux", function (package)
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
        ]]}, {configs = {languages = "c++11"}, includes = "xercesc/util/PlatformUtils.hpp"}))
    end)
