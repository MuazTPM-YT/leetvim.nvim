local M = {}

function M.matches_language(lang_slug)
	return lang_slug == "javascript"
end

function M.generate_description_comment(problem_data)
	return ""
end

function M.generate_test_stub(problem_data, examples)
	local func_name = M.extract_function_name(problem_data.codeSnippets)

	local lines = {
		"// Test the solution",
		string.format("console.log(%s());", func_name),
	}

	return table.concat(lines, "\n")
end

function M.extract_function_name(code_snippets)
	for _, snippet in ipairs(code_snippets) do
		if M.matches_language(snippet.langSlug) then
			local func_name = snippet.code:match("var%s+([%w_]+)%s*=%s*function")
				or snippet.code:match("function%s+([%w_]+)%s*%(")
				or snippet.code:match("const%s+([%w_]+)%s*=%s*function")
				or snippet.code:match("let%s+([%w_]+)%s*=%s*function")
			if func_name then
				return func_name
			end
		end
	end
	return "solutionFunction"
end

return M
