return {
  "mfussenegger/nvim-jdtls",
  opts = function(_, opts)
    -------------------------------------------------------------------------
    -- Multi-JDK setup
    --
    -- jdtls (the language server) RUNS on one fixed modern JDK (21+). That is
    -- independent of the JDK each project compiles against: jdtls reads every
    -- project's declared Java level and picks the matching runtime from the
    -- list below — automatically, per project. Register your JDKs once here.
    -------------------------------------------------------------------------

    -- Auto-discover JDKs you manage with jenv (the plain-major symlinks like
    -- 17 / 21 / 25). Install a new JDK + `jenv add` it and it appears here on
    -- the next Neovim restart — no edits needed.
    local function detect_runtimes()
      local base = vim.fn.expand("~/.jenv/versions")
      local list, seen = {}, {}
      if vim.fn.isdirectory(base) == 0 then
        return list
      end
      for name in vim.fs.dir(base) do
        local major = name:match("^(%d+)$") -- only "17", "21", "25", ...
        if major and not seen[major] then
          local home = vim.fn.resolve(base .. "/" .. name)
          if vim.fn.isdirectory(home .. "/bin") == 1 then
            seen[major] = true
            local n = tonumber(major)
            list[#list + 1] = {
              name = n == 8 and "JavaSE-1.8" or ("JavaSE-" .. major),
              path = home,
              major = n,
            }
          end
        end
      end
      table.sort(list, function(a, b)
        return a.major < b.major
      end)
      return list
    end

    local runtimes = detect_runtimes()

    -- JDK that RUNS the server. Eclipse's bundled compiler resolves each
    -- project's `--release N` flag from the SERVER JVM's ct.sym, so the server
    -- JDK must be >= the newest release any project targets. Use the NEWEST
    -- installed JDK (>= 21). (e.g. a project on `--release 25` needs JDK 25.)
    local server_home
    for _, rt in ipairs(runtimes) do
      if rt.major >= 21 then
        server_home = rt.path -- runtimes are sorted ascending → keeps the newest
      end
    end
    server_home = server_home or (runtimes[#runtimes] and runtimes[#runtimes].path)

    -- Fallback runtime for projects that declare no Java level: prefer 17.
    local matched_default = false
    for _, rt in ipairs(runtimes) do
      if rt.major == 17 then
        rt.default = true
        matched_default = true
      end
    end
    if not matched_default and #runtimes > 0 then
      runtimes[#runtimes].default = true
    end

    opts.settings = opts.settings or {}
    opts.settings.java = opts.settings.java or {}
    opts.settings.java.configuration = opts.settings.java.configuration or {}

    -- Hand jdtls a clean runtime list (drop our internal `major` field).
    local jdk_runtimes = {}
    for _, rt in ipairs(runtimes) do
      jdk_runtimes[#jdk_runtimes + 1] = { name = rt.name, path = rt.path, default = rt.default }
    end
    opts.settings.java.configuration.runtimes = jdk_runtimes

    -- Launch the server under the chosen modern JDK, regardless of what jenv
    -- has pinned in your shell. We set BOTH JAVA_HOME and PATH so it works no
    -- matter how the mason launcher resolves Java.
    if server_home then
      opts.cmd = {
        "env",
        "JAVA_HOME=" .. server_home,
        "PATH=" .. server_home .. "/bin:" .. (vim.env.PATH or ""),
        vim.fn.exepath("jdtls"),
      }
    end

    -- Disable jdtls formatting - only use google-java-format via conform
    opts.settings.java.format = opts.settings.java.format or {}
    opts.settings.java.format.enabled = false

    -- Fix: LazyVim's default root_dir uses vim.lsp.config.jdtls.root_markers,
    -- which is nested on Neovim 0.12+ and breaks vim.fs.root(). Flatten it.
    local orig_root_dir = opts.root_dir
    opts.root_dir = function(path)
      local markers = vim.lsp.config.jdtls and vim.lsp.config.jdtls.root_markers or {}
      local flat = {}
      for _, v in ipairs(markers) do
        if type(v) == "table" then
          vim.list_extend(flat, v)
        else
          table.insert(flat, v)
        end
      end
      if #flat > 0 then
        return vim.fs.root(path, flat)
      end
      -- fallback to original if markers couldn't be resolved
      return orig_root_dir and orig_root_dir(path) or nil
    end

    -- Also disable on_attach formatting
    local on_attach = opts.on_attach
    opts.on_attach = function(client, bufnr)
      -- Disable jdtls formatting capability
      if client and client.server_capabilities then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end

      if on_attach then
        on_attach(client, bufnr)
      end
    end

    return opts
  end,
}
