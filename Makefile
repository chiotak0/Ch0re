SHELL:=/bin/bash
.ONESHELL:

.PHONY: all clean simgui simcli

FILELIST=filelist.f
CFLAGS=-debug_access+r -sverilog -kdb -notice -l comp.log
TESTBENCH=pipeline/tb_pipeline_5st.sv
PACKAGES=ch0re_types_pkg.sv
DEPLIST=types.sv memory_models/mem_sync_sp/mem_sync_sp.sv memory_models/regfile_2r1w/regfile_2r1w.sv
DEPLIST+=pipeline/pipeline_5st.sv

#DEPLIST=$(wordlist, 2, $(words $(DEPLIST_)), $(DEPLIST_))


all: simv

simv: $(TESTBENCH) $(DEPLIST)
	@rm -f comp.log || true
	@if [[ -z "$$(command -v vcs)" ]]; then\
		printf "\033[1;31mvcs compiler not found!\033[0m\n";\
		exit 1;\
	fi
	@printf "\033[33mmaking simulation...\033[0m\n"
#
	@vcs -f $(FILELIST) $(CFLAGS) $(PACKAGES) $(TESTBENCH) $(DEPLIST) > /dev/null 2>&1
#	
	@if [[ $$? -eq 0 ]]; then\
		printf "\033[1;32mSUCCESS\033[0m\n";\
	else\
		printf "\033[1;31mFAILURE\033[0m\n";\
		printf "\033[33mopening compiler logs...\033[0m\n";\
		less comp.log
	fi

simgui: simv
	./simv -gui

simcli: simv
	./simv -l sim.log

clean:
	@printf "\033[33mcleaning...\033[0m\n"
	@rm -f comp.log || true
	@rm -f inter.fsdb || true
	@rm -f novas* || true
	@rm -f sim.log || true
	@rm -f ucli.key || true
	@rm -rf verdi* || true
	@rm -rf simv* || true
	@rm -rf csrc/ || true

