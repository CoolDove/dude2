local M={}

function M._begin()
	vim.api.nvim_create_user_command('DudeEvalV', function(opts)
		if opts.range > 0 then
			vim.cmd(":'<,'>w! "..vim.fn.getenv('LOCALAPPDATA')..'\\dude\\game.pipefile')
		end
	end, { nargs = 0, range = true })
	vim.cmd(':vmap <F2> :DudeEvalV<CR>gv')
end

function M._end()

end

return M

