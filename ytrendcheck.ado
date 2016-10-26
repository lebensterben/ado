version 14
capture program drop ytrendcheck
program ytrendcheck
	quietly {
		//Get the number of arguments
		local i = 0
		while "``i''" != "" {
			local ++i
		}
		local --i
		//Locate the year variable and determine the start and end year
		tempname minyear maxyear
		sort ``i''
		sum ``i''
		//local xname = "``i''"
		local xname : variable label ``i''
		scalar `minyear' = r(min)
		scalar `maxyear' = r(max)
		/*
		Get the 95% confidence interval for each element by year
		Temp Variable stores the mean, upbound and lowbound for 95% conf interval
		*/
		local j = 1
		tempvar meconfint upconfint loconfint	
		while `j' < `i' {
			gen `meconfint' = .
			gen `upconfint' = .
			gen `loconfint' = .
			local k = `minyear'
			while `k' <= `maxyear' {
				quietly sum ``j'' if ``i'' == `k'
				//local yname = "``j''"
				local yname : variable label ``j''
				local graphname = "`yname'" + "On" + "`xname'"
				local ytitlename = "95% Conf. Interval of " + "`yname'"
				local mename = "Mean Value of " + "`yname'"
				local upname = "Upper-bound of 95% Conf. Intv"
				local loname = "Lower-bound of 95% Conf. Intv"
				if (r(N) > 0) {
					if (r(sd) != .) {
						replace `meconfint' = r(mean) if ``i''==`k'
						replace `upconfint' = r(mean) + invttail(r(N),0.025)*r(sd)/sqrt(r(N)) if ``i''==`k'
						replace `loconfint' = r(mean) - invttail(r(N),0.025)*r(sd)/sqrt(r(N)) if ``i''==`k'
					}	
					else {
						replace `meconfint' = r(mean) if ``i''==`k'
						replace `upconfint' = r(mean) if ``i''==`k'
						replace `loconfint' = r(mean) if ``i''==`k'
					}
				}
				local ++k
			}
			//Draw the histogram of `j'th argument and store them in memory
			graph twoway ///
			(line `meconfint' ``i'', lwidth(medthick) lcolor("10 40 50")) ///
			(line `upconfint' ``i'', lcolor("208 27 36")) ///
			(line `loconfint' ``i'', lcolor("32 117 199")) ///
			, graphregion(color("253 246 227")) ///
			ytitle("`ytitlename'") ///
			legend (order(1 "`mename'" 2 "`upname'" - ""   3 "`loname'")) ///
			name("`graphname'", replace) ///
			saving("`graphname'", replace)
			graph export "`graphname'.png", replace
			local ++j
			drop `meconfint'
			drop `upconfint'
			drop `loconfint'
		}
	}
end
