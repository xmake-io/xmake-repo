package("qcefview")
    set_homepage("https://cefview.github.io/QCefView/")
    set_description("A QWidget-based Web View Component Integrated with CEF")
    add_urls("https://github.com/CefView/QCefView.git")
    
    add_configs("sandbox", {description = "Enable sandbox mode.", default = false, type = "boolean"})
    add_configs("debug", {description = "Enable debug mode.", default = false, type = "boolean"})
    add_configs("demo", {description = "Build demo.", default = false, type = "boolean"})
    --只提供选项,如果版本编译不能使用,请自行修改CefViewCore
    add_configs("cef_version", {description = "CEF version.", default = "113.3.1+g525fa10+chromium-113.0.5672.128", type = "string"})
    add_patches("@default", path.join(os.scriptdir(), "patches", "CefConfig.cmake.patch"),"f26ddcf689572618548d028e9b84d02247cd435536a620a548ceb0895a2dbf69")

    add_deps("cmake")
   
    on_install("windows", "linux", function (package)
        local configs = {}
        import("detect.sdks.find_qt")
        local qt = package:data("qt")
        if not qt then
            qt = find_qt()
        end
        table.insert(configs, "-DCMAKE_PREFIX_PATH=" .. qt.sdkdir )
        table.insert(configs, "-DUSE_SANDBOX=" .. (package:config("sandbox") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:config("debug") and "Debug" or "Release"))
        if not (package:config("cef_version") == "") then
            table.insert(configs, "-DCEF_SDK_VERSION=" .. package:config("cef_version"))
        end
        if package:is_arch("x86_64", "x64") then
            table.insert(configs, "-DPROJECT_ARCH=x86_64")
        elseif package:is_arch("x86") then
            table.insert(configs, "-DPROJECT_ARCH=x86")
        elseif package:is_arch("arm64.*") then
            table.insert(configs, "-DPROJECT_ARCH=arm64")
        end
        table.insert(configs, "-DBUILD_DEMO=" .. (package:config("demo") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        os.cp(package:installdir("QCefView/*"), package:installdir())
        os.rm(package:installdir("QCefView"))
    end)

    -- on_test(function (package)
    --     assert(package:has_cxxfuncs("QCefView::QCefView(QWidget*)", 
    --     {includes = "QCefView.h", configs={vs_runtime="MD",rules = "qt.widgetapp"}}))
    -- end)