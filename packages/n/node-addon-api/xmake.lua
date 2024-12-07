package("node-addon-api")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/nodejs/node-addon-api")
    set_description("Module for using Node-API from C++")
    set_license("MIT")

    add_configs("errors", {description = "Choose error handling method.", default = "except", type = "string", values = {"except", "noexcept", "maybe"}})
    add_configs("deprecated", {description = "Disable deprecated APIs.", default = false, type = "boolean"})
    add_configs("napi_version", {description = "Target a specific Node-API version.", default = nil, type = "number"})

    set_urls("https://github.com/nodejs/node-addon-api/archive/refs/tags/$(version).tar.gz",
        "https://github.com/nodejs/node-addon-api.git")
    add_versions("v8.3.0", "a5ddbbe7c4a04aa4d438205e2f90bfc476042951e8ebddac6883f123a7e88cae")
    add_versions("v8.2.2", "b9fe0f1535deb17825ff57fb97b4690f49517a42c923e475e960870831f2fa79")
    add_versions("v8.0.0", "42424c5206b9d67b41af4fcff5d6e3cb22074168035a03b8467852938a281d47")

    add_deps("node-api-headers")

    on_load(function(package)
        package:add("defines", "NAPI_VERSION=" .. (package:config("napi_version") or package:version():major()))
        if not package:config("deprecated") then
            package:add("defines", "NODE_ADDON_API_DISABLE_DEPRECATED")
        end
        
        local errors = package:config("errors")
        if errors == "noexcept" or errors == "maybe" then
            package:add("cxxflags", "-fno-exceptions")
            package:add("defines", "NAPI_DISABLE_CPP_EXCEPTIONS")
        end
        if errors == "maybe" then
            package:add("defines", "NODE_ADDON_API_ENABLE_MAYBE")
        end
        if errors == "except" then
            package:add("defines", "NAPI_CPP_EXCEPTIONS")
        end
    end)

    on_install("linux" ,function(package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("Napi::Just(0)", {includes = "napi.h"}))
    end)
