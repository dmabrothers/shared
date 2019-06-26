#!/usr/bin/lua

local sctl = require "shortcontrol"

print("Press any key:")
print("You pressed", sctl.getchar())

print("Start typing either sequence 'gg' or 'gcava':")
print("\rYour sequence is", sctl.readseq({"gg", "gcava"}) or "other")

local seqecho = function(got, list)
	print(string.rep("-", 30))
	print("got:", got)
	print("variants:")
	for i, v in pairs(list) do
		print("  "..v)
	end
	print(string.rep("-", 30))
end

print("Start typing either sequence 'gg' or 'gcava':")
print("\rYour sequence is", sctl.readseq({"gg", "gcava"}, seqecho) or "other")

