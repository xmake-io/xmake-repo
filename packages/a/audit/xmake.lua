package("audit")
    set_description("Userspace components of the audit framework.")

    add_urls("https://github.com/linux-audit/audit-userspace/archive/refs/tags/$(version).tar.gz",
             "https://github.com/linux-audit/audit-userspace.git")
    add_versions("v4.1.2", "5c638bbeef9adb6c5715d3a60f0f5adb93e9b81633608af13d23c61f5e5db04d")

    add_configs("listener",       {description = "Enable auditd network listener support.", default = true, type = "boolean"})
    add_configs("zos_remote",     {description = "Enable audisp zos remote plugin.", default = true, type = "boolean"})
    add_configs("legacy_actions", {description = "Enable legacy actions.", default = true, type = "boolean"})
    add_configs("gssapi_krb5",    {description = "Enable gssapi kerberos 5 support.", default = true, type = "boolean"})
    add_configs("experimental",   {description = "Enable experimental audit components.", default = false, type = "boolean"})

    add_configs("arm",       {description = "Enable armeabi processor support.", default = false, type = "boolean"})
    add_configs("aarch64",   {description = "Enable aarch64 processor support.", default = false, type = "boolean"})
    add_configs("riscv",     {description = "Enable risc-v processor support.", default = false, type = "boolean"})
    add_configs("apparmor",  {description = "Enable apparmor events.", default = false, type = "boolean"})
    add_configs("io_uring",  {description = "Enable io_uring support.", default = false, type = "boolean"})
    add_configs("nftables",  {description = "Use nftables. (default is nftables)", default = true, type = "boolean"})
    add_configs("libcap_ng", {description = "Add libcap-ng support.", default = true, type = "boolean"})

    add_deps("autotools")
    on_load(function (package)
        if package:config("zos_remote") then
            package:add("deps", "openldap")
        end
        if package:config("gssapi_krb5") then
            package:add("deps", "krb5")
        end
        if package:config("libcap_ng") then
            package:add("deps", "libcap-ng")
        end
    end)

    on_install("linux", function (package)
        local configs = {
            "--disable-dependency-tracking",
            "--without-python3",
            "--without-golang"
        }

        table.insert(configs, "--enable-listener=" .. (package:config("listener") and "yes" or "no"))
        table.insert(configs, "--enable-zos-remote=" .. (package:config("zos_remote") and "yes" or "no"))
        table.insert(configs, "--enable-legacy-actions=" .. (package:config("legacy_actions") and "yes" or "no"))
        table.insert(configs, "--enable-gssapi-krb5=" .. (package:config("gssapi_krb5") and "yes" or "no"))
        table.insert(configs, "--enable-experimental=" .. (package:config("experimental") and "yes" or "no"))

        table.insert(configs, "--with-arm=" .. (package:config("arm") and "yes" or "no"))
        table.insert(configs, "--with-aarch64=" .. (package:config("aarch64") and "yes" or "no"))
        table.insert(configs, "--with-riscv=" .. (package:config("riscv") and "yes" or "no"))
        table.insert(configs, "--with-apparmor=" .. (package:config("apparmor") and "yes" or "no"))
        table.insert(configs, "--with-io_uring=" .. (package:config("io_uring") and "yes" or "no"))
        table.insert(configs, "--with-nftables=" .. (package:config("nftables") and "yes" or "no"))
        table.insert(configs, "--with-libcap-ng=" .. (package:config("libcap_ng") and "yes" or "no"))

        io.replace("src/Makefile.am", "SUBDIRS = test", "SUBDIRS = ", {plain = true})
        io.replace("auparse/Makefile.am", "SUBDIRS = . test", "SUBDIRS = .", {plain = true})

        local packagedeps = {}
        for _, dep in ipairs(package:librarydeps()) do
            table.insert(packagedeps, dep:name())
        end

        import("package.tools.autoconf").install(package, configs, {packagedeps = packagedeps})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("audit_get_session", {includes = "libaudit.h"}))
    end)
