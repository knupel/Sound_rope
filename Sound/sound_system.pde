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
float [] radius_beat,radius_transient;
void sound_system_setup() {
	build_log_sound() ;

  int length_analyze = 512 ;
	sounda = new Sounda(length_analyze);

  int num_spectrum_bands = 128;
  float scale_spectrum_sound = .11 ;
  sounda.set_spectrum(num_spectrum_bands, scale_spectrum_sound) ;

  int num_section = 4 ;
  iVec2 [] section_in_out = new iVec2[num_section];
  section_in_out[0] = iVec2(0,5);
  section_in_out[1] = iVec2(5,30);
  section_in_out[2] = iVec2(30,85);
  section_in_out[3] = iVec2(85,128);
  sounda.set_section(section_in_out);
  
  /**
  transient
  */
  int [] transient_section_id = new int[section_in_out.length] ;
  transient_section_id[0] = 0;
  transient_section_id[1] = 1;
  transient_section_id[2] = 2;
  transient_section_id[3] = 3;

  Vec2 [] transient_part_threshold = new Vec2[section_in_out.length];
  transient_part_threshold[0] = Vec2(.1, 2.5);
  transient_part_threshold[1] = Vec2(.3, 4.5);
  transient_part_threshold[2] = Vec2(.4, 6.5);
  transient_part_threshold[3] = Vec2(.5, 8.5);

  sounda.set_transient(transient_section_id, transient_part_threshold);
  // set_beat(beat_part_threshold); // this method don't need to set section

  radius_transient = new float[transient_part_threshold.length];
  /**
  beat
  */
  int [] beat_section_id = new int[section_in_out.length] ;
  beat_section_id[0] = 0;
  beat_section_id[1] = 1;
  beat_section_id[2] = 2;
  beat_section_id[3] = 3;

  float [] beat_part_threshold = new float[section_in_out.length];
  beat_part_threshold[0] = 3.5;
  beat_part_threshold[1] = 2.5;
  beat_part_threshold[2] = 1.5;
  beat_part_threshold[3] = .5;

  sounda.set_beat(beat_section_id, beat_part_threshold);
  // set_beat(beat_part_threshold); // this method don't need to set section

  radius_beat = new float[beat_part_threshold.length];
 

  float [] tempo_threshold = new float[section_in_out.length];
  tempo_threshold[0] = 4.5;
  tempo_threshold[1] = 3.5;
  tempo_threshold[2] = 2.5;
  tempo_threshold[3] = .5;
  sounda.set_tempo(tempo_threshold);
  // set_tempo();

}


void sound_system_draw() {
	sounda.update();

  show_spectrum();
  show_beat();
  show_transient();
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
  text("tempo global: "+sounda.get_tempo_name()+" "+sounda.get_tempo(),pos_x,pos_y);
  // all beat have a tempo catchable init_tempo(true);
  if(sounda.section_num() > 1) {
    for(int i = 0 ; i < sounda.section_num();i++) {
      int rank = i+1;
      text("Tempo "+i+" threshold "+ sounda.get_tempo_threshold(i)+" – " +sounda.get_tempo_name(i)+" "+sounda.get_tempo(i),pos_x,pos_y +(rank*(size*1.3)));
    }
  }
}





void show_beat_range() {
  stroke(r.WHITE);
  strokeWeight(1);
  float step = sounda.buffer_size() / sounda.band_num();
  for(int i = 1 ; i < sounda.section_num() -1 ; i++) {
    int line_in_x = int(sounda.get_section_in(i) *step);
    line(line_in_x, 0, line_in_x, height) ;
    int line_out_x = int(sounda.get_section_out(i) *step);
    line(line_out_x, 0, line_out_x, height);
  }
}


void show_transient() {
  sounda.audio_buffer(r.MIX);

  for(int i = 0 ; i < sounda.section_num() ; i++) {
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

  if(sounda.section_num() > 1) {
    for(int i = 0 ; i < sounda.section_num();i++) {
      int rank = i;
      int x = pos_x ;
      int y = int(pos_y +(rank*(size*1.3)));
      text("transient "+(i+1)+" threshold "+ sounda.get_transient_threshold(i)+" : " +sounda.transient_is(i),x,y);
    }
  }
}





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
  int pos_y = height/3;

  if(sounda.section_num() > 1) {
    for(int i = 0 ; i < sounda.section_num();i++) {
      int rank = i+1;
      text("Beat "+i+" threshold "+ sounda.get_beat_threshold(i)+" : " +sounda.beat_is(i),pos_x,pos_y +(rank*(size*1.3)));
    }
  }
}




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
  int pos_y = height/2 +(height/6);
  // only one tempo is available init_tempo(false);
  float value = truncate(sounda.get_spectrum_average(),5) *100;
  text("Spectrum average value: "+value,pos_x,pos_y);

}

void show_spectrum_level(Vec2 pos, int size) {
	float band_width = height /  sounda.band_num() ;
  for(int i = 0; i < sounda.band_num(); i++) {
    float pos_x = i * band_width +pos.x;
    float pos_y = pos.y + abs(size) ;
    float size_x = band_width ;
    float size_y = -(sounda.get_spectrum(i) *size) ;
    rect(pos_x, pos_y, size_x, size_y) ;
  }
}




void show_beat_spectrum_level(Vec2 pos, int size) {
	float band_width = height /  sounda.band_num() ;
  for(int i = 0 ; i < sounda.section_num() ; i++) {
    for(int k = 0; k < sounda.band_num() ; k++) {
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

















