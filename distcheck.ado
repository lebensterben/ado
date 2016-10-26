version 14
capture program drop distcheck
program distcheck
	quietly {
		//Get the number of arguments
		local i = 0
		while "``i''" != "" {
			local ++i
		}
		local --i
		//Draw the histogram of `j'th argument and store them in memory
		local j = 1
		while `j' <= `i' {
			histogram ``j'', name(distcheck`j', replace)
			local ++j
		}
	}
end
