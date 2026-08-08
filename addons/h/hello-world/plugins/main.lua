import("core.base.option")

function main()
    local name = option.get("name") or "world"
    cprint("${bright green}hello %s!", name)
end
