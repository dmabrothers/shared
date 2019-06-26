local term_mode = require "term_mode"

local function get_char()

	term_mode.set_mode_to_raw()

	local cmd_char = io.stdin:read(1)

	--if not string.match(cmd_char, "[%a%d%p%s]") then
	--	cmd_char = cmd_char .. io.stdin:read(1)
	--end

	term_mode.reset_mode()

	return cmd_char
end

local function read_line(delim)

	local cmd_line = ""

	if not delim then
		delim = "\n"
	end

	repeat
		local char = get_char()
		if char ~= delim then
			if char == "\8" then
				cmd_line = string.sub(cmd_line, 1, -2)
				io.write(char)
			else
				cmd_line = cmd_line .. char
				io.write(char)
			end
		end
	until char == delim

	return cmd_line
end

local function read_sequence(seqlist, echofunc, key_overrides)

	if type(seqlist) ~= "table" then
		return nil, "seqlist not a table (arg #1)"
	end

	if key_overrides and (type(key_overrides) ~= "table") then
		return nil, "key_overrides not a table (arg #3)"
	end

	if not key_overrides then
		key_overrides = {}
	end

	local function defaultecho(str, foundlist)
		io.write("\r", str)
	end

	local cmd_line = ""
	local found = {}

	repeat
		local char = get_char()

		if char == "\8" then
			cmd_line = string.sub(cmd_line, 1, -2)
		else
			if key_overrides[char] then
				local ret = {key_overrides[char](seqlist, cmd_line, char)}
				if not ret[1] then
					table.remove(ret, 1)
					return unpack(ret)
				else
					cmd_line = ret[2]
				end
			else
				cmd_line = cmd_line .. char
			end
		end

		found = {}

		for i, v in pairs(seqlist) do

			cmpline = string.sub(v, 1, #cmd_line)

			--print("#D", cmpline, cmd_line)

			if cmpline == cmd_line then
				table.insert(found, v)
			end
		end

		if echofunc then
			echofunc(cmd_line, found)
		else
			defaultecho(cmd_line, found)
		end

	until #found <= 1

	if #found == 1 then
		return found[1]
	else
		return false, "not found"
	end
end

return {
	getchar = get_char,
	readline = read_line,
	readseq = read_sequence,
}

