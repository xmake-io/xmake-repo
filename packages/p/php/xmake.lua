package("php")
    set_homepage("https://www.php.net/")
    set_description("PHP is a popular general-purpose scripting language that is especially suited to web development.")

    add_schemes("binary", "source")

    add_configs("debug", {description = "Enable debug symbols", default = false, type = "boolean"})
    add_configs("threadsafe", {description = "Enable windows thread safe", default = true, type = "boolean"})
    add_configs("devpack", {description = "Download Windows SDK (headers+lib)", default = true, type = "boolean"})

    includes(path.join(os.scriptdir(), "versions.lua"))
    local php_versions = php_versions

    -- 辅助：根据架构、TS、dev 标志生成 hash 表 key
    local function win_key(arch, threadsafe, dev, debug)
        local a = arch == "x86_64" and "x64" or "x86"
        local t = threadsafe and "ts" or "nts"
        if dev then
            return "dev_" .. a .. "_" .. t
        elseif debug then
            return "debug_" .. a .. "_" .. t
        else
            return a .. "_" .. t
        end
    end

    on_source("linux", function(package)
        local source = package:scheme("source")
        source:add("urls", "https://www.php.net/distributions/php-$(version).tar.gz")
        for ver, info in pairs(php_versions) do
            source:add("versions", ver, info.source)
        end

        -- 无二进制包 schemes
        local binary = package:scheme("binary")
    end)

    on_source("windows", function(package)
        local binary = package:scheme("binary")
    
        local arch = package:is_arch("x86_64", "x64") and "x64" or "x86"
        local ts = package:config("threadsafe")
        local suffix = ts and "" or "-nts"
        local url = string.format(
            "https://downloads.php.net/~windows/releases/archives/php-$(version)%s-Win32-vs17-%s.zip",
            suffix, arch)

        binary:add("urls", url)

        for ver, info in pairs(php_versions) do
            binary:add("versions", ver, info.win[win_key(arch, ts, false)])
        end
    end)

    on_load("linux", function (package)
        package:add("deps", "pkg-config")
        package:add("deps", "autoconf")
        package:add("deps", "bison")
        package:add("deps", "re2c")
        package:add("deps", "libxml2")
        package:add("deps", "sqlite3")
        package:add("deps", "libtool")
        package:add("deps", "automake")
    end)

    on_download("windows", function (package, opt)
        import("net.http")
        import("utils.archive")
        -- 通用下载+校验（主包与 devpack 复用同一套逻辑）
        local function download_and_verify(file, url, original_hash)
            local cached = true
            if not os.isfile(file) or (original_hash and original_hash ~= hash.sha256(file)) then
                cached = false
                os.tryrm(file)
                http.download(url, file)
                if original_hash and original_hash ~= hash.sha256(file) then
                    raise("unmatched checksum, current hash(%s) != original hash(%s)",
                          hash.sha256(file):sub(1, 8), original_hash:sub(1, 8))
                end
            end
            return cached
        end

        -- ==================== 主包（标准流程） ====================
        local url = opt.url
        local sourcedir = opt.sourcedir
        local packagefile = path.filename(url)
        local sourcehash = package:sourcehash(opt.url_alias)

        download_and_verify(packagefile, url, sourcehash)

        local sourcedir_tmp = sourcedir .. ".tmp"
        os.rm(sourcedir_tmp)
        if archive.extract(packagefile, sourcedir_tmp) then
            os.rm(sourcedir)
            os.mv(sourcedir_tmp, sourcedir)
        else
            os.tryrm(sourcedir)
            os.mkdir(sourcedir)
        end
        package:originfile_set(path.absolute(packagefile))

        -- ==================== 开发包（条件下载，同样校验 hash） ====================
        if package:config("devpack") then
            local ver = package:version_str()
            local info = php_versions[ver]
            if not info then return end

            local arch = package:is_arch("x86_64", "x64") and "x64" or "x86"
            local ts = package:config("threadsafe")
            local dev_key = win_key(arch, ts, true)
            local dev_hash = info.win[dev_key]

            local dev_url = string.format(
                "https://downloads.php.net/~windows/releases/archives/php-devel-pack-%s%s-Win32-vs17-%s.zip",
                ver, ts and "" or "-nts", arch)
            local devfile = path.join(package:cachedir(), path.filename(dev_url))

            if not os.isfile(devfile) then
                print("downloading php devpack:", dev_url)
            end
            download_and_verify(devfile, dev_url, dev_hash)

            local devdir = path.join(sourcedir, "devpack")
            local devdir_tmp = devdir .. ".tmp"
            os.rm(devdir_tmp)
            if archive.extract(devfile, devdir_tmp) then
                os.rm(devdir)
                os.mv(devdir_tmp, devdir)
            end
        end

        -- ==================== 调试符号包 ====================
        if package:config("debug") then
            local ver = package:version_str()
            local info = php_versions[ver]
            if info then
                local arch = package:is_arch("x86_64", "x64") and "x64" or "x86"
                local ts = package:config("threadsafe")
                local debug_key = win_key(arch, ts, false, true)
                local debug_hash = info.win[debug_key]

                -- 注意 URL 格式：php-debug-pack-{version}-{ts/nts}-Win32-vs17-{arch}.zip
                local debug_url = string.format(
                    "https://downloads.php.net/~windows/releases/archives/php-debug-pack-%s%s-Win32-vs17-%s.zip",
                    ver, ts and "" or "nts", arch)
                local debugfile = path.join(package:cachedir(), path.filename(debug_url))

                if not os.isfile(debugfile) then
                    print("downloading php debug pack:", debug_url)
                end
                download_and_verify(debugfile, debug_url, debug_hash)

                local debugdir = path.join(sourcedir, "debugpack")
                local debugdir_tmp = debugdir .. ".tmp"
                os.rm(debugdir_tmp)
                if archive.extract(debugfile, debugdir_tmp) then
                    os.rm(debugdir)
                    os.mv(debugdir_tmp, debugdir)
                end
            end
        end
    end)

    on_install("linux", function(package)
        local scheme = package:current_scheme()

        local configs = {}
        table.insert(configs, package:config("debug") and "--enable-debug" or "")

        if os.isfile("buildconf") then
            os.vrun("./buildconf --force")
        else
            os.vrun("autoreconf -fi")
        end
        
        import("package.tools.autoconf").install(package, configs)
    end)

    on_install("windows|x64", "windows|x86", function(package)
        local scheme = package:current_scheme()
        if scheme and scheme:name() == "binary" then
            -- 主包：运行时
            os.cp("*.dll", package:installdir("bin"))
            os.cp("ext/*", package:installdir("bin", "ext"), {rootdir = "ext"})
            os.cp("dev/*", package:installdir("bin", "dev"), {rootdir = "dev"})
            os.trycp("extras/*", package:installdir("bin", "extras"), {rootdir = "extras"})
            os.trycp("lib/enchant/*", package:installdir("lib", "enchant"))
            os.cp("*.exe", package:installdir("bin"))
            os.cp("*.phar", package:installdir("bin"))
            os.cp("*.bat", package:installdir("bin"))
            os.cp("*.lib", package:installdir("lib"))
            os.cp("*.txt", package:installdir())
            os.cp("*.md", package:installdir())

            -- dev有lib文件,同步一份到lib目录
            os.cp("dev/*", package:installdir("lib"))

            -- 开发包：头文件 + 导入库
            if package:config("devpack") then
                -- 开发包 zip 内部通常还有一层版本目录
                local devdirs = os.dirs(path.join("devpack", "*"))
                local devroot = #devdirs > 0 and devdirs[1] or "devpack"

                os.trycp(path.join(devroot, "phpize.bat"), package:installdir("bin"))
                os.trycp(path.join(devroot, "include", "*"), path.join(package:installdir("include"), "php"))
                os.trycp(path.join(devroot, "lib", "*"), package:installdir("lib"))
                os.trycp(path.join(devroot, "script", "*"), package:installdir("script"))
                os.trycp(path.join(devroot, "build", "*"), package:installdir("build"))
            end

            -- 调试符号包：.pdb 与 .dll/.exe 同目录才能自动加载
            if package:config("debug") then
                local debugdirs = os.dirs(path.join("debugpack", "*"))
                local debugroot = #debugdirs > 0 and debugdirs[1] or "debugpack"
                os.trycp(path.join(debugroot, "*.pdb"), package:installdir("bin"))
            end
        else
            -- source scheme
        end
    end)

    on_test(function(package)
        local php_exe = path.join(package:installdir("bin"), "php")
        os.vrun(php_exe .. " -v")
        assert(package:has_cincludes("php/main/php_version.h"))
    end)

    on_test("windows", function(package)
        local php_exe = path.join(package:installdir("bin"), "php.exe")
        os.vrun(php_exe .. " -v")

        local scheme = package:current_scheme()
        if scheme and scheme:name() == "source" or package:config("devpack") then
            assert(package:has_cincludes("php/main/php_version.h"))
        end
    end)
