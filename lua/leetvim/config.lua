local m = {}

local default_config = {
	base_dir = vim.fn.expand("~/leetcode"),
	create_subdirs = true,
	filename_pattern = "{number:03d}-{slug}.{ext}",
	leetcode_url = "https://leetcode.com",
	user_agent = "mozilla/5.0 (compatible; leetvim.nvim)",
	include_description = true,
	include_examples = true,
	include_test_stub = true,
	default_language = "python",
	language_extensions = {
		python = "py",
	},
}

local config = vim.deepcopy(default_config)

function m.setup(user_config)
	config = vim.tbl_deep_extend("force", config, user_config or {})
	vim.fn.mkdir(config.base_dir, "p")
end

function m.get()
	return config
end

function m.get_cookie_path()
	return vim.fn.stdpath("data") .. "/leetvim/cookie.txt"
end

function m.get_cookie()
	local cookie_path = m.get_cookie_path()
	if vim.fn.filereadable(cookie_path) == 1 then
		local file = io.open(cookie_path, "r")
		if file then
			local content = file:read("*a")
			file:close()
			return vim.trim(content)
		end
	end
	return nil
end

function m.set_cookie(cookie)
	local cookie_path = m.get_cookie_path()
	vim.fn.mkdir(vim.fn.fnamemodify(cookie_path, ":h"), "p")
	local file = io.open(cookie_path, "w")
	if file then
		file:write(cookie)
		file:close()
	end
end

return m
