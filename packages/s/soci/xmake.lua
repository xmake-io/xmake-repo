package("soci")
    set_homepage("http://soci.sourceforge.net/")
    set_description("Official repository of the SOCI - The C++ Database Access Library")
    set_license("BSL-1.0")

    add_urls("https://github.com/SOCI/soci/archive/refs/tags/$(version).tar.gz",
             "https://github.com/SOCI/soci.git")

    add_versions("v4.1.2", "c0974067e57242f21d9a85677c5f6cc7848fba3cbd5ec58d76c95570a5a7a15b")
    add_versions("v4.0.3", "4b1ff9c8545c5d802fbe06ee6cd2886630e5c03bf740e269bb625b45cf934928")
    add_patches("v4.0.3", path.join(os.scriptdir(), "patches", "v4.0.3", "cmake_policy_fix.patch"), "6d8746c3ae39edf1b750d47dcfde97dedbe4211c2563481e877d36a9dccc556a")

    local backends = {
        "empty",
        "sqlite3",
        "db2",
        "odbc",
        "oracle",
        "firebird",
        "mysql",
        "postgresql",
    }
    for _, backend in ipairs(backends) do
        add_configs(backend, {description = "Build " .. backend .. " backend", default = false, type = "boolean"})
    end
    add_configs("boost", {description = "Enable boost integration", default = false, type = "boolean"})
    add_configs("visibility", {description = "Enable hiding private symbol using ELF visibility if supported by the platform", default = true, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        for _, pkg in ipairs({"sqlite3", "mysql", "postgresql"}) do
            if package:config(pkg) then
                package:add("deps", pkg)
            end
        end
        if package:config("boost") then
            package:add("deps", "boost")
        end
    end)

    on_install(function (package)
        local configs = {"-DSOCI_TESTS=OFF", "-DSOCI_CXX11=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DSOCI_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSOCI_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DSOCI_LTO=" .. (package:config("lto") and "ON" or "OFF"))
        table.insert(configs, "-DSOCI_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DSOCI_VISIBILITY=" .. (package:config("visibility") and "ON" or "OFF"))
        table.insert(configs, "-DSOCI_EMPTY=" .. (package:config("empty") and "ON" or "OFF"))
        for name, enabled in pairs(package:configs()) do
            if (not package:extraconf("configs", name, "builtin")) and (name ~= "empty") then
                table.insert(configs, "-DWITH_" .. name:upper() .. "=" .. (package:config(name) and "ON" or "OFF"))
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local includes = {"soci/soci.h"}
        for _, pkg in ipairs(backends) do
            if package:config(pkg) then
                table.insert(includes, "soci/" .. pkg .. "/soci-" .. pkg .. ".h")
            end
        end
        assert(package:check_cxxsnippets({test = [[
            void test() {
                soci::session sql("connectString");
            }
        ]]}, {configs = {languages = "c++14", defines = package:config("boost") and "SOCI_USE_BOOST" or {}}, includes = includes}))
    end)
