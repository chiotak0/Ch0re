SHELL:=/bin/bash
.ONESHELL:

.PHONY: all clean simgui simcli

CFLAGS=-debug_access+r -sverilog -kdb -notice -l comp.log

DEBUG?=

ifeq ($(DEBUG), 1)
	CFLAGS+= +define+DEBUG
endif

SIM?=1

ifeq ($(SIM), 1)
	CFLAGS+= +define+SIMULATION
endif


DUT=ch0re_pipeline.sv
TESTBENCH=tb_$(DUT)

PACKAGES=../debug_prints.sv\
	../ch0re_types.sv\
	../instruction/ch0re_instruction.sv

FILELIST=filelist.f

DEPLIST=../memory_models/mem_sync_sp/mem_sync_sp.sv ../memory_models/regfile_2r1w/regfile_2r1w.sv
DEPLIST+=../memory_models/mem_sync_sp_rvdmem/mem_sync_sp_rvdmem.sv
DEPLIST+=decoder/ch0re_idecoder.sv alu/ch0re_alu.sv
DEPLIST+=$(DUT)

#DEPLIST=$(wordlist, 2, $(words $(DEPLIST_)), $(DEPLIST_))


all: simv

simv: $(TESTBENCH) $(PACKAGES) $(DEPLIST)
	@rm -f comp.log || true
	@if [[ -z "$$(command -v vcs)" ]]; then\
		printf "\033[1;31mvcs compiler not found!\033[0m\n";\
		exit 1;\
	fi
	@printf "\033[33mmaking simulation...\033[0m\n"
#
	@vcs $(CFLAGS) $(PACKAGES) $(TESTBENCH) $(DEPLIST) > /dev/null 2>&1
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

