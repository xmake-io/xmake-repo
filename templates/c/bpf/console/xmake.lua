add_rules("mode.debug", "mode.release")

add_requires("linux-tools", {configs = {bpftool = true}})
add_requires("libbpf")
if is_plat("android") then
    add_requires("ndk >=22.0 <26.0")
    set_toolchains("@ndk", {sdkver = "23"})
else
    add_requires("llvm >=10.x")
    set_toolchains("@llvm")
    add_requires("linux-headers")
end

target("${TARGET_NAME}")
    add_rules("platform.linux.bpf")
    set_kind("binary")
    add_files("src/*.c")
    add_packages("linux-tools", "linux-headers", "libbpf")
    set_license("GPL-2.0")

${FAQ}
