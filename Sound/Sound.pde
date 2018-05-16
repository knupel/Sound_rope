
void settings() {
  size(100, 100);
}


int length_analyze = 512 ;
// Beat [] beat = new Beat[4] ;

void setup() {
  
  build_log_sound() ;
  surface.setSize(length_analyze, length_analyze) ;

  background(0);

  // beat alert
  set_sound(length_analyze) ;

  int num_spectrum_bands = 32 ;
  float scale_spectrum_sound = .11 ;
  set_spectrum(num_spectrum_bands, scale_spectrum_sound) ;

  // classic beat setting
  
  float [] beat_part_sensibility = {1.5,.8,.3,.3};
  //set_beat_basic(beat_part_sensibility) ;


  // class Beat

  iVec2 [] beat_in_out = new iVec2[beat_part_sensibility.length];
  beat_in_out[0] = iVec2(0,5);
  beat_in_out[1] = iVec2(5,30);
  beat_in_out[2] = iVec2(30,85);
  beat_in_out[3] = iVec2(85,128);
  // set_beat(beat_in_out, beat_part_sensibility);
  set_beat(.5,.6);

}      


float radius_x_bass, radius_bass, radius_medium, radius_high ;
void draw() { 
  // background_rope(255,75) ;
  // println(frameRate) ;
  background_rope(0);
  noStroke() ;

  if(beat_is(0)) {
    //println("EXTRA BASSE", frameCount) ;
    radius_x_bass = height *.75 ;
  }
  if(beat_is(1)) {
    // println("BASSE", frameCount) ;
    radius_bass = height *.75 ;
  }
  if(beat_is(2)) {
    // println("MEDIUM", frameCount) ;
    radius_medium = height *.75 ;
  }
  if(beat_is(3)) {
    // println("HIGH", frameCount) ;
    radius_high= height *.75 ;
  }
  
  radius_x_bass *= .95;
  radius_bass *= .95;
  radius_medium *= .95;
  radius_high *= .95;
  float dist = width /5;
  textAlign(CENTER);
  fill(r.BLOOD);
  float min_text_size = 1.;
  if(radius_x_bass > min_text_size) {
    textSize(radius_x_bass *.05);
    text("extra-basse", dist, height/3);
  }
  if(radius_bass > min_text_size) {
    textSize(radius_bass *.05);
    text("basse", dist*2, height/3);
  }
  if(radius_medium > min_text_size) {
    textSize(radius_medium *.05);
    text("medium", dist*3, height/3);
  }
  if(radius_high > min_text_size) {
    textSize(radius_high *.05);
    text("haut", dist*4, height/3);
  }
  fill(r.YELLOW);
  ellipse(dist,height/2,radius_x_bass,radius_x_bass) ;
  ellipse(dist*2,height/2,radius_bass,radius_bass) ;
  ellipse(dist*3,height/2,radius_medium,radius_medium) ; 
  ellipse(dist*4,height/2,radius_high,radius_high) ;
  // line
  stroke(r.BLACK);
  float step = length_analyze / num_bands();
  for(int i = 0 ; i < beat_num() ; i++) {
    int line_in_x = int(get_beat_in(i) *step);
    line(line_in_x, 0, line_in_x, height) ;
    int line_out_x = int(get_beat_out(i) *step);
    line(line_out_x, 0, line_out_x, height);
  }


  audio_buffer(RIGHT) ;

  fill(r.BLACK);
  noStroke();
  show_beat(Vec2(0), height/2);

  fill(255,0,0);

  show_spectrum(Vec2(0),height/2); 
  

  audio_buffer(LEFT);
  fill(r.BLACK);
  noStroke();
  show_beat(Vec2(0),-height/2) ;

  fill(r.WHITE);
  noStroke();
  show_spectrum(Vec2(0),-height/2) ; 
  

  int log_each_frame = 60;
  boolean log_on_beat_only = true;
  // log_sound(log_each_frame, log_on_beat_only) ;

}



/**
sound method
*/
void show_spectrum(Vec2 pos, int size) {
  for(int i = 0; i < num_bands(); i++) {
    float pos_x = i * band_size +pos.x;
    float pos_y = pos.y + abs(size) ;
    float size_x = band_size ;
    float size_y = -(spectrum(i) *size) ;
    rect(pos_x, pos_y, size_x, size_y) ;
  } 
}


void show_beat(Vec2 pos, int size) {
  for(int i = 0; i < num_bands() ; i++) {
    if(beat_band_is(i)) {
      float pos_x = i *band_size +pos.x;
      float pos_y = pos.y +abs(size);
      float size_x = band_size;
      float size_y = -size;
      rect (pos_x, pos_y, size_x, size_y);
    }
  }
}















/**
log
*/
Table log_sound ;
TableRow [] tableRow_sound ;
String date_log_sound = "" ;


void build_log_sound() {
  log_sound = new Table() ;
  date_log_sound = year()+"_"+month()+"_"+day()+"_"+hour()+"_"+minute()+"_"+second() ;
  log_sound = new Table() ;
  log_sound.addColumn("time") ;
  log_sound.addColumn("band id") ;
  log_sound.addColumn("section") ;
  log_sound.addColumn("beat") ;
  log_sound.addColumn("threshold") ;
  log_sound.addColumn("spectrum") ;
}


void log_sound(int log_sound_frame, boolean log_beat_only) {
  if(frameCount%log_sound_frame == 0) {
    String time = hour() +" "+ minute() +" "+ second() +" "+ frameCount ;
    for(int i = 0 ; i < spectrum().length ; i++) {
      if(log_beat_only) {
        if(beat_band_is(i)) {
          // println(i, beat_is(i), get_beat_alert(i), spectrum(i)) ;
          write_log_sound(time, i, beat_band_is(i), beat_section(i), get_beat_alert(i), spectrum(i)) ;
        }
      } else {
        // println(i, beat_is(i), get_beat_alert(i), spectrum(i)) ;
        write_log_sound(time, i, beat_band_is(i), beat_section(i), get_beat_alert(i), spectrum(i)) ;
      }     
    }
  }
}


void write_log_sound(String time, int id, boolean beat_is, int section, float threshold, float spectrum) {
  TableRow newRow = log_sound.addRow();
  newRow.setString("time", time);
  newRow.setInt("band id", id);
  if(beat_is) {
    newRow.setString("beat", "true");
  } else {
    newRow.setString("beat", "false");
  }
  newRow.setInt("section", section);
  newRow.setFloat("threshold", threshold);
  newRow.setFloat("spectrum", spectrum);

  saveTable(log_sound, sketchPath("") + "/log/log_sound_"+date_log_sound+".csv") ;
}




















