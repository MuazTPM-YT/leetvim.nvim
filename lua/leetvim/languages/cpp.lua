local M = {}

function M.matches_language(lang_slug)
	return lang_slug == "cpp" or lang_slug == "c++"
end

function M.generate_description_comment(problem_data)
	return ""
end

function M.generate_test_stub(problem_data, examples)
	local func_name = M.extract_function_name(problem_data.codeSnippets)

	local lines = {
		"#include <iostream>",
		"using namespace std;",
		"",
		"int main() {",
		"    Solution solution;",
		"",
		string.format("    cout << solution.%s() << endl;", func_name),
		"",
		"    return 0;",
		"}",
	}

	return table.concat(lines, "\n")
end

function M.extract_function_name(code_snippets)
	for _, snippet in ipairs(code_snippets) do
		if M.matches_language(snippet.langSlug) then
			local func_name = snippet.code:match("%w+%s+([%w_]+)%s*%(")
			if func_name and func_name ~= "class" then
				return func_name
			end
		end
	end
	return "solutionMethod"
end

return M
