all: clean comp run

clean:
	\rm -rf csrc simv* *.log *.vcd *.key

comp:
	vcs -sverilog regfile_2r1w.sv rf_tb.sv -l comp.log

run:
	./simv -l run.log

