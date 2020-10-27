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
,   {nil, "cflags",     "kv", nil, "Set the cflags."                            }
,   {nil, "cxxflags",   "kv", nil, "Set the cxxflags."                          }
,   {nil, "ldflags",    "kv", nil, "Set the ldflags."                           }
,   {nil, "ndk",        "kv", nil, "Set the android NDK directory."             }
,   {nil, "sdk",        "kv", nil, "Set the SDK directory of cross toolchain."  }
,   {nil, "mingw",      "kv", nil, "Set the MingW directory."                   }
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
    if argv.mingw then
        table.insert(config_argv, "--mingw=" .. argv.mingw)
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
    if argv.verbose then
        table.insert(require_argv, "-v")
    end
    if argv.diagnosis then
        table.insert(require_argv, "-D")
    end
    if argv.shallow then
        table.insert(require_argv, "--shallow")
    end
    if argv.mode == "debug" and argv.kind == "shared" then
        table.insert(require_argv, "--extra={debug=true,configs={shared=true}}")
    elseif argv.mode == "debug" then
        table.insert(require_argv, "--extra={debug=true}")
    elseif argv.kind == "shared" then
        table.insert(require_argv, "--extra={configs={shared=true}}")
    end
    table.join2(require_argv, packages)
    os.vexecv("xmake", require_argv)
end

-- the given package is supported?
function _package_is_supported(argv, packagename)
    local packages = get_packages()
    if packages then
        local plat = argv.plat or os.host()
        local packages_plat = packages[plat]
        for _, package in ipairs(packages_plat) do
            if package and packagename:split("%s+")[1] == package.name then
                local arch = argv.arch or platform.archs(plat)[1] or os.arch()
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
            if file:find("packages", 1, true) and path.filename(file) == "xmake.lua" then
                local package = path.filename(path.directory(file))
                table.insert(packages, package)
            end
        end
    end
    if #packages == 0 then
        table.insert(packages, "tbox dev")
    end

    -- remove unsupported packages
    for idx, package in irpairs(packages) do
        if not _package_is_supported(argv, package) then
            table.remove(packages, idx)
        end
    end
    if #packages == 0 then
        print("no testable packages on %s!", argv.plat or os.host())
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
end
