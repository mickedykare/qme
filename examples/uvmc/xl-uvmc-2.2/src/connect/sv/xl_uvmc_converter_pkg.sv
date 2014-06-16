//============================================================================
// @(#) $Id: xl_uvmc_converter_pkg.sv 949 2013-02-25 21:26:37Z jstickle $
//============================================================================

   //_______________________
  // Mentor Graphics, Corp. \_________________________________________________
 //                                                                         //
//   (C) Copyright, Mentor Graphics, Corp. 2003-2012                        //
//   All Rights Reserved                                                    //
//                                                                          //
//    Licensed under the Apache License, Version 2.0 (the                   //
//    "License"); you may not use this file except in                       //
//    compliance with the License.  You may obtain a copy of                //
//    the License at                                                        //
//                                                                          //
//        http://www.apache.org/licenses/LICENSE-2.0                        //
//                                                                          //
//    Unless required by applicable law or agreed to in                     //
//    writing, software distributed under the License is                    //
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR                //
//    CONDITIONS OF ANY KIND, either express or implied.  See               //
//    the License for the specific language governing                      //
//    permissions and limitations under the License.                      //
//-----------------------------------------------------------------------//

package xl_uvmc_converter_pkg; // {

`include "uvm_macros.svh"
import uvm_pkg::*;
import uvmc_pkg::*;

//----------------------------------------------------------------------------
// DPI-C import "C-assist" helper functions
//
// The following SV2C functions provide "turbo boost" for performing
// certain copy operations between C and SV arrays.
//----------------------------------------------------------------------------

import "DPI-C" function void SV2C_copy_c2sv_array(
    int unsigned num_bytes,
    longint unsigned src_c_array_chandle,
    inout byte unsigned dst_sv_array_handle[] );

import "DPI-C" function void SV2C_convert_array_ref_to_chandle(
    input byte unsigned src_sv_array_handle[],
    inout bit [63:0] dst_c_array_chandle );

//________________________________                             _______________
// class xl_uvmc_tlm_gp_converter \___________________________/ johnS 5-7-2012
//
// Converts an object of type uvm_tlm_generic_payload to/from the canonical
// type using the uvm_packer. 
//
// Because this converter operates specifically on transactions of
// class uvm_tlm_generic_payload, dedicated packer/unpacker operations can
// be done that bypass some of the overhead of using a more general
// approach for all uvm_objects that make use of the field automation
// macros.
//
// Consider this the 'XLerated' version of a uvmc_converter specifically
// tuned for TLM2 generic payloads. While this converter was originally
// designed to target acceleration and emulation applications, it also has
// the side benefit of signficantly improving pure simulation performance
// by as much as 10X in pure transaction communication performance as well
// and should be considered for that reason as a higher performing alternative
// to the default UVMC converters that come wtih the UVMC release and make
// use of the field automation macros.
//
// Specifically, all the integer and enum fields of the generic payloads
// are deserialized (unpacked) and serialized (packed) in a way similar
// to the original versions - although more directly and without use
// of the field automation macros.
//
// However for data payloads and byte enables, copy operations are made quite
// a bit more efficient by using "C assist". More importantly, the payload
// itself *is not* contained in the canonical bitstream. Rather, only 'chandles'
// or references to the payload are carried in the bitstream. In addition
// to a significant performance improvement, this has the added benefit
// that it avoids having a limited statically sized bitstream that requires
// a globally specified maximum size that must be able to accommodate
// both fix sized members of generic payloads and any possible variable data
// payload itself that must be carried over the link.
//
// Furthermore, it takes better advantage of 'pass by reference' semantics
// which is one of the strengths of the TLM-2.0 standard in the first place
// and one of the primary reasons the SystemC version is so high performing.
//
// Also, see important information in the SystemC-side counterpart to this
// class, in xl_uvmc_converter.h regarding special assumptions being
// made in the implementation of the ::do_unpack() call.
//------------------------------------------------------------------------

class xl_uvmc_tlm_gp_converter; // {

    static uvm_tlm_generic_payload m_t;

    //---------------------------------------------------------
    // ::do_pack()                               johnS 5-7-2012
    //
    // Convert an object of type uvm_tlm_generic_payload to the canonical
    // bitstream representation type bits_t.
    //
    // Well, actually for the XLerated TLM-GP converter this function does
    // nothing. It's all done in the m_post_pack(). See comments below for
    // why this is.
    //---------------------------------------------------------

    static function void do_pack(uvm_tlm_generic_payload t, uvm_packer packer);
//      if (t == null)
//          `uvm_fatal("UVMC",
//               "Null transaction handle passed to xl_uvmc_tlm_gp_converter::do_pack")
// The original way of doing it (please don't do this) ...
//      t.__m_uvm_field_automation(null, UVM_PACK, "");
//      t.do_pack(packer);

        // ... now,
        // Do nothing !
    endfunction

    //---------------------------------------------------------
    // ::do_unpack()                             johnS 5-7-2012
    //
    // Unpacks the canonical bitstream representation type bits_t into an
    // object of type uvm_tlm_generic_payload.
    //
    // Well, actually for the XLerated TLM-GP converter this function does
    // nothing. It's all done in the m_pre_unpack(). See comments below for
    // why this is.
    //---------------------------------------------------------

    static function void do_unpack(
            uvm_tlm_generic_payload t, uvm_packer packer);

//      if (t == null)
//          `uvm_fatal("UVMC",
//              "Null transaction handle passed to xl_uvmc_tlm_gp_converter::do_unpack")
// The original way of doing it (please don't do this) ...
//      t.__m_uvm_field_automation(null, UVM_UNPACK, "");
//      t.do_unpack(packer);

        // ... now,
        // Do nothing !
    endfunction

    //---------------------------------------------------------
    // ::m_pre_pack()                            johnS 5-7-2012
    // ::m_post_pack()
    //
    // In the original class uvmc_default_converter these were methods for
    // retreiving the canonical bitstream from the packer after packing.
    // However, in this high performance version these methods, which
    // are required by higher layers of UVM-connect, are used in a slightly
    // different, more direct way, than using the field automation macros.
    //
    // This totally avoids the expensive data copy operations that had
    // existed in the class uvmc_default_converter() versions.
    //
    // For packing, the entire operation of transferring data in the
    // source transaction to the target canonical bitstream is done
    // in the m_post_pack() method only. This is be because it is only
    // here that you have access to both the bitstream and the
    // source transaction themselves.
    //
    // The do_pack() and m_pre_pack() methods do nothing.
    //---------------------------------------------------------

    static function void m_pre_pack (
            uvm_tlm_generic_payload t, uvm_packer packer);
        // Do nothing !
    endfunction

   static function void m_post_pack (ref bits_t bits, input uvm_tlm_generic_payload t, uvm_packer packer);
      bit [63:0]     chandle_vector;
      if (t == null)
        `uvm_fatal("UVMC","Null transaction handle passed to xl_uvmc_tlm_gp_converter::m_post_pack")
      { bits[1], bits[0] } = t.m_address;
      bits[2] = t.m_command;
      bits[3] = t.m_length;
      if( t.m_length > 0 )
        SV2C_convert_array_ref_to_chandle( t.m_data, chandle_vector );
      else chandle_vector = 0;
      { bits[5], bits[4] } = chandle_vector;

      bits[6] = t.m_response_status;
      bits[7] = t.m_byte_enable_length;
      
      if( t.m_byte_enable_length > 0 )
        SV2C_convert_array_ref_to_chandle(t.m_byte_enable, chandle_vector );
      else chandle_vector = 0;
      
      { bits[9], bits[8] } = chandle_vector;
      bits[10] = t.m_streaming_width;


   endfunction // m_post_pack
   

    //---------------------------------------------------------
    // ::m_pre_unpack()                          johnS 5-7-2012
    // ::m_post_unpack()
    //
    // In the original class uvmc_default_converter these were methods for
    // preloading the canonical bitstream ref into packer before unpacking.
    // However, in this high performance version these methods, which
    // are required by higher layers of UVM-connect, are used in a slightly
    // different, more direct way, than using the field automation macros.
    //
    // This totally avoids the expensive data copy operations that had
    // existed in the class uvmc_default_converter() versions.
    //
    // For unpacking, the entire operation of transferring data in the
    // canonical bitstream to the target transaction itself is done
    // in the m_pre_unpack() method. This is be because it is only
    // here that you have access to both the bitstream and the
    // target transaction themselves.
    //
    // The do_unpack() and m_post_unpack() methods do nothing.
    //---------------------------------------------------------
   static function void m_pre_unpack (ref bits_t bits, input uvm_tlm_generic_payload t, uvm_packer packer);
      byte 	   unsigned new_data[];
      byte 	   unsigned new_byte_enable[];
      bit [63:0]   new_address = { bits[1], bits[0] };
      uvm_tlm_command_e new_command = uvm_tlm_command_e'{bits[2]};
      int 	   unsigned new_data_len = bits[3];
      longint 	   unsigned new_data_ptr_chandle = {bits[5],bits[4]};
      int 	   unsigned new_byte_enable_len = bits[7];
      longint 	   unsigned new_byte_enable_ptr_chandle = {bits[9],bits[8]};
      int 	   unsigned new_streaming_width = bits[10];
      int 	   unsigned is_extension_present = bits[11];

      
      if (t == null)
        `uvm_fatal( "UVMC",
		    "Null transaction handle passed to xl_uvmc_tlm_gp_converter::m_pre_unpack()")
      m_t = t;
      m_t.m_address = new_address;
      m_t.m_command = new_command;
      m_t.m_length = new_data_len;
      m_t.m_byte_enable_length = new_byte_enable_len;
	     
      if( new_data_len > 0 ) begin
         // Preserve the old data array before updating
         // with the new just in case they're the same !
         new_data = new[new_data_len];
      end
	  
             
      SV2C_copy_c2sv_array(new_data_len, new_data_ptr_chandle, new_data );
      m_t.m_data = new_data;
      

      if( new_byte_enable_len > 0 ) begin
         new_byte_enable = new[new_byte_enable_len];
      end
	  
      SV2C_copy_c2sv_array( new_byte_enable_len,new_byte_enable_ptr_chandle, new_byte_enable );
      m_t.m_byte_enable = new_byte_enable;
      m_t.m_streaming_width = new_streaming_width;
   endfunction  

    static function void m_post_unpack (
            uvm_tlm_generic_payload t, uvm_packer packer);
        // Do nothing !
    endfunction
endclass // } xl_uvnc_tlm_gp_converter

endpackage : xl_uvmc_converter_pkg // }
