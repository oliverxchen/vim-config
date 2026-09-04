local M = {}

local function normalize(path)
  if not path or path == "" then
    return nil
  end

  return vim.fs.normalize(path)
end

local function buffer_dir(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr or 0)
  if filename == "" then
    return normalize(vim.fn.getcwd())
  end

  return normalize(vim.fs.dirname(filename))
end

local function find_upward(start_dir, stop_dir, callback)
  local current = normalize(start_dir)
  local stop = normalize(stop_dir)

  while current do
    local result = callback(current)
    if result then
      return result
    end

    if stop and current == stop then
      break
    end

    local parent = normalize(vim.fs.dirname(current))
    if not parent or parent == current then
      break
    end
    current = parent
  end
end

local function executable(path)
  return path and vim.fn.executable(path) == 1 and path or nil
end

function M.repository_root(bufnr)
  return vim.fs.root(buffer_dir(bufnr), { ".git" })
end

function M.node_tool(name, bufnr)
  local root = M.repository_root(bufnr)
  if not root then
    return nil
  end

  return find_upward(buffer_dir(bufnr), root, function(dir)
    return executable(vim.fs.joinpath(dir, "node_modules", ".bin", name))
  end)
end

local function python_tool_in_environment(name, environment)
  if not environment or environment == "" then
    return nil
  end

  return executable(vim.fs.joinpath(environment, "bin", name))
end

function M.python_tool(name, bufnr)
  local root = M.repository_root(bufnr)
  if not root then
    return nil
  end

  local active_tool = python_tool_in_environment(name, vim.env.VIRTUAL_ENV)
  if active_tool then
    return active_tool
  end

  return find_upward(buffer_dir(bufnr), root, function(dir)
    for _, environment in ipairs({ ".venv", "venv", "env" }) do
      local tool = python_tool_in_environment(name, vim.fs.joinpath(dir, environment))
      if tool then
        return tool
      end
    end
  end)
end

function M.python_tool_in_root(name, root)
  if not root then
    return nil
  end

  local active_tool = python_tool_in_environment(name, vim.env.VIRTUAL_ENV)
  if active_tool then
    return active_tool
  end

  for _, environment in ipairs({ ".venv", "venv", "env" }) do
    local tool = python_tool_in_environment(name, vim.fs.joinpath(root, environment))
    if tool then
      return tool
    end
  end
end

return M
