local features = {
    {name = "alsa",         option = "alsa",          deps = {"alsa-lib"}},
    {name = "pipewire-alsa", option = "pipewire-alsa", deps = {"alsa-lib"}},
    {name = "pulseaudio",   option = "libpulse",      deps = {"pulseaudio"}},
    {name = "jack",         option = "jack",          deps = {"jack2"}},
    {name = "sndfile",      option = "sndfile",       deps = {"libsndfile"}},
    {name = "gstreamer",    option = "gstreamer",     deps = {"gstreamer", "glib"}},
    {name = "ffmpeg",       option = "ffmpeg",        deps = {"ffmpeg"}},
    {name = "x11",          option = "x11",           deps = {"libx11"}},
    {name = "x11-xfixes",   option = "x11-xfixes",    deps = {"libx11", "libxfixes"}},
    {name = "libcanberra",  option = "libcanberra",   deps = {"libcanberra"}},
    {name = "udev",         option = "udev",          deps = {"libudev"}},
    {name = "v4l2",         option = "v4l2",          deps = {"libudev"}},
    {name = "libusb",       option = "libusb",        deps = {"libusb"}},
    {name = "readline",     option = "readline",      deps = {"readline"}},
    {name = "lv2",          option = "lv2",           deps = {"lilv"}},
    {name = "ebur128",      option = "ebur128",       deps = {"libebur128"}},
    {name = "fftw",         option = "fftw",          deps = {"fftw"}},
    {name = "raop",         option = "raop",          deps = {"openssl"}},
    {name = "selinux",      option = "selinux",       deps = {"libselinux"}},
    {name = "libsystemd",   option = "libsystemd",    deps = {"libsystemd"}},
    {name = "vulkan",       option = "vulkan",        deps = {"vulkan-loader", "vulkan-headers", "libdrm"}},
    {name = "sdl2",         option = "sdl2",          deps = {"libsdl2"}},
    {name = "flatpak",      option = "flatpak",       deps = {}},
    {name = "onnxruntime",  option = "onnxruntime",   deps = {"onnxruntime"}},
    {name = "snap",         option = "snap",          deps = {}},
}

package("pipewire")
    set_homepage("https://pipewire.org")
    set_description("PipeWire is a server and user space API to deal with multimedia pipelines.")
    set_license("MIT")

    add_urls("https://github.com/PipeWire/pipewire/archive/refs/tags/$(version).tar.gz",
             "https://github.com/PipeWire/pipewire.git")
    add_versions("1.6.8", "8181172a1d95131f6af8bbc0b98f90b2a33349b042b84c3ce57dd5d11348cc58")

    add_extsources("pacman::pipewire", "apt::libpipewire-0.3-dev")

    add_configs("dbus", {description = "Enable code that depends on dbus.", default = false, type = "boolean"})
    for _, feature in ipairs(features) do
        add_configs(feature.name, {description = "Enable the " .. feature.name .. " integration.", default = false, type = "boolean"})
    end
    add_configs("session-managers", {description = "Session managers to build (meson array, e.g. ['wireplumber']).", default = "[]", type = "string"})

    add_deps("meson", "ninja", "pkg-config")

    add_includedirs("include/pipewire-0.3", "include/spa-0.2")

    add_links("pipewire-0.3")

    if is_plat("linux") then
        add_syslinks("pthread", "dl", "m", "rt")
    end

    on_load(function (package)
        if package:config("dbus") then
            package:add("deps", "dbus")
        end
        for _, feature in ipairs(features) do
            if package:config(feature.name) and #feature.deps > 0 then
                package:add("deps", table.unpack(feature.deps))
            end
        end
    end)

    on_install("linux", function (package)
        local configs = {
            "-Ddocs=disabled",
            "-Dman=disabled",
            "-Dtests=disabled",
            "-Dexamples=disabled",
            "-Dgstreamer-device-provider=disabled",
            "-Dlogind=disabled",
            "-Dsystemd-system-service=disabled",
            "-Dsystemd-user-service=disabled",
            "-Dpipewire-jack=disabled",
            "-Dpipewire-v4l2=disabled",
            "-Dbluez5=disabled",
            "-Dlibcamera=disabled",
            "-Dlibmysofa=disabled",
            "-Droc=disabled",
            "-Davahi=disabled",
            "-Decho-cancel-webrtc=disabled",
            "-Dlegacy-rtkit=false",
            "-Davb=disabled",
            "-Dgsettings=disabled",
            "-Dcompress-offload=disabled",
            "-Dpw-cat=disabled",
            "-Dopus=disabled",
            "-Dlibffado=disabled",
        }
        table.insert(configs, "-Dsession-managers=" .. package:config("session-managers"))
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Ddbus=" .. (package:config("dbus") and "enabled" or "disabled"))
        for _, feature in ipairs(features) do
            table.insert(configs, "-D" .. feature.option .. "=" .. (package:config(feature.name) and "enabled" or "disabled"))
        end

        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test(int argc, char** argv) {
                pw_init(&argc, &argv);
                const char* version = pw_get_library_version();
                pw_deinit();
            }
        ]]}, {configs = {languages = "c11", defines = "_GNU_SOURCE"}, includes = "pipewire/pipewire.h"}))
    end)
