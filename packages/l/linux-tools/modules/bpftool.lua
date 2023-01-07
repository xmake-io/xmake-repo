function load(package)
    package:add("deps", "libcap", "elfutils", "zlib", {host = true})
    package:add("deps", "python 3.x", {kind = "binary"})
    package:addenv("PATH", "sbin")
end

function install(package)

    local cflags = {}
    local ldflags = {}
    for _, dep in ipairs(package:orderdeps()) do
        local fetchinfo = dep:fetch()
        if fetchinfo then
            for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                table.insert(cflags, "-isystem " .. includedir)
            end
            for _, linkdir in ipairs(fetchinfo.linkdirs) do
                table.insert(ldflags, "-L" .. linkdir)
            end
            for _, link in ipairs(fetchinfo.links) do
                table.insert(ldflags, "-l" .. link)
            end
        end
    end

    local configs = {}
    table.insert(configs, "EXTRA_CFLAGS=" .. table.concat(cflags, " "))
    table.insert(configs, "LDFLAGS=" .. table.concat(ldflags, " "))

    os.cd("tools/bpf/bpftool")
    io.replace("Makefile", "prefix ?= /usr/local", "prefix ?= " .. package:installdir(), {plain = true})
    io.replace("Makefile", "bash_compdir ?= /usr/share", "bash_compdir ?= " .. package:installdir("share"), {plain = true})
    import("package.tools.make").build(package, configs)
    os.vrunv("make", table.join("install", configs))
end

function test(package)
    os.vrun("bpftool --version")
end
