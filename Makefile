SHELL:=/bin/bash
.ONESHELL:

.PHONY: all clean

CFLAGS=-debug_access+r -sverilog -kdb -l comp.log
DEPLIST=pipeline


all: simv

simv: $(DEPLIST)
	@rm -f comp.log || true
	@if [[ -z "$$(command -v vcs)" ]]; then\
		printf "\033[1;31mvcs compiler not found!\033[0m\n";\
		exit 1;\
	fi
	@printf "\033[33mmaking simulation...\033[0m\n"
#
	@vcs $(CFLAGS) $< > /dev/null 2>&1
#	
	@if [[ $$? -eq 0 ]]; then\
		printf "\033[1;32mSUCCESS\033[0m\n";\
	else\
		printf "\033[1;31mFAILURE\033[0m\n";\
		printf "\033[33mopening compiler logs...\033[0m\n";\
		less comp.log
	fi

cntrlr: cntrl

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
