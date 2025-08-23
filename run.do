vlib work
vlog UART_TX.v UART_RX.v UART_TOP.v Synchronizer.v test_bench.v
vsim -voptargs=+acc work.test_bench
add wave *
run -all
#quit -sim


