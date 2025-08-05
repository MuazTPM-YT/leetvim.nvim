local M = {}

function M.ensure_dir(path)
	vim.fn.mkdir(path, "p")
end

function M.get_problem_filepath(language, problem_data, config)
	local ext = config.language_extensions[language] or language

	local filename = config.filename_pattern
		:gsub("{number:(%d+)d}", function(digits)
			return string.format("%0" .. digits .. "d", tonumber(problem_data.questionFrontendId))
		end)
		:gsub("{slug}", problem_data.titleSlug)
		:gsub("{ext}", ext)

	local full_path = config.base_dir .. "/" .. filename

	return full_path
end

function M.create_file_with_content(filepath, content)
	local dir = vim.fn.fnamemodify(filepath, ":h")
	M.ensure_dir(dir)
	return M.write_file(filepath, content)
end

function M.write_file(path, content)
	local file = io.open(path, "w")
	if file then
		file:write(content)
		file:close()
		return true
	end
	return false
end

return M
