import("core.base.semver")
import("net.http")
import("devel.git")
import("private.action.require.impl.utils.filter")

function shasum_of(package, url, version)
    local shasum
    local tmpfile = os.tmpfile()
    package:version_set(version)
    url = filter.handle(url, package)
    local ok = try { function() http.download(url, tmpfile); return true end }
    if ok and os.isfile(tmpfile) and os.filesize(tmpfile) > 1024 then
        shasum = hash.sha256(tmpfile)
    end
    os.tryrm(tmpfile)
    return shasum
end

function _is_valid_version(version)
    if not semver.is_valid(version) then
        return false
    end
    local v = semver.new(version)
    local prerelease = v:prerelease()
    if prerelease and #prerelease > 0 then
        return false
    end
    return true
end

function _get_version_and_shasum(package, url, version_latest)
    if version_latest then
        local has_prefix_v = false
        for _, version in ipairs(package:versions()) do
            if version:startswith("v") then
                has_prefix_v = true
            end
            if semver.compare(version, version_latest) >= 0 then
                version_latest = nil
                break
            end
        end
        if version_latest then
            if has_prefix_v and not version_latest:startswith("v") then
                version_latest = "v" .. version_latest
            elseif not has_prefix_v and version_latest:startswith("v") then
                version_latest = version_latest:sub(2)
            end
        end
    end
    if version_latest then
        local shasum = shasum_of(package, url, version_latest)
        if shasum then
            return version_latest, shasum
        end
    end
end

function _check_version_from_github_tags(package, url)
    local repourl = url:match("https://github%.com/.-/.-/")
    if repourl then
        print("checking version from github tags %s ..", repourl)
        local version_latest
        local tags = git.tags(repourl)
        for _, tag in ipairs(tags) do
            if _is_valid_version(tag) and (not version_latest or semver.compare(tag, version_latest) > 0) then
                version_latest = tag
            end
        end
        if version_latest then
            return _get_version_and_shasum(package, url, version_latest)
        end
    end
end

function _check_version_from_github_releases(package, url)
    local repourl = url:match("https://github%.com/.-/.-/")
    if repourl then
        print("checking version from github releases %s ..", repourl)
        local list = try {function() return os.iorunv("gh", {"release", "list", "--exclude-drafts", "--exclude-pre-releases", "-R", repourl}) end}
        if not list then
            list = os.iorunv("gh", {"release", "list", "-R", repourl})
        end
        if list then
            local version_latest
            for _, line in ipairs(list:split("\n")) do
                local splitinfo = line:split("%s+")
                local release = splitinfo[1]
                local version = splitinfo[#splitinfo - 1]
                if not version or not _is_valid_version(version) and _is_valid_version(release) then
                    version = release
                end
                if version and _is_valid_version(version) then
                    version_latest = version
                    break
                end
            end
            if version_latest then
                return _get_version_and_shasum(package, url, version_latest)
            end
        end
    end
end

function _version_is_behind_conditions(package)
    local scriptfile = path.join(package:scriptdir(), "xmake.lua")
    local file = io.open(scriptfile)
    for line in file:lines() do
        local pos = line:find("add_versions", 1, true) or line:find("add_versionfiles", 1, true)
        if pos and pos > 5 then
            return true
        end
    end
    file:close()
end

function main(package)
    local checkers = {
        ["https://github%.com/.-/.-/archive/refs/tags/.*"] = _check_version_from_github_tags,
        ["https://github%.com/.-/.-/releases/download/.*"] = _check_version_from_github_releases
    }
    for _, url in ipairs(package:urls()) do
        for pattern, checker in pairs(checkers) do
            if url:match(pattern) and not _version_is_behind_conditions(package) then
                return checker(package, url)
            end
        end
    end
end
