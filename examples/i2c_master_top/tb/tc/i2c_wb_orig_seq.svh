class i2c_wb_orig_seq extends i2c_wb_base_seq;
   uvm_status_e status;   
   uvm_reg_data_t data,ref_data;
 `uvm_object_utils(i2c_wb_orig_seq)
   
   
   function new(string name="i2c_wb_orig_seq");
      super.new(name);
      // Insert Constructor Code Here
   endfunction : new

   function check_data(input uvm_reg_data_t actual,expected);
      assert(actual === expected) else `uvm_error(get_type_name(),$psprintf("MISMATCH: Expected:0x%0h, Actual::0x%0h",expected,actual));
   endfunction

   task check_tip;
      bit tip;
      
      // check tip bit
      //m_registermodel.SR_REG.read(status,data,.parent(this));
      
      while(data[1])
	m_registermodel.SR_REG.read(status,data,.parent(this));
      `uvm_info(get_type_name(),"tip==0",UVM_MEDIUM);      
   endtask

   task generate_start_write(input bit[6:0] slaveaddress);
      m_registermodel.TXR_REG.write(status,{slaveaddress,WR},.parent(this));
      m_registermodel.CR_REG.WR.set(1);
      m_registermodel.CR_REG.STA.set(1);
      m_registermodel.CR_REG.update(status,.parent(this));
      `uvm_info(get_type_name(),$psprintf("Generate 'start' to slave addr %0h,write cmd 0x%0h (slave address+write)",slaveaddress,{slaveaddress,WR}),UVM_MEDIUM);            
      check_tip();
   endtask // generate_start_write

   task generate_start_read(input bit[6:0] slaveaddress);
      m_registermodel.TXR_REG.write(status,{slaveaddress,RD},.parent(this));
      m_registermodel.CR_REG.write(status,8'h90,.parent(this));
      `uvm_info(get_type_name(),$psprintf("Generate 'start',read cmd 0x%0h (slave address+write)",{slaveaddress,RD}),UVM_MEDIUM);            
      check_tip();
   endtask // generate_start_write


   
   task send_memory_address(input byte address);
   // send memory address
      m_registermodel.TXR_REG.write(status,address,.parent(this));
      m_registermodel.CR_REG.write( status,8'h10,.parent(this));
      `uvm_info(get_type_name(),$psprintf("Write slave memory address 0x01"),UVM_MEDIUM);           
      check_tip();
   endtask // send_memory_address

   task send_i2c_data(input byte data);
      m_registermodel.TXR_REG.write(status,data,.parent(this));
      m_registermodel.CR_REG.write( status,8'h10,.parent(this));
      `uvm_info(get_type_name(),$psprintf("write data 0x%0h",data),UVM_MEDIUM);
      check_tip();
   endtask      
   
   task send_last_i2c_data(input byte data);
      m_registermodel.TXR_REG.write(status,data,.parent(this));
      m_registermodel.CR_REG.write( status,8'h50,.parent(this));
      `uvm_info(get_type_name(),$psprintf("Write last data 0x%0h ,generate 'stop'",data),UVM_MEDIUM);           
      check_tip();
   endtask // send_last_i2c_data

   task read_and_check_data_from_slave(input byte expected);
      uvm_reg_data_t data;
      m_registermodel.CR_REG.write( status,8'h20,.parent(this));
      check_tip();
      m_registermodel.RXR_REG.read(status,data,.parent(this));
      check_data(data,expected);
   endtask // read_data_from_slave
   
   rand byte send_data[int];
   
   task write_to_slave(input bit [7:0] slaveaddress,input byte mem_start_address,input int no_of_bytes,ref byte input_data_array[int]);
      generate_start_write(slaveaddress);
      send_memory_address(mem_start_address);
      for (int i=0;i <no_of_bytes-1;i++) send_i2c_data(input_data_array[i]);
      send_last_i2c_data(no_of_bytes-1);
   endtask // write_to_slave

  // task read_from_slave(input bit [7:0] slaveaddress,input byte mem_start_address,input int no_of_bytes,ref byte input_data_array[int]);
   

      
   
   
   
   
   task body;
      super.body();
      `uvm_info(get_type_name(),"Starting to setup registers",UVM_MEDIUM);
      // register testing is done in  separte test. So we skip this.
      m_registermodel.PRER_LO_REG.write(status,8'hfa,.parent(this));
      m_registermodel.PRER_LO_REG.write(status,8'hc8,.parent(this));
      m_registermodel.PRER_HI_REG.write(status,8'h00,.parent(this));
      `uvm_info(get_type_name(),"Programmed Registers",UVM_MEDIUM);
      
      m_registermodel.PRER_LO_REG.read(status,data,.parent(this));
      check_data(data,8'hc8);
      m_registermodel.PRER_HI_REG.read(status,data,.parent(this));
      check_data(data,8'h00);
      `uvm_info(get_type_name(),"Verified Registers",UVM_MEDIUM);      
      
      
      // Enable core
      m_registermodel.CTR_REG.write(status,8'h80,.parent(this));
      
      `uvm_info(get_type_name(),"Core Enabled",UVM_MEDIUM);      
      $display("###################################");
      $display("###################################");
      $display("# Starting to write to slave      #" );
      $display("###################################");
      $display("###################################");
      send_data[0] = 8'ha5;
      write_to_slave(SADR,8'h01,1,send_data);
      //
      // access slave (read)
      //
      $display("###################################");
      $display("###################################");
      $display("# Starting to read from slave     #" );
      $display("###################################");
      $display("###################################");
      

      generate_start_write(SADR);      
      send_memory_address(8'h01);
      generate_start_read(SADR);      
      read_and_check_data_from_slave(8'ha5);
      

      

      #10us;
      
      
   endtask // body

endclass // i2c_wb_setup_seq

   