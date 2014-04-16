# This file will also be used for regression runs.
# Please keep run -a outside

set StdArithNoWarnings 1
set NumericStdNoWarnings 1

run 0

# To avoid collecting coverage during the first deltadelays where a lot of signals might be X
coverage clear -codeAll -assert

# finding tc specific dofile. Requires an argument to the dofile. I.e. "do vsim.do <test_name>"
set tcok [info exists 1]
if {$tcok} {
#   puts "Info:Testcase name defined - OK"
} else {
  puts "Warning:No testcase name defined, should be \"do vsim.do <testname> <dut name>\""
}

set dutok [info exists 2]
if {$dutok} {
#   puts "Info:dut name defined, looking - OK"
} else {
  puts "Warning:No dut name defined, should be \"do vsim.do <testname> <dut name>\""
}


if {$dutok & $tcok} {
   set dofile $::env(QME_PROJECT_HOME)/$2/$::env(QME_SIM_SETTINGS_DIR)/$1.do
   puts "Info: Looking for $dofile"
   if { [file exists $dofile]} {
      puts "executing $dofile"
      source $dofile
   } else {
      puts "Info: testcase specific $dofile did not exist. Skipping..."
   }  
}
