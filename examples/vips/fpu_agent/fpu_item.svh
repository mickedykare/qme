`ifndef __FPU_ITEM
 `define __FPU_ITEM

class fp_operand extends uvm_object;
    `uvm_object_utils(fp_operand)
    
    rand operand_kind_t mode;
    rand single_float_t operand;
    
    
    constraint fair   { solve mode before operand; }
    
    
    constraint NaN { if (mode == C_NaN) {
                                         operand.sign inside {'b0, 'b1} ;
                                         operand.exponent == 'hff;
                                         operand.mantissa[$size(operand.mantissa)-1] inside {'b0, 'b1}; // msb
                                         }
    } // Nan
    
    constraint Infinity { if (mode == C_Infinity) {
                                                   operand.sign inside {'b0, 'b1} ;
                                                   operand.exponent == 'hff;
                                                   operand.mantissa == 'h0;
                                                   }
    }// Infinity
    
    constraint Zero { if (mode == C_Zero) {
                                              operand.sign inside {'b0, 'b1} ;
                                              operand.exponent == 0;
                                              operand.mantissa == 0;
                                              }
    } // Zero
    
    constraint Valid { if (mode == C_Valid) {
                                             operand.sign inside {'b0, 'b1} ;
                                             operand.exponent != 'h00;
                                             operand.exponent != 'hff;
                                             operand.mantissa != 'h0;
                                             operand.mantissa != 'h7fffff;
                                             }
    } // Valid
    
    
    function new (string name = "fp_operand");
          super.new(name);
//          this.operand = operand;
          operand.sign=1;
          operand.exponent=1;
          operand.mantissa=1;
          mode=C_Valid;
    endfunction // new
    
    function uvm_object clone(); // always return the baseclass
          fp_operand t = new();
          t.copy (this);
          return t;
    endfunction // clone
    
    
    function void copy (input fp_operand t);
          super.copy (t);
          operand = t.operand;
    endfunction  
    
    
    function string convert2string;
          string s;
          shortreal r_operand;
          
          r_operand = $bitstoshortreal(operand);
          //$sformat(s,"(%s)%e", mode, r_operand);
          $sformat(s,"%e", r_operand);
          return s;
    endfunction // convert2string
    
    local function bit compare(fp_operand t);
          if(t.operand != this.operand) return 0;
          return 1;
    endfunction // bit
    
endclass

class fpu_item extends uvm_sequence_item;

   // ---------------------------------------------------------------
   // Extended information
   // ---------------------------------------------------------------
   rand bit [7:0] m_total_length;
   rand bit [3:0]  m_token;
   rand bit [16:0] m_address;
   rand byte       unsigned m_data[];
	
   rand fp_operand a;
   rand fp_operand b;
   rand op_t    op=OP_ADD;
   rand round_t round=ROUND_EVEN;
   fp_operand        result;
   status_vector_t   status;
	

   // This bit is used by the register package implementation since
   // responses are received on a different agent than the initiating agent.
   bit is_a_read_response=0;

   tlm_status_t m_status = TRANSFER_OK;

   uvm_tlm_command_e m_command = UVM_TLM_IGNORE_COMMAND; 
   //    UVM_TLM_READ_COMMAND
   //    UVM_TLM_WRITE_COMMAND
   //    UVM_TLM_IGNORE_COMMAND

   // ---------------------------------------------------------------
   // Delays
   // ---------------------------------------------------------------

   //  constraints
   constraint valid_c {m_data.size() < 10;}


   // factory registration macro
   `uvm_object_utils_begin(fpu_item)
      `uvm_field_int(m_address,UVM_ALL_ON|UVM_NOCOMPARE)
      `uvm_field_int(m_total_length,UVM_ALL_ON|UVM_NOCOMPARE)
      `uvm_field_int(m_token,UVM_ALL_ON|UVM_NOCOMPARE)
      `uvm_field_array_int(m_data,UVM_ALL_ON|UVM_NOCOMPARE)
      `uvm_field_enum(uvm_tlm_command_e,m_command,UVM_ALL_ON|UVM_NOCOMPARE)
      `uvm_field_enum(tlm_status_t,m_status,UVM_ALL_ON|UVM_NOCOMPARE)
   `uvm_object_utils_end

   //--------------------------------------------------------------------
   // new
   //--------------------------------------------------------------------
   function new (string name = "fpu_item" );
      super.new(name);
         a = new();
         b = new();
			result=new();
   endfunction: new

   // We need two support functions to be able to convert to/from the gp_item used in the systemc model
   function uvm_tlm_gp convert2fpu_gp_item();
      uvm_tlm_gp gp_item=new();
      fpu_gp_ext gp_ext =new();

      gp_item.set_data(this.m_data);
      gp_item.m_length = this.m_data.size();
      gp_item.set_address(this.m_address);
      gp_item.m_byte_enable_length = 0;
      gp_item.m_command = this.m_command;

      gp_ext.m_token                   = this.m_token;
      gp_ext.m_total_length            = this.m_total_length;
         
      void'(gp_item.set_extension(gp_ext));
      return gp_item;
   endfunction // convert2fpu_gp_item

   function void convert2fpu_item(input uvm_tlm_gp gp_item);
		fpu_item tmp= new();
      this.m_total_length     = tmp.m_total_length;
      this.m_token            = tmp.m_token;
      this.m_address          = tmp.m_address;
      this.m_command          = tmp.m_command;
   	this.m_data           	= tmp.m_data;
/*      int len,new_length;
      fpu_gp_ext gp_ext=new();

      $cast(gp_ext,gp_item.get_extension(gp_ext.get_type_handle()));
      assert (gp_ext != null) else 
			`uvm_error(get_type_name(),"No extension available on the GP payload");
   
      this.m_total_length          = gp_ext.m_total_length;
      this.m_token                 = gp_ext.m_token;
      this.m_address               = gp_item.m_address;
      this.m_command               = gp_item.m_command;
      this.m_data.delete();
      
   	this.m_data           = new[ gp_item.get_data_length()](gp_item.m_data);
*/	
   endfunction // convert2fpu_item


   function bit compare(input fpu_item rhs, bit comp_major = 0);
      bit ok;
      int length;

      // We do need to utilize our own compare function for this:
      // 1. Compare address
      // 2. Compare m_total_length
      // 3. Compare Token
      // 4. for (m_total_length) compare data  // We might reuse transaction
      // 5. compare m_command
      ok = 1;
      ok = super.compare(rhs);

      assert (this.m_token == rhs.m_token) else
        ok = 0;

      if (comp_major)begin
         assert (this.m_command == rhs.m_command) else
           ok = 0;
      end

      length = m_total_length;
      for (int i= 0;i <length;i++) begin
         assert (this.m_data[i] == rhs.m_data[i]) else
           ok = 0;
      end
      return ok;
   endfunction // compare

   function void print_differences(input fpu_item rhs);
      int length;
      assert (this.m_token == rhs.m_token) else
        `uvm_info(get_type_name(),$psprintf("Token mismatch: %0s vs %0s",this.m_token,rhs.m_token), UVM_NONE);
      assert (this.m_command == rhs.m_command) else
        `uvm_info(get_type_name(),$psprintf("Command mismatch: %0s vs %0s",this.m_command,rhs.m_command), UVM_NONE);

        length = m_total_length;

      for (int i= 0;i <length;i++) begin
         assert (this.m_data[i] == rhs.m_data[i]) else
           `uvm_info(get_type_name(),$psprintf("data mismatch(m_data[%0d]): 0x%0h vs 0x%0h",i,this.m_data[i],rhs.m_data[i]), UVM_NONE);
      end
   endfunction // compare


   function void set_transaction_color(int tr_handle);
      case (this.m_token)
        0  : begin
           //           this.set_name("UNKNOWN");
           $add_color(tr_handle,"RED");
        end
        1  : begin
           //           this.set_name("UNKNOWN");
           $add_color(tr_handle,"GREEN");
        end
      endcase
   endfunction // set_transaction_color


   function void set_transaction_name();
      case (this.m_token)
        0  : begin
           this.set_name("Type1");
        end
        1  : begin
           this.set_name("Type2");
        end
      endcase
   endfunction // set_transaction_name

endclass: fpu_item
`endif
