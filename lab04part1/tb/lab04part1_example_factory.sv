//GLOBAL VARIABLES -----------------------------------------------------
parameter CIRCLE    = 2;
parameter TRIANGLE  = 3;
parameter RECTANGLE = 4;
parameter POLYGON   = 5;

typedef struct {

	real x;
	real y;

} coordinates_struct;

//CLASSESS ------------------------------------------------------------
//---------------------------------------------------------------------

virtual class shape_c;

	protected coordinates_struct points[$];
	protected string name;

	//-------------------------
	function new(string n,coordinates_struct points_queue[$]);

		name   = n;
		points = points_queue;

	endfunction : new

	//-------------------------
	pure virtual function real get_area();

	//-------------------------
	virtual function void print();

		real area = get_area();

		$display("----------------------------------------------------------------------------------------");
		$display("This is: %s",name);

		foreach (points[i]) $display("(%0.2f %0.2f)",points[i].x, points[i].y);

		if (area != 0.0) $display("Area is: %0.2f",area);
		else             $display("Area is: can not be calculated for generic polygon");
	endfunction : print

endclass : shape_c

//---------------------------------------------------------------------
class rectangle_c extends shape_c;

	//-------------------------
	function new(string name,coordinates_struct points[$]);

		super.new(name,points);

	endfunction : new

	//-------------------------
	function real get_distance(coordinates_struct point1, coordinates_struct point2);

		real distance = ((point1.x - point2.x)**2 + (point1.y - point2.y)**2)**0.5;

		return distance;

	endfunction  : get_distance

	//-------------------------
	function real get_area();

		coordinates_struct r_coords1;
		coordinates_struct r_coords2;
		coordinates_struct r_coords3;
		coordinates_struct r_coords4;
		coordinates_struct points_copy[$];
		real area   = 0.0;
		real side1 = 0.0;
		real side2 = 0.0;

		points_copy = points;
		r_coords1 = points_copy.pop_front();
		r_coords2 = points_copy.pop_front();
		r_coords3 = points_copy.pop_front();
		r_coords4 = points_copy.pop_front();

		side1 = get_distance(r_coords1,r_coords2);
		side2 = get_distance(r_coords2,r_coords3);
		area = side1 * side2;

		return area;

	endfunction : get_area

endclass : rectangle_c

//---------------------------------------------------------------------
class circle_c extends rectangle_c;

	//-------------------------
	function new(string name,coordinates_struct points[$]);

		super.new(name,points);

	endfunction : new

	//-------------------------
	protected function real get_radius();

		coordinates_struct points_copy[$];
		coordinates_struct coords1;
		coordinates_struct coords2;
		real radius = 0.0;

		points_copy = points;
		coords1 = points_copy.pop_front();
		coords2 = points_copy.pop_front();
		radius = get_distance(coords1, coords2);

		return radius;

	endfunction : get_radius

	//-------------------------
	virtual function void print();

		$display("----------------------------------------------------------------------------------------");
		$display("This is: %s",name);

		foreach (points[i])
			$display("(%0.2f %0.2f)",points[i].x, points[i].y);

		$display("radius: %0.2f",get_radius());

		$display("Area is: %0.2f",get_area());

	endfunction : print

	//-------------------------
	function real get_area();

		coordinates_struct circle_coords1;
		coordinates_struct circle_coords2;
		coordinates_struct points_copy[$];
		real area   = 0.0;
		real radius   = 0.0;

		points_copy = points;
		circle_coords1 = points_copy.pop_front();
		circle_coords2 = points_copy.pop_front();

		radius = get_radius();
		area = 3.14 * radius**2;

		return area;

	endfunction : get_area

endclass : circle_c

//---------------------------------------------------------------------
class triangle_c extends shape_c;

	//-------------------------
	function new(string name,coordinates_struct points[$]);

		super.new(name,points);

	endfunction : new

	//-------------------------
	function real get_area();

		coordinates_struct t_coords1;
		coordinates_struct t_coords2;
		coordinates_struct t_coords3;
		coordinates_struct points_copy[$];
		real area   = 0.0;

		points_copy = points;
		t_coords1 = points_copy.pop_front();
		t_coords2 = points_copy.pop_front();
		t_coords3 = points_copy.pop_front();

		area = 0.5 * (((t_coords2.x - t_coords1.x)*(t_coords3.y - t_coords1.y) - (t_coords2.y - t_coords1.y)*(t_coords3.x - t_coords1.x))**2)**0.5;

		return area;

	endfunction : get_area

endclass : triangle_c

//---------------------------------------------------------------------
class polygon_c extends shape_c;

	//-------------------------
	function new(string name,coordinates_struct points[$]);

		super.new(name,points);

	endfunction : new

	//-------------------------
	function real get_area();

		return 0.0;

	endfunction : get_area

endclass : polygon_c
//---------------------------------------------------------------------

//---------------------------------------------------------------------
class shape_factory;

	static function shape_c make_shape(coordinates_struct points[$]);

		circle_c circle_o;
		triangle_c triangle_o;
		rectangle_c rectangle_o;
		polygon_c polygon_o;

		coordinates_struct points_q[$];
		coordinates_struct points_q_copy[$];

		static int ctr_local = 0;
		coordinates_struct point1;
		coordinates_struct point2;
		coordinates_struct point3;
		coordinates_struct point4;
		real diameter1 = 0.0;
		real diameter2 = 0.0;

		points_q_copy = points;

		ctr_local = 0;

		foreach(points[i]) ctr_local++;

		point1 = points_q_copy.pop_front();
		point2 = points_q_copy.pop_front();
		point3 = points_q_copy.pop_front();
		point4 = points_q_copy.pop_front();

		diameter1 = ((point1.x - point3.x)**2 + (point1.y - point3.y)**2)**0.5;
		diameter2 = ((point2.x - point4.x)**2 + (point2.y - point4.y)**2)**0.5;

		//  in case of 4 points check if it's rectangle
		if (ctr_local == 4 && diameter1 != diameter2) ctr_local = 5;

		case (ctr_local)

			CIRCLE:
			begin
				circle_o = new("circle",points);
				return circle_o;
			end

			TRIANGLE:
			begin
				triangle_o = new("triangle",points);
				return triangle_o;
			end

			RECTANGLE:
			begin
				rectangle_o = new("rectangle",points);
				return rectangle_o;
			end

			default :
			begin
				polygon_o = new("polygon",points);
				return polygon_o;
			end

		endcase // case (species)

	endfunction : make_shape

endclass : shape_factory


//---------------------------------------------------------------------
class shape_reporter #(type T = shape_c);

	protected static T storage[$];
	protected static int i = 0;
	//-------------------------
	static function void shapes_storage(T l);

		storage.push_back(l);

	endfunction : shapes_storage

	//-------------------------
	static function void report_shapes();

		foreach (storage[i]) storage[i].print();

	endfunction : report_shapes

endclass : shape_reporter

//------------------------------------------------------------------------------------------------------------------------------------------
module top;

	/*
	 * The main top module should:
	 * - read the lab04part1_shapes.txt file;
	 * - call the make_shape() function for each line of the file;
	 * - call the report_shapes() function for each object type.
	 */

	coordinates_struct x_y_pos;
	coordinates_struct coordinates_q  [$];
	shape_c shape_o;

	string filename = "/home/student/zwatroba/VDIC/lab04part1/lab04part1_shapes.txt";
	string line;
	string temp_string = "";
	int ctr = 0;
	int n = 0;
	int j= 0;
	int no_of_char_read = 0;

// Reading the lab04part1_shapes.txt file
//---------------------------------------------------------------------


	initial
	begin

		//read file
		static int file = $fopen(filename, "r");

		if (file == 0) begin
			$display("ERROR: can't open the file %s", filename);
			$stop;
		end

		while (!$feof(file))
		begin

			no_of_char_read = $fgets(line,file);

			if (no_of_char_read != 0)
			begin

				j = 0;

				foreach (line[n])
				begin

					if (line[n] != " " && line[n] != 10)
					begin

						temp_string = {temp_string,line[n]};

					end

					else if (line[n] == " " || line[n] == 10)
					begin

						if (j % 2 == 0)
						begin
							x_y_pos.x = temp_string.atoreal();
						end

						else
						begin
							x_y_pos.y = temp_string.atoreal();
							coordinates_q.push_back(x_y_pos);
						end
						j++;
						temp_string = "";

					end

				end

			end

			/* - call the make_shape() function for each line of the file;*/
			shape_o = shape_factory::make_shape(coordinates_q);

			/* - call the report_shapes() function for each object type.*/
			shape_reporter#(shape_c)::shapes_storage(shape_o);

			coordinates_q.delete();

			
			ctr++;

		end

		shape_reporter#(shape_c)::report_shapes();

		$fclose(file);

	end

endmodule : top




