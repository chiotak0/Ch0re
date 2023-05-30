all: clean comp run

clean:
	\rm -rf csrc simv* *.log *.vcd *.key

comp:
	vcs -sverilog mem_sync_sp_rvdmem.sv mem_tb.sv -l comp.log

run:
	./simv -l run.log

