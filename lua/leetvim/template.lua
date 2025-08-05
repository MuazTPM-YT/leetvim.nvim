local M = {}

local language_generators = {}

local function get_language_generator(language)
	if not language_generators[language] then
		local ok, generator = pcall(require, "leetvim.languages." .. language)
		if ok then
			language_generators[language] = generator
		else
			return nil
		end
	end
	return language_generators[language]
end

function M.is_language_supported(language)
	local generator = get_language_generator(language)
	return generator ~= nil
end

function M.generate(language, problem_data)
	local generator = get_language_generator(language)
	if not generator then
		return nil
	end

	local code_snippet = nil
	for _, snippet in ipairs(problem_data.codeSnippets) do
		if generator.matches_language(snippet.langSlug) then
			code_snippet = snippet
			break
		end
	end

	if not code_snippet then
		return string.format("# No %s template available for this problem", language)
	end

	local examples = M.parse_examples(problem_data)
	local template_parts = {}

	local description = generator.generate_description_comment(problem_data)
	if description and description ~= "" then
		table.insert(template_parts, description)
	end

	table.insert(template_parts, code_snippet.code)

	table.insert(template_parts, generator.generate_test_stub(problem_data, examples))

	return table.concat(template_parts, "\n\n")
end

function M.parse_examples(problem_data)
	local examples = {}

	if problem_data.exampleTestcases then
		local test_cases = vim.split(problem_data.exampleTestcases, "\n")
		for i = 1, #test_cases, 2 do
			if test_cases[i] and test_cases[i + 1] then
				table.insert(examples, {
					input = test_cases[i],
					output = test_cases[i + 1],
				})
			end
		end
	end

	return examples
end

return M
