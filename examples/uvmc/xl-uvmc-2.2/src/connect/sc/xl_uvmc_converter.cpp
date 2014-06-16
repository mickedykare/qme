static const char* svnid = "@(#) $Id: xl_uvmc_converter.cpp 949 2013-02-25 21:26:37Z jstickle $";
static void* gccnowarn = &gccnowarn + (long)&svnid;

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

#include <stdio.h>
#include <string.h>

#include "svdpi.h"

#include "xl_uvmc_converter.h"

//----------------------------------------------------------------------------
// DPI-C import "C-assist" helper functions
//
// The following SV2C functions assist in providing "pass-by-reference"
// handling and "turbo boost" for performing certain copy operations
// between C and SV arrays.
//----------------------------------------------------------------------------

extern "C" {
void  SV2C_copy_c2sv_array(
    unsigned num_bytes,
    unsigned long long src_c_array_chandle,
    const svOpenArrayHandle dst_sv_array_handle )
{
    memcpy( svGetArrayPtr(dst_sv_array_handle), (void *)src_c_array_chandle,
        num_bytes );
}

void  SV2C_convert_array_ref_to_chandle(
    const svOpenArrayHandle src_sv_array_handle,
    svBitVecVal *dst_sv_array_chandle )
{
    union {
        svBitVecVal bitVecRep[2];
        unsigned long long cRep;
        void *chandle;
    } chandle_caster;

    chandle_caster.chandle = svGetArrayPtr(src_sv_array_handle);

    dst_sv_array_chandle[0] = chandle_caster.bitVecRep[0];
    dst_sv_array_chandle[1] = chandle_caster.bitVecRep[1];
}
};

//_________________________                                    _______________
// class xl_uvmc_converter \__________________________________/ johnS 5-7-2012
//----------------------------------------------------------------------------

using namespace xl_uvmc;

//---------------------------------------------------------
// ::do_pack()                               johnS 5-7-2012
//---------------------------------------------------------

void xl_uvmc_converter<tlm_generic_payload>::do_pack(
        const tlm_generic_payload &t, uvmc_packer &packer )
{
    unsigned char *data_ptr    = t.get_data_ptr();
    unsigned int data_len      = t.get_data_length();
    unsigned char *byte_en_ptr = t.get_byte_enable_ptr();
    unsigned int byte_en_len   = t.get_byte_enable_length();
    sc_dt::uint64 addr         = t.get_address();

    packer << addr;                            // {bits[1],bits[0]}
    packer << (int)(t.get_command());          // bits[2]

    if( data_len == 0 || data_ptr == NULL ) {
        data_len = 0;
        data_ptr = NULL;
    }

    packer << data_len;                        // bits[3]

    // Here we just pass the payload "by reference" using its "chandle".
    packer << (unsigned long long)(void *)data_ptr; // {bits[5],bits[4]}

    packer << (int)(t.get_response_status());  // bits[6]

    if( byte_en_len == 0 || byte_en_ptr == NULL ) {
        byte_en_len = 0;
        byte_en_ptr = NULL;
    }

    packer << byte_en_len;                     // bits[7]

    // Here we just pass the byte_enable_ptr "by reference" using its "chandle".
    packer << (unsigned long long)(void *)byte_en_ptr; // {bits[9],bits[8]}

    packer << t.get_streaming_width();         // bits[10]
}

//---------------------------------------------------------
// ::do_unpack()                             johnS 5-7-2012
//---------------------------------------------------------

void xl_uvmc_converter<tlm_generic_payload>::do_unpack(
        tlm_generic_payload &t, uvmc_packer &packer )
{ 
    sc_dt::uint64  new_addr;
    unsigned int   new_cmd;
    unsigned int   new_data_len;
    unsigned int   new_byte_en_len;
    unsigned int   new_resp_stat;
    unsigned int   new_streaming_width;
    unsigned long long new_data_ptr_chandle;
    unsigned long long new_byte_en_ptr_chandle;

    unsigned char *curr_data_ptr    = t.get_data_ptr();
    unsigned int   curr_data_len    = t.get_data_length();
    unsigned char *curr_byte_en_ptr = t.get_byte_enable_ptr();
    unsigned int   curr_byte_en_len = t.get_byte_enable_length();
    unsigned char *new_data_ptr;
    unsigned char *tmp_ptr;
    unsigned char *new_byte_en_ptr;

    packer >> new_addr;
    packer >> new_cmd;
    packer >> new_data_len;
    packer >> new_data_ptr_chandle;
    packer >> new_resp_stat;
    packer >> new_byte_en_len;
    packer >> new_byte_en_ptr_chandle;
    packer >> new_streaming_width;

    // Code modified by Mikael A 130423
    // We always make sure that data is transferred.

    t.set_address(new_addr);
    t.set_command((tlm::tlm_command)(new_cmd));
    t.set_data_length(new_data_len);
    t.set_byte_enable_length(new_byte_en_len);
    t.set_streaming_width(new_streaming_width);
    // Update response status no matter what.
    t.set_response_status((tlm::tlm_response_status)(new_resp_stat));

    if (curr_data_ptr != NULL) {
      //      cout <<"DEBUG:Reusing a old transaction,new_data_len="<<new_data_len<<" current data len=" << curr_data_len<<endl;
      if (new_data_len > curr_data_len) {
	//	cout <<"DEBUG: Increasing..."<<endl;
        //delete curr_data_ptr;
        new_data_ptr = (unsigned char *)(new int[new_data_len]);
      }
      else {
	//	cout <<"DEBUG: Doing nothing..."<<endl;
        new_data_ptr = curr_data_ptr;
      }
    }
    else {
      //      cout <<"DEBUG: New transaction"<<endl;      
      if (new_data_len>0)
        new_data_ptr = (unsigned char *)(new int[new_data_len]);
    } 

    for (unsigned int i=0;i<new_data_len;i++) {
      unsigned int data;
      tmp_ptr = (unsigned char *) new_data_ptr_chandle; 
      data=(unsigned int)(uint8_t) *(tmp_ptr + i);
      //      cout << "DEBUG:" << hex << data  << endl;
      *(new_data_ptr+i) = (unsigned char)  data;
    }

    t.set_data_ptr((unsigned char *)new_data_ptr);

    if (curr_byte_en_ptr != NULL) {
      if (new_byte_en_len > curr_byte_en_len) {
        //delete curr_byte_en_ptr;
        new_byte_en_ptr = (unsigned char *)(new int[new_byte_en_len]);
      }
      else {
        new_byte_en_ptr = curr_byte_en_ptr;
      }
    }
    else {
      if (new_byte_en_len>0) {
        new_byte_en_ptr = (unsigned char *)(new int[new_byte_en_len]);
      }
    }


   for (unsigned int i=0;i<new_byte_en_len;i++) {
      unsigned int data;
      tmp_ptr = (unsigned char *) new_byte_en_ptr_chandle; 
      data=(unsigned int)(uint8_t) *(tmp_ptr + i);
      //      cout << "DEBUG:" << hex << data  << endl;
      *(new_byte_en_ptr+i) = (unsigned char)  data;
    }
    





   //      t.set_byte_enable_ptr((unsigned char *)new_byte_en_ptr_chandle);
      t.set_byte_enable_ptr(new_byte_en_ptr);



}
