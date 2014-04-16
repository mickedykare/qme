class i2c_wb_setup_seq extends i2c_wb_base_seq;
   rand uvm_reg_data_t prer_lo;
   rand uvm_reg_data_t prer_hi;
   uvm_status_e status;   

 
   
 `uvm_object_utils(i2c_wb_setup_seq)

   function new(string name="i2c_wb_setup_seq");
      super.new(name);
      // Insert Constructor Code Here
   endfunction : new

   task body;
      super.body();
      `uvm_info(get_type_name(),"Starting to setup registers",UVM_MEDIUM);
      // register testing is done in  separte test. So we skip this.
      m_registermodel.PRER_LO_REG.write(status,prer_lo,.parent(this));
      m_registermodel.PRER_HI_REG.write(status,prer_hi,.parent(this));
      // Enable core
   //   m_register_model.CTR_REG.EN.set(1);
      


      
   endtask // body

endclass // i2c_wb_setup_seq

   