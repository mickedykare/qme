module (input WSI, WSO, SelectWIR, CaptureWR, ShiftWR,UpdateWR,TransferDR
);

/*
 Some of the assertions I can think of. Some of them are probably internal signals
 stolen from spec
 
 1. When instruction is WS_BYPASS and ShiftWR is active, delay between WSI and WSO should be one cycle
 2. WS_EXTEST instruction should select WBR (DR), I.e. not IR.
 3.While the WS_EXTEST instruction is selected, only the WBR shall be connected for serial access
between WSI and WSO during the Shift operation (i.e., no other test data register may be connected
in series with the WBR).
 
4. While the WS_EXTEST instruction is selected, only the WBR shall be connected for serial access
between WSI and WSO during the Shift operation (i.e., no other test data register may be connected
in series with the WBR).
 
 While the WS_EXTEST instruction is selected, only the WBR shall be connected for serial access
between WSI and WSO during the Shift operation (i.e., no other test data register may be connected
in series with the WBR).
 
 Capture and shift should not be active at the same time
 Update and shift should not be active at the same time
  Can update and capture be active at the same time?
 
 SelectWIR should never change while shift is high (?)
 
 
 
 
 
 */

   property p_not_active_at_the_same_time(a,b);
      @(posedge RCK) disable iff(~RSTN)
	(a^b==1);
   endproperty
      
   a_capture_shift:assert property p_not_active_at_the_same_time(CaptureWR,ShiftWR);
   a_update_shift:assert property p_not_active_at_the_same_time(UpdateWR,ShiftWR);

   


   


endinterface
