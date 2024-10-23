-- imports
import("core.base.option")
import("core.platform.platform")
import("core.package.package", {alias = "core_package"})
import("packages", {alias = "get_packages"})

-- the options
local options =
{
    {'v', "verbose",        "k",  nil, "Enable verbose information."                }
,   {'D', "diagnosis",      "k",  nil, "Enable diagnosis information."              }
,   {nil, "shallow",        "k",  nil, "Only install the root packages."            }
,   {'k', "kind",           "kv", nil, "Enable static/shared library."              }
,   {'p', "plat",           "kv", nil, "Set the given platform."                    }
,   {'a', "arch",           "kv", nil, "Set the given architecture."                }
,   {'m', "mode",           "kv", nil, "Set the given mode."                        }
,   {'j', "jobs",           "kv", nil, "Set the build jobs."                        }
,   {'f', "configs",        "kv", nil, "Set the configs."                           }
,   {'d', "debugdir",       "kv", nil, "Set the debug source directory."            }
,   {nil, "policies",       "kv", nil, "Set the policies."                          }
,   {nil, "fetch",          "k",  nil, "Fetch package only."                        }
,   {nil, "precompiled",    "k",  nil, "Attemp to install the precompiled package." }
,   {nil, "remote",         "k",  nil, "Test package on the remote server."         }
,   {nil, "linkjobs",       "kv", nil, "Set the link jobs."                         }
,   {nil, "cflags",         "kv", nil, "Set the cflags."                            }
,   {nil, "cxxflags",       "kv", nil, "Set the cxxflags."                          }
,   {nil, "ldflags",        "kv", nil, "Set the ldflags."                           }
,   {nil, "ndk",            "kv", nil, "Set the Android NDK directory."             }
,   {nil, "ndk_sdkver",     "kv", nil, "Set the Android NDK platform sdk version."  }
,   {nil, "sdk",            "kv", nil, "Set the SDK directory of cross toolchain."  }
,   {nil, "vs",             "kv", nil, "Set the VS Compiler version."               }
,   {nil, "vs_sdkver",      "kv", nil, "Set the Windows SDK version."               }
,   {nil, "vs_toolset",     "kv", nil, "Set the Windows Toolset version."           }
,   {nil, "vs_runtime",     "kv", nil, "Set the VS Runtime library (deprecated)."   }
,   {nil, "runtimes",       "kv", nil, "Set the Runtime libraries."                 }
,   {nil, "xcode_sdkver",   "kv", nil, "The SDK Version for Xcode"                  }
,   {nil, "target_minver",  "kv", nil, "The Target Minimal Version"                 }
,   {nil, "appledev",       "kv", nil, "The Apple Device Type"                      }
,   {nil, "mingw",          "kv", nil, "Set the MingW directory."                   }
,   {nil, "toolchain",      "kv", nil, "Set the toolchain name."                    }
,   {nil, "toolchain_host", "kv", nil, "Set the host toolchain name."               }
,   {nil, "packages",       "vs", nil, "The package list."                          }
}

-- check package is supported?
function _check_package_is_supported()
    for _, names in pairs(core_package.apis()) do
        for _, name in ipairs(names) do
            if type(name) == "string" and name == "package.on_check" then
                return true
            end
        end
    end
end

-- require packages
function _require_packages(argv, packages)
    local config_argv = {"f", "-c"}
    if argv.verbose then
        table.insert(config_argv, "-v")
    end
    if argv.diagnosis then
        table.insert(config_argv, "-D")
    end
    if argv.plat then
        table.insert(config_argv, "--plat=" .. argv.plat)
    end
    if argv.arch then
        table.insert(config_argv, "--arch=" .. argv.arch)
    end
    if argv.mode then
        table.insert(config_argv, "--mode=" .. argv.mode)
    end
    if argv.policies then
        table.insert(config_argv, "--policies=" .. argv.policies)
    end
    if argv.ndk then
        table.insert(config_argv, "--ndk=" .. argv.ndk)
    end
    if argv.sdk then
        table.insert(config_argv, "--sdk=" .. argv.sdk)
    end
    if argv.ndk_sdkver then
        table.insert(config_argv, "--ndk_sdkver=" .. argv.ndk_sdkver)
    end
    if argv.vs then
        table.insert(config_argv, "--vs=" .. argv.vs)
    end
    if argv.vs_sdkver then
        table.insert(config_argv, "--vs_sdkver=" .. argv.vs_sdkver)
    end
    if argv.vs_toolset then
        table.insert(config_argv, "--vs_toolset=" .. argv.vs_toolset)
    end
    local runtimes = argv.runtimes or argv.vs_runtime
    if runtimes then
        if is_host("windows") then
            table.insert(config_argv, "--vs_runtime=" .. runtimes)
        else
            table.insert(config_argv, "--runtimes=" .. runtimes)
        end
    end
    if argv.xcode_sdkver then
        table.insert(config_argv, "--xcode_sdkver=" .. argv.xcode_sdkver)
    end
    if argv.target_minver then
        table.insert(config_argv, "--target_minver=" .. argv.target_minver)
    end
    if argv.appledev then
        table.insert(config_argv, "--appledev=" .. argv.appledev)
    end
    if argv.mingw then
        table.insert(config_argv, "--mingw=" .. argv.mingw)
    end
    if argv.toolchain then
        table.insert(config_argv, "--toolchain=" .. argv.toolchain)
    end
    if argv.toolchain_host then
        table.insert(config_argv, "--toolchain_host=" .. argv.toolchain_host)
    end
    if argv.cflags then
        table.insert(config_argv, "--cflags=" .. argv.cflags)
    end
    if argv.cxxflags then
        table.insert(config_argv, "--cxxflags=" .. argv.cxxflags)
    end
    if argv.ldflags then
        table.insert(config_argv, "--ldflags=" .. argv.ldflags)
    end
    os.vexecv(os.programfile(), config_argv)
    local require_argv = {"require", "-f", "-y"}
    local check_argv = {"require", "-f", "-y", "--check"}
    if not argv.precompiled then
        table.insert(require_argv, "--build")
    end
    if argv.verbose then
        table.insert(require_argv, "-v")
        table.insert(check_argv, "-v")
    end
    if argv.diagnosis then
        table.insert(require_argv, "-D")
        table.insert(check_argv, "-D")
    end
    local is_debug = false
    if argv.debugdir then
        is_debug = true
        table.insert(require_argv, "--debugdir=" .. argv.debugdir)
    end
    if argv.shallow or is_debug then
        table.insert(require_argv, "--shallow")
    end
    if argv.jobs then
        table.insert(require_argv, "--jobs=" .. argv.jobs)
    end
    if argv.linkjobs then
        table.insert(require_argv, "--linkjobs=" .. argv.linkjobs)
    end
    if argv.fetch then
        table.insert(require_argv, "--fetch")
    end
    local extra = {}
    if argv.mode == "debug" then
        extra.debug = true
    end
    -- Some packages set shared=true as default, so we need to force set
    -- shared=false to test static build.
    extra.configs = extra.configs or {}
    extra.configs.shared = argv.kind == "shared"
    local configs = argv.configs
    if configs then
        extra.system  = false
        extra.configs = extra.configs or {}
        local extra_configs, errors = ("{" .. configs .. "}"):deserialize()
        if extra_configs then
            table.join2(extra.configs, extra_configs)
        else
            raise(errors)
        end
    end
    local extra_str = string.serialize(extra, {indent = false, strip = true})
    table.insert(require_argv, "--extra=" .. extra_str)
    table.insert(check_argv, "--extra=" .. extra_str)

    local install_packages = {}
    if _check_package_is_supported() then
        for _, package in ipairs(packages) do
            local ok = os.vexecv(os.programfile(), table.join(check_argv, package), {try = true})
            if ok == 0 then
                table.insert(install_packages, package)
            end
        end
    else
        install_packages = packages
    end
    if #install_packages > 0 then
        os.vexecv(os.programfile(), table.join(require_argv, install_packages))
    else
        print("no testable packages on %s or you're using lower version xmake!", argv.plat or os.subhost())
    end
end

-- the given package is supported?
function _package_is_supported(argv, packagename)
    local packages = get_packages()
    if packages then
        local plat = argv.plat or os.subhost()
        local packages_plat = packages[plat]
        for _, package in ipairs(packages_plat) do
            if package and packagename:split("%s+")[1] == package.name then
                local arch = argv.arch
                if not arch and plat ~= os.subhost() then
                    arch = table.wrap(platform.archs(plat))[1]
                end
                if not arch then
                    arch = os.subarch()
                end
                for _, package_arch in ipairs(package.archs) do
                    if arch == package_arch then
                        return true
                    end
                end
            end
        end
    end
end

function get_modified_packages()
    local packages = {}
    local diff = os.iorun("git --no-pager diff HEAD^")
    for _, line in ipairs(diff:split("\n")) do
        if line:startswith("+++ b/") then
            local file = line:sub(7)
            if file:startswith("packages") then
                assert(file == file:lower(), "%s must be lower case!", file)
                local package = file:match("packages/%w/(%S-)/")
                table.insert(packages, package)
            end
        elseif line:startswith("+") and line:find("add_versions") then
            local version = line:match("add_versions%(\"(.-)\"")
            if version:find(":", 1, true) then
                version = version:split(":")[2]
            end
            if #packages > 0 and version then
                local lastpackage = packages[#packages]
                local splitinfo = lastpackage:split("%s+")
                table.insert(packages, splitinfo[1] .. " " .. version)
            end
        end
    end
    return table.unique(packages)
end

-- the main entry
function main(...)

    -- parse arguments
    local argv = option.parse({...}, options, "Test all the given or changed packages.")

    -- get packages
    local packages = argv.packages or {}
    if #packages == 0 then
        packages = get_modified_packages()
    end
    if #packages == 0 then
        table.insert(packages, "tbox dev")
    end

    -- remove unsupported packages
    for idx, package in irpairs(packages) do
        assert(package == package:lower(), "package(%s) must be lower case!", package)
        if not _package_is_supported(argv, package) then
            table.remove(packages, idx)
        end
    end
    if #packages == 0 then
        print("no testable packages on %s!", argv.plat or os.subhost())
        return
    end

    -- prepare test project
    local repodir = os.curdir()
    local workdir = path.join(os.tmpdir(), "xmake-repo")
    print(packages)
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
    print(os.curdir())
    -- do action for remote?
    if os.isdir("xmake-repo") then
        os.execv(os.programfile(), {"service", "--disconnect"})
    end
    if argv.remote then
        os.tryrm("xmake-repo")
        os.cp(path.join(repodir, "packages"), "xmake-repo/packages")
        os.execv(os.programfile(), {"service", "--connect"})
        repodir = "xmake-repo"
    end
    os.execv(os.programfile(), {"repo", "--add", "local-repo", repodir})
    os.execv(os.programfile(), {"repo", "-l"})

    -- require packages
    _require_packages(argv, packages)
    --[[for _, package in ipairs(packages) do
        _require_packages(argv, package)
    end]]
end
