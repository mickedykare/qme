`ifndef __FPU_GP_EXT
 `define __FPU_GP_EXT

// We should extend this instead of the uvm_tlm_gp
class fpu_gp_ext extends uvm_tlm_extension #(fpu_gp_ext);

   // ****************************************************************
   // Extended information : bit sizes must be same as in SC, else
   // you'll need to unpack into a temporary of the correct width
   // on the SC side.
   // sc_bv<5> tmp5;
   // packer >> tmp5;  // need to do this so only 5 bits are extracted
   // Future packer impl may provide a packer.unpack( var, int numbits) function
   // so you can go packer.unpack( var, 5);
   // this will take 5 bits off the bit stream and assign them to var.
   // Setting constraints to match this instead
   // rand bit [10:0] m_total_length;
   // rand bit [5:0]  m_token;
   // ****************************************************************

   rand int unsigned m_total_length;
   rand int unsigned m_token;
   
   constraint c_valid {m_total_length < 2**7;
      m_token < 2**3;}
   `uvm_object_utils(fpu_gp_ext)

   function new (string name = "fpu_gp_ext" );
      super.new(name);
   endfunction: new

   virtual function void do_print(uvm_printer printer);
      printer.print_field("total_length",m_total_length,32);
      printer.print_field("token_type",m_token,32);
   endfunction

   virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      fpu_gp_ext _rhs;
      if (!$cast(_rhs,rhs)) begin
         `uvm_error("WRONG TYPE", "Rhs to compare is wrong type")
         return 0;
      end
      return (super.do_compare(rhs,comparer) &&
              m_total_length            == _rhs.m_total_length &&
              m_token                   == _rhs.m_token );
   endfunction

endclass: fpu_gp_ext

import xl_uvmc_converter_pkg::*;

class gp_with_fpu_converter extends xl_uvmc_tlm_gp_converter;

   static function void m_post_pack (ref bits_t bits, input uvm_tlm_generic_payload t, uvm_packer packer);
      fpu_gp_ext m_ext;
      super.m_post_pack(bits,t,packer);
      $cast(m_ext,t.get_extension(fpu_gp_ext::ID));
      //Encode extension fields into bit stream (if present).
      if( m_ext != null ) begin
         bits[11] = 1; // Flag indicating extension is present.
         bits[12] = m_ext.m_total_length;
         bits[13] = m_ext.m_token;
      end
   endfunction

   static function void m_pre_unpack (ref bits_t bits, input uvm_tlm_generic_payload t, uvm_packer packer);
      fpu_gp_ext m_ext;
      int unsigned is_extension_present = bits[11];

      super.m_pre_unpack(bits,t,packer);
      if( is_extension_present ) begin
         m_ext = new();
         m_ext.m_total_length            = bits[12];
         m_ext.m_token                   = bits[13];
         
         void'(m_t.set_extension( m_ext ));
      end

   endfunction // m_pre_unpack

endclass // gp_with_fpu_converter


`endif //  `ifndef __FPU_GP_EXT

