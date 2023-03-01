function get_links(package)
    local links = {
        "unwind"
    }
    return links
end

function main(package, component)
    component:add("links", get_links(package))
end


