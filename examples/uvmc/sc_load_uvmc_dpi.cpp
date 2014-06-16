#include <systemc.h>
//----------------------------------------------------------------------------
// This module is only used when running agents in rtl mode.
// It is there to remove warnings and a fatal
using namespace sc_core;
SC_MODULE(sc_load_uvmc_dpi)
{  
  SC_CTOR(sc_load_uvmc_dpi) {
  };

};
SC_MODULE_EXPORT(sc_load_uvmc_dpi);

