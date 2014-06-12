class listener extends uvm_subscriber #(fpu_item);
`uvm_component_utils(listener) 
  function new(string name="listener",uvm_component parent=null);
    super.new(name,parent);
  endfunction
 
  function void write(fpu_item t);
   `uvm_info(get_name(),"Received something from the master agent",UVM_INFO);
	t.print();
  endfunction
 
endclass

