package("collada-dom")

    set_homepage("https://github.com/rdiankov/collada-dom/")
    set_description("COLLADA Document Object Model (DOM) C++ Library")

    add_urls("https://github.com/rdiankov/collada-dom/archive/refs/tags/$(version).tar.gz",
             "https://github.com/rdiankov/collada-dom.git")
    add_versions("v2.5.0", "3be672407a7aef60b64ce4b39704b32816b0b28f61ebffd4fbd02c8012901e0d")

    add_patches("v2.5.0", path.join(os.scriptdir(), "patches", "v2.5.0", "uriparser.patch"), "b3ab281d5f4498531ff387992f731f94c64d7f8ea07674f66ad74ba455f650ef")

    add_deps("cmake", "libxml2", "minizip", "pcre", "uriparser")
    add_deps("boost", {configs = {filesystem = true}})
    on_load("windows", function (package)
        if package:config("shared") then
            package:add("defines", "DOM_DYNAMIC")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        os.cd("dom")
        os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), "xmake.lua")
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        elseif package:is_plat("linux") and package:config("pic") ~= false then
            configs.cxflags = "-fPIC"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("DAE", {configs = {languages = "c++11"}, includes = "dae.h"}))
    end)
