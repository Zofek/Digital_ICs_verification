class minmax_sequence extends uvm_sequence #(minmax_sequence_item);
    `uvm_object_utils(minmax_sequence)
    
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

// not necessary, req is inherited
//    add_sequence_item req;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "minmax_sequence");
	    
        super.new(name);
	    
    endfunction : new

//------------------------------------------------------------------------------
// the sequence body
//------------------------------------------------------------------------------

    task body();
	    
        `uvm_info("SEQ_MINMAX","",UVM_MEDIUM)
        repeat (10) begin
//            req = add_sequence_item::type_id::create("req");
//            start_item(req);
//            assert(req.randomize());
//            finish_item(req);
            `uvm_do(req);
            req.print();
        end
        
    endtask : body
    
    
endclass : minmax_sequence











