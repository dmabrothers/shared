-- Modules
local term_mode = require "term_mode"
local pl = {}
pl.dir = require "pl.dir"
pl.file = require "pl.file"
pl.path = require "pl.path"
local lfs = require "lfs"
local unix = require "unix"
local extended_commands = require "extended_commands"
local sctl = require "shortcontrol"



-- Settings
local home_dir = assert(os.getenv("HOME"))
local config_dir = home_dir .. "/.xquicklaunch3"

local current_dir = config_dir
local current_list = {}
local current_list_rev = {}
local file_type = {}
local full_path = {}
local running_on_x = false



-- Subroutines
local get_char_from_terminal = sctl.getchar

local function update_rev_list()
	current_list_rev = {}
	for i, v in pairs(current_list) do
		current_list_rev[v] = i
	end
end

local function fill_list()

	local dirlist = pl.dir.getdirectories(current_dir)
	local filelist = pl.dir.getfiles(current_dir)

	current_list = {}
	file_type = {}
	full_path = {}

	for i, v in pairs(dirlist) do
		table.insert(current_list, pl.path.basename(v))
		full_path[pl.path.basename(v)] = v
		file_type[v] = "directory"
	end

	for i, v in pairs(filelist) do
		table.insert(current_list, pl.path.basename(v))
		full_path[pl.path.basename(v)] = v
		file_type[v] = "file"
	end

	table.sort(current_list, function(a, b)
		local afull = full_path[a]
		local bfull = full_path[b]
		if file_type[afull] == "directory" and file_type[bfull] ~= "directory" then
			return true
		end
		if file_type[afull] ~= "directory" and file_type[bfull] == "directory" then
			return false
		end
		return afull < bfull
	end)

	update_rev_list()
end

local function filter_list(filterstr)

	local new_cur_list = {}

	for i, v in pairs(current_list) do
		if string.find(pl.path.basename(v), filterstr, 1, true) then
			table.insert(new_cur_list, v)
		end
	end

	current_list = new_cur_list

	update_rev_list()
end

local function print_list()

	os.execute("clear")

	print(string.format("\r-- %s --", current_dir))

	for i, v in pairs(current_list) do

		if file_type[full_path[v]] == "directory" then
			suffix = ">"
		else
			suffix = ""
		end
		print(v..suffix)
	end
end

local function print_list_to_less()

	os.execute("clear")

	local fd = assert(io.popen("less", "w"))

	fd:write(string.format("-- %s --\n", current_dir))

	for i, v in pairs(current_list) do

		if file_type[full_path[v]] == "directory" then
			suffix = ">\n"
		else
			suffix = "\n"
		end
		fd:write(v..suffix)
	end

	fd:close()
end

local read_line = sctl.readline

local function start_new(cmd, ...)

	local pid = unix.fork()

	if pid == 0 then

		io.stdin:close()
		io.stdout:close()
		io.stderr:close()

		--local st = os.execute(string.format("bash -c "
		--	.."' { nohup \"%s\" </dev/null"
		--	.." >/dev/null 2>/dev/null & }; exit'", cmd))
		--os.exit(st)
		
		unix.execlp("setsid", "setsid", cmd, ...)
	else
		-- Do nothing
	end

	return true
end



-- main loop

assert(pl.dir.makepath(config_dir))

if os.getenv("DISPLAY") then
	running_on_x = true
end

fill_list()

local key_overrides = {

	["\27"] = function()
		os.exit()
	end,

	["#"] = function()
		if running_on_x then
			start_new("rox", current_dir)
		else
			os.execute(string.format("mc \"%s\"", current_dir))
		end
	end,

	-- Open terminal in current directory
	["$"] = function()
		if running_on_x then

			local term_cmd = "xterm"
				.." -bg black"
				.." -fg darkgray"
				.." -fn '-*-terminus-medium-*-*-*-14-*-*-*-*-*-iso10646-*'"

			start_new("bash", "-c",  string.format("cd \"%s\" && %s",
						current_dir, term_cmd))
		else
			os.execute(string.format("bash -c 'cd \"%s\" && bash'", current_dir))
		end
	end,

	["`"] = function()
		--print(current_dir, "-->")
		current_dir = pl.path.dirname(current_dir)
		if current_dir == "" then
			current_dir = "/"
		end

		--print(current_dir)
		fill_list()
	end,


	["/"] = function()
		io.write("/")

		local cmd_line = sctl.readline()

		filter_list(cmd_line)
	end,

	["@"] = function()
		fill_list()
	end,

	["!"] = function(list, cmdline, char)
		print_list_to_less()
		return true, cmdline

	end,

	["\t"] = function(list, cmdline, char)
		
		local found = {}
		local updatedcmdline = cmdline

		for i, v in pairs(list) do
			if string.sub(v, 1, #cmdline) == cmdline then
				table.insert(found, v)
			end
		end

		repeat
			local guesschar = string.sub(found[1], #updatedcmdline+1,
					#updatedcmdline+1)

			if guesschar == "" then
				return true, updatedcmdline
			end

			local hits = 0
			for i, v in pairs(found) do
				if string.sub(v, 1, #updatedcmdline+1) ==
					updatedcmdline..guesschar then
					hits = hits + 1
				end
			end

			if hits == #found then
				updatedcmdline = updatedcmdline..guesschar
			end

		until hits ~= #found

		return true, updatedcmdline
	end,

	["\n"] = function(list, cmdline, char)
		
		if #list == 1 then
			return false, list[1]
		end

		local hits = 0

		for i, v in pairs(list) do
			if v == cmdline then
				return false, cmdline
			end
		end

		return true, cmdline
	end,
}

while true do

	--os.execute("sleep 1s")

	print_list()

	-- Wait for input
	local selected = sctl.readseq(current_list, nil, key_overrides)

	if selected then
		local true_offset = current_list_rev[selected]
		local name = full_path[selected]
		if current_list[true_offset] then

			-- Directory
			if file_type[name] == "directory" then

				if string.match(name, "%.dir$") then
				    	if running_on_x then
						start_new("rox", name)
					else
						os.execute(string.format("mc \"%s\"", name))
					end
				else
					current_dir = name
					fill_list()
				end

			-- File
			else
				if string.match(name, "%.sh$") then

					--os.execute("bash \""..name.."\"")
					term_mode.reset_mode()
					os.execute(string.format(
						"bash -c 'cd \"%s\" && bash \"%s\"'",
							current_dir, name))
					term_mode.set_mode_to_raw()

				elseif string.match(name, "%.xapp$")
				    or string.match(name, "%.app$") then
					
				    	if running_on_x then
						start_new(name)
					else
						os.execute(name)
						print("Press any key...")
						get_char_from_terminal()
					end

				elseif string.match(name, "%.dir$") then
				    	if running_on_x then
						start_new("rox", name)
					else
						os.execute(string.format("mc \"%s\"", name))
					end

				-- Graphics image
				elseif string.match(string.lower(name), "%.jpg$")
				    or string.match(string.lower(name), "%.jpeg$")
				    or string.match(string.lower(name), "%.png$")
				    or string.match(string.lower(name), "%.gif$")
				    or string.match(string.lower(name), "%.bmp$")
				then
				    	if running_on_x then
						start_new("eom", name)
					else
						os.execute(string.format("fbi \"%s\"", name))
					end

				-- Audio file
				elseif string.match(string.lower(name), "%.flac$")
				    or string.match(string.lower(name), "%.wav$")
				    or string.match(string.lower(name), "%.mp3$")
				    or string.match(string.lower(name), "%.ogg$")
				    or string.match(string.lower(name), "%.wma$")
				then
				    	if running_on_x then
						start_new("vlc", name)
					else
						os.execute(string.format("mpg123 \"%s\"", name))
					end
					

				-- Video file
				elseif string.match(string.lower(name), "%.avi$")
				    or string.match(string.lower(name), "%.mkv$")
				    or string.match(string.lower(name), "%.mpg$")
				    or string.match(string.lower(name), "%.mp4$")
				    or string.match(string.lower(name), "%.ogm$")
				    or string.match(string.lower(name), "%.flv$")
				    or string.match(string.lower(name), "%.webm$")
				then	
				    	if running_on_x then
						start_new("mplayer", "-gui", name)
					else
						--term_mode.reset_mode()
						os.execute(string.format(
						"mplayer -zoom -xy 1680"
						.." -vo fbdev2 \"%s\""
						.." >/dev/null"
						.." 2>/dev/null", name))
						--term_mode.set_mode_to_raw()
					end

				-- HTML page
				elseif string.match(string.lower(name), "%.html$")
				    or string.match(string.lower(name), "%.htm$") then
				    	if running_on_x then
						start_new("seamonkey", name)
					else
						os.execute(string.format("vim \"%s\"", name))
					end

				-- Electronic book
				elseif string.match(string.lower(name), "%.pdf$")
				    or string.match(string.lower(name), "%.djvu$")
				    or string.match(string.lower(name), "%.djv$") then
				    	if running_on_x then
						start_new("okular", name)
					else
						os.execute(string.format("vim \"%s\"", name))
					end

				-- Default behaviour when open unknown type of file
				else
					os.execute("vim \""..name.."\"")
				end
			end
		end
	end

	-- DEBUG
	--print("#SEL", selected)

	if cmd_char == "\8"
	or cmd_char == "\27"
	or cmd_char == "`" then
		--print(current_dir, "-->")
		current_dir = pl.path.dirname(current_dir)
		if current_dir == "" then
			current_dir = "/"
		end

		--print(current_dir)
		fill_list()
	end

	-- Page navigation
	if cmd_char == "X" then
		if current_list[current_offset + #keys + 1] then
			current_offset = current_offset + #keys
		end
	end
	if cmd_char == "Z" then
		if current_list[current_offset - #keys + 1] then
			current_offset = current_offset - #keys
		end
	end

	-- Extended commands
	if cmd_char == ":" then

		io.write(":")

		local cmd_line = read_line()

		print()

		cmd_name, cmd_args = string.match(cmd_line, "^([_%a%.%d]+)%s*(.*)")

		if cmd_name and extended_commands[cmd_name] then
			extended_commands[cmd_name](current_dir, cmd_args)
		end

		print("Press any key...")
		get_char_from_terminal()
	end
	if cmd_char == "!" then

		io.write("bash$ ")

		local cmd_line = read_line()

		print()

		os.execute(string.format("cd \"%s\" && bash -c '%s'", current_dir, cmd_line))

		print("Press any key...")
		get_char_from_terminal()
	end
	if cmd_char == "/" then

		io.write("/")

		local cmd_line = read_line()

		filter_list(cmd_line)
	end

	-- Refresh list
	if cmd_char == "r" then
		fill_list()
	end

	-- To script's config directory
	if cmd_char == "~" then
		current_dir = config_dir
		fill_list()
	end

	-- Open current directory in file browser
	if cmd_char == "#" then
		if running_on_x then
			start_new("rox", current_dir)
		else
			os.execute(string.format("mc \"%s\"", current_dir))
		end
	end

	-- Open terminal in current directory
	if cmd_char == "$" then
		if running_on_x then

			local term_cmd = "xterm"
				.." -bg black"
				.." -fg darkgray"
				.." -fn '-*-terminus-medium-*-*-*-14-*-*-*-*-*-iso10646-*'"

			start_new("bash", "-c",  string.format("cd \"%s\" && %s", current_dir, term_cmd))
		else

			term_mode.reset_mode()
			os.execute(string.format("bash -c 'cd \"%s\" && bash'", current_dir))
			term_mode.set_mode_to_raw()
		end
	end

	-- Handle request
	if cmd_char == "q" then
		break
	end
end

