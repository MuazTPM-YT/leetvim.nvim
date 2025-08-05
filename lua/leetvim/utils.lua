local M = {}

function M.ensure_dir(path)
	vim.fn.mkdir(path, "p")
end

function M.get_problem_filepath(language, problem_data, config)
	local ext = config.language_extensions[language] or language
	local filename = string.format("%03d-%s.%s", tonumber(problem_data.questionFrontendId), problem_data.titleSlug, ext)

	local full_path = config.base_dir
	if config.create_subdirs then
		full_path = full_path .. "/" .. language
	end
	full_path = full_path .. "/" .. filename

	return full_path
end

function M.create_file_with_content(filepath, content)
	local dir = vim.fn.fnamemodify(filepath, ":h")
	M.ensure_dir(dir)

	local file = io.open(filepath, "w")
	if file then
		file:write(content)
		file:close()
		return true
	end
	return false
end

return M
