class random_command_transaction extends uvm_transaction;
    `uvm_object_utils(random_command_transaction)

//------------------------------------------------------------------------------
// transaction variables
//------------------------------------------------------------------------------

	rand shortint 	arg_a;
    rand shortint 	arg_b;
	bit 		arg_a_parity;
	bit 		arg_b_parity;
    rand operation_t op;

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------
	constraint data 
	{
        arg_a dist {16'sh0000:=1, 16'sh0001:=4, 16'sh7FFF:=3,  16'shFFFF:=1, 16'sh8000:=3, [16'sh0002:16'sh7FFE]:=1, [16'sh8001:16'shFFFE]:=1};
        arg_b dist {16'sh0000:=1, 16'sh0001:=4, 16'sh7FFF:=3,  16'shFFFF:=1, 16'sh8000:=3, [16'sh0002:16'sh7FFE]:=1, [16'sh8001:16'shFFFE]:=1};
	}
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new (string name = "");
	    
        super.new(name);
	    
    endfunction : new


//------------------------------------------------------------------------------
// transaction functions: do_copy, clone_me, do_compare, convert2string
//------------------------------------------------------------------------------

    extern function void do_copy(uvm_object rhs);
    extern function random_command_transaction clone_me();
    extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    extern function string convert2string();

endclass : random_command_transaction
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// external functions
//------------------------------------------------------------------------------

//----------------------------------
    function string random_command_transaction::convert2string();
	    
        string s;

        s = $sformatf("Arg_a=%0d, arg_b=%0d, arg_a_parity=%0d, arg_b_parity=%0d, operation=%0d",
			arg_a, arg_b, arg_a_parity, arg_b_parity, op);
	    
        return s;
	    
    endfunction : convert2string

//----------------------------------
    function bit random_command_transaction::do_compare(uvm_object rhs, uvm_comparer comparer);
        
        random_command_transaction compared_transaction_h;
        bit same;

        if (rhs==null) `uvm_fatal("RANDOM TRANSACTION",
                "Tried to do comparison to a null pointer");

        if (!$cast(compared_transaction_h,rhs))
            same = 0;
        else
            same = super.do_compare(rhs, comparer) &&
            (compared_transaction_h.arg_a == arg_a) &&
            (compared_transaction_h.arg_b == arg_b) &&
            (compared_transaction_h.arg_a_parity == arg_a_parity) &&
            (compared_transaction_h.arg_b_parity == arg_b_parity) &&
            (compared_transaction_h.op == op);

        return same;
        
    endfunction : do_compare

//----------------------------------
    function random_command_transaction random_command_transaction::clone_me();
        
        random_command_transaction clone;
        uvm_object tmp;

        tmp = this.clone();
        $cast(clone, tmp);
        return clone;
        
    endfunction : clone_me

//----------------------------------
    function void random_command_transaction::do_copy(uvm_object rhs);
	    
        random_command_transaction copied_transaction_h;

        if(rhs == null)
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")

        super.do_copy(rhs); // copy all parent class data

        if(!$cast(copied_transaction_h,rhs))
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")

        arg_a  = copied_transaction_h.arg_a;
        arg_b  = copied_transaction_h.arg_b;
        arg_a_parity  = copied_transaction_h.arg_a_parity;
        arg_b_parity  = copied_transaction_h.arg_b_parity;
        op = copied_transaction_h.op;

    endfunction : do_copy

