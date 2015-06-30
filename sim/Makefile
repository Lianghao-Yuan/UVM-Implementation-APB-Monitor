# You may change these configuration to fit your need
UVM_VERBOSITY = UVM_HIGH
# --------------------------------------------------
#  YOU HAVE TO MODIFY THIS PATH BELOW
#  -------------------------------------------------
UVM_HOME = /nethome/lyuan39/uvm-1.2

# Files declaration
SRC_FILES = ../apb_monitor/apb_monitor_pkg.sv \
            ../apb_monitor/apb_if.sv \
            ../apb_monitor/apb_monitor_assert_if.sv \
            ../testbench/apb_monitor_tb.sv

# Directory declaration
CHECKER_PKG_DIR = +incdir+../apb_monitor
CHECKER_TB_DIR = +incdir+../testbench

# Testname 
UVM_TESTNAME = apb_monitor_test

# VCS related commands (my computer is 64 bits OS, that's why I put '-full64' there)
VCS = vcs
VCS_OPTS = -sverilog -timescale=1ns/1ns +acc +vpi -full64
UVM_OPTS = +incdir+$(UVM_HOME)/src \
                   $(UVM_HOME)/src/uvm.sv \
                   $(UVM_HOME)/src/dpi/uvm_dpi.cc -CFLAGS -DVCS
DEBUG_OPTS = cm line -debug_all

INCDIRS = $(CHECKER_PKG_DIR) \
         $(CHECKER_TB_DIR)

             

.PHONY: vcs_std run_test vcs_urg clean


all: vcs_std run_test vcs_urg

vcs_std:
	$(VCS) $(VCS_OPTS) $(UVM_OPTS) $(INCDIRS) $(SRC_FILES)

run_test:
	./simv +UVM_TESTNAME=$(UVM_TESTNAME) +UVM_VERBOSITY=$(UVM_VERBOSITY)

vcs_urg:
	urg -dir simv.vdb

clean:
	rm -rf *~ core csrc simv* vc_hdrs.h ucli.key urg* *.log


