local sorted_libs = {
  "asio",
  "wave",
  "url",
  "type_erasure",
  "timer",
  "test",
  "stacktrace",
  "program_options",
  "process",
  "nowide",
  "log",
  "locale",
  "json",
  "iostreams",
  "graph_parallel",
  "mpi",
  "python",
  "graph",
  "serialization",
  "regex",
  "math",
  "random",
  "fiber",
  "filesystem",
  "coroutine",
  "contract",
  "thread",
  "date_time",
  "exception",
  "cobalt",
  "context",
  "container",
  "chrono",
  "system",
  "charconv",
  "atomic"
}

local libs_dep = {
  asio = {
    "date_time",
  },
  json = {
    "container",
    "system"
  },
  python = {
    "graph"
  },
  test = {
    "exception"
  },
  type_erasure = {
    "thread"
  },
  thread = {
    "atomic",
    "chrono",
    "container",
    "date_time",
    "exception",
    "system"
  },
  fiber = {
    "context",
    "filesystem"
  },
  chrono = {
    "system"
  },
  charconv = { },
  contract = {
    "exception",
    "thread"
  },
  timer = { },
  wave = {
    "filesystem",
    "serialization"
  },
  stacktrace = { },
  coroutine = {
    "context",
    "exception",
    "system"
  },
  math = {
    "random"
  },
  exception = { },
  filesystem = {
    "atomic",
    "system"
  },
  date_time = {
    "container",
    "exception",
    "regex"
  },
  atomic = { },
  url = {
    "system"
  },
  serialization = { },
  process = {
    "filesystem",
    "system"
  },
  regex = { },
  container = { },
  random = {
    "system"
  },
  nowide = {
    "filesystem"
  },
  program_options = { },
  system = { },
  cobalt = {
    "container",
    "context",
    "system"
  },
  graph = {
    "math",
    "random",
    "regex",
    "serialization"
  },
  context = { },
  mpi = {
    "graph",
    "python",
    "serialization"
  },
  log = {
    "atomic",
    "date_time",
    "exception",
    "filesystem",
    "random",
    "regex",
    "system",
    "thread"
  },
  iostreams = {
    "random",
    "regex"
  },
  locale = {
    "thread"
  },
  graph_parallel = {
    "filesystem",
    "graph",
    "mpi",
    "random",
    "serialization"
  }
}

local header_only_buildable = {
  "graph_parallel",
  "system",
  "exception",
  "regex",
  "math",
}

function get_libs()
    return sorted_libs
end

function get_lib_deps()
    return libs_dep
end

function get_header_only_buildable()
    return header_only_buildable
end

function for_each(lambda)
    for _, libname in ipairs(get_libs()) do
        lambda(libname)
    end
end

function for_each_header_only_buildable_lib(lambda)
    for _, libname in ipairs(get_header_only_buildable()) do
        lambda(libname)
    end
end

function for_each_lib_deps(lambda)
    for libname, deps in pairs(get_lib_deps()) do
        lambda(libname, deps)
    end
end

function get_sub_libs(package)
    local sub_libs_map = {
        test = {"prg_exec_monitor", "unit_test_framework"},
        serialization = {"wserialization", "serialization"},
        fiber = {"fiber", "fiber_numa"},
        log = {"log", "log_setup"},
        stacktrace = {
            "stacktrace_noop",
            "stacktrace_backtrace",
            "stacktrace_addr2line",
            "stacktrace_basic",
            "stacktrace_windbg",
            "stacktrace_windbg_cached",
        },
    }

    if package:config("python") then
        local py_ver = assert(package:dep("python"):version(), "Can't get python version")
        py_ver = py_ver:major() .. py_ver:minor()
        -- TODO: detect numpy
        sub_libs_map["python"] = {
            "python" .. py_ver,
            "numpy" .. py_ver,
        }
    end

    return sub_libs_map
end
