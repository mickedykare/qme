#ifndef __PACKING_UTIL_H__
#define __PACKING_UTIL_H__
#include "datatypes.h"

namespace packing_util {

  class bits {
  public:
    uint64t m_data;
    int      m_bits;
    bits(int _bits, uint64t _data):
      m_data(_data),
      m_bits(_bits)
      {}
  };

  // Set Width Manipulator
  class setwidth { 
  public: 
    int i; 
    setwidth(int in) {i=in;}
  } ;

  // Utilities class for packing classes
  class pack_util {
  public:
    
    // Shift right by shift.
    // If shift is negative, value is shifted in the other
    // direction.
    static uint64t rshift(uint64t indata, int shift) {
      if (shift > 0) 
        return indata >> shift;
      else if (shift == 0)
        return indata;
      else
        return indata << -shift;
    }
  };

  // Pack base class
  // This class holds the Interfaces for the packing classes.
  class pack_base {
  public:
    pack_base() : m_nextw(-1) {}
    virtual ~pack_base() {}

    // Interface Resetting the pack pointers
    virtual void reset()= 0;

    // Interfaces for packing data.
    virtual pack_base& operator<<(const bits& bf)=0;
    virtual pack_base& operator<<(const bool& val)=0;
    virtual pack_base& operator<<(const uint8t& val)=0;
    virtual pack_base& operator<<(const uint16t& val)=0;
    virtual pack_base& operator<<(const uint32t& val)=0;
    virtual pack_base& operator<<(const uint64t& val)=0;

    // Interfaces for unpacking data.
    virtual pack_base& operator>>(bits& bf)=0;
    virtual pack_base& operator>>(bool& val)=0;
    virtual pack_base& operator>>(uint8t& val)=0;
    virtual pack_base& operator>>(uint16t& val)=0;
    virtual pack_base& operator>>(uint32t& val)=0;
    virtual pack_base& operator>>(uint64t& val)=0;

    // Interfaces for manipulating the stream
    void setnextw(int w) {
      m_nextw = w;
    }
    pack_base& operator<<(const setwidth& i) {
      setnextw(i.i);
      return(*this);
    }
    pack_base& operator>>(const setwidth& i) {
      setnextw(i.i);
      return(*this);
    }

  protected:
    // Get width of next bit field. If m_nextw is not set
    // Use the default width passed in to the method
    int _get_nextw(int def_val) {
      int res = (m_nextw == -1) ? def_val : m_nextw;
      m_nextw = -1;
      return res;
    }
    
  private:
    // Holds bit width of next value to extract
    // If -1 use width of object to extract to instead
    // of m_nextw for width. After a value have been
    // extracted m_nextw should be reset to -1.
    int m_nextw;
  };

  template <typename TYPE>
    class be_pack : public pack_base {
    public:
    typedef TYPE arr_type;
    
    be_pack(arr_type* _data_arr, int size) : 
      m_data(_data_arr),
      m_width(sizeof(TYPE)*8),
      m_bit_pos(0), 
      m_word_pos(_data_arr),
      m_max_size(size){
    }
    
    void reset() {
      m_word_pos = m_data;
      m_bit_pos  = 0;
    }

    pack_base& operator<<(const setwidth& i) {
      setnextw(i.i);
      return(*this);
    }
    pack_base& operator>>(const setwidth& i) {
      setnextw(i.i);
      return(*this);
    }

    // Pack Operators
    pack_base& operator<<(const bits& bf) {
      _pack(bf.m_data, _get_nextw(bf.m_bits));
      return *this;
    }
    pack_base& operator<<(const bool& val) {
      _pack(val, _get_nextw(1));
      return *this;
    }
    pack_base& operator<<(const uint8t& val) {
      _pack(val, _get_nextw(8));
      return *this;
    }
    pack_base& operator<<(const uint16t& val) {
      _pack(val, _get_nextw(16));
      return *this;
    }
    pack_base& operator<<(const uint32t& val) {
      _pack(val, _get_nextw(32));
      return *this;
    }
    pack_base& operator<<(const uint64t& val) {
      _pack(val, _get_nextw(64));
      return *this;
    }
    
    // Unpack Operators
    pack_base& operator>>(bits& bf) {
      bf.m_data = _unpack(_get_nextw(bf.m_bits));
      return *this;
    }
    pack_base& operator>>(bool& val) {
      val = (bool) _unpack(_get_nextw(1));
      return *this;
    }
    pack_base& operator>>(uint8t& val) {
     val = (uint8t) _unpack(_get_nextw(8));
      return *this;
    }
    pack_base& operator>>(uint16t& val) {
      val = (uint16t) _unpack(_get_nextw(16));
      return *this;
    }
    pack_base& operator>>(uint32t& val) {
      val = (uint32t) _unpack(_get_nextw(32));
      return *this;
    }
    pack_base& operator>>(uint64t& val) {
      val = (uint64t) _unpack(_get_nextw(64));
      return *this;
    }

    private:
    
    void _pack(uint64t bf_data, unsigned int bf_bits) {
      // First fit what we can in the current word.
      if ( m_bit_pos != 0) {
        int shift = bf_bits + m_bit_pos - m_width;
        uint64t mask = pack_util::rshift((((uint64t) 1) << bf_bits) - 1, shift);
        *m_word_pos = (arr_type) (*m_word_pos & ~mask) | (pack_util::rshift(bf_data,shift) & mask);
        
        // Align data for next word
        if ((m_bit_pos + bf_bits) >= m_width) {
          bf_bits -= (m_width-m_bit_pos);
          m_bit_pos = 0;
          m_word_pos++;
        }
        else {
          m_bit_pos += bf_bits;
          // We're done
          return;
        }
      }
      
      // Add all full words in the bit field
      while (bf_bits >= m_width) {
        *m_word_pos++ = (arr_type) (bf_data >> (bf_bits-m_width));
        bf_bits -= m_width;
      }
      
      // Take care of bits in the last word
      if (bf_bits > 0) {
        uint64t mask = ((((uint64t) 1) << bf_bits) - 1) << (m_width-bf_bits);
        *m_word_pos = (arr_type) ((bf_data << (m_width-bf_bits) )& mask);
        m_bit_pos = bf_bits % m_width;
     }
      
      return;
    }
    
    uint64t _unpack(int bf_bits) {
      uint64t bf = 0;
      int tmp_bits = 0;
      for (int bits = bf_bits; bits > 0; bits -= tmp_bits) {
        // How many bits should be unpack in this loop
        tmp_bits = ((bits+m_bit_pos) < m_width) ? bits : (m_width-m_bit_pos);

        // Insert bits into the word
        uint64t mask = (((uint64t) 1) << tmp_bits) - 1;
        bf = ((bf<<tmp_bits) & ~mask) | ((*m_word_pos >> (m_width-m_bit_pos-tmp_bits)) & mask);
        
        // Update position for next time
        if ( (m_bit_pos + tmp_bits) >= m_width)
          ++m_word_pos;
        m_bit_pos = (m_bit_pos + tmp_bits)%m_width;
      }
      return bf;
    }

    arr_type*      m_data;
    unsigned int   m_width; 
    unsigned int   m_bit_pos;
    arr_type*      m_word_pos;
    unsigned int   m_max_size;
  };
}

#endif
