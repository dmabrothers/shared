#!/usr/bin/env lua

local lfs = require "lfs"
local pretty = require "pl.pretty"
local file = require "pl.file"
local json = require "JSON"

local suri = {}

for dir in lfs.dir("koran_na_russkom") do
	if dir ~= ".." and dir ~= "." then
		--print(type(dir), dir)
		local suri_n, suri_name = assert(string.match(dir,
				"^suri%-(%d+)%-(.+)%.html$"))
		suri_n = assert(tonumber(suri_n))
		--print("suri:", suri_n, suri_name)
		local data = file.read("koran_na_russkom/"..dir)
		local fullname = assert(string.match(data, "<title>([^<]+)</title>"))
		local ayaty = {}
		for ayat in string.gmatch(data, "<p>([^<]+)</p>") do
			local ayat_t = {}
			local ayatno, ayattext = string.match(ayat, "^(%d+)%.%s(.+)$")
			if ayatno then
				ayat_t.number = ayatno
				ayat_t.text = ayattext
			else
				if #ayaty == 0 then
					ayat_t.text = ayat
				else
					error("unexpected ayat without number")
				end
			end
			table.insert(ayaty, ayat_t)
		end
		suri[suri_n] = {
			number = suri_n,
			shortlatname = suri_name,
			filename = dir,
			fullrusname = fullname,
			ayaty = ayaty,
		}
	end
end

--print(pretty.write(suri))
local suri_json = json:encode(suri)
local suri = json:decode(suri_json)
print(suri_json)

