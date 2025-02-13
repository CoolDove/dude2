local M={}

function M._begin()
	vim.api.nvim_create_user_command('DudeEvalV', function(opts)
		if opts.range > 0 then
			-- 获取选中的内容
			local start_pos = vim.api.nvim_buf_get_mark(0, '<')  -- 获取可视模式起始位置
			local end_pos = vim.api.nvim_buf_get_mark(0, '>')    -- 获取可视模式结束位置
			local lines = vim.api.nvim_buf_get_lines(0, start_pos[1] - 1, end_pos[1], false)  -- 获取选中的行
			-- 将内容写入文件
			vim.fn.writefile(lines, vim.fn.expand('~tmpcmd'))
			vim.cmd(":silent !dude2 eval-file ~tmpcmd")
			vim.cmd(":silent !rm ~tmpcmd")
			vim.cmd("normal! gv")
			print("Eval!")
		end
	end, { nargs = 0, range = true })
	vim.api.nvim_create_user_command('DudeEval', function(opts)
		local input = vim.fn.input("Eval: ")
		if input ~= "" then
			vim.fn.writefile({input}, "~tmpcmd")
			vim.cmd(":silent !dude2 eval-file ~tmpcmd")
			vim.cmd(":silent !rm ~tmpcmd")
		end
	end, { nargs = 0 })
	vim.cmd(':vmap <C-Enter> :DudeEvalV<CR>')
	vim.cmd(':nmap <C-Enter> :DudeEval<CR>')
end

function M._end()

end

return M

