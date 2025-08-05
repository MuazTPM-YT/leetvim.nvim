local M = {}

function M.matches_language(lang_slug)
	return lang_slug == "python" or lang_slug == "python3"
end

function M.generate_description_comment(problem_data)
	return ""
end

function M.generate_test_stub(problem_data, examples)
	local func_name = M.extract_function_name(problem_data.codeSnippets)

	local lines = {
		'if __name__ == "__main__":',
		"    solution = Solution()",
		"",
		string.format("    print(solution.%s())", func_name),
	}

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

return M
