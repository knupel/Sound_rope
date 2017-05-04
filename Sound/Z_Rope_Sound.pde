/**
SOUND rope
v 1.0.5
*/
import ddf.minim.*;
import ddf.minim.analysis.*;



/**
setting
*/
Minim minim ;
AudioInput input ;




int bands_max ;

void set_sound(int max) {
  bands_max = max ;
  minim = new Minim(this);
  //sound from outside
 //  minim.debugOn();
  input = minim.getLineIn(Minim.STEREO, bands_max);
}


AudioBuffer source_buffer ;

int MIX = 41 ;
void audio_buffer(int which) {
  switch(which) {
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
v 0.0.2
*/
float[] spectrum  ;
FFT fft;
int spectrum_bands = 0 ;
float band_size ;
float scale_spectrum = .1 ;


void set_spectrum(int num, float scale) {
  if(num > bands_max) {
    spectrum_bands = bands_max ;
  } else {
    spectrum_bands = num ;
  }

  band_size = bands_max / spectrum_bands ;
  spectrum = new float [spectrum_bands] ;
  fft = new FFT(input.bufferSize(), input.sampleRate());
  fft.linAverages(spectrum_bands);

  scale_spectrum = scale ;
}




// scale .5 be good
float spectrum(int target) {
  if(source_buffer == null) {
    source_buffer = input.mix ;
  }
  return spectrum(source_buffer, target, scale_spectrum) ;
}

float spectrum(AudioBuffer fftData, int target) {
  return spectrum(fftData, target, scale_spectrum) ;
}

float spectrum(AudioBuffer fftData, int target, float scale) {
  fft.forward(fftData) ;
  fft.scaleBand(target, scale_spectrum) ;
  return fft.getBand(target) ;
}

float [] spectrum() {
  float [] f = new float[spectrum_bands] ;
  for(int i = 0 ; i < spectrum_bands ; i++) {
    f[i] = fft.getBand(i) ;
  }
  return f ;
}

int num_bands() {
  return spectrum_bands ;
}


float get_spectrum_sum() {
  float result = 0 ;
  for (int i = 0 ; i < num_bands() ; i++) {
    result += spectrum(i) ;
  }
  return result ;
}


/**
time track
v 1.0.0
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








/**
BEAT 
v 0.0.2
*/
/**
class
*/
class Beat {
  float sensibility ;
  int in ;
  int out ;
  int [] beat_band ;
  Beat(int in, int out, float sensibility) {
    beat_band = new int[out -in +1];
    this.in = in;
    this.out = out;
    this.sensibility = sensibility;
  }

  boolean beat_is() {
    boolean beat_is = false ;
    int max = out ;
    if(out >= spectrum_bands) {
      max = spectrum_bands -1;
    }

    for(int i = in ; i <= max ; i++) {
      if(spectrum(i) > sensibility) {
        beat_is = true ;
        break ;
      }
    }
    return beat_is ;
  }

  int get_in() {
    return in ;
  }

  int get_out() {
    return out ;
  }
}




/**
method
v 0.0.1
*/
// float [] beat_alert ;
int num_beat_section ;
Beat beat_rope[] ;
boolean beat_advance_is ;
boolean [] beat_band_is ;


/**
setting
*/
void set_beat_basic(float... threshold) {
  // beat_alert = new float[spectrum_bands] ;
  num_beat_section = threshold.length ;
  beat_rope = new Beat[num_beat_section] ;
  for(int i = 0 ; i < num_beat_section ; i++) {
    int length_analyze = int(spectrum_bands /num_beat_section);
    int in = i *length_analyze ;
    // may be there is an error on the out, but no matter !
    int out = i *length_analyze +length_analyze;
    beat_rope[i] = new Beat(in, out,threshold[i]);
  }
}

void set_beat_advance(iVec2[] in_out,  float[] threshold) {
  beat_advance_is = true ;
  beat_band_is = new boolean [spectrum_bands] ;
  // beat_alert = new float[spectrum_bands] ;
  num_beat_section = in_out.length ;
  beat_rope = new Beat[num_beat_section] ;
  // check the max value of beat analyze
  for(int i = 0 ; i< num_beat_section ; i++) {
    if(in_out[i].y > spectrum_bands) {
      in_out[i].y = spectrum_bands;
      in_out[i].x = spectrum_bands -1;
      System.err.print("'OUT' of beat is upper of spectrum, the value beat 'y' max analyze is cap to the spectrum, and 'x' to spectrum minus '1") ;
    }
    if(in_out[i].x > spectrum_bands) {
      in_out[i].y = spectrum_bands;
      in_out[i].x = spectrum_bands -1;
      System.err.print("'IN' of beat is upper of spectrum, the value beat 'y' max analyze is cap to the spectrum, and 'x' to spectrum minus '1") ;
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
      beat_band_is[k] = true ;
    }
  }
}





/**
method
*/
boolean beat_is() {
  boolean beat_is = false ;
  for(int i = 0 ; i < spectrum_bands ; i++ ) {
    if(beat_band_is(i)) {
      beat_is = true ; 
      break ;
    }
  }
  return beat_is ;
}

boolean beat_is(int target_beat_range) {
  boolean beat_is = false ;
  for(int i = beat_rope[target_beat_range].in ; i < beat_rope[target_beat_range].out ; i++ ) {
    if(beat_band_is(i, target_beat_range)) {
//      if(target_beat_range == 1)println("BASSE", beat_rope[target_beat_range].in, beat_rope[target_beat_range].out, i, frameCount);
      beat_is = true ; 
      break ;
    }
  }
  return beat_is ;
}



// beat band is
boolean beat_band_is(int target) {
  boolean beat_is = false ;
  if(spectrum(target) > get_beat_alert(target)) {
    beat_is = true ;
  }
  return beat_is ;
}

boolean beat_band_is(int target, int which_beat) {
  if(spectrum(target) > get_beat_alert(target, which_beat)) {
    return true ; 
  } else {
    return false ;
  }
}


float get_beat_alert(int target) {
  float alert = Float.MAX_VALUE ;
  // check if the target is on the beat range analyze
  if(beat_advance_is && beat_band_is[target]) {
    // advance
    for(int i = 0 ; i < beat_rope.length ; i++) {
      // println(60, "advanded mode", frameCount) ;
      if(target > beat_rope[i].in && target < beat_rope[i].out) {
        alert = beat_rope[i].sensibility ;
        break ;
      }
    }
  } else if(!beat_advance_is) { 
    // classic
    int section = beat_section(target) ;
    alert = beat_rope[section].sensibility;
  }
  return alert;
}


float get_beat_alert(int target, int which_beat) {
  float alert = Float.MAX_VALUE ;
  // check if the target is on the beat range analyze
  if(beat_advance_is && beat_band_is[target]) {
    // advance
  //  printTempo(60, "beat", which_beat, "band",target) ;
    alert = beat_rope[which_beat].sensibility ;
  } 
  return alert;
}









int beat_section(int target) {
  int section = floor((float)target /spectrum_bands *num_beat_section) ;
  // if(section == 0) section = 1 ;
  return section ;
}



int get_beat_in(int which_beat) {
  return beat_rope[ which_beat].in ;
}

int get_beat_out(int which_beat) {
  return beat_rope[ which_beat].out ;
}

int beat_num() {
  return beat_rope.length ;
}


/**

*/













/**
STOP
*/
void stop() {
  input.close() ;
  minim.stop() ;
  super.stop() ;
}



