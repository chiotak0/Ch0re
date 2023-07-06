.PHONY: comp clean

comp:
	dc_shell -f scripts/compile.tcl 2>&1 | tee check.log

clean:
	rm -f *.pvl *.syn *.svf *.v *.log *.mr
