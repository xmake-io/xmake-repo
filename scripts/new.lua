import("core.base.option")
import("core.base.semver")
import("core.base.json")
import("core.base.hashset")
import("lib.detect.find_tool")
import("lib.detect.find_file")
import("net.http")
import("devel.git")
import("utils.archive")

local options = {
    {nil, "repo", "v", nil, "Set repository name.",
                            "e.g. ",
                            "  - github:xmake-io/xmake",
                            "  - gitlab:xmake-io/xmake"}
}

-- function to get Gitlab data
function get_gitlab_data(reponame)
    local glab = assert(find_tool("glab"), "glab not found!")
    local host = os.iorunv(glab.program, {"config", "get", "host"}):trim()
    local graphql_query = 'query={ project(fullPath: "' .. reponame .. '") { description webUrl sshUrlToRepo name } }'
    local repoinfo = os.iorunv(glab.program, {"api", "graphql", "-f", graphql_query})

    local data = {}
    if repoinfo then
        repoinfo = json.decode(repoinfo)
        if repoinfo.data and repoinfo.data.project then
            -- extract required data and restructure it
            local project_data = repoinfo.data.project
            data = {
                description = project_data.description,
                homepageUrl = project_data.webUrl,
                licenseInfo = "MIT", -- NOTE: Find a way to get the project license in gitlab
                url = project_data.webUrl,
                sshUrl = project_data.sshUrlToRepo,
                name = project_data.name,
            }
            repoinfo.data.project = data
        end
    end
    return {host = host, data = data}
end

local function get_github_data(reponame)
    local gh = assert(find_tool("gh"), "gh not found!")
    local host = "github.com"
    local data = os.iorunv(gh.program, {
        "repo",
        "view",
        reponame,
        "--json",
        "description,homepageUrl,licenseInfo,url,sshUrl,name,latestRelease",
    })
    if data then
        data = json.decode(data)
    end
    return {data = data, host = host}
end

function generate_package(reponame, get_data)
    local repo_data = get_data(reponame)
    local data = repo_data.data
    local host = repo_data.host

    -- generate package header
    local packagename = assert(data.name, "package name not found!"):lower()
    local packagefile = path.join("packages", string.sub(packagename, 1, 1), packagename, "xmake.lua")
    local file = io.open(packagefile, "w")

    -- define package and homepage
    file:print('package("%s")', packagename)
    local homepage = data.homepageUrl and data.homepageUrl ~= "" and data.homepageUrl or data.url
    if homepage then
        file:print('    set_homepage("%s")', homepage)
    end

    local description = data.description or ("The " .. packagename .. " package")
    file:print('    set_description("%s")', description)

    -- define license if available
    if type(data.licenseInfo) == "table" and data.licenseInfo.key then
        local licenses = {
            ["apache-2.0"] = "Apache-2.0",
            ["lgpl-2.0"] = "LGPL-2.0",
            ["lgpl-2.1"] = "LGPL-2.1",
            zlib = "zlib",
            mit = "MIT",
        }
        local license = licenses[data.licenseInfo.key]
        if license then
            file:print('    set_license("%s")', license)
        end
    end
    file:print("")

    -- define package URLs and versions
    local repodir
    local has_xmake, has_cmake, has_meson, has_bazel, has_autoconf, need_autogen
    local latest_release = data.latestRelease

    if type(latest_release) == "table" then
        local url = string.format("https://%s/%s/archive/refs/tags/%s.tar.gz", host, reponame, latest_release.tagName)
        local giturl = string.format("https://%s/%s.git", host, reponame)
        local tmpfile = os.tmpfile({ramdisk = false}) .. ".tar.gz"
        repodir = tmpfile .. ".dir"

        file:write('    add_urls("https://' .. host .. '/' .. reponame .. '/-/archive/$(version).tar.gz",\n')
        file:print('             "%s")\n', giturl)

        print("downloading %s", url)
        http.download(url, tmpfile)

        file:print('    add_versions("%s", "%s")', latest_release.tagName, hash.sha256(tmpfile))
        archive.extract(tmpfile, repodir)
        os.rm(tmpfile)
    else
        local giturl = string.format("git@%s:%s.git", host, reponame)
        repodir = os.tmpfile({ ramdisk = false })

        file:print('    add_urls("%s")', giturl)

        print("downloading %s", giturl)
        git.clone(giturl, { outputdir = repodir, depth = 1 })

        local commit = git.lastcommit({ repodir = repodir })
        local version = try {
            function()
                return os.iorunv("git", {
                    "log",
                    "-1",
                    "--date=format:%Y.%m.%d",
                    "--format=%ad",
                }, { curdir = repodir })
            end
        }
        if version then
            file:print('    add_versions("%s", "%s")', version:trim(), commit)
        end
    end

    local build_systems = {
        ["xmake.lua"] = {
            deps = {},
            install = function(configs, package)
                return [=[
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("%s")
                set_kind("$(kind)")
                add_files("src/*.c")
                add_headerfiles("src/(*.h)")
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)]=]
            end,
        },
        ["CMakeLists.txt"] = {
            deps = {"cmake"},
            install = function(configs, package)
                return [[
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)]]
            end,
        },
        ["configure,configure.ac,autogen.sh"] = {
            deps = {"autoconf", "automake", "libtool"},
            install = function(configs, package)
                return [[
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package, configs)]]
            end,
        },
        ["meson.build"] = {
            deps = {"meson", "ninja"},
            install = function(configs, package)
                return [[
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)]]
            end,
        },
        ["BUILD,BUILD.bazel"] = {
            deps = {"bazel"},
            install = function(configs, package)
                return 'import("package.tools.bazel").install(package, configs)'
            end,
        }
    }

    -- detect build system
    local build_system = nil
    if repodir then
        local files = os.files(path.join(repodir, "*")) or {}
        table.join2(files, os.files(path.join(repodir, "*", "*")))
        for _, file in ipairs(files) do
            local filename = path.filename(file)
            for k, v in pairs(build_systems) do
                local filenames = hashset.from(k:split(","))
                if filenames:has(filename) then
                    build_system = v
                    break
                end
            end
        end
        os.rm(repodir)
    end
    if not build_system then
        build_system = build_systems["xmake.lua"]
    end

    -- add dependencies
    if build_system then
        file:print('')
        local deps = table.wrap(build_system.deps)
        if deps and #deps > 0 then
            file:print('    add_deps("' .. table.concat(deps, '", "') .. '")')
        end
    end

    -- generate install scripts
    file:print('')
    file:print('    on_install(function (package)')
    file:print('        local configs = {}')
    if build_system then
        file:print(build_system.install(configs, package))
    end
    file:print('    end)')

    -- generate test scripts
    file:print('')
    file:print('    on_test(function (package)')
    file:print('        assert(package:has_cfuncs("foo", {includes = "foo.h"}))')
    file:print('    end)')
    file:close()

    io.cat(packagefile)
    cprint("${bright}%s generated!", packagefile)
end

function main(...)
    local opt = option.parse(table.pack(...), options, "New a package.", "", "Usage: xmake l scripts/new.lua [options]")
    local repo = assert(opt.repo, "repository name must be set!")
    local reponame = repo:sub(8)

    if repo:startswith("github:") then
        generate_package(reponame, get_github_data)
        return
    end

    if repo:startswith("gitlab:") then
        generate_package(reponame, get_gitlab_data)
        return
    end

    raise("unsupported repository source. only 'github' and 'gitlab' are supported.")
end
