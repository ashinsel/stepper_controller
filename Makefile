# Project name
PROJECT=stepper_controller

# VHDL files
FILES= src/stepper_controller.vhdl

# Testbench files
SIMTOP = stepper_controller
SIMFILES= testbench/stepper_controller_tb.vhdtst

# Simulation break condition
GHDL_SIM_OPT = --assert-level=error --stop-time=500ns

SIMDIR = sim

GHDL_CMD	= ghdl
GHDL_FLAGS	= --ieee=synopsys --warn-no-vital-generic

VIEW_CMD	= /usr/bin/gtkwave

compile:
	mkdir -p $(SIMDIR)
	$(GHDL_CMD) -i $(GHDL_FLAGS) --workdir=$(SIMDIR) --work=work $(SIMFILES) $(FILES)
	$(GHDL_CMD) -m $(GHDL_FLAGS) --workdir=$(SIMDIR) --work=work $(SIMTOP)
	@mv $(SIMTOP) $(SIMDIR)/$(SIMTOP)
 
sim: compile
	@$(SIMDIR)/$(SIMTOP) $(GHDL_SIM_OPT) --vcdgz=$(SIMDIR)/$(SIMTOP).vcdgz

view: sim
	gunzip --stdout $(SIMDIR)/$(SIMTOP).vcdgz | $(VIEW_CMD) --vcdgz
	
clean:
	$(GHDL_CMD) --clean --workdir=$(SIMDIR)
	
	