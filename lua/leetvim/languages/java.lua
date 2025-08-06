local M = {}

function M.matches_language(lang_slug)
	return lang_slug == "java"
end

function M.generate_description_comment(problem_data)
	return ""
end

function M.generate_test_stub(problem_data, examples)
	local func_name = M.extract_function_name(problem_data.codeSnippets)
	local class_name = M.extract_class_name(problem_data.codeSnippets)
	local lines = {
		"public class Main {",
		"    public static void main(String[] args) {",
		string.format("        %s solution = new %s();", class_name, class_name),
		"",
		string.format("        System.out.println(solution.%s());", func_name),
		"    }",
		"}",
	}
	return table.concat(lines, "\n")
end

function M.extract_function_name(code_snippets)
	for _, snippet in ipairs(code_snippets) do
		if M.matches_language(snippet.langSlug) then
			local func_name = snippet.code:match("public%s+%w+%s+([%w_]+)%s*%(")
			if func_name then
				return func_name
			end
		end
	end
	return "solutionMethod"
end

function M.extract_class_name(code_snippets)
	for _, snippet in ipairs(code_snippets) do
		if M.matches_language(snippet.langSlug) then
			local class_name = snippet.code:match("class%s+([%w_]+)")
			if class_name then
				return class_name
			end
		end
	end
	return "Solution"
end

return M
