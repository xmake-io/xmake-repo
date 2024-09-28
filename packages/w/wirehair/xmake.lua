package("wirehair")
    set_homepage("http://wirehairfec.com")
    set_description("Wirehair : O(N) Fountain Code for Large Data")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/catid/wirehair.git")

    add_versions("2023.12.02", "557c00c707a4b6a51db312c113b8036dadbe132e")

    if on_check then
        on_check("mingw", function (package)
            if is_host("macosx") then
                raise("package(wirehair) unsupport mingw plat on macosx")
            end
        end)
    end

    on_install("!macosx and !iphoneos and !wasm and (!windows or windows|!arm64)", function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "WIREHAIR_DLL")
        end

        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++11")
            add_vectorexts("all")
            target("wirehair")
                set_kind("$(kind)")
                add_files("*.cpp")
                add_includedirs("include")
                add_headerfiles("include/(wirehair/*.h)")
                if is_plat("windows") and is_kind("shared") then
                    add_defines("WIREHAIR_BUILDING", "WIREHAIR_DLL")
                end
                add_installfiles("python/*.py", {prefixdir = "python"})
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("wirehair_encoder_create", {includes = "wirehair/wirehair.h"}))
    end)
