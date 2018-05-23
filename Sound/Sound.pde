
void settings() {
  size(100, 100);
}

int length_analyze = 512 ;
float [] radius;
void setup() {
  build_log_sound() ;
  surface.setSize(length_analyze, length_analyze) ;

  background(0);

  // beat alert
  set_sound(length_analyze) ;

  int num_spectrum_bands = 128;
  float scale_spectrum_sound = .11 ;
  set_spectrum(num_spectrum_bands, scale_spectrum_sound) ;

  // classic beat setting
  
  float [] beat_part_threshold = {7.5,6.5,1.5,.6};
  // float [] beat_part_threshold = {6.5,4.5,1.5};
  //set_beat(beat_part_sensibility) ;

  iVec2 [] beat_in_out = new iVec2[beat_part_threshold.length];
  /*
  beat_in_out[0] = iVec2(0,5);
  beat_in_out[1] = iVec2(5,10);
  beat_in_out[2] = iVec2(10,16);
  */
  
  beat_in_out[0] = iVec2(0,5);
  beat_in_out[1] = iVec2(5,30);
  beat_in_out[2] = iVec2(30,85);
  beat_in_out[3] = iVec2(85,128);

  set_beat(beat_in_out, beat_part_threshold);
  // set_beat(.5,.6);

  radius = new float[beat_part_threshold.length];

  init_tempo(true);

}      



void draw() {


  background_rope(r.BLOOD);


  update_sound();
  show_spectrum();
  show_beat();
  show_beat_range();
  show_tempo();


  int log_each_frame = 60;
  boolean log_on_beat_only = true;
  // log_sound(log_each_frame, log_on_beat_only) ;

}


void show_tempo() {
  textAlign(LEFT);  
  fill(r.WHITE);
  int size = 14 ;
  textSize(size);
  int pos_x = width/6;
  int pos_y = height/2 +(height/4);
  // only one tempo is available init_tempo(false);
  text("tempo global: "+get_tempo_name()+" "+get_tempo(),pos_x,pos_y);
  // all beat have a tempo catchable init_tempo(true);
  if(beat_num() > 1) {
    for(int i = 0 ; i < beat_num();i++) {
      int rank = i+1;
      text("tempo "+i+": "+get_tempo_name()+" "+get_tempo(i),pos_x,pos_y +(rank*(size*1.3)));
    }
  } 
}



void show_beat_range() {
  stroke(r.WHITE);
  strokeWeight(1);
  float step = length_analyze / band_num();
  for(int i = 1 ; i < beat_num() -1 ; i++) {
    int line_in_x = int(get_beat_in(i) *step);
    line(line_in_x, 0, line_in_x, height) ;
    int line_out_x = int(get_beat_out(i) *step);
    line(line_out_x, 0, line_out_x, height);
  }
}



void show_beat() {
  for(int i = 0 ; i < radius.length ;i++) {
    if(beat_is(i)) {
      radius[i] = height *.75 ;
    }
    radius[i] *= .95;
  }

  float dist = width /5;
  textAlign(CENTER);  
  float min_text_size = 1.;
  for(int i = 0 ; i < radius.length ;i++) {
    int step = (i+1);
    fill(r.YELLOW,125);
    ellipse(dist *step,height/2,radius[i],radius[i]);
    float text_size = radius[i] *.05;
    if(text_size > 1) {
      fill(r.WHITE);
      textSize(text_size);
      text("beat "+i, dist *step, height/3);
    }
  }
}



void show_spectrum() {
  noStroke();

  audio_buffer(RIGHT) ;
  fill(r.WHITE);
  show_beat_spectrum_level(Vec2(0), height/2);
  fill(r.BLACK);
  show_spectrum_level(Vec2(0),height/2); 

  audio_buffer(LEFT);
  fill(r.WHITE);
  show_beat_spectrum_level(Vec2(0),-height/2);
  fill(r.BLACK);
  show_spectrum_level(Vec2(0),-height/2); 

}

void show_spectrum_level(Vec2 pos, int size) {
  for(int i = 0; i < band_num(); i++) {
    float pos_x = i * band_size +pos.x;
    float pos_y = pos.y + abs(size) ;
    float size_x = band_size ;
    float size_y = -(get_spectrum(i) *size) ;
    rect(pos_x, pos_y, size_x, size_y) ;
  } 
}

void show_beat_spectrum_level(Vec2 pos, int size) {
  for(int i = 0 ; i < beat_num() ; i++) {
    for(int k = 0; k < band_num() ; k++) {
      if(beat_band_is(i,k)) {
        float pos_x = k *band_size +pos.x;
        float pos_y = pos.y +abs(size);
        float size_x = band_size;
        float size_y = -size;
        rect (pos_x, pos_y, size_x, size_y);
      }
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
    for(int target_beat = 0 ; target_beat < beat_num() ;target_beat++) {
      for(int target_band = 0 ; target_band < get_spectrum().length ; target_band++) {
        if(log_beat_only) {
          if(beat_band_is(target_beat,target_band)) {
            write_log_sound(time,target_beat,target_band, beat_band_is(target_beat,target_band), get_beat_section(target_band), get_beat_threshold(target_beat,target_band), get_spectrum(target_band)) ;
          }
        } else {
          write_log_sound(time,target_beat,target_band, beat_band_is(target_beat,target_band), get_beat_section(target_band), get_beat_threshold(target_beat,target_band), get_spectrum(target_band)) ;
        }     
      }
    }
  }
}


void write_log_sound(String time, int id_beat, int id_band, boolean beat_is, int section, float threshold, float spectrum) {
  TableRow newRow = log_sound.addRow();
  newRow.setString("time", time);
  newRow.setInt("beat id", id_beat);
  newRow.setInt("band id", id_band);
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




















