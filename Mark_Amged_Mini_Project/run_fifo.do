vlib work
vlog -f src_files.list -mfcu +define+SIM +cover
vsim -voptargs=+acc work.FIFO_top -coverage
add wave -r /FIFO_top/fifo_if/*
coverage save -onexit FIFO_top.ucdb
run -all