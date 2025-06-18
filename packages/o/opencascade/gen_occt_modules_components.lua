import("core.base.json")
import("core.base.semver")

import("net.http")
import("utils.archive")
import("devel.git")
import("lib.detect.find_tool")


function parse_version(tag)
    -- Removes 'V' and replaces '_' with '.', e.g. V8_0_0_rc1 -> 8.0.0-rc.1
    local version = tag:lower():gsub("^v", ""):gsub("_", ".")
    -- Replace last `.rcN` with `-rc.N`
    version = version:gsub("%.?(rc%d+)", function(s)
        local label, num = s:match("([a-z]+)(%d+)")
        return "-" .. label .. "." .. num
    end)
    return semver.new(version)
end

function classify_dependency(dep)

     local system_mapping = {
        CSF_androidlog = "syslinks",
        CSF_ThreadLibs = "syslinks",
        CSF_dl = "syslinks",
        CSF_dpsLibs = "syslinks",
        CSF_XmuLibs = "syslinks",
        CSF_advapi32 = "syslinks",
        CSF_gdi32 = "syslinks",
        CSF_psapi = "syslinks",
        CSF_shell32 = "syslinks",
        CSF_user32 = "syslinks",
        CSF_winmm = "syslinks",
        CSF_wsock32 = "syslinks",
        CSF_d3d9 = "syslinks",
        CSF_Appkit = "frameworks",
        CSF_IOKit = "frameworks",
        CSF_objc = "frameworks"
    }

    if dep:startswith("TK") then
        return "links"
    elseif dep:startswith("CSF_") then
        return system_mapping[dep] or "deps"
    end
    return nil
end


function parse_modules_lt_v8_0_0(source_dir, version)
    
    local modules_file = path.join(source_dir, "adm", "MODULES")
    if not os.isfile(modules_file) then
        raise("MODULES file not found: %s", modules_file)
    end


    cprint("Collecting occt modules and toolkits...")
    local result = {}
    for line in io.lines(modules_file) do
        line = line:trim()
        if #line > 0 then
            local words = line:split("%s+")
            local module_name = words[1]
            local components = {}

            for i = 2, #words do
                local comp = words[i]
                local deps = {}
                local externlib_path = path.join(source_dir, "src", comp, "EXTERNLIB")
                if os.isfile(externlib_path) then
                    for dep_line in io.lines(externlib_path) do
                        local dep = dep_line:trim()
                        local category = classify_dependency(dep)
                        if category then -- otherwise it is just internal imported target
                            deps[category] = deps[category] or {}
                            table.insert(deps[category], dep)
                        end
                    end
                end
                components[comp] = deps
            end

            result[module_name] = components
        end
    end
    
    local outfile = "opencascade.modules.components." .. version .. ".json"
    json.savefile(outfile, result)
    cprint("${green}✓ wrote${reset} %s", outfile)
    cprint("${yellow} Don't forget to prettify json before pushing to remote!")
end

function parse_modules(source_dir, version)
    
    if version:gt("7.9.1") then
        raise("Parsing logic has not been explored for this version and above yet. [Version %s]", version)
    else
        parse_modules_lt_v8_0_0(source_dir, version)
    end
end
-- also add a function that exports link orders as occt components maybe 

function main(tag)
    assert(tag, "Please pass an exact GitHub release tag like V7_7_0 or V8_0_0_rc1")

    local version = parse_version(tag)
    if version:gt("7.9.1") then
        raise("Parsing logic has not been explored for this version and above yet. [Version %s]", version)
    end

    local url = string.format("https://github.com/Open-Cascade-SAS/OCCT/archive/refs/tags/%s.tar.gz", tag)
    local tmpfile = os.tmpfile() .. ".tar.gz"
    local extractedir = tmpfile .. ".dir"

    cprint("downloading %s ...", url)
    http.download(url, tmpfile)

    archive.extract(tmpfile, extractedir)
    os.rm(tmpfile)

    local foldername = "OCCT-" .. tag:gsub("^V", "")
    local sourcedir = path.join(extractedir, foldername)
    -- actual source dir inside extracted tarball
    parse_modules(sourcedir, version)

    os.rm(extractedir)

end
