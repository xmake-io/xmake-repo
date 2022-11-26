package("llfio")
    set_homepage("https://github.com/ned14/llfio")
    set_description("UTF8-CPP: UTF-8 with C++ in a Portable Way")
    set_license("Apache-2.0")

    local versions = {
        ["2022.9.7"] = "4ed331368afa8e7fdb2ecb02352b578c2a4c7349a8a45c1b34b85f658208a39b"
    }
    local hashes = {
        ["2022.9.7"] = "ae7f9c5a92879285ad5100c89efc47ce1cb0031b"
    }
    add_urls("https://github.com/ned14/llfio/archive/refs/tags/all_tests_passed_$(version).tar.gz", {version = function (version)
        return hashes[tostring(version)]
    end})
    add_urls("https://github.com/ned14/llfio.git")

    add_configs("headeronly", {description = "Use header only version.", default = false, type = "boolean"})

    for version, commit in pairs(versions) do
        add_versions(version, commit)
    end

    if is_plat("android") then
        add_defines("QUICKCPPLIB_DISABLE_EXECINFO")
    end


    add_deps("quickcpplib", "outcome", "ntkernel-error-category", "openssl")
    on_load(function(package)
        if package:config("headeronly") then
            package:add("defines", "LLFIO_HEADERS_ONLY=1")
            if package:is_plat("windows", "mingw") then
                package:add("syslinks", "advapi32", "user32", "wsock32", "ws2_32", "ole32", "shell32")
            end
        else
            if not package:config("shared") then
                if package:is_plat("windows", "mingw") then
                    package:add("syslinks", "advapi32", "user32", "wsock32", "ws2_32", "ole32", "shell32")
                end
            end
            package:add("defines", "LLFIO_HEADERS_ONLY=0")
        end
    end)

    on_install(function (package)
        local configs = {}
        if package:config("headeronly") then
            configs.kind = "headeronly"
        elseif package:config("shared") then
            configs.kind = "shared"
        end
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++17")
            add_requires("quickcpplib", "outcome", "ntkernel-error-category", "openssl")
            target("llfio")
                set_kind("$(kind)")
                add_packages("quickcpplib", "outcome", "ntkernel-error-category", "openssl")
                add_headerfiles("include/(llfio/**.hpp)")
                add_headerfiles("include/(llfio/**.ixx)")
                add_headerfiles("include/(llfio/**.h)")
                add_includedirs("include")

                if is_plat("windows", "mingw") then
                    add_syslinks("advapi32", "user32", "wsock32", "ws2_32", "ole32", "shell32")
                end
                if is_plat("android") then
                    add_defines("QUICKCPPLIB_DISABLE_EXECINFO")
                end

                if not is_kind("headeronly") then
                    if is_kind("shared") then
                        add_defines("LLFIO_DYN_LINK=1")
                    else
                        add_defines("LLFIO_STATIC_LINK=1")
                    end
                    add_defines("LLFIO_SOURCE=1")
                    add_files("src/*.cpp")
                else
                    add_defines("LLFIO_HEADERS_ONLY=1")
                    add_headerfiles("include/(llfio/**.ipp)")
                end

                remove_headerfiles("include/llfio/ntkernel-error-category/**")
        ]])
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <llfio/llfio.hpp>
            void test () {
                namespace llfio = LLFIO_V2_NAMESPACE;
                llfio::file_handle fh = llfio::file({}, "foo").value();
            }
        ]]}, {configs = {languages = "c++17", exceptions = "cxx"}}))
    end)
