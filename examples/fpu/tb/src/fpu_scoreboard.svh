`uvm_analysis_imp_decl(_from_fpu_tlm_2gp_analysis);
`uvm_analysis_imp_decl(_from_fpu_response_analysis);

class fpu_scoreboard extends uvm_scoreboard;
	
`uvm_component_utils(fpu_scoreboard)
	
	uvm_analysis_imp_from_fpu_tlm_2gp_analysis  #(fpu_item, fpu_scoreboard) response_analysis_export_tlm; 
	uvm_analysis_imp_from_fpu_response_analysis #(fpu_item, fpu_scoreboard) response_analysis_export; 
	
	
	function new(string name = "fpu_scoreboard", uvm_component parent=null);
	      super.new(name, parent);
	endfunction // new
	
	
	function void build_phase(uvm_phase phase);     
	      super.build();
	      response_analysis_export = new("response_analysis_export",  this);
	      response_analysis_export_tlm = new("response_analysis_export_tlm",  this);
	endfunction // new
	
	virtual function void write_from_fpu_tlm_2gp_analysis(fpu_item t);
	endfunction: write_from_fpu_tlm_2gp_analysis

	virtual function void write_from_fpu_response_analysis(fpu_item t);
	endfunction: write_from_fpu_response_analysis

endclass
