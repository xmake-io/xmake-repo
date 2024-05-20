package("thrift")
    set_homepage("https://thrift.apache.org/")
    set_description("Thrift is a lightweight, language-independent software stack for point-to-point RPC implementation.")
    set_license("Apache-2.0")

    add_urls("https://github.com/apache/thrift/archive/refs/tags/$(version).tar.gz",
             "https://github.com/apache/thrift.git")

    add_versions("v0.16.0", "df2931de646a366c2e5962af679018bca2395d586e00ba82d09c0379f14f8e7b")

    add_patches(">=0.16.0", "patches/0.16.0/cmake.patch", "8dd82f54d52a37487e64aa3529f4dbcedcda671ab46fcb7a8c0f2c521ee0be9b")

    add_configs("compiler", {description = "Build compiler", default = false, type = "boolean"})

    add_deps("cmake", "boost")
    if is_plat("windows") then
        add_deps("winflexbison")
    else
        add_deps("flex", "bison")
    end

    local configdeps = {"glib", "libevent", "openssl", "zlib", "qt5"}
    for _, dep in pairs(configdeps) do
        add_configs(dep, {description = "Enable " .. dep .. " support.", default = false, type = "boolean"})
    end

    on_load(function (package)
        for _, dep in pairs(configdeps) do
            if package:config(dep) then
                if dep == "libevent" and package:config("openssl") then
                    package:add("deps", "libevent", {configs = {openssl = true}})
                elseif dep == "openssl" then
                    package:add("deps", "openssl3")
                elseif dep == "qt5" then
                    package:add("deps", "qt5core", "qt5network")
                else
                    package:add("deps", dep)
                end
            end
        end
    end)

    on_install("windows", "linux", "macosx", "cross", function (package)
        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DBUILD_TUTORIALS=OFF",

            "-DBUILD_CPP=ON",
            "-DBUILD_JAVA=OFF",
            "-DBUILD_JAVASCRIPT=OFF",
            "-DBUILD_NODEJS=OFF",
            "-DBUILD_PYTHON=OFF",
        }

        for _, dep in pairs(configdeps) do
            local feat = dep:upper()
            if dep == "glib" then
                feat = "C_GLIB"
            end
            table.insert(configs, "-DWITH_" .. feat .. "=" .. (package:config(dep) and "ON" or "OFF"))
        end

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_COMPILER=" .. (package:config("compiler") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DWITH_MT=" .. (package:has_runtime("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            apache::thrift::transport::TTransport* test() {
                return new apache::thrift::transport::TSocket("localhost", 9090);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "thrift/transport/TSocket.h"}))
    end)
