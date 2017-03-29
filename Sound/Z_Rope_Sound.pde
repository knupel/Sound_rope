/**
SOUND rope
v 1.0.1
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

*/
float[] spectrum  ;
FFT fft;
int spectrum_bands = 0 ;
float band_size ;
float scale_spectrum = .1 ;


void set_spectrum(int n) {
  if(n > bands_max) {
    spectrum_bands = bands_max ;
  } else {
    spectrum_bands = n ;
  }

  band_size = bands_max / spectrum_bands ;
  spectrum = new float [spectrum_bands] ;
  fft = new FFT(input.bufferSize(), input.sampleRate());
  fft.linAverages(spectrum_bands);
}


void spectrum_scale(float scale) {
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









/**
BEAT

*/
float [] beat_alert ;
int num_section ;

void set_beat(float... threshold) {
  beat_alert = new float[spectrum_bands] ;
  int section = spectrum_bands / threshold.length ;

  int count = 0 ;
  for(int i = 0 ; i < spectrum_bands ; i++) {
    beat_alert[i] = threshold[count] ;
    if(i > section) {
      section += section ;
      count++ ;
    }   
  }
  num_section = count +1 ;
}

int beat_section(int target) {
  println(target, spectrum_bands, num_section) ;
  int section = ceil((float)target /spectrum_bands *num_section) ;
  if(section == 0) section = 1 ;
  return section ;
}

float get_beat_alert(int target) {
  return beat_alert[target] ;
}


boolean beat_is(int target) {
  if(spectrum(target) > beat_alert[target]) {
    return true ; 
  } else {
    return false ;
  }
}

boolean beat_is() {
  boolean beat_is = false ;
  for(int i = 0 ; i < spectrum_bands ; i++ ) {
    if(beat_is(i)) {
      beat_is = true ; 
      break ;
    }

  }
  return beat_is ;
}







/**
STOP
*/
void stop() {
  input.close() ;
  minim.stop() ;
  super.stop() ;
}



