#include <systemc.h>
#include "uvmc.h"
#include "fpu_extension.h"

using namespace tlm;
using namespace uvmc;

#include "xl_uvmc_converter.h"
using namespace xl_uvmc;
namespace xl_uvmc {


  template <>
    struct xl_uvmc_converter<FPU_extension>
    {

      static void do_pack(const FPU_extension &t, uvmc_packer &packer) {

        packer << t.length();
        packer << t.type();

#ifdef DEBUG_COUT
        cout << "############################################" << endl;;
        cout << "### UVM Connect Packing extension        ###" << endl;
        cout << "### The extension is being sent from     ###" << endl;
        cout << "### SystemC -> SystemVerilog side ###\n";
        cout << "### Packing FPU extension t.type() = "         << t.type()         << endl;
        cout << "### Packing FPU extension t.length() = "       << t.length()       << endl;
        cout << "############################################\n";
#endif
      }

      static void do_unpack(FPU_extension &t, uvmc_packer &packer) {
        uint32t len;
        token_type_e tok;
        packer >> len; // bits[12]
        t.set_length(len);
        packer >> tok; // bits[13]
        t.set_type(tok);

#ifdef DEBUG_COUT
        cout << "############################################" << endl;;
        cout << "### UVM Connect Unpacking extension      ###" << endl;
        cout << "### The Extension is being sent from     ###" << endl;
        cout << "### SystemVerilog -> SystemC side        ###" << endl;
        cout << "### FPU_extension  t.length() = "             << t.length() << endl;
        cout << "### FPU_extension  t.type() = "               << t.type()   << endl;
        cout << "############################################" << endl;
#endif
      }

    };


  struct gp_with_FPU_converter : public xl_uvmc_converter<tlm_generic_payload> {


    static void do_pack(const tlm_generic_payload &t, uvmc_packer &packer)
    {
      const FPU_extension *ext = t.get_extension<FPU_extension>();
      uint32t is_extended=1;

#ifdef DEBUG_COUT
      cout << "############################################" << endl;;
      cout << "### UVM Connect Packing Payload          ###" << endl;
      cout << "### The payload is being sent from       ###" << endl;
      cout << "### SystemC -> SystemVerilog side        ###\n";
      cout << "############################################\n";
      cout << "### transaction:" << hex << t << endl;
      cout << "############################################\n";
#endif

      if (ext == NULL) {
        cout << "**** ERROR: gp_with_FPU_converter received tlm gp without a FPU extension" << endl;
      } else {

        // Two steps. First we pack the GP part and then the extension
        xl_uvmc_converter<tlm_generic_payload>::do_pack(t,packer);
        packer << is_extended; // Indication of extension bits[11]
        xl_uvmc_converter<FPU_extension>::do_pack(*ext,packer);
      }

    }


    static void do_unpack(tlm_generic_payload &t, uvmc_packer &packer)
    {
      uint32t is_extended;
#ifdef DEBUG_COUT
      cout << "############################################" << endl;;
      cout << "### UVM Connect Unpacking Payload (FPU)  ###" << endl;
      cout << "### The Payload is being sent from       ###" << endl;
      cout << "### SystemVerilog -> SystemC side        ###" << endl;
      cout << "############################################" << endl;;
#endif
      // Unpacking the actual GP
      xl_uvmc_converter<tlm_generic_payload>::do_unpack(t,packer);
#ifdef DEBUG_COUT
      cout << "### Unpacked Generic Payload" << t << endl;
#endif

      packer >> is_extended; // bits[11]

      // Unpacking the FPU extension
      FPU_extension* m_FPU_ext = t.get_extension<FPU_extension>();
      if (m_FPU_ext == NULL)
        m_FPU_ext = new er_tlm::FPU_extension();
      // Using this method requires a mem mgr
      // t.set_auto_extension(m_FPU_ext);

      // this doesn't require a mem mgr, but it will leak
      // because the extension will never be deleted. When mem mgr
      // present, using set_auto_extension will automatically delete
      // or pool the extension

      // Now we need to update the members of the extension
      xl_uvmc_converter<FPU_extension>::do_unpack(*m_FPU_ext,packer);
#ifdef DEBUG_COUT
      cout << "### GP           :" << hex << t << endl;
      cout << "### FPU extension:" << hex << m_FPU_ext << endl;
      cout << "############################################" << endl;;
#endif
      t.set_extension(m_FPU_ext);

    }
  };
};



