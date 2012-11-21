#to do: log the clrchng eye data in a separate file, along with cue position, so that eye data can be calibrated later.

active_buttons = 2;
button_codes = 1, 2;

##############################################################################################
begin;	#begin SDL (defining the experiment images / trial types)
##############################################################################################
video { filename = "party.avi"; detailed_logging = true; release_on_stop = true;} vid;


#CLRCHNG OBJECTS
box{height = 10; width = 10; color = "150, 150, 150";} box1;
box{height = 10; width = 10; color = "195, 195, 130";} box2;

picture{} default;
picture{display_index = 2;} default2;
picture{	box box1; x=0; y=0;}ccue;
picture{ box box2; x=0; y=0;}cstim;

picture{
	display_index=2;  #display this picutre on the experimenter's monitor (monitor 2)

	#draw a white box, this is the fixspot, height/width are temporary and are updated later
	box {color = 255,255,255;height=10;width=10;display_index=2;}fixspot;
	x=0; y=0; #the position of the fixspot, this can be edited in the PCL code
	on_top=true; #draw the fixspot on top layer of the picture
	
	#draw a green box, this is the eyeposition, height/width are 3 pixels
	box {color=0,255,0;height=3;width=3;display_index=2;};
	x=0; y=0; #the eye position is updated throughout the fixspot presentation
	on_top=true; # plot the eye positon on the top layer of the picture
	
	box {color = 255,0,0;height=600;width=800;display_index=2;}fixspotBoundary;
	x=0; y=0;
	
	box {color = 0,0,0;height=590;width=790;display_index=2;}fixspotBoundary2;
	x=0; y=0; 
	
	text { caption = "+"; font_size = 36; font = "Courier"; transparent_color = 0,0,0; font_color= 0,0,0; display_index=2;}cross;
	x = 0; y = 0; on_top=true;
	
}fixspot_copy; #the name of this picture is "fixspot_copy"

picture{
	display_index = 1;
	text { caption = "+"; font_size = 36; font = "Courier"; transparent_color = 0,0,0; };
	x = 0; y = 0;
}fixreq;

picture{
	display_index=2;  #display this picutre on the experimenter's monitor (monitor 2)

	#draw a white box, this is the fixspot, height/width are temporary and are updated later
	text { caption = "+"; font_size = 36; font = "Courier"; transparent_color = 0,0,0; display_index = 2;};
	x=0; y=0; #the position of the fixspot, this can be edited in the PCL code
	on_top=true; #draw the fixspot on top layer of the picture
	
	#draw a green box, this is the eyeposition, height/width are 3 pixels
	box {color=0,255,0;height=3;width=3;display_index=2;};
	x=0; y=0; #the eye position is updated throughout the fixspot presentation
	on_top=true; # plot the eye positon on the top layer of the picture
	
	box {color = 255,0,0;height=72;width=72;display_index=2;}fixreqBoundary;
	x=0; y=0;
	
	box {color = 0,0,0;height=62;width=62;display_index=2;}fixsreqBoundary2;
	x=0; y=0; 
	
}fixreq_copy; #the name of this picture is "fixspot_copy"

###############
begin_pcl;
##################

int iteration = 1;

output_file eyedata = new output_file;

eyedata.open( date_time("mm_dd_yyyy_hh_nn") + ".txt", true );

# ~~~~~~~~~~~~~~~~~~ INITIALIZATION VARIABLES AND SET THEIR VALUES ~~~~~~~~~~~~~~~~~~~~~
double monitorX=800.0; #monitor width (pixels)
double monitorY=600.0; #monitor height (pixels)
double ratioX=(monitorX/2.0)/4.0; #ratio to multiply ISCAN eyeX voltage by to convert volts into pixels (want 5Volts to be at least 1/2 the width of the monitor)
double ratioY=(monitorY/2.0)/4.0; #ratio to multiply ISCAN eyeY voltage by to convert volts into pixels (want 5Volts to be at least 1/2 the height of the mon

int x;
int y; 
int xory;
int reward = 0;

dio_device iscan = new dio_device(ni_dio_device, 1, 0); # initialize the analog portion of the NI DIO card in the presentaiton computer so that we can collect eye data
int idX = iscan.acquire_analog_input("ISCAN,x");  # set up retrieval of the x coordinate of eye tracker from Measurement and Automation software
int idY = iscan.acquire_analog_input("ISCAN,y");  # set up retrieval of the y coordinate of eye tracker from Measurement and Automation software
double iscan_x; # initialize variable for eye tracker x postion
double iscan_y; # initialize variable for eye tracker y postion

################

sub iti begin
	default.present(); 
	default2.present();
	wait_interval(1000);   
end;

sub monitor_eye begin
	iscan_x =iscan.read_analog(idX)*ratioX; # get the X eye position
	iscan_y =iscan.read_analog(idY)*ratioY; # get the Y eye position
	fixspot_copy.set_part_x( 2, iscan_x ); # set the X eye position to eyeposition of the picture
	fixspot_copy.set_part_y( 2, iscan_y ); # set the Y eye position to eyeposition of the picture
	fixspot_copy.present();
end;

sub fixate begin
	cross.set_font_color(255,255,255); cross.redraw();
	fixspot.set_color(0,0,0); fixspotBoundary.set_height(72); fixspotBoundary.set_width(72); fixspotBoundary2.set_height(65); fixspotBoundary2.set_width(65);

	
	int fixspotTime;
	loop bool ok = false; until ok == true begin
		fixreq.present();
		fixspotTime = clock.time();
		loop until iscan_x<double(36) && iscan_x>double(-36) &&
				iscan_y<double(36) && iscan_y>double(-36) ||
				(clock.time()-3000)>fixspotTime #conditional statement about eye postion and time
		begin	
			monitor_eye();
		end;
		
		if iscan_x>double(36) || iscan_x<double(-36) ||	iscan_y>double(36) || iscan_y<double(-36) then
			iti();
		else
			int clockticker = clock.time();
			loop until iscan_x>double(36) || iscan_x<double(-36) ||	iscan_y>double(36) || iscan_y<double(-36) || (clock.time()-500)>clockticker begin
				monitor_eye();
			end;
			
			if iscan_x>double(36) || iscan_x<double(-36) ||	iscan_y>double(36) || iscan_y<double(-36) then
				iti();
			else ok = true; 
			end;
		end;
	end;
	
	cross.set_font_color(0,0,0); cross.redraw();
	fixspot.set_color(255,255,255); fixspotBoundary.set_height(600); fixspotBoundary.set_width(800); fixspotBoundary2.set_height(590); fixspotBoundary2.set_width(790);
	default.present(); default2.present();
end;


sub clrchng begin

	loop until response_manager.response_data_count() > 0 begin 
		monitor_eye(); end;
	
	response_data last_response = response_manager.last_response_data();
	
	loop int i = 0; until i == 1 begin
	
		int error = 0;
		x = random(1, 2) * random(-1, 1) * 72;
		y = random(1, 2) * random(-1, 1) * 72;
		xory = random(1, 2);
		if xory == 1 then
			ccue.set_part_x(1, x); cstim.set_part_x(1, x);
			ccue.set_part_y(1, 0); cstim.set_part_y(1, 0); 
			fixspot_copy.set_part_x( 1, x ); # set the X eye position to eyeposition of the picture
			fixspot_copy.set_part_y( 1, 0 ); # set the Y eye position to eyeposition of the picture

		else
			ccue.set_part_y(1, y); cstim.set_part_y(1, y);
			ccue.set_part_x(1, 0); cstim.set_part_x(1, 0);
			fixspot_copy.set_part_x( 1, 0 ); # set the X eye position to eyeposition of the picture
			fixspot_copy.set_part_y( 1, y ); # set the Y eye position to eyeposition of the picture
		end;

		fixspot_copy.present(); # show the eye postion on the monitor
	
		loop until last_response.button() == 1 begin
		last_response = response_manager.last_response_data();
		monitor_eye();
		end;
	
		ccue.present();
		int ticker = clock.time();
		int cuetime = random(500, 1500);
		
		loop until (clock.time() - ticker) >= cuetime  || error == 1 begin
			last_response = response_manager.last_response_data();
			monitor_eye();
			if last_response.button() == 2 then
				error = 1;
			end;
		end;
	
		if error == 1 then
			iti();
		else		
			cstim.present();
			reward = 1;
			ticker = clock.time();
			
			loop  until ((clock.time() - ticker) >= 500) ||  reward > 1 begin
				monitor_eye();
				last_response = response_manager.last_response_data();
				if last_response.button() == 2 then
					default.present();
					i = i + 1;
					loop until reward > 5 begin
						wait_interval(50);
						output_port_manager.get_port( 1 ).send_code(1);
						reward = reward + 1;				
					end;	   			  
				end;
			end;
			iti();
		end;  
	end;
	
end;

sub movie begin
	#fixspot.set_color(0, 0, 0);
	vid.prepare();
	eyedata.print("\n\n\n" + "Iteration: " + string(iteration) + "\n\n\n");
	video_player.play(vid, "showtime");
	loop until vid.playing() == false begin
		#monitor_eye();		
		iscan_x =iscan.read_analog(idX)*ratioX; # get the X eye position
		iscan_y =iscan.read_analog(idY)*ratioY; # get the Y eye position
		eyedata.print(string(clock.time()) + "\t" + string(iscan_x) + "\t" + string(iscan_y) + "\t" + string(vid.frame_position()) + "\n");
	end;
end;

sub release begin
	iscan.release_analog_input(idX); # release the X eye postion
	iscan.release_analog_input(idY); # release the Y eye position
end;

########TASK##############

loop until iteration > 15 begin
	clrchng();
	fixate();
	movie();
	iteration = iteration + 1;
end;

release();

