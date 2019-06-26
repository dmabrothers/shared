local cont = {
	q = function()
		local term = require "term_mode"
		term.reset_mode()
		os.exit()
	end,

	dummy = function(curdir, args)
		print(string.format(
			">>> dummy action >>>\ncurrent_dir: %s\nargs: %s", curdir, args))
	end,

	bookmark = function(curdir, args)

		local pl_dir = require "pl.dir"

		if args == "" or not args then
			print('Bookmark current directory '
				..'into xquicklaunch\'s "locations" directory. '
				..'\nusage: bookmark <bookmark_name>')
			return false
		end

		local home_path = assert(os.getenv("HOME"))
		local locations_path = home_path.."/.xquicklaunch2/locations"
		pl_dir.makepath(locations_path)

		local fd, descr = io.open(locations_path.."/"..args..".sh", "w")
		if not fd then
			print("Cannot create bookmark file:", descr)
			return false
		end

		fd:write(string.format("#!/bin/bash\nIFS='\n'\n\nnohup rox \"%s\" &\n", curdir))
		fd:close()

		print(string.format("Bookmark \"%s\" pointed to \"%s\" created.", args, curdir))

		return true
	end,
}

-- Aliases
cont.b = cont.bookmark

return cont
