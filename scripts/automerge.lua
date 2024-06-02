
function _get_autoupdate_pr_list()
    local result = {}
    local list = os.iorun("gh pr list --label auto-update --state open -R xmake-io/xmake-repo")
    if list then
        for _, line in ipairs(list:split("\n")) do
            if line:find("Auto-update", 1, true) then
                local id = line:match("(%d+)%s+Auto%-update")
                if id then
                    table.insert(result, {id = id, title = line})
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

function main()
    local pr_list = _get_autoupdate_pr_list()
    for _, info in ipairs(pr_list) do
        local id = info.id
        local title = info.title
        print("checking %s ...", title)
        if _check_pr_passed(id) then
            print("pull/%d passed, it will be merged next.", id)
            os.vexec("gh pr merge %d --squash -d -R xmake-io/xmake-repo", id)
        end
    end
end
