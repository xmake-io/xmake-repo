package("libsolv")
    set_homepage("https://github.com/openSUSE/libsolv")
    set_description("Library for solving packages and reading repositories.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/openSUSE/libsolv/archive/refs/tags/$(version).tar.gz",
             "https://github.com/openSUSE/libsolv.git")

    add_versions("0.7.35", "e6ef552846f908beb3bbf6ca718b6dd431bd8a281086d82af9a6d2a3ba919be5")
    add_versions("0.7.34", "fd9c8a75d3ca09d9ff7b0d160902fac789b3ce6f9fb5b46a7647895f9d3eaf05")

    add_patches("<=0.7.34", "patches/fix-msvc-c2036.patch", "a924517033d4f8ba18e922e892953834d3ca1a4fa5a69ae04fd308df40d1b2e8")
    add_patches("<=0.7.34", "patches/fix-compile-on-mingw-w64.patch", "e6ba565110c918363a4499a4fc949f29777e0a189f192c231c81a47da821d21d")

    -- when using mingw, cmake cannot force export of all symbols.
    if is_plat("mingw", "msys", "cygwin") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_configs("tools", {description = "Build tools.", default = false, type = "boolean"}) 

     -- needs rpm, rpmdb, rpmio, rpmmisc, db
    add_configs("rpmdb",             {description = "Build with rpm database support.", default = false, type = "boolean"})
    add_configs("rpmdb_librpm",      {description = "Use librpm to access the rpm database.", default = false, type = "boolean"})
    add_configs("rpmdb_bdb",         {description = "Use BerkeleyDB to access the rpm database.", default = false, type = "boolean"})
    add_configs("rpmdb_byrpmheader", {description = "Build with rpmdb Header support.", default = false, type = "boolean"})
    add_configs("rpmpkg",            {description = "Build with rpm package support.", default = false, type = "boolean"})
    add_configs("rpmpkg_librpm",     {description = "Use librpm to access rpm header information.", default = false, type = "boolean"})
    add_configs("pubkey",            {description = "Build with pubkey support.", default = false, type = "boolean"})
    add_configs("rpmmd",             {description = "Build with rpmmd repository support.", default = false, type = "boolean"})
    add_configs("rpm5",              {description = "Enabling RPM 5 support.", default = false, type = "boolean"})

    add_configs("suserepo",  {description = "Build with suse repository support.", default = false, type = "boolean"})
    add_configs("comps",     {description = "Build with fedora comps support.", default = false, type = "boolean"})
    add_configs("helixrepo", {description = "Build with helix repository support.", default = false, type = "boolean"})
    add_configs("debian",    {description = "Build with debian package/repository support.", default = false, type = "boolean"})
    add_configs("mdkrepo",   {description = "Build with mandriva/mageia repository support.", default = false, type = "boolean"})
    add_configs("archrepo",  {description = "Build with archlinux repository support.", default = false, type = "boolean"})
    add_configs("apk",       {description = "Build with apk package/repository support.", default = false, type = "boolean"})
    add_configs("cudfrepo",  {description = "Build with cudf repository support.", default = false, type = "boolean"})

    add_configs("haiku",     {description = "Build with Haiku package support.", default = false, type = "boolean"})
    add_configs("conda",     {description = "Build with conda dependency support.", default = false, type = "boolean"})
    add_configs("appdata",   {description = "Build with AppStream appdata support.", default = false, type = "boolean"})
    add_configs("multi_semantics", {description = "Build with support for multiple distribution types.", default = false, type = "boolean"})

    add_configs("lzma_compression",   {description = "Build with lzma/xz compression support.", default = false, type = "boolean"})
    add_configs("bzip2_compression",  {description = "Build with bzip2 compression support.", default = false, type = "boolean"})
    add_configs("zstd_compression",   {description = "Build with zstd compression support.", default = false, type = "boolean"})
    add_configs("zchunk_compression", {description = "Build with zchunk compression support.", default = false, type = "boolean"})

    add_configs("libxml2", {description = "Build with libxml2 instead of libexpat.", default = false, type = "boolean"})
    if not is_plat("windows", "mingw", "msys", "cygwin") then
        add_configs("cookieopen", {description = "Enable the use of stdio cookie opens.", default = true, type = "boolean"})
    else
        add_configs("cookieopen", {description = "Enable the use of stdio cookie opens.", default = false, type = "boolean", readonly = true})
    end

    add_configs("FEDORA",    {description = "Building for Fedora.", default = false, type = "boolean"})
    add_configs("DEBIAN",    {description = "Building for Debian.", default = false, type = "boolean"})
    add_configs("SUSE",      {description = "Building for SUSE.", default = false, type = "boolean"})
    add_configs("ARCHLINUX", {description = "Building for Archlinux.", default = false, type = "boolean"})
    add_configs("MANDRIVA",  {description = "Building for Mandriva.", default = false, type = "boolean"})
    add_configs("MAGEIA",    {description = "Building for Mageia.", default = false, type = "boolean"})
    add_configs("HAIKU",     {description = "Building for Haiku.", default = false, type = "boolean"}) -- needs haiku be, network, package.

    add_deps("cmake")
    if not is_subhost("windows") then
        add_deps("pkg-config")
    else
        add_deps("pkgconf")
    end
    on_load(function (package)
        local libxml2_or_expat_enabled = false

        if package:config("ARCHLINUX") then
            package:config_set("archrepo", true)
        end
        if package:config("MANDRIVA") then
            package:config_set("mdkrepo", true)
        end
        if package:config("MAGEIA") then
            package:config_set("mdkrepo", true)
            package:config_set("lzma_compression", true)
        end
        if package:config("DEBIAN") then
            package:config_set("debian", true)
        end
        if package:config("SUSE") then
            package:config_set("suserepo", true)
            package:config_set("helixrepo", true)
        end

        if package:config("rpm5") then
            package:config_set("rpmmd", true)
        end
        if package:config("archrepo") or package:config("debian") then
            package:config_set("lzma_compression", true)
        end
        if package:config("apk") then
            package:config_set("zstd_compression", true)
        end
        if package:config("rpmmd") or package:config("suserepo") or package:config("appdata") or package:config("comps") or package:config("helixrepo") or mdkrepo_enabled then
            libxml2_or_expat_enabled = true
        end

        package:add("deps", "zlib")
        if package:config("lzma_compression") then
            package:add("deps", "xz")
        end
        if package:config("bzip2_compression") then
            package:add("deps", "bzip2")
        end
        if package:config("zstd_compression") then
            package:add("deps", "zstd")
        end
        if package:config("zchunk_compression") then
            package:add("deps", "zchunk")
        end
        if libxml2_or_expat_enabled then
            if package:config("libxml2") then
                package:add("deps", "libxml2")
            else
                package:add("deps", "expat")
            end
        end
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DENABLE_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DDISABLE_SHARED=" .. (package:config("shared") and "OFF" or "ON"))

        local options = {
            "rpmdb", "rpmdb_librpm", "rpmdb_bdb", "rpmdb_byrpmheader", "rpmpkg", "rpmpkg_librpm", "pubkey", "rpmmd", "rpm5",
            "suserepo", "comps", "helixrepo", "debian", "mdkrepo", "archrepo", "apk", "cudfrepo",
            "haiku", "conda", "appdata", "multi_semantics",
            "lzma_compression", "bzip2_compression", "zstd_compression", "zchunk_compression"
        }
        local no_prefix_options = {
            "multi_semantics", "rpm5"
        }
        for _, option in ipairs(options) do
            if package:config(option) then
                if not table.contains(no_prefix_options, option) then
                    table.insert(configs, ("-DENABLE_%s=ON"):format(option:upper()))
                else
                    table.insert(configs, ("-D%s=ON"):format(option:upper()))
                end
            end
        end

        table.insert(configs, "-DWITHOUT_COOKIEOPEN=" .. (package:config("cookieopen") and "OFF" or "ON"))
        table.insert(configs, "-DWITH_LIBXML2=" .. (package:config("libxml2") and "ON" or "OFF"))
        if package:config("zchunk_compression") then
            table.insert(configs, "-DWITH_SYSTEM_ZCHUNK=ON")
        end

        if not package:config("tools") then
            io.replace("CMakeLists.txt", "ADD_SUBDIRECTORY (tools)", "", {plain = true})
        end
        io.replace("CMakeLists.txt", "ADD_SUBDIRECTORY (examples)", "", {plain = true})
        io.replace("CMakeLists.txt", "ADD_SUBDIRECTORY (doc)", "", {plain = true})
        io.replace("ext/CMakeLists.txt", "repo_testcase.c", "", {plain = true})
        io.replace("ext/CMakeLists.txt", "testcase.c", "", {plain = true})
        io.replace("ext/CMakeLists.txt", "testcase.h", "", {plain = true})

        if package:config("cookieopen") then
            -- @see https://developer.android.com/ndk/guides/common-problems
            -- funopen() is sometimes not available when API < 24.
            if package:is_plat("android") and package:is_arch("armeabi-v7a") then
                local ndk_sdkver = package:toolchain("ndk"):config("ndk_sdkver")
                if ndk_sdkver and tonumber(ndk_sdkver) < 24 then
                    io.replace("CMakeLists.txt", "ADD_DEFINITIONS (-D_FILE_OFFSET_BITS=64)", "", {plain = true})
                end
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                Pool *pool = pool_create();
            }
        ]]}, {configs = {languages = "c99"}, includes = "solv/pool.h"}))
    end)
