package("cmake")

    set_kind("binary")
    set_homepage("https://cmake.org")
    set_description("A cross-platform family of tool designed to build, test and package software")

    if is_host("macosx") then
        add_urls("https://cmake.org/files/v$(version)-Darwin-x86_64.tar.gz", {version = function (version)
                return table.concat(table.slice((version):split('%.'), 1, 2), '.') .. "/cmake-" .. version 
            end})
        add_urls("https://github.com/Kitware/CMake/releases/download/v$(version)/cmake-$(version)-Darwin-x86_64.tar.gz")
        add_urls("https://gitlab.com/xmake-mirror/cmake-releases/raw/master/cmake-$(version)-Darwin-x86_64.tar.gz")
        add_versions("3.11.4", "2b5eb705f036b1906a5e0bce996e9cd56d43d73bdee8318ece3e5ce31657b812")
        add_versions("3.15.4", "adfbf611d21daa83b9bf6d85ab06a455e481b63a38d6e1270d563b03d4e5f829")
    elseif is_host("linux") and is_arch("x86_64") then
        add_urls("https://cmake.org/files/v$(version)-Linux-x86_64.tar.gz", {version = function (version)
                return table.concat(table.slice((version):split('%.'), 1, 2), '.') .. "/cmake-" .. version 
            end})
        add_urls("https://github.com/Kitware/CMake/releases/download/v$(version)/cmake-$(version)-Linux-x86_64.tar.gz")
        add_urls("https://gitlab.com/xmake-mirror/cmake-releases/raw/master/cmake-$(version)-Linux-x86_64.tar.gz")
        add_versions("3.11.4", "6dab016a6b82082b8bcd0f4d1e53418d6372015dd983d29367b9153f1a376435")
        add_versions("3.15.4", "7c2b17a9be605f523d71b99cc2e5b55b009d82cf9577efb50d4b23056dee1109")
    elseif is_host("windows") then
        if os.arch() == "x64" then
            add_urls("https://cmake.org/files/v$(version)-win64-x64.zip", {excludes = "*/doc/*", version = function (version)
                    return table.concat(table.slice((version):split('%.'), 1, 2), '.') .. "/cmake-" .. version 
                end})
            add_urls("https://github.com/Kitware/CMake/releases/download/v$(version)/cmake-$(version)-win64-x64.zip", {excludes = "*/doc/*"})
            add_urls("https://gitlab.com/xmake-mirror/cmake-releases/raw/master/cmake-$(version)-win64-x64.zip", {excludes = "*/doc/*"})
            add_versions("3.11.4", "d3102abd0ded446c898252b58857871ee170312d8e7fd5cbff01fbcb1068a6e5")
            add_versions("3.15.4", "5bb49c0274800c38833e515a01af75a7341db68ea82c71856bb3cf171d2068be")
        else
            add_urls("https://cmake.org/files/v$(version)-win32-x86.zip", {excludes = "*/doc/*", version = function (version)
                    return table.concat(table.slice((version):split('%.'), 1, 2), '.') .. "/cmake-" .. version 
                end})
            add_urls("https://github.com/Kitware/CMake/releases/download/v$(version)/cmake-$(version)-win32-x86.zip", {excludes = "*/doc/*"})
            add_urls("https://gitlab.com/xmake-mirror/cmake-releases/raw/master/cmake-$(version)-win32-x86.zip", {excludes = "*/doc/*"})
            add_versions("3.11.4", "b068001ff879f86e704977c50a8c5917e4b4406c66242366dba2674abe316579")
            add_versions("3.15.4", "19c2bfd26c4de4d8046dd5ad6de95b57a2556559ec81b13b94e63ea4ae49b3f2")
        end
    end

    on_install("@macosx", function (package)
        os.cp("CMake.app/Contents/bin", package:installdir())
        os.cp("CMake.app/Contents/share", package:installdir())
    end)

    on_install("@linux|x86_64", "@windows", function (package)
        os.cp("bin", package:installdir())
        os.cp("share", package:installdir())
    end)

    on_test(function (package)
        os.vrun("cmake --version")
    end)
