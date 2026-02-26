package("cmake")
    set_kind("binary")
    set_homepage("https://cmake.org")
    set_description("A cross-platform family of tools designed to build, test and package software")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::cmake")
    elseif is_plat("linux") then
        add_extsources("pacman::cmake", "apt::cmake")
    elseif is_plat("macosx") then
        add_extsources("brew::cmake")
    end

    if add_schemes then
        add_schemes("binary", "source")
    end

    on_source(function (package)
        import("schemes.binary")
        import("schemes.source")
        if package.current_scheme then
            binary.add_urls(package, "binary")
            source.add_urls(package, "source")
        else
            if binary.add_urls(package) then
                package:data_set("scheme", "binary")
            else
                source.add_urls(package)
                package:data_set("scheme", "source")
            end
        end
    end)

    on_load(function (package)
        -- xmake v3.x will enable this ninja policy by default
        import("core.project.project")
        if xmake.version():ge("2.9.0") and project.policy("package.cmake_generator.ninja") then
            -- We mark it as public, even if cmake is already installed,
            -- we need also to install ninja and export the ninja PATH. (above xmake 2.9.8)
            package:add("deps", "ninja", {public = true})
        end
    end)

    on_install("@macosx", "@linux", "@windows", "@msys", "@cygwin", "@bsd", function (package)
        import("schemes.binary")
        import("schemes.source")
        local scheme_name = package.current_scheme and package:current_scheme():name() or package:data("scheme")
        if scheme_name == "binary" then
            binary.install(package)
        else
            source.install(package)
        end
    end)

    on_test(function (package)
        os.vrun("cmake --version")
    end)
