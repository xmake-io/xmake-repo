set_project("BNM")

set_languages("c++20")

add_rules("mode.debug", "mode.release")

if is_config("hook_lib", "dobby") then
    add_requires("dobby")
elseif is_config("hook_lib", "shadowhook") then
    add_requires("shadowhook")
end

option("link_log", {
    description = "Link against liblog.so",
    default = false,
    type = "boolean"
})
option("hook_lib", {
    description = "Choose the hooking library used (dobby or shadowhook).",
    default = "shadowhook", 
    type = "string",
    values = {"shadowhook", "dobby"}
})
option("unity_version", {
    description = "Unity version (e.g., 5.6.4, 2017.1.0, 2022.2.1)",
    default = "2022.2.0",
    type = "string"
})
option("version", {
    description = "Set the version",
    type = "string"
})

set_version(get_config("version"))

target("BNM")
    set_kind("static")
    if is_config("hook_lib", "dobby") then
        add_packages("dobby", {public = true})
    elseif is_config("hook_lib", "shadowhook") then
        add_packages("shadowhook", {public = true})
    end

    add_files("src/*.cpp")
    
    add_headerfiles("include/(**.h)", "include/(**.hpp)")
    add_headerfiles("external/include/(**.h)", "external/include/(**.hpp)")
    add_includedirs("include", "external/include", "external", "external/utf8", "src/private")
    
    if has_config("link_log") then
        add_syslinks("log")
    end
    
    set_configvar("BNM_INCLUDE_DIRECTORIES", "include;external/include")
