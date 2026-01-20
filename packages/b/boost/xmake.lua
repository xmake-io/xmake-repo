package("boost")
    set_homepage("https://www.boost.org/")
    set_description("Collection of portable C++ source libraries.")
    set_license("BSL-1.0")

    -- xrepo does not support `package:config("cmake")` in on_source to set the download url, so if you want to build with cmake, we need to `add_urls` cmake archive url at first line.
    -- Users can also download the cmake archive and put it in `xmake g --pkg_searchdirs=` to avoid xrepo using a non-cmake archive url.
    add_urls("https://github.com/boostorg/boost/releases/download/boost-$(version)/boost-$(version)-cmake.tar.gz", {alias = "cmake"})
    add_urls("https://github.com/boostorg/boost/releases/download/boost-$(version)/boost-$(version)-b2-nodocs.tar.gz")
    add_urls("https://github.com/boostorg/boost/releases/download/boost-$(version)/boost-$(version).tar.gz")
    add_urls("https://github.com/xmake-mirror/boost/releases/download/boost-$(version).tar.bz2", {alias = "mirror", version = function (version)
            return version .. "/boost_" .. (version:gsub("%.", "_"))
        end})

    add_versions("cmake:1.90.0", "913ca43d49e93d1b158c9862009add1518a4c665e7853b349a6492d158b036d4")
    add_versions("cmake:1.89.0", "954a01219bf818c7fb850fa610c2c8c71a4fa28fa32a1900056bcb6ff58cf908")
    add_versions("cmake:1.88.0", "dcea50f40ba1ecfc448fdf886c0165cf3e525fef2c9e3e080b9804e8117b9694")
    add_versions("cmake:1.87.0", "78fbf579e3caf0f47517d3fb4d9301852c3154bfecdc5eeebd9b2b0292366f5b")
    add_versions("cmake:1.86.0", "c62ce6e64d34414864fef946363db91cea89c1b90360eabed0515f0eda74c75c")

    add_versions("1.90.0", "e848446c6fec62d8a96b44ed7352238b3de040b8b9facd4d6963b32f541e00f5")
    add_versions("1.89.0", "aa25e7b9c227c21abb8a681efd4fe6e54823815ffc12394c9339de998eb503fb")
    add_versions("1.88.0", "85138e4a185a7e7535e82b011179c5b5fb72185bea9f59fe8e2d76939b2f5c51")
    add_versions("1.87.0", "d6c69e4459eb5d6ec208250291221e7ff4a2affde9af6e49c9303b89c687461f")
    add_versions("1.86.0", "2128a4c96862b5c0970c1e34d76b1d57e4a1016b80df85ad39667f30b1deba26")
    add_versions("1.85.0", "f4a7d3f81b8a0f65067b769ea84135fd7b72896f4f59c7f405086c8c0dc61434")
    add_versions("1.84.0", "4d27e9efed0f6f152dc28db6430b9d3dfb40c0345da7342eaa5a987dde57bd95")
    add_versions("1.83.0", "0c6049764e80aa32754acd7d4f179fd5551d8172a83b71532ae093e7384e98da")
    add_versions("1.82.0", "b62bd839ea6c28265af9a1f68393eda37fab3611425d3b28882d8e424535ec9d")
    add_versions("1.81.0", "121da556b718fd7bd700b5f2e734f8004f1cfa78b7d30145471c526ba75a151c")

    add_versions("mirror:1.80.0", "1e19565d82e43bc59209a168f5ac899d3ba471d55c7610c677d4ccf2c9c500c0")
    add_versions("mirror:1.79.0", "475d589d51a7f8b3ba2ba4eda022b170e562ca3b760ee922c146b6c65856ef39")
    add_versions("mirror:1.78.0", "8681f175d4bdb26c52222665793eef08490d7758529330f98d3b29dd0735bccc")
    add_versions("mirror:1.77.0", "fc9f85fc030e233142908241af7a846e60630aa7388de9a5fafb1f3a26840854")
    add_versions("mirror:1.76.0", "f0397ba6e982c4450f27bf32a2a83292aba035b827a5623a14636ea583318c41")
    add_versions("mirror:1.75.0", "953db31e016db7bb207f11432bef7df100516eeb746843fa0486a222e3fd49cb")
    add_versions("mirror:1.74.0", "83bfc1507731a0906e387fc28b7ef5417d591429e51e788417fe9ff025e116b1")
    add_versions("mirror:1.73.0", "4eb3b8d442b426dc35346235c8733b5ae35ba431690e38c6a8263dce9fcbb402")
    add_versions("mirror:1.72.0", "59c9b274bc451cf91a9ba1dd2c7fdcaf5d60b1b3aa83f2c9fa143417cc660722")
    add_versions("mirror:1.70.0", "430ae8354789de4fd19ee52f3b1f739e1fba576f0aded0897c3c2bc00fb38778")

    add_patches("1.75.0", "patches/1.75.0/warning.patch", "43ff97d338c78b5c3596877eed1adc39d59a000cf651d0bcc678cf6cd6d4ae2e")

    includes(path.join(os.scriptdir(), "libs.lua"))
    for _, libname in ipairs(get_libs()) do
        add_configs(libname, {description = "Enable " .. libname .. " library.", default = (libname == "filesystem"), type = "boolean"})
    end
    add_configs("zlib", {description = "Enable zlib for iostreams", default = false, type = "boolean"})
    add_configs("bzip2", {description = "Enable bzip2 for iostreams", default = false, type = "boolean"})
    add_configs("lzma", {description = "Enable lzma for iostreams", default = false, type = "boolean"})
    add_configs("zstd", {description = "Enable zstd for iostreams", default = false, type = "boolean"})
    add_configs("openssl", {description = "Enable openssl for mysql/redis", default = false, type = "boolean"})
    add_configs("icu", {description = "Enable icu for regex/locale", default = false, type = "boolean"})

    add_configs("cmake", {description = "Use cmake build system (>= 1.86)", default = true, type = "boolean"})
    add_configs("all", {description = "Enable all library modules support.", default = false, type = "boolean"})
    add_configs("header_only", {description = "Enable header only modules", default = false, type = "boolean"})

    add_configs("pyver", {description = "python version x.y, etc. 3.10 (only for b2)", default = "3.10"})
    add_configs("multi", {description = "Enable multi-thread support (only for b2)",  default = true, type = "boolean"})

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::boost")
    elseif is_plat("linux") then
        add_extsources("pacman::boost", "apt::libboost-all-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::boost")
    end

    on_fetch("fetch")

    if on_check then
        on_check(function (package)
            if not package:is_plat("macosx", "linux", "windows", "bsd", "mingw", "cross") then
                if not package:config("cmake") then
                    raise("package(boost/b2) unsupported current platform.")
                end
            end
        end)
    end

    on_load(function (package)
        if package:is_plat("linux", "bsd") then
            package:add("syslinks", "pthread", "dl")
        elseif package:is_plat("windows", "mingw") then
            package:add("syslinks", "ntdll", "shell32", "advapi32", "user32", "ws2_32")
        end

        local version = package:version()
        if package:config("cmake") and version:lt("1.86") then
            -- Don't break old version
            package:config_set("cmake", false)
        end

        if package:config("cmake") then
            wprint("If cmake build failure, set package config cmake = false fallback to b2 for the build")

            package:add("deps", "cmake")
            import("cmake.load")(package)
        else
            if package:is_plat("linux") then
                package:add("deps", "bzip2", "zlib")
            end
            import("b2.load")(package)
        end
    end)

    on_install(function (package)
        if package:config("cmake") then
            assert(os.isfile("CMakeLists.txt"), "Currently the source archive only has the b2 build system, you need to download the cmake archive and put it in `xmake g --pkg_searchdirs=` to avoid xrepo using a non-cmake archive url.")
            import("cmake.install")(package)
        else
            import("b2.install")(package)
        end
    end)

    on_test(function (package)
        import("test")(package)
    end)
