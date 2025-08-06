local M = {}

function M.matches_language(lang_slug)
	return lang_slug == "python" or lang_slug == "python3"
end

function M.generate_description_comment(problem_data)
	return ""
end

function M.generate_test_stub(problem_data, examples)
	local func_name = M.extract_function_name(problem_data.codeSnippets)
	local params = M.extract_function_params(problem_data.codeSnippets)

	local lines = {
		'if __name__ == "__main__":',
		"    solution = Solution()",
		"",
	}

	if #examples > 0 then
		for i, example in ipairs(examples) do
			local test_lines = M.parse_example_to_test_lines(example, params, func_name)

			for _, line in ipairs(test_lines) do
				table.insert(lines, "    " .. line)
			end

			if i < #examples then
				table.insert(lines, "")
			end
		end
	else
		local param_placeholder = {}
		for _, param in ipairs(params) do
			table.insert(param_placeholder, param)
		end
		table.insert(
			lines,
			string.format("    print(solution.%s(%s))", func_name, table.concat(param_placeholder, ", "))
		)
	end

	return table.concat(lines, "\n")
end

function M.extract_function_name(code_snippets)
	for _, snippet in ipairs(code_snippets) do
		if M.matches_language(snippet.langSlug) then
			local func_name = snippet.code:match("def%s+([%w_]+)%s*%(")
			if func_name then
				return func_name
			end
		end
	end
	return "solution_function"
end

function M.extract_function_params(code_snippets)
	for _, snippet in ipairs(code_snippets) do
		if M.matches_language(snippet.langSlug) then
			local params_str = snippet.code:match("def%s+[%w_]+%s*%(self[%s,]*([^)]*)%)")
			if params_str then
				local params = {}
				for param in params_str:gmatch("([^,]+)") do
					local clean_param = vim.trim(param):match("([%w_]+)")
					if clean_param and clean_param ~= "" then
						table.insert(params, clean_param)
					end
				end
				return params
			end
		end
	end
	return {}
end

function M.parse_example_to_test_lines(example, param_names, func_name)
	local lines = {}
	local input_str = vim.trim(example.input)

	local input_lines = vim.split(input_str, "\n")

	local assignments = {}
	local call_params = {}

	for i, input_line in ipairs(input_lines) do
		input_line = vim.trim(input_line)
		if input_line ~= "" and param_names[i] then
			local param_name = param_names[i]
			local value = M.format_input_value(input_line)

			table.insert(assignments, string.format("%s = %s", param_name, value))
			table.insert(call_params, param_name)
		end
	end

	for _, assignment in ipairs(assignments) do
		table.insert(lines, assignment)
	end

	local call_str = string.format("print(solution.%s(%s))", func_name, table.concat(call_params, ", "))
	table.insert(lines, call_str)

	return lines
end

function M.format_input_value(input_str)
	input_str = vim.trim(input_str)

	if input_str:match("^%[.*%]$") then
		return input_str
	end

	if input_str:match('^".*"$') then
		return input_str
	end

	if input_str:match("^%-?%d+%.?%d*$") then
		return input_str
	end

	if input_str:lower() == "true" or input_str:lower() == "false" then
		return input_str:lower():gsub("^%l", string.upper)
	end

	if not input_str:match("^[%[{]") then
		return '"' .. input_str .. '"'
	end

	return input_str
end

return M
