Sounda sounda;
/**
STOP
*/
void stop() {
  sounda.stop();
  super.stop();
}


/**
setup
*/


void sound_system_setup() {
	build_log_sound() ;

  int length_analyze = 512 ;
	sounda = new Sounda(length_analyze);
  set_spectrum();
  set_section();
  set_transient();
  set_beat();
  set_tempo();
}



void set_spectrum() {
  int num_spectrum_bands = 128;
  float scale_spectrum_sound = .11 ;
  sounda.set_spectrum(num_spectrum_bands, scale_spectrum_sound) ;
}


iVec2 [] section_in_out;
void set_section() {
  int num_section = 4 ;
  section_in_out = new iVec2[num_section];
  section_in_out[0] = iVec2(0,60);
  section_in_out[1] = iVec2(60,160);
  section_in_out[2] = iVec2(160,310);
  section_in_out[3] = iVec2(310,sounda.buffer_size());
  sounda.set_section(section_in_out); // by deffault the section is built on the buffer_size() value pass in the Sounda Constructor
}





float [] radius_transient;
void set_transient() {
  sounda.set_transient_low_pass(20);     
  sounda.set_transient_smooth_slow(3.);
  sounda.set_transient_smooth_fast(21.);
  sounda.set_transient_ratio_transient(100,50,40,30); 
  sounda.set_transient_threshold_low(.05,.08,.12,.16);
  sounda.set_transient_threshold_high(.8,.3,.25,.20);
  // lp>20 || tss>200 || tsf>800 || trt>75 || ttf>0.1 || tts>0.5
  // lp>20 || tss>3 || tsf>21 || trt>75 || ttf>0.1 || tts>0.35 // more detail in the curve with tss and tsf low
  
  Vec2 [] transient_part_threshold = new Vec2[sounda.section_size()];
  transient_part_threshold[0] = Vec2(.1, 0.5);
  transient_part_threshold[1] = Vec2(.1, 0.5);
  transient_part_threshold[2] = Vec2(.1, 0.5);
  transient_part_threshold[3] = Vec2(.1, 0.5);
  sounda.init_transient(transient_part_threshold);
  // after you can sect a specific transient like
  int section_index = 0 ;
  Vec2 new_value_threshold = Vec2(.25, 5.9);
  sounda.set_transient(section_index,new_value_threshold);

  radius_transient = new float[transient_part_threshold.length];
}


float [] radius_beat; 
void set_beat() {
  int [] beat_section_id = new int[sounda.section_size()] ;
  beat_section_id[0] = 0;
  beat_section_id[1] = 1;
  beat_section_id[2] = 2;
  beat_section_id[3] = 3;

  float [] beat_part_threshold = new float[sounda.section_size()];
  beat_part_threshold[0] = 3.5;
  beat_part_threshold[1] = 2.5;
  beat_part_threshold[2] = 1.5;
  beat_part_threshold[3] = .5;

  sounda.set_beat(beat_section_id, beat_part_threshold);

  radius_beat = new float[beat_part_threshold.length];
}




void set_tempo() {
  float [] tempo_threshold = new float[sounda.section_size()];
  tempo_threshold[0] = 4.5;
  tempo_threshold[1] = 3.5;
  tempo_threshold[2] = 2.5;
  tempo_threshold[3] = .5;
  sounda.set_tempo(tempo_threshold);
  // set_tempo();

}









// DRAW
void sound_system_draw() {
	// sounda.update_tempo(true);
  sounda.update_spectrum(true);

  show_spectrum();
  show_beat();
  show_transient();
  show_section();
  show_tempo();

  int log_each_frame = 60;
  boolean log_on_beat_only = true;
  // log_sound(log_each_frame, log_on_beat_only) ;
}




// spectrum
void show_spectrum() {
  noStroke();

  sounda.audio_buffer(RIGHT) ;
  fill(r.WHITE);
  show_beat_spectrum_level(Vec2(0), height/2);
  

  fill(r.BLACK);
  show_spectrum_level(Vec2(0),height/2);

  sounda.audio_buffer(LEFT);
  fill(r.WHITE);
  show_beat_spectrum_level(Vec2(0),-height/2);
  

  fill(r.BLACK);
  show_spectrum_level(Vec2(0),-height/2);


  textAlign(LEFT);
  fill(r.WHITE);
  int size = 14 ;
  textSize(size);
  int pos_x = width/6;
  int pos_y = height/2;
  // only one tempo is available init_tempo(false);
  float value = truncate(sounda.get_spectrum_average(),5) *100;
  text("Spectrum average value: "+value,pos_x,pos_y);

}

void show_spectrum_level(Vec2 pos, int size) {
  float band_width = height /  sounda.spectrum_size() ;
  for(int i = 0; i < sounda.spectrum_size(); i++) {
    float pos_x = i * band_width +pos.x;
    float pos_y = pos.y + abs(size) ;
    float size_x = band_width ;
    float size_y = -(sounda.get_spectrum(i) *size) ;
    rect(pos_x, pos_y, size_x, size_y) ;
  }
}



// section
void show_section() {
  stroke(r.WHITE);
  strokeWeight(1);
  // float step = sounda.buffer_size() / sounda.spectrum_size();
  float step = 1;
  for(int i = 1 ; i < sounda.section_size() -1 ; i++) {
    int line_in_x = int(sounda.get_section_in(i) *step);
    line(line_in_x, 0, line_in_x, height) ;
    int line_out_x = int(sounda.get_section_out(i) *step);
    line(line_out_x, 0, line_out_x, height);
  }
}













void show_tempo() {
  textAlign(LEFT);
  fill(r.WHITE);
  int size = 14 ;
  textSize(size);
  int pos_x = width/6;
  int pos_y = height/2 +(height/4);
  // only one tempo is available init_tempo(false);
  text("tempo global: "+sounda.get_tempo_name()+" "+sounda.get_tempo(),pos_x,pos_y);
  // all beat have a tempo catchable init_tempo(true);
  if(sounda.section_size() > 1) {
    for(int i = 0 ; i < sounda.section_size();i++) {
      int rank = i+1;
      text("Tempo "+i+" threshold "+ sounda.get_tempo_threshold(i)+" – " +sounda.get_tempo_name(i)+" "+sounda.get_tempo(i),pos_x,pos_y +(rank*(size*1.3)));
    }
  }
}












// transient
void show_transient() {
  sounda.audio_buffer(r.MIX);
  /*
  sounda.set_transient_low_pass(mouseX/10);     
  sounda.set_transient_smooth_slow(mouseX/10);
  sounda.set_transient_smooth_fast(sounda.get_transient_smooth_slow()[0] *10);
  sounda.set_transient_ratio_transient(1 +(mouseY/10));
  sounda.set_transient_threshold_first(.1);
  sounda.set_transient_threshold_second(.5);
  */
  /*
  sounda.set_transient_low_pass(3);     
  sounda.set_transient_smooth_slow(50);
  sounda.set_transient_smooth_fast(2000);
  sounda.set_transient_ratio_transient(50); // 100 not bad
  sounda.set_transient_threshold_first(.1);
  sounda.set_transient_threshold_second(1.);
  */

  for(int i = 0 ; i < sounda.section_size() ; i++) {
    if(sounda.transient_is(i)) {
      radius_transient[i] = height *.75 ;
    }
    radius_transient[i] *= .95;
  }
  float dist = width /5;
  textAlign(CENTER);
  float min_text_size = 1.;
  for(int i = 0 ; i < radius_transient.length ;i++) {
    int step = (i+1);
    fill(r.YELLOW,125);
    ellipse(dist *step,height/4,radius_transient[i],radius_transient[i]);
    float text_size = radius_transient[i] *.05;
    if(text_size > 1) {
      fill(r.WHITE);
      textSize(text_size);
      text("TRANSIENT "+i, dist *step, height/3);
    }
  }

  textAlign(LEFT);
  fill(r.WHITE);
  int size = 14 ;
  textSize(size);
  int pos_x = width/6;
  int pos_y = height/12;
  

  int rank = 0;
  if(sounda.section_size() > 1) {
    for(int i = 0 ; i < sounda.section_size();i++) {
      rank = i;
      int x = pos_x ;
      int y = int(pos_y +(rank*(size*1.3)));
      text("transient "+(i+1)+" threshold "+ sounda.get_transient_threshold(i)+" : " +sounda.transient_is(i),x,y);
    }
  }
  
  String value = ":";
  rank++;
  for(int i = 0 ; i < sounda.get_transient_low_pass().length ; i++) {
    value += (" " +sounda.get_transient_low_pass()[i]);
  }
  int y = int(pos_y +(rank*(size*1.3)));
  text("transient low pass: "+ value,pos_x,y);  

  value = ":";
  rank++;
  for(int i = 0 ; i < sounda.get_transient_smooth_slow().length ; i++) {
    value += (" " +sounda.get_transient_smooth_slow()[i]);
  }
  y = int(pos_y +(rank*(size*1.3)));
  text("transient smooth slow: "+ value,pos_x,y);

  value = ":";
  rank++;
  for(int i = 0 ; i < sounda.get_transient_smooth_fast().length ; i++) {
    value += (" " +sounda.get_transient_smooth_fast()[i]);
  }
  y = int(pos_y +(rank*(size*1.3)));
  text("transient smooth fast: "+ value,pos_x,y);

  value = ":";
  rank++;
  for(int i = 0 ; i < sounda.get_transient_ratio_transient().length ; i++) {
    value += (" " +sounda.get_transient_ratio_transient()[i]);
  }
  y = int(pos_y +(rank*(size*1.3)));
  text("transient ratio transient: "+ value,pos_x,y);

  value = ":";
  rank++;
  for(int i = 0 ; i < sounda.get_transient_threshold_low().length ; i++) {
    value += (" " +sounda.get_transient_threshold_low()[i]);
  }
  y = int(pos_y +(rank*(size*1.3)));
  text("transient threshold first: "+ value,pos_x,y);

  value = ":";
  rank++;
  for(int i = 0 ; i < sounda.get_transient_threshold_high().length ; i++) {
    value += (" " +sounda.get_transient_threshold_high()[i]);
  }
  y = int(pos_y +(rank*(size*1.3)));
  text("transient threshold second: "+ value,pos_x,y);



}











// beat
void show_beat() {
  for(int i = 0 ; i < radius_beat.length ;i++) {
    if(sounda.beat_is(i)) {
      radius_beat[i] = height *.75 ;
    }
    radius_beat[i] *= .95;
  }
  float dist = width /5;
  textAlign(CENTER);
  float min_text_size = 1.;
  for(int i = 0 ; i < radius_beat.length ;i++) {
    int step = (i+1);
    fill(r.YELLOW,125);
    ellipse(dist *step,height -(height/4),radius_beat[i],radius_beat[i]);
    float text_size = radius_beat[i] *.05;
    if(text_size > 1) {
      fill(r.WHITE);
      textSize(text_size);
      text("BEAT "+i, dist *step, height -(height/3));
    }
  }

  textAlign(LEFT);
  fill(r.WHITE);
  int size = 14 ;
  textSize(size);
  int pos_x = width/6;
  int pos_y = height/2;

  if(sounda.section_size() > 1) {
    for(int i = 0 ; i < sounda.section_size();i++) {
      int rank = i+1;
      text("Beat "+i+" threshold "+ sounda.get_beat_threshold(i)+" : " +sounda.beat_is(i),pos_x,pos_y +(rank*(size*1.3)));
    }
  }
}




void show_beat_spectrum_level(Vec2 pos, int size) {
  float band_width = height /  sounda.spectrum_size() ;
  for(int i = 0 ; i < sounda.section_size() ; i++) {
    for(int k = 0; k < sounda.spectrum_size() ; k++) {
      if(sounda.beat_band_is(i,k)) {
        float pos_x = k *band_width +pos.x;
        float pos_y = pos.y +abs(size);
        float size_x = band_width;
        float size_y = -size;
        rect (pos_x, pos_y, size_x, size_y);
      }
    }
  }
}































