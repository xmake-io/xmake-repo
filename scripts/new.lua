import("core.base.option")
import("core.base.semver")
import("core.base.json")
import("lib.detect.find_tool")
import("lib.detect.find_file")
import("net.http")
import("devel.git")
import("utils.archive")

local options = {
    {
        nil,
        "repo",
        "v",
        nil,
        "Set repository name.",
        "e.g. ",
        "  - github:xmake-io/xmake",
        "  - gitlab:xmake-io/xmake",
    },
}

--[[
   {
        host: string,
        data: {
             name: string,
             description: string,
             homepageUrl: string,
             sshUrl: string,
             url: string,
             licenseInfo: {
                 key: string,
                 name: string,
                 nickname: string,
             },
             latestRelease: {
                 name: string,
                 tagName: string,
                 url: string,
                 publishedAt: string
             }
        }
   }
]]

-- Function to get Gitlab data
local function get_gitlab_data(reponame)
    -- Ensure 'glab' tool is available
    local glab = assert(find_tool("glab"), "glab not found!")

    -- Get the host
    local host = os.iorunv(glab.program, { "config", "get", "host" }):trim()

    -- Build the GraphQL query
    local graphql_query = 'query={ project(fullPath: "' .. reponame .. '") { description webUrl sshUrlToRepo name } }'

    -- Execute the query and get repository info
    local repoinfo = os.iorunv(glab.program, { "api", "graphql", "-f", graphql_query })

    local data = {}
    if repoinfo then
        -- Decode the response JSON
        repoinfo = json.decode(repoinfo)

        if repoinfo.data and repoinfo.data.project then
            -- Extract required data and restructure it
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

    -- Return host and data
    return { host = host, data = data }
end

local function get_github_data(reponame)
    -- get repository info
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

    return { data = data, host = host }
end

local function generate_package(reponame, get_data)
    -- Retrieve repository data
    local repo_data = get_data(reponame)
    local data = repo_data.data
    local host = repo_data.host

    -- Generate package header
    local packagename = assert(data.name, "package name not found!"):lower()
    local packagefile = path.join("packages", string.sub(packagename, 1, 1), packagename, "xmake.lua")
    local file = io.open(packagefile, "w")

    -- Define package and homepage
    file:write(string.format('package("%s")\n', packagename))
    local homepage = data.homepageUrl and data.homepageUrl ~= "" and data.homepageUrl or data.url
    if homepage then
        file:write(string.format('    set_homepage("%s")\n', homepage))
    end

    -- Define package description
    local description = data.description or ("The " .. packagename .. " package")
    file:write(string.format('    set_description("%s")\n', description))

    -- Define license if available
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
            file:write(string.format('    set_license("%s")\n', license))
        end
    end

    file:write("\n")

    -- Define package URLs and versions
    local repodir
    local has_xmake, has_cmake, has_meson, has_bazel, has_autoconf, need_autogen
    local latest_release = data.latestRelease

    if type(latest_release) == "table" then
        local url = string.format("https://%s/%s/archive/refs/tags/%s.tar.gz", host, reponame, latest_release.tagName)
        local giturl = string.format("https://%s/%s.git", host, reponame)
        local tmpfile = os.tmpfile({ ramdisk = false }) .. ".tar.gz"
        repodir = tmpfile .. ".dir"

        file:write(string.format('    add_urls("https://%s/%s/-/archive/$(version).tar.gz",\n', host, reponame))
        file:write(string.format('             "%s")\n', giturl))

        print(string.format("downloading %s", url))
        http.download(url, tmpfile)

        file:write(string.format('    add_versions("%s", "%s")\n', latest_release.tagName, hash.sha256(tmpfile)))
        archive.extract(tmpfile, repodir)
        os.rm(tmpfile)
    else
        local giturl = string.format("git@%s:%s.git", host, reponame)
        repodir = os.tmpfile({ ramdisk = false })

        file:write(string.format('    add_urls("%s")\n', giturl))

        print(string.format("downloading %s", giturl))
        git.clone(giturl, { outputdir = repodir, depth = 1 })

        local commit = git.lastcommit({ repodir = repodir })
        local version = try({
            function()
                return os.iorunv("git", {
                    "log",
                    "-1",
                    "--date=format:%Y.%m.%d",
                    "--format=%ad",
                }, { curdir = repodir })
            end,
        })

        if version then
            file:write(string.format('    add_versions("%s", "%s")\n', version:trim(), commit))
        end
    end

    -- Detect build system
    if repodir then
        local files = os.files(path.join(repodir, "*")) or {}
        table.join2(files, os.files(path.join(repodir, "*", "*")))

        local build_systems = {
            ["xmake.lua"] = function()
                has_xmake = true
            end,
            ["CMakeLists.txt"] = function()
                has_cmake = true
            end,
            ["configure"] = function()
                has_autoconf = true
            end,
            ["autogen.sh"] = function()
                has_autoconf, need_autogen = true, true
            end,
            ["configure.ac"] = function()
                has_autoconf, need_autogen = true, true
            end,
            ["meson.build"] = function()
                has_meson = true
            end,
            ["BUILD"] = function()
                has_bazel = true
            end,
            ["BUILD.bazel"] = function()
                has_bazel = true
            end,
        }

        for _, file in ipairs(files) do
            local filename = path.filename(file)
            local action = build_systems[filename]
            if action then
                action()
            end
        end

        os.rm(repodir)
    end

    -- Define actions for build systems
    local build_systems_actions = {
        ["cmake"] = function()
            file:print('    add_deps("cmake")')
            file:print(
                '        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))'
            )
            file:print(
                '        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))'
            )
            file:print('        import("package.tools.cmake").install(package, configs)')
        end,
        ["meson"] = function()
            file:print('    add_deps("meson", "ninja")')
            file:print(
                '        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))'
            )
            file:print('        import("package.tools.meson").install(package, configs)')
        end,
        ["autogen"] = function()
            file:print('    add_deps("autoconf", "automake", "libtool")')
            file:print(
                '        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))'
            )
            file:print("        if package:debug() then")
            file:print('            table.insert(configs, "--enable-debug")')
            file:print("        end")
            file:print('        import("package.tools.autoconf").install(package, configs)')
        end,
        ["bazel"] = function()
            file:print('    add_deps("bazel")')
            file:print('        import("package.tools.bazel").install(package, configs)')
        end,
    }

    -- Execute build system specific code
    if build_systems_actions[has_build_system] then
        build_systems_actions[has_build_system]()
    end

    -- Default to xmake if no known build system is found
    if not has_build_system then
        file:print('        io.writefile("xmake.lua", [[')
        file:print('            add_rules("mode.release", "mode.debug")')
        file:print('            target("%s")', packagename)
        file:write('                set_kind("$(kind)")\n')
        file:print('                add_files("src/*.c")')
        file:print('                add_headerfiles("src/(*.h)")')
        file:print("        ]])")
        file:print('        if package:config("shared") then')
        file:print('            configs.kind = "shared"')
        file:print("        end")
        file:print('        import("package.tools.xmake").install(package, configs)')
    end

    file:print("    end)")

    -- Generate test scripts
    file:print("")
    file:print("    on_test(function (package)")
    file:print('        assert(package:has_cfuncs("foo", {includes = "foo.h"}))')
    file:print("    end)")

    file:close()
    io.cat(packagefile)
    cprint("${bright}%s generated!", packagefile)
end

function main(...)
    -- Parse the options
    local opt = option.parse(table.pack(...), options, "New a package.", "", "Usage: xmake l scripts/new.lua [options]")

    -- Extract the repository
    local repo = opt.repo

    -- Ensure repository is provided
    if not repo then
        error("Repository name must be set!")
    end

    local reponame = repo:sub(8)

    -- Check if the repository is from GitHub
    if repo:startswith("github:") then
        -- _generate_package_from_github(reponame)
        generate_package(reponame, get_github_data)
        return
    end

    -- Check if the repository is from GitLab
    if repo:startswith("gitlab:") then
        generate_package(reponame, get_gitlab_data)
        return
    end

    -- If the repository is neither from GitHub nor GitLab, raise an error
    error("Unsupported repository source. Only 'github' and 'gitlab' are supported.")
end
