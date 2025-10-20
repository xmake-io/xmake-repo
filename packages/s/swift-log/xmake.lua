package("swift-log")
    set_homepage("https://swiftpackageindex.com/apple/swift-log")
    set_description("A Logging API for Swift")
    set_license("Apache-2.0")

    add_urls("https://github.com/apple/swift-log/archive/refs/tags/$(version).tar.gz",
             "https://github.com/apple/swift-log.git")

    add_versions("1.6.4", "0c5ce73e9e90da99391600436317e2ed7186645c63ae9e866321c3e977b7d587")

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        for _, file in ipairs(os.files(path.join(package:installdir(), "**"))) do
            print(file)
        end
        assert(os.isdir(package:installdir("lib")), "Library directory not found")
    end)
