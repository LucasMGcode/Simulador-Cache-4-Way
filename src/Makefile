SIM ?= cache4_sim
TOP ?= tb_cache4.v

.PHONY: sim clean

sim:
	iverilog -g2012 -o $(SIM) $(TOP)
	vvp $(SIM)

clean:
	rm -f $(SIM) *.vcd *.data *.txt
