class result_transaction extends uvm_transaction;

//------------------------------------------------------------------------------
// transaction variables
//------------------------------------------------------------------------------

	bit 	arg_parity_error;
	int 	result;
	bit 	result_parity; 	

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "");
	    
        super.new(name);
	    
    endfunction : new

//------------------------------------------------------------------------------
// transaction functions: do_copy, do_compare, convert2string
//------------------------------------------------------------------------------

    extern function void do_copy(uvm_object rhs);
    extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    extern function string convert2string();

endclass : result_transaction

//------------------------------------------------------------------------------
// transaction methods - do_copy, convert2string, do_compare
//------------------------------------------------------------------------------

//------------------------------------
    function void result_transaction::do_copy(uvm_object rhs);
	    
        result_transaction copied_transaction_h;
	    
        assert (rhs != null) 
        else   `uvm_fatal("RESULT TRANSACTION","Tried to copy null transaction");
        
        super.do_copy(rhs);
        
        assert ($cast(copied_transaction_h,rhs)) 
        else   `uvm_fatal("RESULT TRANSACTION","Failed cast in do_copy");
        
        result = copied_transaction_h.result;
        arg_parity_error = copied_transaction_h.arg_parity_error;
        result_parity = copied_transaction_h.result_parity;
        
    endfunction : do_copy

//------------------------------------
    function string result_transaction::convert2string();
	    
        string s;
	    
        s = $sformatf("result: %0d, arg_parity_error: %0d, result_parity: %0d",result,arg_parity_error, result_parity);
	    
        return s;
	    
    endfunction : convert2string

//------------------------------------
    function bit result_transaction::do_compare(uvm_object rhs, uvm_comparer comparer);
	    
        result_transaction RHS;
	    
        bit same;
	    
        assert (rhs != null) 
        else   `uvm_fatal("RESULT TRANSACTION","Tried to compare null transaction");

        same = super.do_compare(rhs, comparer);

        $cast(RHS, rhs);
        
        same =  (result 		  == RHS.result) 		   && 
        		(arg_parity_error == RHS.arg_parity_error) &&
        		(result_parity    == RHS.result_parity)    && same;
        		
        return same;
        
    endfunction : do_compare
