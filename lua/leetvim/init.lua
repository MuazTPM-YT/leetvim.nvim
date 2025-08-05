local M = {}

local config_ok, config = pcall(require, "leetvim.config")
if not config_ok then
	vim.notify("Failed to load leetvim.config: " .. config, vim.log.levels.ERROR)
	config = nil
end

function M.setup(opts)
	if config then
		config.setup(opts or {})
	else
		vim.notify("Config module not available", vim.log.levels.ERROR)
	end
end

function M.fetch_template(language, problem_number)
	vim.notify(string.format("Fetching problem %d template for %s...", problem_number, language))

	local template_ok, template = pcall(require, "leetvim.template")
	if not template_ok then
		vim.notify("Failed to load template module: " .. template, vim.log.levels.ERROR)
		return
	end

	if not template.is_language_supported(language) then
		vim.notify(string.format('Language "%s" is not supported', language), vim.log.levels.ERROR)
		return
	end

	local api_ok, api = pcall(require, "leetvim.api")
	local utils_ok, utils = pcall(require, "leetvim.utils")

	if not api_ok then
		vim.notify("Failed to load API module: " .. api, vim.log.levels.ERROR)
		return
	end

	if not utils_ok then
		vim.notify("Failed to load utils module: " .. utils, vim.log.levels.ERROR)
		return
	end

	api.get_problem_by_number(problem_number, function(problem_data, err)
		if err then
			vim.notify(string.format("Failed to fetch problem: %s", err), vim.log.levels.ERROR)
			return
		end

		if not problem_data then
			vim.notify(string.format("Problem %d not found", problem_number), vim.log.levels.ERROR)
			return
		end

		local template_content = template.generate(language, problem_data)
		if not template_content then
			vim.notify("Failed to generate template", vim.log.levels.ERROR)
			return
		end

		local filepath = utils.get_problem_filepath(language, problem_data, config and config.get() or {})
		utils.create_file_with_content(filepath, template_content)

		vim.cmd(string.format("edit %s", vim.fn.fnameescape(filepath)))
		vim.notify(string.format("Created template: %s", filepath))
	end)
end

function M.setup_auth()
	vim.ui.input({
		prompt = "Enter your Leetcode session cookie: ",
	}, function(cookie)
		if cookie and cookie ~= "" then
			if config then
				config.set_cookie(cookie)
				vim.notify("Cookie saved successfully")
			else
				local cookie_path = vim.fn.stdpath("data") .. "/leetvim/cookie.txt"
				vim.fn.mkdir(vim.fn.fnamemodify(cookie_path, ":h"), "p")

				local file = io.open(cookie_path, "w")
				if file then
					file:write(cookie)
					file:close()
					vim.notify("Cookie saved successfully (fallback method)")
				else
					vim.notify("Failed to save cookie", vim.log.levels.ERROR)
				end
			end
		else
			vim.notify("Authentication cancelled", vim.log.levels.WARN)
		end
	end)
end

return M
