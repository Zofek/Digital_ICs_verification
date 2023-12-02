class random_command_transaction extends uvm_transaction;
    `uvm_object_utils(random_command_transaction)

//------------------------------------------------------------------------------
// transaction variables
//------------------------------------------------------------------------------

	rand shortint 	arg_a;
    rand shortint 	arg_b;
	rand bit 		arg_a_parity;
	rand bit 		arg_b_parity;
    rand operation_t op;

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// transaction functions: do_copy, clone_me, do_compare, convert2string
//------------------------------------------------------------------------------

//----------------------------------
    function void do_copy(uvm_object rhs);
	    
        random_command_transaction copied_transaction_h;

        if(rhs == null)
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")

        super.do_copy(rhs); // copy all parent class data

        if(!$cast(copied_transaction_h,rhs))
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")

        arg_a  = copied_transaction_h.arg_a;
        arg_b  = copied_transaction_h.arg_a;
        arg_a_parity  = copied_transaction_h.arg_a_parity;
        arg_b_parity  = copied_transaction_h.arg_b_parity;
        op = copied_transaction_h.op;

    endfunction : do_copy

//----------------------------------
    function random_command_transaction clone_me();
        
        random_command_transaction clone;
        uvm_object tmp;

        tmp = this.clone();
        $cast(clone, tmp);
        return clone;
        
    endfunction : clone_me

//----------------------------------
    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        
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
    function string convert2string();
	    
        string s;

        s = $sformatf("Arg_a=%0d, arg_b=%0d, arg_a_parity=%0d, arg_b_parity=%0d, operation=%0d",
			arg_a, arg_b, arg_a_parity, arg_b_parity, op);
	    
        return s;
	    
    endfunction : convert2string

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new (string name = "");
	    
        super.new(name);
	    
    endfunction : new

endclass : random_command_transaction
