class sequence_item extends uvm_sequence_item;

//  This macro is moved below the variables definition and expanded.
//    `uvm_object_utils(sequence_item)

//------------------------------------------------------------------------------
// sequence item variables
//------------------------------------------------------------------------------

    rand shortint arg_a;
	rand shortint arg_b;
	rand operation_t op;
	bit arg_a_parity;
	bit arg_b_parity;
	
//------------------------------------------------------------------------------
// Macros providing copy, compare, pack, record, print functions.
// Individual functions can be enabled/disabled with the last
// `uvm_field_*() macro argument.
// Note: this is an expanded version of the `uvm_object_utils with additional
//       fields added. DVT has a dedicated editor for this (ctrl-space).
//------------------------------------------------------------------------------

    `uvm_object_utils_begin(sequence_item)
        `uvm_field_int(arg_a, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(arg_b, UVM_ALL_ON | UVM_DEC)
        `uvm_field_enum(operation_t, op, UVM_ALL_ON)
        `uvm_field_int(arg_a_parity, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(arg_b_parity, UVM_ALL_ON | UVM_DEC)
    `uvm_object_utils_end

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

	constraint data 
	{
        arg_a dist {16'sh0000:=50, 16'sh0001:=50, 16'sh7FFF:=50,  16'shFFFF:=50, 16'sh8000:=50, [16'sh0002:16'sh7FFE], [16'sh8001:16'shFFFE]};
        arg_b dist {16'sh0000:=50, 16'sh0001:=50, 16'sh7FFF:=50,  16'shFFFF:=50, 16'sh8000:=50, [16'sh0002:16'sh7FFE], [16'sh8001:16'shFFFE]};
	}

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "sequence_item");
	    
        super.new(name);
	    
    endfunction : new

//------------------------------------------------------------------------------
// convert2string 
//------------------------------------------------------------------------------

    function string convert2string();
	    
        return {super.convert2string(),
            $sformatf("Arg_a=%0d, arg_b=%0d, arg_a_parity=%0d, arg_b_parity=%0d, operation=%0d",
			arg_a, arg_b, arg_a_parity, arg_b_parity, op)
        };
	    
    endfunction : convert2string

endclass : sequence_item


