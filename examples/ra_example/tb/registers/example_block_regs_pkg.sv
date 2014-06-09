//----------------------------------------------------------------------
//   THIS IS AUTOMATICALLY GENERATED CODE
//   Generated by Mentor Graphics' Register Assistant UVM V4.4 (Build 1)
//   UVM Register Kit version 1.1
//----------------------------------------------------------------------
// Project         : registers
// Unit            : example_block_regs_pkg
// File            : example_block_regs_pkg.sv
//----------------------------------------------------------------------
// Created by      : mikaela
// Creation Date   : 6/9/14 10:15 PM
//----------------------------------------------------------------------
// Title           : registers
//
// Description     : 
//
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// example_block_regs_pkg
//----------------------------------------------------------------------
package example_block_regs_pkg;

   import uvm_pkg::*;

   `include "uvm_macros.svh"

   /* DEFINE REGISTER CLASSES */



   //--------------------------------------------------------------------
   // Class: SYSPOR_DBB_RST_N_MASK1_REG_reg
   // 
   //--------------------------------------------------------------------

   class SYSPOR_DBB_RST_N_MASK1_REG_reg extends uvm_reg;
      `uvm_object_utils(SYSPOR_DBB_RST_N_MASK1_REG_reg)

      rand uvm_reg_field LDOA_mask; 
      rand uvm_reg_field LDOB_mask; 
      rand uvm_reg_field LDOC_mask; 
      rand uvm_reg_field LDOF_mask; 
      rand uvm_reg_field LDOG_mask; 
      rand uvm_reg_field LDOH_mask; 
      rand uvm_reg_field spare; 
      rand uvm_reg_field LDOT_mask; 


      // Function: new
      // 
      function new(string name = "SYSPOR_DBB_RST_N_MASK1_REG_reg");
         super.new(name, 8, UVM_NO_COVERAGE);
      endfunction


      // Function: build
      // 
      virtual function void build();
         LDOA_mask = uvm_reg_field::type_id::create("LDOA_mask");
         LDOB_mask = uvm_reg_field::type_id::create("LDOB_mask");
         LDOC_mask = uvm_reg_field::type_id::create("LDOC_mask");
         LDOF_mask = uvm_reg_field::type_id::create("LDOF_mask");
         LDOG_mask = uvm_reg_field::type_id::create("LDOG_mask");
         LDOH_mask = uvm_reg_field::type_id::create("LDOH_mask");
         spare = uvm_reg_field::type_id::create("spare");
         LDOT_mask = uvm_reg_field::type_id::create("LDOT_mask");

         LDOA_mask.configure(this, 1, 7, "RW", 0, 1'b0, 1, 1, 0);
         LDOB_mask.configure(this, 1, 6, "RW", 0, 1'b0, 1, 1, 0);
         LDOC_mask.configure(this, 1, 5, "RW", 0, 1'b0, 1, 1, 0);
         LDOF_mask.configure(this, 1, 4, "RW", 0, 1'b0, 1, 1, 0);
         LDOG_mask.configure(this, 1, 3, "RW", 0, 1'b0, 1, 1, 0);
         LDOH_mask.configure(this, 1, 2, "RW", 0, 1'b0, 1, 1, 0);
         spare.configure(this, 1, 1, "RW", 0, 1'b0, 1, 1, 0);
         LDOT_mask.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 0);
      endfunction
   endclass



   //--------------------------------------------------------------------
   // Class: SYSPOR_DBB_RST_N_MASK4_REG_reg
   // 
   //--------------------------------------------------------------------

   class SYSPOR_DBB_RST_N_MASK4_REG_reg extends uvm_reg;
      `uvm_object_utils(SYSPOR_DBB_RST_N_MASK4_REG_reg)

      rand uvm_reg_field spare; 
      rand uvm_reg_field rtcclk12_mask; 


      // Function: new
      // 
      function new(string name = "SYSPOR_DBB_RST_N_MASK4_REG_reg");
         super.new(name, 8, UVM_NO_COVERAGE);
      endfunction


      // Function: build
      // 
      virtual function void build();
         spare = uvm_reg_field::type_id::create("spare");
         rtcclk12_mask = uvm_reg_field::type_id::create("rtcclk12_mask");

         spare.configure(this, 7, 1, "RW", 0, 7'b0000000, 1, 1, 0);
         rtcclk12_mask.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 0);
      endfunction
   endclass



   //--------------------------------------------------------------------
   // Class: SYSPOR_DBB_RST_N_MASK3_REG_reg
   // 
   //--------------------------------------------------------------------

   class SYSPOR_DBB_RST_N_MASK3_REG_reg extends uvm_reg;
      `uvm_object_utils(SYSPOR_DBB_RST_N_MASK3_REG_reg)

      rand uvm_reg_field BUCK5_mask; 
      rand uvm_reg_field spare; 


      // Function: new
      // 
      function new(string name = "SYSPOR_DBB_RST_N_MASK3_REG_reg");
         super.new(name, 8, UVM_NO_COVERAGE);
      endfunction


      // Function: build
      // 
      virtual function void build();
         BUCK5_mask = uvm_reg_field::type_id::create("BUCK5_mask");
         spare = uvm_reg_field::type_id::create("spare");

         BUCK5_mask.configure(this, 1, 7, "RW", 0, 1'b0, 1, 1, 0);
         spare.configure(this, 7, 0, "RW", 0, 7'b0000000, 1, 1, 0);
      endfunction
   endclass



   //--------------------------------------------------------------------
   // Class: SYSPOR_DBB_RST_N_MASK2_REG_reg
   // 
   //--------------------------------------------------------------------

   class SYSPOR_DBB_RST_N_MASK2_REG_reg extends uvm_reg;
      `uvm_object_utils(SYSPOR_DBB_RST_N_MASK2_REG_reg)

      rand uvm_reg_field LDOM_mask; 
      rand uvm_reg_field LDOS_mask; 
      rand uvm_reg_field EXTBST1_mask; 
      rand uvm_reg_field spare; 
      rand uvm_reg_field BUCK2_mask; 
      rand uvm_reg_field BUCK4_mask; 
      rand uvm_reg_field BUCK1_mask; 
      rand uvm_reg_field LDOP_mask; 


      // Function: new
      // 
      function new(string name = "SYSPOR_DBB_RST_N_MASK2_REG_reg");
         super.new(name, 8, UVM_NO_COVERAGE);
      endfunction


      // Function: build
      // 
      virtual function void build();
         LDOM_mask = uvm_reg_field::type_id::create("LDOM_mask");
         LDOS_mask = uvm_reg_field::type_id::create("LDOS_mask");
         EXTBST1_mask = uvm_reg_field::type_id::create("EXTBST1_mask");
         spare = uvm_reg_field::type_id::create("spare");
         BUCK2_mask = uvm_reg_field::type_id::create("BUCK2_mask");
         BUCK4_mask = uvm_reg_field::type_id::create("BUCK4_mask");
         BUCK1_mask = uvm_reg_field::type_id::create("BUCK1_mask");
         LDOP_mask = uvm_reg_field::type_id::create("LDOP_mask");

         LDOM_mask.configure(this, 1, 7, "RW", 0, 1'b0, 1, 1, 0);
         LDOS_mask.configure(this, 1, 6, "RW", 0, 1'b0, 1, 1, 0);
         EXTBST1_mask.configure(this, 1, 5, "RW", 0, 1'b0, 1, 1, 0);
         spare.configure(this, 1, 4, "RW", 0, 1'b0, 1, 1, 0);
         BUCK2_mask.configure(this, 1, 3, "RW", 0, 1'b0, 1, 1, 0);
         BUCK4_mask.configure(this, 1, 2, "RW", 0, 1'b0, 1, 1, 0);
         BUCK1_mask.configure(this, 1, 1, "RW", 0, 1'b0, 1, 1, 0);
         LDOP_mask.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 0);
      endfunction
   endclass




   /* BLOCKS */



   //--------------------------------------------------------------------
   // Class: example_block_registers
   // 
   //--------------------------------------------------------------------

   class example_block_registers extends uvm_reg_block;
      `uvm_object_utils(example_block_registers)

      rand SYSPOR_DBB_RST_N_MASK1_REG_reg SYSPOR_DBB_RST_N_MASK1_REG; 
      rand SYSPOR_DBB_RST_N_MASK2_REG_reg SYSPOR_DBB_RST_N_MASK2_REG; 
      rand SYSPOR_DBB_RST_N_MASK3_REG_reg SYSPOR_DBB_RST_N_MASK3_REG; 
      rand SYSPOR_DBB_RST_N_MASK4_REG_reg SYSPOR_DBB_RST_N_MASK4_REG; 

      uvm_reg_map example_block_registers_map; 


      // Function: new
      // 
      function new(string name = "example_block_registers");
         super.new(name, UVM_NO_COVERAGE);
      endfunction


      // Function: build
      // 
      virtual function void build();
         SYSPOR_DBB_RST_N_MASK1_REG = SYSPOR_DBB_RST_N_MASK1_REG_reg::type_id::create("SYSPOR_DBB_RST_N_MASK1_REG");
         SYSPOR_DBB_RST_N_MASK1_REG.configure(this);
         SYSPOR_DBB_RST_N_MASK1_REG.build();

         SYSPOR_DBB_RST_N_MASK2_REG = SYSPOR_DBB_RST_N_MASK2_REG_reg::type_id::create("SYSPOR_DBB_RST_N_MASK2_REG");
         SYSPOR_DBB_RST_N_MASK2_REG.configure(this);
         SYSPOR_DBB_RST_N_MASK2_REG.build();

         SYSPOR_DBB_RST_N_MASK3_REG = SYSPOR_DBB_RST_N_MASK3_REG_reg::type_id::create("SYSPOR_DBB_RST_N_MASK3_REG");
         SYSPOR_DBB_RST_N_MASK3_REG.configure(this);
         SYSPOR_DBB_RST_N_MASK3_REG.build();

         SYSPOR_DBB_RST_N_MASK4_REG = SYSPOR_DBB_RST_N_MASK4_REG_reg::type_id::create("SYSPOR_DBB_RST_N_MASK4_REG");
         SYSPOR_DBB_RST_N_MASK4_REG.configure(this);
         SYSPOR_DBB_RST_N_MASK4_REG.build();

         example_block_registers_map = create_map("example_block_registers_map", 'h0, 1, UVM_LITTLE_ENDIAN);
         default_map = example_block_registers_map;

         example_block_registers_map.add_reg(SYSPOR_DBB_RST_N_MASK1_REG, 'h0, "RW");
         example_block_registers_map.add_reg(SYSPOR_DBB_RST_N_MASK2_REG, 'h1, "RW");
         example_block_registers_map.add_reg(SYSPOR_DBB_RST_N_MASK3_REG, 'h2, "RW");
         example_block_registers_map.add_reg(SYSPOR_DBB_RST_N_MASK4_REG, 'h3, "RW");

         lock_model();
      endfunction
   endclass


endpackage
