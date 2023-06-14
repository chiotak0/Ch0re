`ifndef CH0RE_DEBUG_PRINTS_SV
`define CH0RE_DEBUG_PRINTS_SV

`define DBP_RST  "\033[0m"
`define DBP_BOLD "\033[1m"
`define DBP_DIM  "\033[2m"
`define DBP_ITAL "\033[3m"
`define DBP_UNDL "\033[4m"

/* FOREGROUND NORMAL */

`define DBP_FRED   "\033[31m"
`define DBP_FGREEN "\033[32m"
`define DBP_FYELL  "\033[33m"
`define DBP_FBLUE  "\033[34m"
`define DBP_FMAGEN "\033[35m"
`define DBP_FCYAN  "\033[36m"
`define DBP_FWHITE "\033[37m"

/* FOREGROUND BRIGHT */

`define DBP_FBRED  "\033[91m"
`define DBP_FBGREE "\033[92m"
`define DBP_FBYELL "\033[93m"

/* BACKGROUND NORMAL */

`define DBP_BRED   "\033[41m"
`define DBP_BGREEN "\033[42m"
`define DBP_BYELL  "\033[43m"
`define DBP_BBLUE  "\033[44m"
`define DBP_BMAGEN "\033[45m"
`define DBP_BCYAN  "\033[46m"
`define DBP_BWHITE "\033[47m"

/* BACKGROUND BRIGHT */

`define DBP_BBRED  "\033[41m"
`define DBP_BBGREE "\033[42m"
`define DBP_BBYELL "\033[43m"

/* PREDEFINED STRINGS */

`define DBP_FAILURE {`DBP_BOLD, `DBP_FRED, "FAILURE", `DBP_RST}
`define DBP_SUCCESS {`DBP_BOLD, `DBP_FGREEN, "SUCCESS", `DBP_RST}
`define DBP_PRINT_CURR(funcname) \
	begin \
		$write({`DBP_FRED, `DBP_BOLD, "[", `DBP_RST, `DBP_UNDL, "%0m", `DBP_RST, \
            `DBP_FYELL, " line ", `DBP_RST, "%0d", `DBP_RST, `DBP_BOLD, \
			`DBP_FRED, "]", `DBP_RST, ": "}, `__LINE__); \
	end

`endif /* CH0RE_DEBUG_PRINTS_SV */
