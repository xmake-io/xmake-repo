-- imports
import("core.base.option")
import("core.package.addon")

-- the options
local options =
{
    {'v', "verbose",   "k",  nil, "Enable verbose information."   }
,   {'D', "diagnosis", "k",  nil, "Enable diagnosis information." }
,   {nil, "addon",     "k",  nil, "Test the addon packages."      }
,   {nil, "addons",    "vs", nil, "The addon list."               }
}

-- get the modified addons from the git diff, e.g. addons/e/esp32-devel/xmake.lua
--
-- @note the addon name is always the third part of the path, an addon can also carry
-- its own sources, e.g. addons/h/hello-world/addon/plugins/hello/xmake.lua
--
function get_modified_addons()
    local addons = {}
    local diff = try {function () return os.iorun("git --no-pager diff --name-only HEAD^") end}
    for _, file in ipairs(diff and diff:split("\n") or {}) do
        local parts = path.split(file:trim())
        local addonname = parts[1] == "addons" and parts[3]

        -- @note it may have been removed or renamed, the diff also lists the deleted files,
        -- e.g. addons/s/serial-monitor -> addons/s/serial-tools
        if addonname and os.isfile(path.join(parts[1], parts[2], addonname, "xmake.lua"))
            and not table.contains(addons, addonname) then
            table.insert(addons, addonname)
        end
    end
    return addons
end

-- check that the addon manifest and the package recipe are kept in sync
--
-- @note the deps are duplicated: the recipe is authoritative, xmake needs them before
-- downloading the addon sources, and the manifest is used by the local installation,
-- e.g. xmake addon --install <dir>
--
function _check_manifest(addonname)

    -- the addon deps come from the package recipe, and the addon manifest declares them
    -- again for the local installation, both are recorded when installing it
    -- @note we need to reload the registry, the addon has been installed by another process
    local addoninfo = addon.addons({force = true})[addon.dirname(addonname)]
    if not addoninfo or not addoninfo.manifest_deps then
        return
    end
    local recipedeps = addoninfo.deps or {}
    for _, depname in ipairs(addoninfo.manifest_deps) do
        assert(table.contains(recipedeps, depname),
            "addon(%s): dep(%s) is declared in its manifest, but not in the package recipe!", addonname, depname)
    end
    for _, depname in ipairs(recipedeps) do
        assert(table.contains(addoninfo.manifest_deps, depname),
            "addon(%s): dep(%s) is declared in the package recipe, but not in its manifest!", addonname, depname)
    end
    print("checking addon(%s) manifest .. ok", addonname)
end

-- test the given addon
--
-- it installs the addon from the local repository, the `on_test` script of the addon
-- will be run after installing it, and then we remove it again
--
function _test_addon(argv, addonname)
    print("testing addon(%s) ..", addonname)

    -- remove it first, we need to install and test it again
    --
    -- @note we need to reload the registry, it may have been installed by another process
    if addon.addons({force = true})[addon.dirname(addonname)] then
        os.execv(os.programfile(), {"addon", "--remove", "--force", addonname})
    end

    -- install it, `xmake require --addon` will run the `on_test` script of the addon
    --
    -- @note we install it from our test project instead of `xrepo install --addon`,
    -- xrepo installs the packages in its own working project, which would not see
    -- the local repository of this project, @see main()
    --
    local install_argv = {"require", "-y", "--force", "--addon", "--extra={system=false}"}
    if argv.verbose then
        table.insert(install_argv, "-v")
    end
    if argv.diagnosis then
        table.insert(install_argv, "-D")
    end
    table.insert(install_argv, addonname)
    os.vexecv(os.programfile(), install_argv)

    -- the manifest of the addon and the package recipe must be kept in sync
    _check_manifest(addonname)

    -- and remove it, we should not pollute the environment
    os.vexecv(os.programfile(), {"addon", "--remove", "--force", addonname})
    print("testing addon(%s) ok!", addonname)
end

-- the main entry
function main(...)

    -- parse arguments
    local argv = option.parse({...}, options, "Test all the given or changed addons.")

    -- the current xmake does not support addons? we just skip them
    if not os.isdir(path.join(os.programdir(), "actions", "addon")) then
        wprint("xmake %s does not support addons, we skip the addon tests!", xmake.version())
        return
    end

    -- get addons
    local addons = argv.addons or {}
    if #addons == 0 then
        addons = get_modified_addons()
    end
    if #addons == 0 then
        print("no testable addons!")
        return
    end
    print(addons)

    -- prepare the test project, we install the addons from it
    --
    -- @note we add the local repository to this project only, so that we do not
    -- touch the global configuration, @see scripts/test_packages.lua
    --
    local repodir = os.curdir()
    local workdir = path.join(os.tmpdir(), "xmake-repo-addons")
    os.setenv("XMAKE_STATS", "false")
    if not os.isfile(path.join(workdir, "test", "xmake.lua")) then
        os.tryrm(workdir)
        os.mkdir(workdir)
        os.cd(workdir)
        os.execv(os.programfile(), {"create", "test"})
    else
        os.cd(workdir)
    end
    os.cd("test")
    os.execv(os.programfile(), {"repo", "--add", "local-repo", repodir})

    -- test addons
    for _, addonname in ipairs(addons) do
        _test_addon(argv, addonname)
    end
end

return main
