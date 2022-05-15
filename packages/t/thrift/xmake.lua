package("thrift")

    set_homepage("https://thrift.apache.org/")
    set_description("Thrift is a lightweight, language-independent software stack for point-to-point RPC implementation.")
    set_license("Apache-2.0")

    add_urls("https://dlcdn.apache.org/thrift/0.16.0/thrift-0.16.0.tar.gz",  {version = function (version)
        return version:gsub("v", "")
    end})
    add_urls("https://github.com/apache/thrift.git")
    add_versions("v0.16.0", "f460b5c1ca30d8918ff95ea3eb6291b3951cf518553566088f3f2be8981f6209")

    add_deps("cmake", "boost")
    if is_plat("windows") then
        add_deps("winflexbison")
    else
        add_deps("flex", "bison")
    end

    local configdeps = {glib = "glib", libevent = "libevent", ssl = "openssl", zlib = "zlib"}
    for config, dep in pairs(configdeps) do
        add_configs(config, {description = "Enable " .. config .. " support.", default = false, type = "boolean"})
    end

    on_load(function (package)
        for name, dep in pairs(configdeps) do
            if package:config(name) then
                if name == "libevent" and package:config("ssl") then
                    package:add("deps", "libevent", {configs = {openssl = true}})
                else
                    package:add("deps", dep)
                end
            end
        end
    end)

    on_install("linux", "macosx", "cross", function (package)
        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DWITH_STDTHREADS=ON",
            "-DBUILD_COMPILER=ON",
            "-DBUILD_TUTORIALS=OFF",
            -- language support.
            "-DBUILD_CPP=ON",
            "-DBUILD_JAVA=OFF",
            "-DBUILD_JAVASCRIPT=OFF",
            "-DBUILD_NODEJS=OFF",
            "-DBUILD_PYTHON=OFF",
        }

        for config, dep in pairs(configdeps) do
            -- Use WITH_OPENSSL instead of WITH_SSL, thus use dep:upper().
            local feat = dep:upper()
            if config == "glib" then
                feat = "C_GLIB"
            end
            table.insert(configs, "-DWITH_" .. feat .. "=" .. (package:config(config) and "ON" or "OFF"))
        end

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            apache::thrift::transport::TTransport* test() {
                return new apache::thrift::transport::TSocket("localhost", 9090);
            }
        ]]}, {configs = {languages = "c++11"}, includes="thrift/transport/TSocket.h"}))
    end)
