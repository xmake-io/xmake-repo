-- array utils
function _filter(array, callback)
    local result = {}
    for idx, val in ipairs(array) do
        if callback(val, idx, array) then
            table.insert(result, val)
        end
    end
    return result
end

function _find(array, callback)
    for idx, val in ipairs(array) do
        if callback(val, idx, array) then
            return val
        end
    end
    return nil
end

function _join(array, separator)
    local result = ""
    for idx, val in ipairs(array) do
        rusult = result .. val
        if not idx == #array then
            result = result .. separator
        end
    end
    return result
end

function get_target(package)
    import("core.tool.compiler")
    local default_plat = "generic-gnu"

    local platforms = {}
    for plat in io.readfile("configure"):gmatch("all_platforms=\"%${all_platforms} ([%a%d-_]-)\"") do
        table.insert(platforms, plat:split("-", {plain = true}))
    end

    local arch = package:targetarch()
    if arch:startswith("arm64") then
        arch = "arm64"
    elseif arch == "armeabi-v7a" or arch == "arm" then
        arch = "armv7"
    elseif arch == "x64" then
        arch = "x86_64"
    end

    local os
    if package:is_targetos("iphoneos") then
        if package:is_targetarch("x64", "x86", "x86_64") then
            os = "iphonesimulator"
        else
            os = "darwin"
        end
    elseif package:is_targetos("macosx", "watchos") then
        os = "darwin"
    elseif package:is_targetos("cygwin", "mingw", "windows") then
        os = "win"
    else
        os = package:targetos()
    end

    local cc = path.basename(compiler.compcmd("foo.c")):split(" ", {plain = true})[1]:lower()
    if cc == "clang" or cc == "emcc" or cc:endswith("-gcc") then
        cc = "gcc"
    elseif cc == "cl" then
        cc = "vs"
    end

    cprint("${green}info: ${clear}looking for target platform match ${blue}" .. os .. " " .. arch .. " " .. cc .. "${clear}")
    local matched_plats
    matched_plats = _filter(platforms, function (p) return p[1] == arch end)
    local tmp = _filter(matched_plats, function (p) return p[2] == os end)
    matched_plats = #tmp == 0 and _filter(matched_plats, function (p) return p[2] and  p[2]:startswith(os) end) or tmp
    tmp = nil
    if #matched_plats == 0 then
        cprint("${yellow}warning: ${clear}no matching platform, use " .. default_plat)
    end
    local result = _join(_find(platforms, function(p) return p[3] == cc end) or _find(platforms, function(p) return p[3] and p[3]:startswith(cc) end) or matched_plats[1], "-")
    cprint("${green}info: ${clear}use target platform ${blue}" .. result .. "${clear}")
    return result
end
