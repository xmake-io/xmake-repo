-- imports
import("core.base.option")
import("core.platform.platform")
import("packages", {alias = "get_packages"})

-- the options
local options =
{
    {'v', "verbose",    "k",  nil, "Enable verbose information."                }
,   {'D', "diagnosis",  "k",  nil, "Enable diagnosis information."              }
,   {nil, "shallow",    "k",  nil, "Only install the root packages."            }
,   {'k', "kind",       "kv", nil, "Enable static/shared library."              }
,   {'p', "plat",       "kv", nil, "Set the given platform."                    }
,   {'a', "arch",       "kv", nil, "Set the given architecture."                }
,   {'m', "mode",       "kv", nil, "Set the given mode."                        }
,   {'j', "jobs",       "kv", nil, "Set the build jobs."                        }
,   {'f', "configs",    "kv", nil, "Set the configs."                           }
,   {'d', "debugdir",   "kv", nil, "Set the debug source directory."            }
,   {nil, "fetch",      "k",  nil, "Fetch package only."                        }
,   {nil, "precompiled","k",  nil, "Attemp to install the precompiled package." }
,   {nil, "linkjobs",   "kv", nil, "Set the link jobs."                         }
,   {nil, "cflags",     "kv", nil, "Set the cflags."                            }
,   {nil, "cxxflags",   "kv", nil, "Set the cxxflags."                          }
,   {nil, "ldflags",    "kv", nil, "Set the ldflags."                           }
,   {nil, "ndk",        "kv", nil, "Set the Android NDK directory."             }
,   {nil, "ndk_sdkver", "kv", nil, "Set the Android NDK platform sdk version."  }
,   {nil, "sdk",        "kv", nil, "Set the SDK directory of cross toolchain."  }
,   {nil, "vs",         "kv", nil, "Set the VS Compiler version."               }
,   {nil, "vs_sdkver",  "kv", nil, "Set the Windows SDK version."               }
,   {nil, "vs_toolset", "kv", nil, "Set the Windows Toolset version."           }
,   {nil, "vs_runtime", "kv", nil, "Set the VS Runtime library."                }
,   {nil, "mingw",      "kv", nil, "Set the MingW directory."                   }
,   {nil, "toolchain",  "kv", nil, "Set the toolchain name."                    }
,   {nil, "packages",   "vs", nil, "The package list."                          }
}


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
    if argv.vs_runtime then
        table.insert(config_argv, "--vs_runtime=" .. argv.vs_runtime)
    end
    if argv.mingw then
        table.insert(config_argv, "--mingw=" .. argv.mingw)
    end
    if argv.toolchain then
        table.insert(config_argv, "--toolchain=" .. argv.toolchain)
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
    os.vexecv("xmake", config_argv)
    local require_argv = {"require", "-f", "-y"}
    if not argv.precompiled then
        table.insert(require_argv, "--build")
    end
    if argv.verbose then
        table.insert(require_argv, "-v")
    end
    if argv.diagnosis then
        table.insert(require_argv, "-D")
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
    table.join2(require_argv, packages)
    os.vexecv("xmake", require_argv)
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

-- the main entry
function main(...)

    -- parse arguments
    local argv = option.parse({...}, options, "Test all the given or changed packages.")

    -- get packages
    local packages = argv.packages or {}
    if #packages == 0 then
        local files = os.iorun("git diff --name-only HEAD^")
        for _, file in ipairs(files:split('\n'), string.trim) do
            if file:startswith("packages") then
                assert(file == file:lower(), "%s must be lower case!", file)
                local package = file:match("packages/%w/(%S+)/")
                table.insert(packages, package)
            end
        end
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
    os.tryrm(workdir)
    os.mkdir(workdir)
    os.cd(workdir)
    os.exec("xmake create test")
    os.cd("test")
    print(os.curdir())
    os.exec("xmake repo --add local-repo %s", repodir)
    os.exec("xmake repo -l")

    -- require packages
    _require_packages(argv, packages)
    --[[for _, package in ipairs(packages) do
        _require_packages(argv, package)
    end]]
end
