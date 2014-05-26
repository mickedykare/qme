#ifndef __FPU_EXTENSION_H__
#define __FPU_EXTENSION_H__
#endif
#include "token_types.h"


  // Generic Payload extension for Token contents
  class  FPU_extension:public tlm::tlm_extension<FPU_extension> {
  public:
    FPU_extension(token_type_e type = TOKEN_TYPE_0):
      m_token_type(type),
      m_length(0)		{
    }

    // Get length
    uint32t length() const {
      return m_length;
    }
    // Set length
    void set_length(uint32t len) {
      m_length = len;
    }

    // Get type
    token_type_e type() const {
      return m_token_type;
    }
    // Set type
    void set_type(token_type_e type) {
      m_token_type = type;
    }

    // Override pure virtual clone method
	 virtual tlm::tlm_extension_base* clone() const { 
      FPU_extension* t = new FPU_extension(m_token_type);
      t->set_length(m_length);
      return t;
    }

    // Override pure virtual copy_from method
    virtual void copy_from(const tlm::tlm_extension_base & ext)
    {
      m_token_type   = static_cast<const FPU_extension& >(ext).m_token_type;
      m_length       = static_cast<const FPU_extension& >(ext).m_length;
    }

    static const int length_c = 5;  //! Length of FPU header in bytes

  private:
    token_type_e    m_token_type;   //! Token Type
    uint32t         m_length;       //! Total length of token in bytes
  };


