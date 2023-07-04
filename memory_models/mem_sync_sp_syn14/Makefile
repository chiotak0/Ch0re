all: clean comp run

clean:
	\rm -rf csrc simv* *.log *.vcd *.key

comp:
	vcs -sverilog mem_sync_sp_syn.sv mem_tb.sv saed14sram.v -l comp.log

run:
	./simv -l run.log

