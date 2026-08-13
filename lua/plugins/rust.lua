local function rustup_rustc_dir()
  local rustc = vim.fn.systemlist({ "rustup", "which", "rustc" })
  if vim.v.shell_error ~= 0 or #rustc == 0 then
    return nil
  end
  return vim.fn.fnamemodify(rustc[1], ":h")
end

local function rust_analyzer_cmd()
  local candidates = {
    vim.fn.expand("~/.cargo/bin/rust-analyzer"),
    vim.fn.exepath("rust-analyzer"),
  }
  for _, path in ipairs(candidates) do
    if path ~= "" and vim.fn.executable(path) == 1 then
      return path
    end
  end
  return "rust-analyzer"
end

local function rust_analyzer_env()
  local path_parts = { vim.fn.expand("~/.cargo/bin") }
  local rustup_bin = rustup_rustc_dir()
  if rustup_bin then
    table.insert(path_parts, rustup_bin)
  end
  if vim.env.PATH then
    table.insert(path_parts, vim.env.PATH)
  end

  return {
    PATH = table.concat(path_parts, ":"),
    RUSTUP_TOOLCHAIN = vim.env.RUSTUP_TOOLCHAIN or "stable",
  }
end

return {
  {
    "Saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = { crates = { enabled = true } },
      lsp = { enabled = true, actions = true, completion = true, hover = true },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "rust", "ron" } },
  },
  {
    "mason-org/mason.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "codelldb" })
    end,
  },
  {
    "mrcjkb/rustaceanvim",
    ft = { "rust" },
    opts = {
      server = {
        cmd = function()
          return {
            rust_analyzer_cmd(),
            "--log-file",
            (vim.g.rustaceanvim or {}).server and vim.g.rustaceanvim.server.logfile
              or vim.fn.tempname() .. "-rust-analyzer.log",
          }
        end,
        on_attach = function(_, bufnr)
          vim.keymap.set("n", "<leader>cR", function()
            vim.cmd.RustLsp("codeAction")
          end, { desc = "Code Action", buffer = bufnr })
          vim.keymap.set("n", "<leader>dr", function()
            vim.cmd.RustLsp("debuggables")
          end, { desc = "Rust Debuggables", buffer = bufnr })
        end,
        default_settings = {
          ["rust-analyzer"] = {
            rustc = { source = "discover" },
            server = { extraEnv = rust_analyzer_env() },
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = { enable = true },
            },
            checkOnSave = { command = "check" },
            diagnostics = { enable = true },
            procMacro = { enable = true },
            files = {
              exclude = {
                ".direnv",
                ".git",
                ".jj",
                ".github",
                ".gitlab",
                "bin",
                "node_modules",
                "target",
                "venv",
                ".venv",
              },
              watcher = "client",
            },
          },
        },
      },
    },
    config = function(_, opts)
      if LazyVim.has("mason.nvim") then
        local codelldb = vim.fn.exepath("codelldb")
        local codelldb_lib_ext = io.popen("uname"):read("*l") == "Linux" and ".so" or ".dylib"
        local library_path = vim.fn.expand("$MASON/opt/lldb/lib/liblldb" .. codelldb_lib_ext)
        opts.dap = { adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, library_path) }
      end
      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
      if vim.fn.executable(rust_analyzer_cmd()) == 0 then
        LazyVim.error(
          "**rust-analyzer** not found in PATH, please install it:\n"
            .. "  rustup component add rust-analyzer\n"
            .. "https://rust-analyzer.github.io/",
          { title = "rustaceanvim" }
        )
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = { servers = { rust_analyzer = { enabled = false } } },
  },
}
