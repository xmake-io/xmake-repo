add_rules("mode.debug", "mode.release")

option("juce_analytics",            {showmenu = true,  default = false})
option("juce_audio_basics",         {showmenu = true,  default = false})
option("juce_audio_devices",        {showmenu = true,  default = false})
option("juce_audio_formats",        {showmenu = true,  default = false})
option("juce_audio_plugin_client",  {showmenu = true,  default = false})
option("juce_audio_processors",     {showmenu = true,  default = false})
option("juce_audio_utils",          {showmenu = true,  default = false})
option("juce_box2d",                {showmenu = true,  default = false})
option("juce_core",                 {showmenu = true,  default = true})
option("juce_cryptography",         {showmenu = true,  default = false})
option("juce_data_structures",      {showmenu = true,  default = false})
option("juce_dsp",                  {showmenu = true,  default = false})
option("juce_events",               {showmenu = true,  default = false})
option("juce_graphics",             {showmenu = true,  default = false})
option("juce_gui_basics",           {showmenu = true,  default = false})
option("juce_gui_extra",            {showmenu = true,  default = false})
option("juce_midi_ci",              {showmenu = true,  default = false})
option("juce_opengl",               {showmenu = true,  default = false})
option("juce_osc",                  {showmenu = true,  default = false})
option("juce_product_unlocking",    {showmenu = true,  default = false})
option("juce_video",                 {showmenu = true,  default = false})
option("utf8",                      {showmenu = true,  default = "8"})


local modules = {
    "juce_analytics",
    "juce_audio_basics",
    "juce_audio_devices",
    "juce_audio_formats",
    "juce_audio_plugin_client",
    "juce_audio_processors",
    "juce_audio_utils",
    "juce_box2d",
    "juce_core",
    "juce_cryptography",
    "juce_data_structures",
    "juce_dsp",
    "juce_events",
    "juce_graphics",
    "juce_gui_basics",
    "juce_gui_extra",
    "juce_midi_ci",
    "juce_opengl",
    "juce_osc",
    "juce_product_unlocking",
    "juce_video"
}

target("juce")
    set_kind("$(kind)")
    set_languages("cxx17")

    add_defines("JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED", {public = true})
    add_defines("JUCE_STRING_UTF_TYPE=8", {public = true})

    if is_kind("shared") then
        add_defines("JUCE_DLL_BUILD")
    end

    for _, module in ipairs(modules) do
        if has_config(module) then
            add_files("modules/" .. module .. "/" .. module .. ".cpp")
            add_includedirs("modules/", { public = true })
            add_headerfiles("modules/(" .. module .. "/" .. module .. ".h)")
            for _, dir in ipairs(os.dirs("modules/" .. module .. "/**")) do
                add_includedirs(dir, { public = true })
                add_headerfiles("modules/(" .. dir:gsub("modules\\", "") .. "/*.h)")
            end
        end
    end