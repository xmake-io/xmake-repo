import("core.base.option")
import("core.base.semver")
import("core.base.json")
import("lib.detect.find_tool")
import("lib.detect.find_file")
import("net.http")
import("utils.archive")

local options = {
    {nil, "repo", "v", nil, "Set repository name.",
                            "e.g. ",
                            "  - github:xmake-io/xmake",
                            "  - brew:zlib"}
}

function _generate_package_from_github(reponame)
    -- get repository info
    local gh = assert(find_tool("gh"), "gh not found!")
    local repoinfo = os.iorunv(gh.program, {"repo", "view", reponame, "--json",
        "description,homepageUrl,licenseInfo,url,sshUrl,name,latestRelease"})
    if repoinfo then
        repoinfo = json.decode(repoinfo)
    end
    print(repoinfo)

    -- generate package header
    local packagename = assert(repoinfo.name, "package name not found!"):lower()
    local packagefile = path.join("packages", packagename:sub(1, 1), packagename, "xmake.lua")
    local file = io.open(packagefile, "w")
    file:print('package("%s")', packagename)
    local homepage = repoinfo.homepageUrl or repoinfo.url
    if homepage then
        file:print('    set_homepage("%s")', homepage)
    end
    local description = repoinfo.description or ("The " .. packagename .. " package")
    file:print('    set_description("%s")', description)
    local licensekey = type(repoinfo.licenseInfo) == "table" and repoinfo.licenseInfo.key
    if licensekey then
        local licenses = {
            ["apache-2.0"] = "Apache-2.0"
        }
        local license = licenses[licensekey]
        if license then
            file:print('    set_license("%s")', license)
        end
    end
    file:print("")

    -- generate package urls and versions
    local has_xmake
    local has_cmake
    local has_meson
    local has_autoconf
    local latest_release = repoinfo.latestRelease
    if type(latest_release) == "table" then
        local url = ("https://github.com/%s/archive/refs/tags/%s.tar.gz"):format(reponame, latest_release.tagName)
        local giturl = ("https://github.com/%s.git"):format(reponame)
        file:print('    add_urls("%s",', url)
        file:print('             "%s")', giturl)
        local tmpfile = os.tmpfile({ramdisk = false}) .. ".tar.gz"
        local tmpdir = tmpfile .. ".dir"
        print("downloading %s", url)
        http.download(url, tmpfile)
        file:print('    add_versions("%s", "%s")', latest_release.tagName, hash.sha256(tmpfile))
        archive.extract(tmpfile, tmpdir)
        local files = os.files(path.join(tmpdir, "*")) or {}
        table.join2(files, os.files(path.join(tmpdir, "*", "*")))
        for _, file in ipairs(files) do
            local filename = path.filename(file)
            if filename == "xmake.lua" then
                has_xmake = true
            elseif filename == "CMakeLists.txt" then
                has_cmake = true
            elseif filename == "configure" or filename == "autogen.sh" then
                has_autoconf = true
            elseif filename == "meson.build" then
                has_meson = true
            end
        end
        os.rm(tmpdir)
        os.rm(tmpfile)
    end

    -- generate install scripts
    file:print("")
    file:print("    on_install(function (package)")
    file:print("        local configs = {}")
    if has_cmake then
        file:print('        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))')
        file:print('        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))')
        file:print('        import("package.tools.cmake").install(package, configs)')
    elseif has_autoconf then
        file:print('        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))')
        file:print('        if package:debug() then')
        file:print('            table.insert(configs, "--enable-debug")')
        file:print('        end')
        file:print('        if package:is_plat("linux") and package:config("pic") ~= false then')
        file:print('            table.insert(configs, "--with-pic")')
        file:print('        end')
    elseif has_meson then
        file:print('        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))')
        file:print('        import("package.tools.meson").install(package, configs)')
    else
        file:print('        io.writefile("xmake.lua", [[')
        file:print('            add_rules("mode.release", "mode.debug")')
        file:print('            target("%s")', packagename)
        file:write('               set_kind("$(kind)")\n')
        file:print('               add_files("src/*.c")')
        file:print('        ]])')
        file:print('        if package:config("shared") then')
        file:print('            configs.kind = "shared"')
        file:print('        end')
        file:print('        import("package.tools.xmake").install(package, configs)')
    end
    file:print("    end)")

    -- generate test scripts
    file:print("")
    file:print("    on_test(function (package)")
    file:print('        assert(package:has_cfuncs("foo", {includes = "foo.h"}))')
    file:print("    end)")

    file:close()
    io.cat(packagefile)
    cprint("${bright}%s generated!", packagefile)
end

function main(...)
    local opt = option.parse(table.pack(...), options, "New a package.", "",
        "Usage: xmake l scripts/new.lua [options]")
    local repo = opt.repo
    if repo and repo:startswith("github:") then
        _generate_package_from_github(repo:sub(8))
    else
        raise("we need set repository name first!")
    end
end
