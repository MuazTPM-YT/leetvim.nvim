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
			local test_vars = M.parse_test_input(example.input, params)

			for _, var_line in ipairs(test_vars.assignments) do
				table.insert(lines, "    " .. var_line)
			end

			table.insert(lines, string.format("    print(solution.%s(%s))", func_name, test_vars.call_params))

			if i < #examples then
				table.insert(lines, "")
			end
		end
	else
		if #params > 0 then
			table.insert(lines, string.format("    print(solution.%s(%s))", func_name, table.concat(params, ", ")))
		else
			table.insert(lines, string.format("    print(solution.%s())", func_name))
		end
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
					local clean_param = param:match("([%w_]+)"):gsub("%s+", "")
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

function M.parse_test_input(input_str, param_names)
	local assignments = {}
	local call_params = {}

	input_str = vim.trim(input_str)

	if input_str:find("=") then
		local lines = vim.split(input_str, "\n")
		for _, line in ipairs(lines) do
			line = vim.trim(line)
			if line ~= "" then
				local var_name, value = line:match("([%w_]+)%s*=%s*(.+)")
				if var_name and value then
					table.insert(assignments, string.format("%s = %s", var_name, value))
					table.insert(call_params, var_name)
				end
			end
		end
	else
		local values = {}

		for value in input_str:gmatch("[^%s]+") do
			table.insert(values, value)
		end

		for i, param_name in ipairs(param_names) do
			if values[i] then
				local value = values[i]
				if value:match("^%[.*%]$") then
					table.insert(assignments, string.format("%s = %s", param_name, value))
				elseif value:match('^".*"$') then
					table.insert(assignments, string.format("%s = %s", param_name, value))
				elseif tonumber(value) then
					table.insert(assignments, string.format("%s = %s", param_name, value))
				else
					table.insert(assignments, string.format('%s = "%s"', param_name, value))
				end
				table.insert(call_params, param_name)
			end
		end
	end

	return {
		assignments = assignments,
		call_params = table.concat(call_params, ", "),
	}
end

return M
