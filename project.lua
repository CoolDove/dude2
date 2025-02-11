local M={}

function M._begin()
	vim.api.nvim_create_user_command('DudeEvalV', function(opts)
		if opts.range > 0 then
			vim.cmd(":'<,'>w! "..'~tmpcmd')
			vim.cmd(":!dude2 eval-file ~tmpcmd")
			vim.cmd(":!rm ~tmpcmd")
			vim.cmd("normal! gv")
		end
	end, { nargs = 0, range = true })
	vim.api.nvim_create_user_command('DudeEval', function(opts)
		local input = vim.fn.input("Eval: ")
		if input ~= "" then
			vim.fn.writefile({input}, "~tmpcmd")
			vim.cmd(":!dude2 eval-file ~tmpcmd")
			vim.cmd(":!rm ~tmpcmd")
		end
	end, { nargs = 0 })
	vim.cmd(':vmap <F5> :DudeEvalV<CR>')
	vim.cmd(':nmap <C-F5> :DudeEval<CR>')
	vim.cmd(':vmap <C-F5> :DudeEval<CR>')
end

function M._end()

end

return M

