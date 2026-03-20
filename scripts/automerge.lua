import("core.base.json")

function _get_autoupdate_pr_list()
    local result = {}
    local list = os.iorun("gh pr list --label auto-update --state open --json number,title,createdAt -R xmake-io/xmake-repo")
    if list then
        local data = json.decode(list)
        if data then
            for _, item in ipairs(data) do
                if item.title and item.title:find("Auto-update", 1, true) then
                    table.insert(result, {id = tostring(math.floor(item.number)), title = item.title, createdAt = item.createdAt})
                end
            end
        end
    end
    return result
end

function _check_pr_passed(id)
    local ok = os.vexecv("gh", {"pr", "checks", id, "-R", "xmake-io/xmake-repo"}, {try = true})
    if ok == 0 then
        return true
    end
end

function _is_pr_stale(createdAt, months)
    months = months or 2
    if not createdAt then
        return false
    end
    -- parse ISO 8601 date, e.g. "2025-01-15T10:30:00Z"
    local year, month, day = createdAt:match("(%d+)-(%d+)-(%d+)")
    if not year then
        return false
    end
    local created_time = os.time({year = tonumber(year), month = tonumber(month), day = tonumber(day)})
    local stale_seconds = months * 30 * 24 * 3600
    return os.time() - created_time > stale_seconds
end

function main()
    local pr_list = _get_autoupdate_pr_list()
    for _, info in ipairs(pr_list) do
        local id = info.id
        local title = info.title
        print("checking %s ...", title)
        if _check_pr_passed(id) then
            print("pull/%d passed, it will be merged next.", id)
            os.vexec("gh pr merge %d --squash -d -R xmake-io/xmake-repo", id)
        elseif _is_pr_stale(info.createdAt) then
            print("pull/%d is stale and not passed, closing it.", id)
            os.vexec("gh pr close %d -R xmake-io/xmake-repo", id)
        end
    end
end
