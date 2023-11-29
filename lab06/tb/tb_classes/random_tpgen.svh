class random_tpgen extends base_tpgen;
    `uvm_component_utils (random_tpgen)
    
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// function: get_data - generate random data for the tpgen
//------------------------------------------------------------------------------
	protected function shortint get_data();

		bit     [2:0] zero_ones;

		zero_ones = 3'($random);

		if      (zero_ones == 3'b000)  return 16'sh0000; //zero
		else if (zero_ones == 3'b001) return 16'sh7FFF; //MAX
		else if (zero_ones == 3'b010) return 16'sh8000; //MIN
		else if (zero_ones == 3'b011) return 16'shFFFF; //-1
		else if (zero_ones == 3'b100) return 16'sh0001; //1
		else                          return 16'($random);

	endfunction : get_data

//------------------------------------------------------------------------------
// function: get_op - generate random opcode for the tpgen
//------------------------------------------------------------------------------
	protected function operation_t get_op();
		
		bit [2:0] op_choice;
		
		op_choice = 3'($random);
		
		case (op_choice)
			
			3'b000  : return RST_OP;
			3'b001  : return CORR_INPUT;
			3'b010  : return INCORRECT_A;
			3'b011  : return INCORRECT_B;
			3'b100  : return INCORRECT_A_B;
			default : return RST_OP;
			
		endcase // case (op_choice)
		
	endfunction : get_op

endclass : random_tpgen






