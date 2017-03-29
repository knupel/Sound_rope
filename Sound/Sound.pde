
void settings() {
  size(100, 100);
}


String preference_path  ;
void setup() {


  preference_path = sketchPath("")+"preferences/" ;
  load_sound_setting() ;
  build_log_sound() ;
  surface.setSize(length_analyze, length_analyze) ;

  background(255);

  // beat alert
  set_sound(length_analyze) ;
  set_spectrum(num_spectrum_bands) ;
  set_beat(beat_part_sensibility) ;
  spectrum_scale(scale_spectrum_sound) ;
  
}      


float radius ;
void draw() { 
  background_rope(255,75) ;
  noStroke() ;

  if(beat_is()) {
    radius = height *.75 ;
  }
  fill(255,230,0) ;
  radius *= .95 ;
  ellipse(width/2,height/2,radius,radius) ;

  audio_buffer(RIGHT) ;

  fill(0) ;
  noStroke() ;
  show_beat(Vec2(0), height/2) ;

  fill(255,0,0) ;

  show_spectrum(Vec2(0), height/2) ; 
  

  audio_buffer(LEFT) ;
  fill(0) ;
  noStroke() ;
  show_beat(Vec2(0), -height/2) ;

  fill(255,0,0) ;
  noStroke() ;
  show_spectrum(Vec2(0), -height/2) ; 

  log_sound() ;

}




/**
setting
*/

Table sound_setting ;
int length_analyze = 512 ;
int num_spectrum_bands = 256 ;
float scale_spectrum_sound = .2 ;
float [] beat_part_sensibility ;
boolean log_sound_is ;
boolean log_beat_only ;
int log_sound_frame ;

void load_sound_setting() {
  String preference_path_sound = preference_path +"sound/sound_rope.csv" ;
  sound_setting = loadTable(preference_path_sound, "header");
  
  String beat_sensibility = "" ;
  String log_is = "" ;
  String log_beat_is = "" ;
  for (TableRow row : sound_setting.rows()) {
    length_analyze = row.getInt("Analyze");
    num_spectrum_bands = row.getInt("Bands");
    scale_spectrum_sound = row.getFloat("Scale spectrum") ;
    beat_sensibility = row.getString("Beat sensibility") ;
    log_is = row.getString("Log is") ;
    log_beat_is = row.getString("Log beat") ;
    log_sound_frame = row.getInt("Log frame");
  }

  if(log_is.equals("true") || log_is.equals("TRUE")) {
    log_sound_is = true ;
  }

  if(log_beat_is.equals("true") || log_beat_is.equals("TRUE")) {
    log_beat_only = true ;
  }

  String [] split = split_text(beat_sensibility, "/") ;
  beat_part_sensibility = new float[split.length] ;
  for(int i = 0 ; i < split.length ; i++) {
    beat_part_sensibility[i] = Float.parseFloat(split[i]);
  }
}



/**
log
*/
Table log_sound ;
TableRow [] tableRow_sound ;
String date_log_sound = "" ;


void build_log_sound() {
  if(log_sound_is) {
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
  
}


void log_sound() {
  if(log_sound_is && frameCount%log_sound_frame == 0) {
    String time = hour() +" "+ minute() +" "+ second() +" "+ frameCount ;
    println(time) ;
    for(int i = 0 ; i < spectrum().length ; i++) {
      if(log_beat_only) {
        if(beat_is(i)) {
          // println(i, beat_is(i), get_beat_alert(i), spectrum(i)) ;
          write_log_sound(time, i, beat_is(i), beat_section(i), get_beat_alert(i), spectrum(i)) ;
        }
      } else {
        // println(i, beat_is(i), get_beat_alert(i), spectrum(i)) ;
        write_log_sound(time, i, beat_is(i), beat_section(i), get_beat_alert(i), spectrum(i)) ;
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
      if(beat_is(i)) {
      float pos_x = i * band_size +pos.x ;
      float pos_y = pos.y + abs(size) ;
      float size_x = band_size ;
      float size_y = -size ;
      rect (pos_x, pos_y, size_x, size_y) ;
    }
  } 
}









