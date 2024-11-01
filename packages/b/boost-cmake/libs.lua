local libs = {
    exception = { },
    test = {
      "exception"
    },
    iostreams = {
      "random",
      "regex"
    },
    atomic = { },
    date_time = { },
    math = {
      "random"
    },
    container = { },
    graph_parallel = {
      "filesystem",
      "graph",
      "mpi",
      "random",
      "serialization"
    },
    serialization = { },
    program_options = { },
    graph = {
      "math",
      "random",
      "regex",
      "serialization"
    },
    timer = { },
    process = {
      "filesystem",
      "system"
    },
    contract = {
      "exception",
      "thread"
    },
    mpi = {
      "graph",
      "python",
      "serialization"
    },
    fiber = {
      "context",
      "filesystem"
    },
    context = { },
    coroutine = {
      "context",
      "exception",
      "system"
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
    regex = { },
    thread = {
      "atomic",
      "chrono",
      "container",
      "date_time",
      "exception",
      "system"
    },
    nowide = {
      "filesystem"
    },
    random = {
      "system"
    },
    url = {
      "system"
    },
    type_erasure = {
      "thread"
    },
    locale = {
      "thread"
    },
    wave = {
      "filesystem",
      "serialization"
    },
    json = {
      "container",
      "system"
    },
    python = {
      "graph"
    },
    charconv = { },
    chrono = {
      "system"
    },
    cobalt = {
      "container",
      "context",
      "system"
    },
    system = { },
    filesystem = {
      "atomic",
      "system"
    },
    stacktrace = { }
}

function get_libs()
    return libs
end

function for_each(lambda)
    for lib, deps in pairs(get_libs()) do
        lambda(lib, deps)
    end
end
