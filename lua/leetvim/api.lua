local config = require("leetvim.config")

local M = {}

local PROBLEM_QUERY = [[
query getQuestionDetail($titleSlug: String!) {
  question(titleSlug: $titleSlug) {
    questionId
    questionFrontendId
    title
    titleSlug
    content
    difficulty
    codeSnippets {
      lang
      langSlug
      code
    }
    sampleTestCase
    exampleTestcases
    metaData
  }
}
]]

local PROBLEM_BY_ID_QUERY = [[
query problemsetQuestionList($categorySlug: String, $limit: Int, $skip: Int, $filters: QuestionListFilterInput) {
  problemsetQuestionList: questionList(
    categorySlug: $categorySlug
    limit: $limit
    skip: $skip
    filters: $filters
  ) {
    questions: data {
      frontendQuestionId: questionFrontendId
      title
      titleSlug
      difficulty
      status
    }
  }
}
]]

function M.get_problem_slug_by_number(problem_number, callback)
	local variables = {
		categorySlug = "",
		skip = problem_number - 1,
		limit = 1,
		filters = {
			orderBy = "FRONTEND_ID",
			sortOrder = "ASCENDING",
		},
	}

	M.make_graphql_request(PROBLEM_BY_ID_QUERY, variables, function(data, err)
		if err then
			callback(nil, err)
			return
		end

		if
			not data.problemsetQuestionList
			or not data.problemsetQuestionList.questions
			or #data.problemsetQuestionList.questions == 0
		then
			callback(nil, "Problem not found")
			return
		end

		local question = data.problemsetQuestionList.questions[1]
		if tonumber(question.frontendQuestionId) ~= problem_number then
			callback(nil, "Problem number mismatch")
			return
		end

		callback(question.titleSlug, nil)
	end)
end

function M.get_problem_by_number(problem_number, callback)
	M.get_problem_slug_by_number(problem_number, function(title_slug, err)
		if err then
			callback(nil, err)
			return
		end

		local variables = { titleSlug = title_slug }
		M.make_graphql_request(PROBLEM_QUERY, variables, function(data, query_err)
			if query_err then
				callback(nil, query_err)
				return
			end

			if not data.question then
				callback(nil, "Question data not found")
				return
			end

			callback(data.question, nil)
		end)
	end)
end

function M.make_graphql_request(query, variables, callback)
	local conf = config.get()
	local url = conf.leetcode_url .. "/graphql/"

	local cookie = config.get_cookie()
	if not cookie then
		callback(nil, "No authentication cookie found. Please run :LeetvimAuth first.")
		return
	end

	local headers = {
		"Content-Type: application/json",
		"User-Agent: " .. conf.user_agent,
		"Referer: " .. conf.leetcode_url .. "/",
		"Cookie: " .. cookie,
	}

	local payload = vim.json.encode({
		query = query,
		variables = variables,
	})

	local curl_cmd = {
		"curl",
		"-s",
		"-X",
		"POST",
		url,
	}

	for _, header in ipairs(headers) do
		table.insert(curl_cmd, "-H")
		table.insert(curl_cmd, header)
	end

	table.insert(curl_cmd, "-d")
	table.insert(curl_cmd, payload)

	vim.fn.jobstart(curl_cmd, {
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = function(_, data)
			local response = table.concat(data, "\n")
			if response == "" then
				callback(nil, "Empty response from LeetCode")
				return
			end

			local ok, parsed = pcall(vim.json.decode, response)
			if not ok then
				callback(nil, "Failed to parse JSON response: " .. parsed)
				return
			end

			if parsed.errors then
				local error_msg = "GraphQL errors: "
				for _, error in ipairs(parsed.errors) do
					error_msg = error_msg .. error.message .. "; "
				end
				callback(nil, error_msg)
				return
			end

			if not parsed.data then
				callback(nil, "No data in response. Check your authentication cookie.")
				return
			end

			callback(parsed.data, nil)
		end,
		on_stderr = function(_, data)
			local error_msg = table.concat(data, "\n")
			if error_msg ~= "" then
				callback(nil, "Request failed: " .. error_msg)
			end
		end,
		on_exit = function(_, exit_code)
			if exit_code ~= 0 then
				callback(nil, "Request failed with exit code: " .. exit_code)
			end
		end,
	})
end

return M
