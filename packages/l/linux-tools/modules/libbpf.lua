function load(package)
    package:add("deps", "libelf", "zlib")
end

function install(package)
    os.cd("tools/lib/bpf")
    io.writefile("xmake.lua", [[
        add_rules("mode.debug", "mode.release")
        add_requires("libelf", "zlib")
        target("bpf")
            set_kind("$(kind)")
            add_files("*.c")
            add_includedirs("../../include", "../../include/uapi")
            add_packages("libelf", "zlib")
            add_headerfiles("*.h", {prefixdir = "bpf"})
            if is_plat("android") then
                add_defines("__user=", "__force=", "__poll_t=uint32_t")
            end
    ]])
    local configs = {buildir = "xmakebuild"}
    if package:config("shared") then
        configs.kind = "shared"
    elseif package:config("pic") ~= false then
        configs.cxflags = "-fPIC"
    end
    import("package.tools.xmake").install(package, configs)
end

function test(package)
    assert(package:has_cfuncs("bpf_object__open", {includes = "bpf/libbpf.h"}))
end
