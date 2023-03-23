package("davix")

    set_homepage("https://davix.web.cern.ch/")
    set_description("High-performance file management over WebDAV/HTTP")
    set_license("LGPL-2.1")

    add_urls("https://github.com/cern-fts/davix/releases/download/R_$(version).tar.gz", {version = function (version)
        return format("%s/davix-%s", version:gsub("%.", "_"), version)
    end})
    add_versions("0.8.4", "519d56f746e86ea3fd615bc49e559b520df07e051e1ca3d8c092067958f3b2b7")

    add_deps("python 3.x", {kind = "binary"})
    add_deps("cmake", "openssl", "libcurl", "libxml2")
    add_deps("util-linux", {configs = {libuuid = true}})
    add_includedirs("include/davix")
    if is_plat("linux") then
        add_syslinks("pthread")
    end
    on_install("macosx", "linux", function (package)
        local configs = {"-DDAVIX_TESTS=OFF", "-DEMBEDDED_LIBCURL=OFF", "-DLIB_SUFFIX="}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DSHARED_LIBRARY=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSTATIC_LIBRARY=" .. (package:config("shared") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs, {packagedeps = {"libcurl", "util-linux"}})
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <davix.hpp>
            void test() {
                Davix::Context context;
                context.loadModule("grid");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
