########################## Questa Makefile Environment (QME) ####################
# This environment is developed by Mikael Andersson, Mentor Graphics
# contact email: Mikael_Andersson@mentor.com
# Documentation can be found at: http://www.github.com/detstorabla/qme
# ################################################################################
#
# This is a verification environment that are intended to easy adoption of 
# uvm and use the power of the Questa Verification Platform for doing 
# Coverage Driven Verification
#################################################################################
# To install this environment using git, I suggest that you do the following:
# >mkdir QME
# >cd QME
# >git init
# >git pull https://github.com/detstorabla/qme 
# ./install.sh
# Set the Unix variables according to INSTALL.txt
##################################################################################
#  
## What is QME and how is it supposed to be used?
# QME is an integrated environment developed for effecient use of the Quest Verification
# Platform.
# The basic use model is that you provide filelists in a very simple format,
# create a simulation directory containing a Makefile by using a simple script.
#
# To get going, I suggest that you run a very simple tutorial:
#
# 1. Do source source_me.sh (if you haven't setup the environment by your self)
# 2. create_simdir.pl -s sim_fpu -b fpu
# 3. Go to the simdir location (copy last line of output from step above)
# 4. type 'make help' and the 'make help_tutorial'



