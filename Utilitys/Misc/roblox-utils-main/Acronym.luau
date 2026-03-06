local pattern = "([%w]+)([%p]*)"

return function(input: string): string
	local acronym = table.create(#input)
	
	for word, punctuation in string.gmatch(input, pattern) do
		table.insert(acronym, string.sub(word, 1, 1) .. punctuation)
	end

	return table.concat(acronym)
end