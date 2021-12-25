import("core.base.option")
import("core.base.semver")
import("core.base.json")
import("lib.detect.find_tool")
import("net.http")

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
    local licensekey = repoinfo.licenseInfo and repoinfo.licenseInfo.key
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
    local latest_release = repoinfo.latestRelease
    if latest_release then
        local url = ("https://github.com/%s/archive/refs/tags/%s.tar.gz"):format(reponame, latest_release.tagName)
        local giturl = ("https://github.com/%s.git"):format(reponame)
        file:print('    add_urls("%s",', url)
        file:print('             "%s")', giturl)
        local tmpfile = os.tmpfile()
        print("downloading %s", url)
        http.download(url, tmpfile)
        file:print('    add_versions("%s", "%s")', latest_release.tagName, hash.sha256(tmpfile))
        os.rm(tmpfile)
    end

    -- generate install scripts
    file:print("")
    file:print("    on_install(function (package)")
    file:print("        local configs = {}")
    file:print('        import("package.tools.xmake").install(package, configs)')
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
