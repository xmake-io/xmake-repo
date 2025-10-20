add_rules("mode.release", "mode.debug")

target("Logging")
    set_kind("$(kind)")
    add_files("Sources/Logging/**.swift")
    
    add_scflags("-enable-experimental-feature", "StrictConcurrency=complete")
    add_scflags("-enable-upcoming-feature", "MemberImportVisibility")
