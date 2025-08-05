if vim.g.loaded_leetcode_template == 1 then
	return
end
vim.g.loaded_leetcode_template = 1

vim.api.nvim_create_user_command("LeetvimTemplate", function(opts)
	local args = vim.split(opts.args, "%s+")
	if #args < 2 then
		vim.notify("Usage: :LeetvimTemplate <language> <problem_number>", vim.log.levels.ERROR)
		return
	end

	local language = string.lower(args[1])
	local problem_number = tonumber(args[2])

	if not problem_number then
		vim.notify("Problem number must be a valid integer", vim.log.levels.ERROR)
		return
	end

	require("leetvim").fetch_template(language, problem_number)
end, {
	nargs = "*",
	complete = function()
		return { "python" }
	end,
	desc = "Fetch LeetCode problem template",
})

vim.api.nvim_create_user_command("LeetvimAuth", function()
	require("leetvim").setup_auth()
end, { desc = "Setup Leetcode authentication" })
