package("openssh")
    set_kind("binary")
    set_description("OpenSSH is a complete implementation of the SSH protocol (version 2) for secure remote login, command execution and file transfer.")
    set_license("BSD-2-Clause")

    add_urls("https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-$(version).tar.gz",
             "https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-$(version).tar.gz",
             "https://mirror.leaseweb.com/pub/OpenBSD/OpenSSH/portable/openssh-$(version).tar.gz",
             "https://mirrors.aliyun.com/pub/OpenBSD/OpenSSH/portable/openssh-$(version).tar.gz",
             "https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-$(version).tar.gz")
    add_versions("10.0p2", "021a2e709a0edf4250b1256bd5a9e500411a90dddabea830ed59cef90eb9d85c")

    add_configs("libcrypto", {description = "Select a crypto backend.", type = "string", default = "openssl3", values = {"builtin", "libressl", "openssl", "openssl3"}})
    add_configs("zlib",      {description = "Enable compression support.", type = "boolean", default = true})
    add_configs("kerberos5", {description = "Enable Kerberos 5 support.", type = "boolean", default = false})

    add_configs("largefile",         {description = "Enable support for large files.", type = "boolean", default = true})
    add_configs("pkcs11",            {description = "Enable PKCS#11 support.", type = "boolean", default = true})
    add_configs("security_key",      {description = "Enable U2F/FIDO support.", type = "boolean", default = true})
    add_configs("strip",             {description = "Enable calling strip(1) on install.", type = "boolean", default = true})
    add_configs("etc_default_login", {description = "Enable using PATH from /etc/default/login.", type = "boolean", default = true})
    add_configs("fd_passing",        {description = "Enable file descriptor passsing.", type = "boolean", default = true})
    add_configs("lastlog",           {description = "If detected, enable use of lastlog.", type = "boolean", default = true})
    add_configs("utmp",              {description = "If detected, enable use of utmp.", type = "boolean", default = true})
    add_configs("utmpx",             {description = "If detected, enable use of utmpx.", type = "boolean", default = true})
    add_configs("wtmp",              {description = "If detected, enable use of utmpx.", type = "boolean", default = true})
    add_configs("wtmpx",             {description = "If detected, enable use of utmpx.", type = "boolean", default = true})
    add_configs("libutil",           {description = "Enable use of libutil. (login() etc.)", type = "boolean", default = true})
    add_configs("pututline",         {description = "Enable use of pututline() etc. (uwtmp)", type = "boolean", default = true})
    add_configs("pututxline",        {description = "Enable use of pututxline() etc. (uwtmpx)", type = "boolean", default = true})

    add_configs("stackprotect",            {description = "Use compiler's stack protection.", type = "boolean", default = nil})
    add_configs("hardening",               {description = "Use toolchain hardening flags.", type = "boolean", default = nil})
    add_configs("retpoline",               {description = "Enable retpoline spectre mitigation.", type = "boolean", default = nil})
    add_configs("linux_memlock_onfault",   {description = "Enables memory locking on Linux.", type = "boolean", default = nil})
    add_configs("security_key_builtin",    {description = "Include builtin U2F/FIDO support.", type = "boolean", default = nil})
    add_configs("security_key_standalone", {description = "Build standalone sk-libfido2 SecurityKeyProvider.", type = "boolean", default = nil})
    add_configs("ssl_engine",              {description = "Enable OpenSSL (hardware) ENGINE support.", type = "boolean", default = nil})
    add_configs("prngd_port",              {description = "Read entropy from PRNGD/EGD TCP localhost:PORT", type = "number", default = nil})
    add_configs("prngd_socket",            {description = "Read entropy from PRNGD/EGD socket FILE.", type = "string", default = nil})
    add_configs("pam",                     {description = "Enable PAM support.", type = "boolean", default = nil})
    add_configs("pam_service",             {description = "Specify PAM service name.", type = "string", default = nil})
    add_configs("privsep_user",            {description = "Specify non-privileged user for privilege separation.", type = "string", default = nil})
    add_configs("sandbox",                 {description = "Specify privilege separation sandbox.", type = "string", default = nil, values = {"no", "capsicum", "darwin", "rlimit", "seccomp_filter"}})
    add_configs("selinux",                 {description = "Enable SELinux support.", type = "boolean", default = nil})
    add_configs("privsep_path",            {description = "Path for privilege separation chroot.", type = "string", default = nil})
    add_configs("xauth",                   {description = "Specify path to xauth program.", type = "string", default = nil})
    add_configs("maildir",                 {description = "Specify your system mail directory.", type = "string", default = nil})
    add_configs("shadow",                  {description = "Enable shadow password support.", type = "boolean", default = nil})
    add_configs("ipaddr_display",          {description = "Use ip address instead of hostname in $DISPLAY.", type = "boolean", default = nil})
    add_configs("default_path",            {description = "Specify default $PATH environment for server.", type = "string", default = nil})
    add_configs("superuser_path",          {description = "Specify different path for super-user.", type = "string", default = nil})
    add_configs("ip4in6",                  {description = "Check for and convert IPv4 in IPv6 mapped addresses.", type = "boolean", default = nil})
    add_configs("bsd_auth",                {description = "Enable BSD auth support.", type = "boolean", default = nil})
    add_configs("pid_dir",                 {description = "Specify location of sshd.pid file.", type = "string", default = nil})
    add_configs("lastlog_dir",             {description = "Specify lastlog location common locations.", type = "string", default = nil})

    on_load(function (package)
        if package:is_plat("msys") then
            package:add("deps", "autotools")

            -- patches from: https://github.com/msys2/MSYS2-packages/tree/master/openssh
            package:add("patches", "*", "patches/8.9p1/msys2-drive-name-in-path.patch", "903b3eee51e492a125cab9c724ad967450307d53e457f025e4432b81cb145af5")
            package:add("patches", "*", "patches/8.9p1/msys2-setkey.patch", "24dacf56b359f9fef584fbf50e7d7993e73bac52dbe8a0ff5e5f13071a22bb42")
            package:add("patches", "*", "patches/8.9p1/msys2.patch", "3fb221882d0cb8554c641a4c7a6684badc98329a8a17dbc42e64594037e5d128")
        end

        local libcrypto = package:config("libcrypto")
        if libcrypto ~= "builtin" then
            package:add("deps", libcrypto)
        end

        if package:config("zlib") then
            package:add("deps", "zlib")
        end

        if package:config("kerberos5") then
            package:add("deps", "krb5")
        end

        if package:config("privsep_path") == nil then
            package:config_set("privsep_path", package:installdir("var/empty"):gsub("\\", "/"))
        end
    end)

    -- about msys2 support:
    -- @see https://github.com/xmake-io/xmake-repo/pull/8092#discussion_r2342822821
    on_install("@linux", "@bsd", "@macosx", "@cygwin", function (package)
        import("package.tools.autoconf")

        local configs = {}
        local ldflags = {}

        local features_enabled_by_default = {
            "largefile", "pkcs11", "security-key", "strip", "etc-default-login", "fd-passing",
            "lastlog", "utmp", "utmpx", "wtmp", "wtmpx", "libutil", "pututline", "pututxline",
        }
        for _, feature in ipairs(features_enabled_by_default) do
            if not package:config(feature:gsub("-", "_")) then
                table.insert(configs, "--disable-" .. feature)
            end
        end
        
        local packages_boolean = {
            "stackprotect", "hardening", "retpoline", "linux-memlock-onfault",
            "pie", "security-key-builtin","security-key-standalone", "ssl-engine",
            "pam", "selinux", "shadow", "ipaddr-display", "bsd-auth"
        }
        local packages_string = {
            "prngd-socket", "pam-service", "privsep-user",
            "sandbox", "privsep-path", "xauth", "default-path", 
            "superuser-path", "pid-dir"
        }
        for _, package_boolean in ipairs(packages_boolean) do
            local value = package:config(package_boolean:gsub("-", "_"))
            if value ~= nil then
                table.insert(configs, ("--with-%s=%s"):format(package_boolean, value and "yes" or "no"))
            end
        end
        for _, package_string in ipairs(packages_string) do
            local value = package:config(package_string:gsub("-", "_"))
            if value ~= nil then
                table.insert(configs, ("--with-%s=%s"):format(package_string, value))
            end
        end

        local libcrypto = package:config("libcrypto")
        if libcrypto == "builtin" then
            table.insert(configs, "--without-openssl")
        else
            table.insert(configs, ("--with-ssl-dir=%s"):format(package:dep(libcrypto):installdir():gsub("\\", "/")))
        end

        if package:config("zlib") then
            table.insert(configs, ("--with-zlib=%s"):format(package:dep("zlib"):installdir():gsub("\\", "/")))
        end

        if package:config("kerberos5") then
            table.insert(configs, ("--with-kerberos5=%s"):format(package:dep("krb5"):installdir():gsub("\\", "/")))
        end

        if package:config("ip4in6") then
            table.insert(configs, "--with-4in6")
        end
        if package:config("prngd_port") then
            table.insert(configs, "--with-prngd-port=" .. tostring(package:config("prngd_port")))
        end
        if package:config("lastlog_dir") then
            table.insert(configs, "--with-lastlog=" .. package:config("lastlog"))
        end
        
        -- fix 'working libcrypto not found' problem.
        if package:config("libcrypto"):startswith("openssl") and package:is_plat("bsd") then
            table.insert(ldflags, "-pthread")
        end

        local envs = autoconf.buildenvs(package, {ldflags = ldflags})

        -- @see https://github.com/msys2/MSYS2-packages/blob/master/openssh/PKGBUILD
        if package:is_plat("msys") then
            os.rm("configure")
            envs.MSYSTEM = "CYGWIN"
            envs.ac_cv_func_setproctitle = "no"
            table.insert(configs, "--build=" .. os.getenv("MINGW_CHOST"))
        end

        autoconf.install(package, configs, {envs = envs})
    end)

    on_test(function (package)
        local suffix = is_host("windows") and ".exe" or ""
        assert(os.isexec(package:installdir("sbin/sshd" .. suffix)), "sshd not found!")
    end)
