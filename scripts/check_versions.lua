-- Check that package versions conform to the semantic versioning specification.
--
-- xmake parses all the package versions with semver, but an invalid version string
-- will be parsed silently, e.g. `1.92.9b` is parsed as a prerelease version, `1.92.9-b`,
-- which is even older than `1.92.9`. So the package will point to a wrong latest version
-- and the users have to select it manually.
--
-- @see https://github.com/xmake-io/xmake/issues/7748
--

-- imports
import("core.base.option")
import("core.base.semver")

-- the options
local options =
{
    {'a', "all", "k", nil, "Check all the packages instead of the modified packages only."}
,   {nil, "packages", "vs", nil, "The package list."                                     }
}

-- The packages below have been using invalid versions before this check was added,
-- we just keep them working, please do not add any new packages to this list.
local legacy_packages =
{
    "ade"
,   "gli"
,   "gpujpeg"
,   "libjpeg"
,   "libmspack"
,   "mscharconv"
,   "named_type"
,   "newtondynamics"
,   "newtondynamics3"
,   "nv-codec-headers"
,   "openssh"
,   "tinyobjloader"
,   "uasm"
,   "v8"
}

-- make the version string from the parsed result and the given version numbers,
-- e.g. 1.0.0, 1.0.0-beta.1, 1.0.0+build.1
function _make_version(instance, numbers)
    local str = numbers
    local prerelease = instance:prerelease()
    if prerelease and #prerelease > 0 then
        str = str .. "-" .. table.concat(prerelease, ".")
    end
    local build = instance:build()
    if build and #build > 0 then
        str = str .. "+" .. table.concat(build, ".")
    end
    return str
end

-- get the parsed version, e.g. 1.92.9b -> 1.92.9-b
function parse(version)
    if semver.is_valid(version) then
        local instance = semver.new(version)
        return _make_version(instance, instance:shortstr()), instance
    end
end

-- is a valid semantic version?
--
-- the version must be `<major>[.<minor>[.<patch>]][-<prerelease>][+<build>]`,
-- e.g. 1, 1.0, 1.0.0, v1.0.0, 1.0.0-beta.1, 1.0.0+build.1
--
function is_valid(version)

    -- we cannot parse it at all, e.g. `1.2.3.4`, `latest`
    local _, instance = parse(version)
    if not instance then
        return false
    end

    -- strip the optional `v` prefix, e.g. v1.0.0
    local rawstr = version
    if rawstr:startswith("v") or rawstr:startswith("V") then
        rawstr = rawstr:sub(2)
    end

    -- the version numbers must be `<major>[.<minor>[.<patch>]]`,
    -- we allow to omit the minor/patch version, e.g. 1, 1.0, 1.0.0
    local numbers = rawstr:match("^%d+%.%d+%.%d+") or rawstr:match("^%d+%.%d+") or rawstr:match("^%d+")
    if not numbers then
        return false
    end

    -- semver parses the invalid version silently, e.g. `1.92.9b` -> `1.92.9-b`,
    -- so the raw version string must be able to be rebuilt from the parsed result
    return _make_version(instance, numbers) == rawstr
end

-- is a legacy package which is allowed to use invalid versions?
function is_legacy(packagename)
    return table.contains(legacy_packages, packagename)
end

-- check the given package version
function check(packagename, version)
    if is_valid(version) or is_legacy(packagename) then
        return
    end
    local parsed = parse(version)
    raise("package(%s): version(%s) is not a valid semantic version!\n" ..
          "  %s, and this package will point to a wrong latest version.\n" ..
          "  please use a valid version, `<major>[.<minor>[.<patch>]][-<prerelease>][+<build>]`, e.g.\n" ..
          "    add_versions(\"1.0.0-beta1\", ...) -- prerelease version, it is older than 1.0.0\n" ..
          "    add_versions(\"1.0.0+b\", ...)      -- revision version, it is newer than 1.0.0\n" ..
          "  and map it back to the real url in add_urls if it does not match the upstream tag, e.g.\n" ..
          "    add_urls(\"https://github.com/xxx/xxx/archive/refs/tags/v$(version).tar.gz\", {version = function (version)\n" ..
          "        return (tostring(version):gsub(\"%%+\", \"\"))\n" ..
          "    end})\n" ..
          "  @see https://github.com/xmake-io/xmake/issues/7748", packagename, version,
          parsed and string.format("xmake will parse it as `%s` silently", parsed) or "xmake cannot parse it")
end

-- get the version in the given line
function _get_version(line)
    local version = line:match("add_versions%(%s*[\"'](.-)[\"']") or
                    line:match("package:add%(%s*[\"']versions[\"']%s*,%s*[\"'](.-)[\"']")
    if version and version:find(":", 1, true) then
        -- strip the platform/arch prefix, e.g. add_versions("windows|x64:1.0", ...)
        version = version:split(":", {plain = true})[2]
    end
    return version
end

-- get all the versions of the given package file
function _get_versions(packagefile)
    local versions = {}
    for _, line in ipairs(io.readfile(packagefile):split("\n")) do
        local version = _get_version(line)
        if version then
            table.insert(versions, version)
        end
    end
    return versions
end

-- the root directories of the package recipes
local rootdirs = {"packages", "addons"}

-- get the package name of the given file, e.g. packages/i/imgui/xmake.lua
function _get_packagename(file)
    for _, rootdir in ipairs(rootdirs) do
        local packagename = file:match("^" .. rootdir .. "/%w/(%S-)/")
        if packagename then
            return packagename
        end
    end
end

-- get the new versions in the current commit
function _get_modified_versions()
    local results = {}
    local packagename
    local diff = try {function () return os.iorun("git --no-pager diff HEAD^") end}
    for _, line in ipairs(diff and diff:split("\n") or {}) do
        if line:startswith("+++ b/") then
            packagename = _get_packagename(line:sub(7))
        elseif packagename and line:startswith("+") then
            local version = _get_version(line)
            if version then
                table.insert(results, {packagename, version})
            end
        end
    end
    return results
end

-- the main entry
function main(...)
    local argv = option.parse({...}, options, "Check the package versions.")
    local packages = argv.packages
    if argv.all or packages then
        local count = 0
        local packagedirs = {}
        for _, rootdir in ipairs(rootdirs) do
            table.join2(packagedirs, os.dirs(path.join(rootdir, "*", "*")))
        end
        for _, packagedir in ipairs(packagedirs) do
            local packagename = path.filename(packagedir)
            if not packages or table.contains(packages, packagename) then
                for _, version in ipairs(_get_versions(path.join(packagedir, "xmake.lua"))) do
                    if not is_valid(version) then
                        local parsed = parse(version)
                        cprint("${color.warning}%s: %s is not a valid semantic version, %s%s", packagename, version,
                            parsed and string.format("it will be parsed as `%s`", parsed) or "xmake cannot parse it",
                            is_legacy(packagename) and " (legacy)" or "")
                        count = count + 1
                    end
                end
            end
        end
        print("%d invalid versions found", count)
    else
        -- only check the new versions in the current commit,
        -- it will raise an error if some new versions are invalid
        for _, item in ipairs(_get_modified_versions()) do
            check(item[1], item[2])
        end
        print("checking ok!")
    end
end
