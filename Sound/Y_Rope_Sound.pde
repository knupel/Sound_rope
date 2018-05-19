/**
SOUND rope
2017-2018
v 1.2.1
*/
import ddf.minim.*;
import ddf.minim.analysis.*;
Minim minim;
AudioInput input;
AudioBuffer source_buffer ;
FFT fft;
int bands_max;

/**
main
v 0.0.1
*/
void set_sound(int max) {
  bands_max = max ;
  minim = new Minim(this);
  input = minim.getLineIn(Minim.STEREO, bands_max);
}

void update_sound() {
  if(spectrum_sound_is) update_spectrum();
  if(tempo_sound_is) update_tempo();
}










/**
MISC
v 0.2.0
*/
int target_sound = 1 ;
float get_right(float scale) {
  return input.right.get(target_sound) *scale; 
}

float get_left(float scale) {
  return input.left.get(target_sound) *scale; 
}

float get_mix(float scale) {
  return input.mix.get(target_sound) *scale; 
}

float get_right() {
  return input.right.get(target_sound); 
}

float get_left() {
  return input.left.get(target_sound); 
}

float get_mix() {
  return input.mix.get(target_sound); 
}



/**
time track
v 1.1.0
*/
int time_track_elapse ;
float no_sound_since ;
float threshold_spectrum_sensibility = .6;
float time_to_reset_time_track = 1;

void set_time_track(float threshold, float time_to_reset) {
  threshold_spectrum_sensibility = threshold;
  time_to_reset_time_track = time_to_reset;
}

float get_time_track() {
  float result = 0;
  if(get_spectrum_sum() < threshold_spectrum_sensibility) {
    no_sound_since += .1;
  } else {
    no_sound_since = 0;
  }

  if(no_sound_since > time_to_reset_time_track) {
    time_track_elapse = 0;
    result = 0 ;
  } else {
    time_track_elapse += millis()%10 ;
    result = time_track_elapse *.01 ;
  }

  result = round(result *10.0f) /10.0f ;
  return result; 
}


boolean sound_plays_is() {
  if(get_time_track() > .2 ) return true ; else return false;
}


/**
set buffer
*/
int MIX = 41 ;
void audio_buffer(int canal) {
  switch(canal) {
    case RIGHT :
      source_buffer = input.right ;
      break ;
    case LEFT :
      source_buffer = input.left ;
      break ;
    case 41 :
      source_buffer = input.mix ;
      break ;
    default :
      source_buffer = input.mix ;
  }
}

























/**
SPECTRUM
v 0.0.3
*/
float[] spectrum  ;
int spectrum_bands = 0 ;
float band_size ;
float scale_spectrum = .1 ;
boolean spectrum_sound_is;
void set_spectrum(int num, float scale) {
  spectrum_sound_is = true;
  if(num > bands_max) {
    spectrum_bands = bands_max ;
  } else {
    spectrum_bands = num ;
  }

  band_size = bands_max / spectrum_bands ;
  spectrum = new float [spectrum_bands] ;
  fft = new FFT(input.bufferSize(), input.sampleRate());
  fft.linAverages(spectrum_bands);

  scale_spectrum = scale;
}

void update_spectrum() {
  if(source_buffer == null) {
    println("void spectrum(): there is no AudioBuffer selected, by default AudioBuffer input.mix is used");
    source_buffer = input.mix;
  }
  fft.forward(source_buffer);
  for(int i = 0 ; i < band_num();i++) {
    fft.scaleBand(i,scale_spectrum);
  } 
}

float [] get_spectrum() {
  float [] f = new float[spectrum_bands];
  for(int i = 0 ; i < spectrum_bands ; i++) {
    f[i] = fft.getBand(i);
  }
  return f;
}


float get_spectrum(int band_target){
  if(band_target < band_num()) {
    return fft.getBand(band_target);
  } else return Float.NaN; 
}

int band_num() {
  return spectrum_bands;
}


float get_spectrum_sum() {
  float result = 0 ;
  for (int i = 0 ; i < band_num() ; i++) {
    result += get_spectrum(i);
  }
  return result ;
}


float get_spectrum_beat_sum(int beat_target) {
  float result = 0 ;
  for (int i = get_beat_in(beat_target) ; i < get_beat_out(beat_target) ; i++) {
    result += get_spectrum(i);
  }
  return result ;
}





















/**
BEAT 
v 0.1.1
*/
/**
beat method
v 0.0.5
*/
int num_beat_section ;
Beat beat_rope[] ;
boolean beat_advance_is ;
boolean [][] beat_band_is ;
/**
setting
*/
void set_beat(float... threshold) {
  iVec2 [] in_out = new iVec2[threshold.length];
  int part = spectrum_bands / in_out.length;
  for(int i = 0 ; i < in_out.length ; i++) {
    in_out[i] = iVec2(i*part,(i+1)*part);
  }
  set_beat(in_out, threshold);
}

void set_beat(iVec2[] in_out, float... threshold) {
  beat_advance_is = true ;
  
  // beat_alert = new float[spectrum_bands] ;
  num_beat_section = in_out.length ;
  beat_band_is = new boolean [num_beat_section][spectrum_bands];
  // init var
  for(int i = 0 ; i < beat_band_is.length ; i++) {
    for(int k = 0 ; k < beat_band_is[0].length ; k++) {
      beat_band_is[i][k] = false;
    }
  }

  beat_rope = new Beat[num_beat_section] ;
  // check the max value of beat analyze
  for(int i = 0 ; i< num_beat_section ; i++) {
    if(in_out[i].y > spectrum_bands) {
      in_out[i].y = spectrum_bands;
      in_out[i].x = spectrum_bands -1;
      println("'OUT' of beat is upper of spectrum, the value beat 'y' max analyze is cap to the spectrum, and 'x' to spectrum minus '1") ;
    }
    if(in_out[i].x > spectrum_bands) {
      in_out[i].y = spectrum_bands;
      in_out[i].x = spectrum_bands -1;
      println("'IN' of beat is upper of spectrum, the value beat 'y' max analyze is cap to the spectrum, and 'x' to spectrum minus '1") ;
    }
  }

  // build the beat analyze if every thing is ok
  for(int i = 0 ; i < num_beat_section ; i++) {
    int length_analyze = in_out[i].y - in_out[i].x ;
    beat_rope[i] = new Beat(in_out[i].x, in_out[i].y, threshold[i]);
  }

  // declare which band must be analyze when there is a beat detection
  for(int i = 0 ; i < beat_rope.length ; i++ ) {
    for(int k = beat_rope[i].in ; k < beat_rope[i].out ; k++) {
      beat_band_is[i][k] = true ;
    }
  }
}


// boolean beat is
boolean beat_is() {
  boolean beat_is = false ;
  for(int i = 0 ; i < beat_num() ; i++) {
    for(int k = 0 ; k < spectrum_bands ; k++ ) {
      if(beat_band_is(i,k)) {
        beat_is = true ; 
        break ;
      }
    }
  }
  return beat_is; 
}

boolean beat_is(int beat_target) {
  boolean beat_is = false ;
  if(beat_target < beat_rope.length) {
    for(int band_target = beat_rope[beat_target].in ; band_target < beat_rope[beat_target].out ; band_target++) {
      if(beat_band_is(beat_target,band_target)) {
        beat_is = true; 
        break ;
      }
    }
  } else {
    printErrTempo(60,"method beat_is(",beat_target,") is out of the range, by default method return false",frameCount); 
  }
  return beat_is;
}



// beat band is
boolean beat_band_is(int beat_target, int band_target) {
  if(get_spectrum(band_target) > get_beat_threshold(beat_target,band_target)) {
    return true ; 
  } else {
    return false ;
  }
}


// get bet threshold
float get_beat_threshold(int beat_target, int band_target) {
  float alert = Float.MAX_VALUE ;
  // check if the target is on the beat range analyze
  if(beat_advance_is && beat_band_is[beat_target][band_target]) {
    alert = beat_rope[beat_target].get_threshold();
  } 
  return alert;
}

// get beat section
int get_beat_section(int band_target) {
  int section = -1;
  for(int i = 0 ; i < beat_rope.length ;i++) {
    if(band_target > beat_rope[i].in && band_target < beat_rope[i].out) {
      section = i ;
      break;
    }
  }
  if(section == -1) {
    println("method get_beat_section(): No section match with the target",band_target,"the method return -1");
  }
  return section ;
}

int get_beat_in(int beat_target) {
  if(beat_target < beat_rope.length) {
    return beat_rope[beat_target].in ;
  } else {
    printErr("method get_beat_in(): target",beat_target,"not found, method return -1");
    return -1;
  }
  
}

int get_beat_out(int beat_target) {
  if(beat_target < beat_rope.length) {
    return beat_rope[beat_target].out;
  } else {
    printErr("method get_beat_out(): target",beat_target,"not found, method return -1");
    return -1;
  }
}

int beat_num() {
  if(beat_rope != null && beat_rope.length > 0) {
    return beat_rope.length ;
  } else {
    printErr("method beat_num(): no array beat found method return -1");
    return -1;
  }
}


/**
class beat
v 0.0.2
*/
class Beat {
  float threshold;
  int in ;
  int out ;
  int [] beat_band ;
  public Beat(int in, int out, float threshold) {
    beat_band = new int[out -in +1];
    this.in = in;
    this.out = out;
    this.threshold = threshold;
  }

  public boolean beat_is() {
    boolean beat_is = false ;
    int max = out ;
    if(out >= spectrum_bands) {
      max = spectrum_bands -1;
    }

    for(int i = in ; i <= max ; i++) {
      if(get_spectrum(i) > threshold) {
        beat_is = true ;
        break ;
      }
    }
    return beat_is ;
  }
  
  // set
  public void set_threshold(float threshold) {
    this.threshold = threshold;
  }

  public void set_in(int in) {
    beat_band = new int[out -in +1];
    this.in = in;
  }

  public void set_out(int out) {
    beat_band = new int[out -in +1];
    this.out = out;
  }

  // get
  public float get_threshold() {
    return threshold;
  }

  public int get_in() {
    return in ;
  }

  public int get_out() {
    return out ;
  }
}



























/**
TEMPO
v 0.3.0
*/
float [] tempo_rope, tempo_rope_ref;
boolean tempo_sound_is;
void init_tempo(boolean advance_tempo) {
  tempo_sound_is = true;
  if(advance_tempo) {
    printErrTempo(60,"method init_tempo(boolean advance_tempo) is not availble at this time try in an other life");
    if(beat_num() > 0) {
      tempo_rope_ref = new float[beat_num()];
      tempo_rope = new float[beat_num()];
      for(int i = 0 ; i < beat_num() ; i++) {
        tempo_rope_ref[i] = 0;
        tempo_rope[i] = 0;
      }
    } else {
      printErr("method set_tempo(boolean true) must be used after set_beat() method");
    }
  }  
}


int time_tempo_count;
int sec_tempo_count;
void update_tempo() {
  if(second() != sec_tempo_count) {
    time_tempo_count++;
    sec_tempo_count = second();
  }
  compute_tempo();
}



int tempo_sound;
int time_elapse = 0;
boolean new_tempo_count = true;
void compute_tempo() {
  if(sound_plays_is()) {
    int time = 4;
    if(time_tempo_count%time == 0 && new_tempo_count) {
      new_tempo_count = false;
      time_elapse = 0;
      tempo_sound = tempo_sound_in_progress;
      if(tempo_sound < 40) tempo_sound = 40;
      tempo_sound_in_progress = 0 ;
    } 

    if(time_tempo_count%time != 0) new_tempo_count = true;

    time_elapse++;
    count_tempo();
  } else {
    tempo_sound_in_progress = 0 ;
    tempo_sound = 0 ;
  }
  
}


int tempo_sound_in_progress;
float alert_tempo = 4.5;
void count_tempo() {
  float div_step = alert_tempo / get_spectrum().length ;
  for(int i = 0 ; i < get_spectrum().length ; i++) {
    // increase sensibility in the high band of the spectrum
    float minus = ((i *div_step) *.8);
    float final_alert_tempo = alert_tempo - minus;
    if(get_spectrum(i) > final_alert_tempo) {
      tempo_sound_in_progress++;
      break;
    }
  }
}


int get_tempo() {
  return tempo_sound;
}

int get_tempo(int target_beat) {
  printErrTempo(60,"method get_tempo(int target_beat) is not availble at this time try in an other life");
  return 40;
}

String [] tempo_name = {"silenzio","largo","larghetto","adagio","andante","moderato","allegro","presto","prestissimo"};
String get_tempo_name() {
  if(tempo_sound <= 0) return tempo_name[0];
  else if(tempo_sound > 0 && tempo_sound <= 60) return tempo_name[1];
  else if(tempo_sound > 60 && tempo_sound <= 66) return tempo_name[2];
  else if(tempo_sound > 66 && tempo_sound <= 76) return tempo_name[3];
  else if(tempo_sound > 76 && tempo_sound <= 108) return tempo_name[4];
  else if(tempo_sound > 108 && tempo_sound <= 120) return tempo_name[5];
  else if(tempo_sound > 120 && tempo_sound <= 160) return tempo_name[6];
  else if(tempo_sound > 160 && tempo_sound <= 200) return tempo_name[7];
  else return tempo_name[7];
}







/*
float get_tempo_ref() {
  // I remove the snare because is very bad information and slow down the the speed
  float ref = 0;
  float sum = 0;
  for(int i = 0 ; i < beat_num() ; i++) {
    sum += get_tempo_ref(i);
  }
  float div = 1./beat_num();
  return 1 -(sum *div);
}



float get_tempo_ref(int beat_target) {
  float max = 1.;
  if(tempo_rope_ref != null) {
    if(beat_target < beat_num()) {
      // println(beat_target,tempo_rope_ref[beat_target],get_spectrum_sum(),get_spectrum_beat_sum(beat_target));
      if (tempo_rope_ref[beat_target] > max || get_spectrum_beat_sum(beat_target) < .03) {
        tempo_rope_ref[beat_target] = max;
      } else {
        // get_spectrum_beat_sum(beat_target)

      }
    }  
    return tempo_rope_ref[beat_target];
  } else {
    printErrTempo(60,"method get_tempo_ref(): return Float.NaN, need to use method set_tempo()");
    return Float.NaN;
  }
}
*/







































/**
color spectrum
v 0.1.0
*/
int [] color_spectrum(int component, int sort) {
  Vec2 range = Vec2(-1) ;
  return color_spectrum(component, sort, range);
}


int [] color_spectrum(int component, int sort, Vec2... range) {
  boolean reverse_alpha = true;
  // set range
  boolean range_is = false ;
  Vec2 range_x = null;
  Vec2 range_y = null;
  Vec2 range_z = null;
  Vec2 range_a = null;
  if(range.length == 1 && range[0].equals(-1)) {
    range_is = false ;
  } else {
    range_is = true ;
    if(range.length == 1) {
      range_x = range[0];
      range_y = range[0];
      range_z = range[0];
      range_a = range[0];
    } else if(range.length == 2) {
      range_x = range[0];
      range_y = range[0];
      range_z = range[0];
      range_a = range[1];
    } else if(range.length == 3) {
      range_x = range[0];
      range_y = range[1];
      range_z = range[2];
    } else if(range.length == 4) {
      range_x = range[0];
      range_y = range[1];
      range_z = range[2];
      range_a = range[3];
    } 
  }
  
  // spectrum part
  int x = 0;
  int y = 0;
  int z = 0;
  int a = 0;

  float norm_x = 1.;
  float norm_y = 1.;
  float norm_z = 1.;
  float norm_a = 1.;

  int [] line = new int[floor(band_num()/component)];
  int c = 0;
  int where = 0;
  int offset_0 = 0;
  int offset_1 = 0;
  int offset_2 = 0;
  int offset_3 = 0;

  for(int i = 0 ; i < line.length ; i++) {
    iVec5 sort_colour = sort_colour(i, line.length, component, sort);
    where = sort_colour.a;
    offset_0 = sort_colour.b;
    offset_1 = sort_colour.c;
    offset_2 = sort_colour.d;
    offset_3 = sort_colour.e;

    switch(component) {
      case 1:
      norm_x = get_spectrum(where);
      if(norm_x > 1) norm_x = 1;

      if(range_is) {
        norm_x = map(norm_x, 0,1, range_x.x, range_x.y) ;
      }

      x = int(norm_x *g.colorModeX);
      c = color(x);
      break ;
      //
      case 2:
      norm_x = get_spectrum(where);
      if(norm_x > 1) norm_x = 1;

      if(!reverse_alpha) {
        norm_a = get_spectrum(where +offset_1);
        if(norm_a > 1) norm_a = 1 ;
      } else {
        norm_a = 1 -get_spectrum(where +offset_1);
        if(norm_a < 0) norm_a = 0;
      }
      
      if(range_is) {
        norm_x = map(norm_x, 0,1, range_x.x, range_x.y) ;
        norm_a = map(norm_a, 0,1, range_a.x, range_a.y) ;
      }
      
      x = int(norm_x *g.colorModeX);
      y = int(norm_x *g.colorModeY);
      z = int(norm_x *g.colorModeZ);
      a = int(norm_a *g.colorModeA);
      c = color(x,y,z,a);
      break ;
      //
      case 3:
      norm_x = get_spectrum(where);
      norm_y = get_spectrum(where +offset_1);
      norm_z = get_spectrum(where +offset_2);

      if(norm_x > 1) norm_x = 1;
      if(norm_y > 1) norm_y = 1;
      if(norm_z > 1) norm_z = 1;

      if(range_is) {
        norm_x = map(norm_x, 0,1, range_x.x, range_x.y) ;
        norm_y = map(norm_y, 0,1, range_y.x, range_y.y) ;
        norm_z = map(norm_z, 0,1, range_z.x, range_z.y) ;
      }

      x = int(norm_x *g.colorModeX);
      y = int(norm_y *g.colorModeY);
      z = int(norm_z *g.colorModeZ);
      c = color(x,y,z);
      break ;
      //
      case 4:
      norm_x = get_spectrum(where);
      norm_y = get_spectrum(where +offset_1);
      norm_z = get_spectrum(where +offset_2);

      if(norm_x > 1) norm_x = 1;
      if(norm_y > 1) norm_y = 1;
      if(norm_z > 1) norm_z = 1;

      if(!reverse_alpha) {
        norm_a = get_spectrum(where +offset_3);
        if(norm_a > 1) norm_a = 1 ;
      } else {
        norm_a = 1 -get_spectrum(where +offset_3);
        if(norm_a < 0) norm_a = 0;
      }

      if(range_is) {
        norm_x = map(norm_x, 0,1, range_x.x, range_x.y) ;
        norm_y = map(norm_y, 0,1, range_y.x, range_y.y) ;
        norm_z = map(norm_z, 0,1, range_z.x, range_z.y) ;
        norm_a = map(norm_a, 0,1, range_a.x, range_a.y) ;
      }

      x = int(norm_x *g.colorModeX);
      y = int(norm_y *g.colorModeY);
      z = int(norm_z *g.colorModeZ);
      a = int(norm_a *g.colorModeA);
      c = color(x,y,z,a);
      break ;
      //
      default:
      norm_x = get_spectrum(where);

      if(norm_x > 1) norm_x = 1;

      if(range_is) {
        norm_x = map(norm_x, 0,1, range_x.x, range_x.y) ;
      }
      x = int(norm_x *g.colorModeX);
      c = color(x);
      break ;
    }
    line[i] = c ;
  }
  return line ;
}

// constant sorting
int SORT_HASH = 0;
int SORT_BLOCK_RGBA = 1;
int SORT_BLOCK_ARGB = 1;


iVec5 sort_colour(int i, int line_length, int component, int sort) {
  // iVec5 result = iVec5();
  int w = 0;
  int r = 0;
  int g = 0;
  int b = 0;
  int a = 0;
  if(sort == SORT_HASH) {
    // pixel position
    w = i *component;
    // pixel component
    r = 0;
    g = 1;
    b = 2;
    a = 3;
  } else if(sort == SORT_BLOCK_RGBA) {
    // pixel position
    w = i;
    // pixel component
    r = 0;
    g = line_length;
    b = line_length *2;
    a = line_length *3;
  } else if(sort == SORT_BLOCK_ARGB) {
    // pixel position
    w = i;
    // pixel component
    a = 0;
    r = line_length;
    g = line_length *2;
    b = line_length *3;
  }
  return iVec5(w,r,g,b,a);
}













/**
STOP
*/
void stop() {
  input.close() ;
  minim.stop() ;
  super.stop() ;
}



