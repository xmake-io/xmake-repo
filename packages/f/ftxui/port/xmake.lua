set_xmakever("2.9.8")
set_project("ftxui")

option("modules", { default = false, "enable C++20 module support"})
option("microsoft_fallback_terminal", { default = true, description = "On windows, assume the \
terminal used will be one of Microsoft and use a set of reasonnable fallback \
to counteract its implementations problems.", type = "boolean" })

add_rules("mode.release", "mode.debug")

local libs = {
  screen = {files = {
    "src/ftxui/screen/box.cpp",
    "src/ftxui/screen/color.cpp",
    "src/ftxui/screen/color_info.cpp",
    "src/ftxui/screen/image.cpp",
    "src/ftxui/screen/screen.cpp",
    "src/ftxui/screen/string.cpp",
    "src/ftxui/screen/terminal.cpp",
  }},
  dom = {deps = {"screen"}, files = {
    "src/ftxui/dom/automerge.cpp",
    "src/ftxui/dom/selection_style.cpp",
    "src/ftxui/dom/blink.cpp",
    "src/ftxui/dom/bold.cpp",
    "src/ftxui/dom/border.cpp",
    "src/ftxui/dom/box_helper.cpp",
    "src/ftxui/dom/canvas.cpp",
    "src/ftxui/dom/clear_under.cpp",
    "src/ftxui/dom/color.cpp",
    "src/ftxui/dom/composite_decorator.cpp",
    "src/ftxui/dom/dbox.cpp",
    "src/ftxui/dom/dim.cpp",
    "src/ftxui/dom/flex.cpp",
    "src/ftxui/dom/flexbox.cpp",
    "src/ftxui/dom/flexbox_config.cpp",
    "src/ftxui/dom/flexbox_helper.cpp",
    "src/ftxui/dom/focus.cpp",
    "src/ftxui/dom/frame.cpp",
    "src/ftxui/dom/gauge.cpp",
    "src/ftxui/dom/graph.cpp",
    "src/ftxui/dom/gridbox.cpp",
    "src/ftxui/dom/hbox.cpp",
    "src/ftxui/dom/hyperlink.cpp",
    "src/ftxui/dom/inverted.cpp",
    "src/ftxui/dom/italic.cpp",
    "src/ftxui/dom/linear_gradient.cpp",
    "src/ftxui/dom/node.cpp",
    "src/ftxui/dom/node_decorator.cpp",
    "src/ftxui/dom/paragraph.cpp",
    "src/ftxui/dom/reflect.cpp",
    "src/ftxui/dom/scroll_indicator.cpp",
    "src/ftxui/dom/selection.cpp",
    "src/ftxui/dom/separator.cpp",
    "src/ftxui/dom/size.cpp",
    "src/ftxui/dom/spinner.cpp",
    "src/ftxui/dom/strikethrough.cpp",
    "src/ftxui/dom/table.cpp",
    "src/ftxui/dom/text.cpp",
    "src/ftxui/dom/underlined.cpp",
    "src/ftxui/dom/underlined_double.cpp",
    "src/ftxui/dom/util.cpp",
    "src/ftxui/dom/vbox.cpp",
    }},
  component = {deps = {"dom"}, files = {
    "src/ftxui/component/animation.cpp",
    "src/ftxui/component/button.cpp",
    "src/ftxui/component/catch_event.cpp",
    "src/ftxui/component/checkbox.cpp",
    "src/ftxui/component/collapsible.cpp",
    "src/ftxui/component/component.cpp",
    "src/ftxui/component/component_options.cpp",
    "src/ftxui/component/container.cpp",
    "src/ftxui/component/dropdown.cpp",
    "src/ftxui/component/event.cpp",
    "src/ftxui/component/hoverable.cpp",
    "src/ftxui/component/input.cpp",
    "src/ftxui/component/loop.cpp",
    "src/ftxui/component/maybe.cpp",
    "src/ftxui/component/menu.cpp",
    "src/ftxui/component/modal.cpp",
    "src/ftxui/component/radiobox.cpp",
    "src/ftxui/component/radiobox.cpp",
    "src/ftxui/component/renderer.cpp",
    "src/ftxui/component/resizable_split.cpp",
    "src/ftxui/component/screen_interactive.cpp",
    "src/ftxui/component/slider.cpp",
    "src/ftxui/component/task.cpp",
    "src/ftxui/component/task_queue.cpp",
    "src/ftxui/component/task_runner.cpp",
    "src/ftxui/component/terminal_input_parser.cpp",
    "src/ftxui/component/util.cpp",
    "src/ftxui/component/window.cpp",
  }}
}

namespace("ftxui", function()
  for name, lib in table.orderpairs(libs) do
      local src_dir = path.join("src", "ftxui", name)
      local include_dir = path.join("include", "(ftxui", name)
      target(name)
          set_kind("$(kind)")
          if get_config("modules") then
              add_languages("c++20")
          else
              add_languages("c++17")
          end
          add_files(lib.files)
          add_cxflags("/utf-8", "/wd4244", "/wd4267", "/D_CRT_SECURE_NO_WARNINGS", {tools = {"cl"}})
          add_cxflags("-pipe", {tools = {"gcc", "clang"}})
          if is_plat("windows") then
              add_defines("UNICODE", "_UNICODE")
          end
          if has_config("microsoft_fallback_terminal") then
              add_defines("FTXUI_MICROSOFT_TERMINAL_FALLBACK")
          end
          add_headerfiles(path.join(include_dir, "**.hpp)"))
          add_headerfiles("include/(ftxui/util/**.hpp)")
          add_includedirs("include", {public = true})
          add_includedirs("src")
          if get_config("modules") then
              add_files(path.join(src_dir, "**.cppm"), {public = true})
          end
          set_basename("ftxui-" .. name)
          set_policy("build.c++.modules.std", false)
          if lib.deps then
              add_deps(table.unpack(lib.deps))
          end
    end

    target("ftxui")
        if get_config("modules") then
            set_kind("moduleonly")
            add_languages("c++20")
            add_files(path.join("src", "ftxui", "*.cppm"))
            add_files(path.join("src", "ftxui", "util", "*.cppm"))
        else
            set_kind("phony")
        end

        add_deps("screen", "dom", "component")
end)
