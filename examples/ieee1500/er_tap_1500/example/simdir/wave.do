onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/i_clk_if/clk
add wave -noupdate /top/i_clk_if/nreset
add wave -noupdate -expand -group TAP_1500 /top/i_er_tap_1500_if/WRCK
add wave -noupdate -expand -group TAP_1500 /top/i_er_tap_1500_if/SelectWIR
add wave -noupdate -expand -group TAP_1500 /top/i_er_tap_1500_if/ShiftWR
add wave -noupdate -expand -group TAP_1500 /top/i_er_tap_1500_if/WRSTN
add wave -noupdate -expand -group TAP_1500 /top/i_er_tap_1500_if/WSI
add wave -noupdate -expand -group TAP_1500 /top/i_er_tap_1500_if/WSO
add wave -noupdate -expand -group TAP_1500 /top/i_er_tap_1500_if/CaptureWR
add wave -noupdate -expand -group TAP_1500 /top/i_er_tap_1500_if/UpdateWR
add wave -noupdate -expand -group TAP_1500 /top/i_er_tap_1500_if/TransferDR
add wave -noupdate -expand -group IR /top/DUT/instruction
add wave -noupdate -expand -group IR /top/DUT/dbg_instruction
add wave -noupdate /uvm_root/uvm_test_top/m_env/m_tap_1500_agent/m_driver/driver_items
add wave -noupdate /uvm_root/uvm_test_top/m_env/m_tap_1500_agent/m_monitor/mon_items
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {405 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 75
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {2100 ns}
