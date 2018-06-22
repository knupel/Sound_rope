/**
SOUNDA Rope
for SOUNDA > SOUND-Analyze
v 1.4.2
* Copyleft (c) 2017-2018
* Stan le Punk > http://stanlepunk.xyz/
* @author Stan le Punk
* @see https://github.com/StanLepunK/Sound_rope

* Class Sounda use Minim library
* more information about this library
* @author Damien Quartz
* @see https://github.com/ddf/Minim
*/



/**
Class Sounda
v 0.0.3
*/
public class Sounda implements Rope_Constants {
  private int analyze_length;
  Section section[];
  // library stuff
  import ddf.minim.*;
  import ddf.minim.analysis.*;
  Minim minim;
  AudioInput input;
  AudioBuffer source_buffer;
  FFT fft;
  

  public Sounda() {}

  public Sounda(int analyze_length) {
    this.analyze_length = analyze_length;
    minim = new Minim(this);
    input = minim.getLineIn(Minim.STEREO, analyze_length);
  }






  /**
  stop minim
  */
  public void stop() {
    input.close() ;
    minim.stop() ;
  }

  /**
  MISC
  v 0.2.0
  */
  public float get_right() {
    float sum = 0 ;
    for(int i = 0 ; i < buffer_size() ; i++) {
      sum += get_right(i);
    }
    return sum / buffer_size();
  }

  public float get_left() {
    float sum = 0 ;
    for(int i = 0 ; i < buffer_size() ; i++) {
      sum += get_left(i);
    }
    return sum / buffer_size();
  }

  public float get_mix() {
    float sum = 0 ;
    for(int i = 0 ; i < buffer_size() ; i++) {
      sum += get_mix(i);
    }
    return sum / buffer_size();
  }


  public float get_right(int target_sample) {
    if(target_sample < buffer_size()) {
       return input.right.get(target_sample);
    } else {
      printErrTempo(60, "method get_right("+target_sample+"): no target match in buffer, instead target 0 is use");
      return input.right.get(0);
    }

  }

  public float get_left(int target_sample) {
    if(target_sample < buffer_size()) {
      return input.left.get(target_sample);
    } else {
      printErrTempo(60, "method get_left("+target_sample+"): no target match in buffer, instead target 0 is use");
      return input.left.get(0);
    }
  }

  public float get_mix(int target_sample) {
    if(target_sample < buffer_size()) {
      return input.mix.get(target_sample);
    } else {
      printErrTempo(60, "method get_mix("+target_sample+"): no target match in buffer, instead target 0 is use");
      return input.mix.get(0);
    }
  }

  public int buffer_size() {
    return analyze_length;
  }


  /**
  time track
  v 1.1.1
  */
  int time_track_elapse ;
  float no_sound_since ;
  float threshold_spectrum_sensibility = .6;
  int time_to_reset_time_track = 20;

  public void set_time_track(float threshold, int time_to_reset) {
    threshold_spectrum_sensibility = threshold;
    time_to_reset_time_track = time_to_reset;
  }



  public float get_time_track() {
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



  public boolean sound_is() {
    if(get_time_track() > .2 ) return true ; else return false;
  }




  /**
  set buffer
  */
  void audio_buffer(int canal) {
    switch(canal) {
      case RIGHT :
        source_buffer = input.right ;
        break ;
      case LEFT :
        source_buffer = input.left ;
        break ;
      case MIX :
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
  float[] spectrum;
  int spectrum_bands = 0 ;
  float scale_spectrum = .1 ;
  public void set_spectrum(int num, float scale) {
    if(num > analyze_length) {
      spectrum_bands = analyze_length ;
    } else {
      spectrum_bands = num ;
    }

    spectrum = new float [spectrum_bands] ;
    fft = new FFT(input.bufferSize(), input.sampleRate());
    fft.linAverages(spectrum_size());

    scale_spectrum = scale;
  }

  public void update_spectrum(boolean update_is) {
    if(update_is) {
      if(source_buffer == null) {
        println("void spectrum(): there is no AudioBuffer selected, by default AudioBuffer input.mix is used");
        source_buffer = input.mix;
      }
      fft.forward(source_buffer);
      for(int i = 0 ; i < spectrum_size();i++) {
        fft.scaleBand(i,scale_spectrum);
      }
    }   
  }

  public float [] get_spectrum() {
    float [] f = new float[spectrum_size()];
    for(int i = 0 ; i < spectrum_size() ; i++) {
      f[i] = fft.getBand(i);
    }
    return f;
  }


  public float get_spectrum(int band_target){
    if(band_target < spectrum_size()) {
      return fft.getBand(band_target);
    } else return Float.NaN;
  }

  public int spectrum_size() {
    return spectrum_bands;
  }


  public float get_spectrum_sum() {
    float result = 0 ;
    for (int i = 0 ; i < spectrum_size() ; i++) {
      result += get_spectrum(i);
    }
    return result ;
  }

  public float get_spectrum_average() {
    return get_spectrum_sum() / spectrum_size();
  }


  public float get_spectrum_beat_sum(int beat_target) {
    float result = 0 ;
    for (int i = get_section_in(beat_target) ; i < get_section_out(beat_target) ; i++) {
      result += get_spectrum(i);
    }
    return result ;
  }


  public float get_spectrum_beat_average(int beat_target) {
    return get_spectrum_beat_sum(beat_target) / spectrum_size();
  }





  /**
  SECTION
  */
  // int num_section ;
  public void set_section(Section... section) {
    this.section = section;
  }

  public void set_section(iVec2[] in_out) {
    int len = buffer_size();
    set_section(len, in_out);
  }

  public void set_section(int len, iVec2[] in_out) {
    int num_section = in_out.length;
    section = new Section[num_section];
    // check the max value of section
    for(int i = 0 ; i < num_section ; i++) {
      if(in_out[i].y > len) {
        in_out[i].y = len;
        in_out[i].x = len -1;
        println("'OUT' of beat is upper of spectrum, the value beat 'y' max analyze is cap to the spectrum, and 'x' to spectrum minus '1") ;
      }
      if(in_out[i].x > len) {
        in_out[i].y = len;
        in_out[i].x = len -1;
        println("'IN' of beat is upper of spectrum, the value beat 'y' max analyze is cap to the spectrum, and 'x' to spectrum minus '1") ;
      }
    }
    for(int i = 0 ; i < num_section ; i++) {
      // int length_analyze = in_out[i].y - in_out[i].x ;
      section[i] = new Section(len,in_out[i].x,in_out[i].y);
    }
  }

  // get beat section
  public int get_section(int band_target) {
    int which_section = -1;
    for(int i = 0 ; i < section.length ;i++) {
      if(band_target > section[i].in && band_target < section[i].out) {
        which_section = i ;
        break;
      }
    }
    if(which_section == -1) {
      println("method get_section(): No section match with the target",band_target,"the method return -1");
    }
    return which_section ;
  }

  public int get_section_in(int section_target) {
    if(section_target < section.length) {
      return section[section_target].in ;
    } else {
      printErr("method get_section_in(): target",section_target,"not found, method return -1");
      return -1;
    }
  }

  public int get_section_out(int section_target) {
    if(section_target < section.length) {
      return section[section_target].out;
    } else {
      printErr("method get_section_out(): target",section_target,"not found, method return -1");
      return -1;
    }
  }

  public int section_num() {
    if(section != null && section.length > 0) {
      return section.length ;
    } else {
      printErr("method section_num(): no array beat found method return -1");
      return -1;
    }
  }

  






  /**
  TRANSIENT DETECTION
  v 0.1.0
  */
  Transient transient_detection ;
  public void set_transient(int[] target_transient_section, Vec2... threshold) {
    if(transient_detection == null) transient_detection = new Transient();
    audio_buffer(MIX);
    buffering();
    transient_detection.set_section(section);
    transient_detection.set_transient(target_transient_section, threshold);
  }

  // set param transient
  public void set_transient_low_pass(float... smooth_low_pass) {
    if(transient_detection != null) {
       transient_detection.set_transient_low_pass(smooth_low_pass);
    } else {
      printErr("method set_transient_low_pass(): set_transient() need in to write in first before the other setting methods");
    }
  }

  public void set_transient_smooth_slow(float... smooth_slow) {
    if(transient_detection != null) {
       transient_detection.set_transient_smooth_slow(smooth_slow);
    } else {
      printErr("method set_transient_smooth_slow(): set_transient() need in to write in first before the other setting methods");
    }
  }

  public void set_transient_smooth_fast(float... smooth_fast) {
    if(transient_detection != null) {
       transient_detection.set_transient_smooth_fast(smooth_fast);
    } else {
      printErr("method set_transient_smooth_fast(): set_transient() need in to write in first before the other setting methods");
    }
  }

  public void set_transient_ratio_transient(float... ratio_log) {
    if(transient_detection != null) {
       transient_detection.set_transient_ratio_transient(ratio_log);
    } else {
      printErr("method set_transient_ratio_transient(): set_transient() need in to write in first before the other setting methods");
    }
  }

  public void set_transient_threshold_low(float... threshold_low) {
    if(transient_detection != null) {
       transient_detection.set_transient_threshold_low(threshold_low);
    } else {
      printErr("method set_transient_threshold_low(): set_transient() need in to write in first before the other setting methods");
    }
  }

  public void set_transient_threshold_high(float... threshold_high) {
    if(transient_detection != null) {
       transient_detection.set_transient_threshold_high(threshold_high);
    } else {
      printErr("method set_transient_threshold_high(): set_transient() need in to write in first before the other setting methods");
    }
  }

  // get param transient
  public float[] get_transient_low_pass() {
    return transient_detection.smooth_low_pass;
  }

  public float[] get_transient_smooth_slow() {
    return transient_detection.smooth_slow;
  }

  public float[] get_transient_smooth_fast() {
    return transient_detection.smooth_fast;
  }

  public float[] get_transient_threshold_low() {
    return transient_detection.threshold_low;
  }

  public float[] get_transient_threshold_high() {
    return transient_detection.threshold_high;
  }

  public float[] get_transient_ratio_transient() {
    return transient_detection.ratio_log;
  }

  public boolean transient_is() {
    boolean transient_is = false ;
    buffering();
    for(int i = 0 ; i < transient_detection.section_num() ; i++) {
      if(transient_detection.transient_is(i)) {
        transient_is = true;
        break;
      }
    }
    return transient_is;
  }

  public boolean transient_is(int section_target) {
    buffering();
    return transient_detection.transient_is(section_target);
  }

  /**
  pass buffer audio to transient class
  */
  private void buffering() {
    float [] temp = new float[source_buffer.size()];
    for(int i = 0 ; i < temp.length ; i++) {
      temp[i] = source_buffer.get(i);
    }
    transient_detection.buffer(temp);
  }

  public Vec2 get_transient_threshold(int section_target, int band_target) {
    return transient_detection.get_transient_threshold(section_target, band_target);
  }

  public Vec2 get_transient_threshold(int section_target) {
    return transient_detection.get_transient_threshold(section_target);
  }
  







  /**
  BEAT
  v 0.1.2
  */
  /**

  BEAT METHOD work with the band, the band is from Spectrum.
  
  */
  boolean beat_advance_is ;
  boolean [][] beat_band_is ;
 
  // setting
  public void set_beat(float... threshold) {
    iVec2 [] in_out = new iVec2[threshold.length];
    int part = spectrum_size() / in_out.length;
    for(int i = 0 ; i < in_out.length ; i++) {
      in_out[i] = iVec2(i*part,(i+1)*part);
    }
    set_section(in_out);
    int [] id_beat_section = new int [threshold.length];
    for(int i = 0 ; i < id_beat_section.length ; i++) {
      id_beat_section[i]=i;
    }
    set_beat(id_beat_section, threshold);
  }


  public void set_beat(int[] target_beat_section, float... threshold) {
    if(section != null && spectrum !=null) {
      beat_advance_is = true ;
      beat_band_is = new boolean [target_beat_section.length][spectrum_size()];
      // init var
      for(int i = 0 ; i < beat_band_is.length ; i++) {
        if(target_beat_section[i] < section_num()) {
          int target_section = target_beat_section[i];
          section[target_section].set_threshold_beat(threshold[i]);

        } else {
          printErr("method set_beat(): int target_beat_section",target_beat_section[i],"is out of the num os section available");
        }
        for(int k = 0 ; k < beat_band_is[0].length ; k++) {
          beat_band_is[i][k] = false;
        }
      }
      // declare which band must be analyze when there is a beat detection
      for(int i = 0 ; i < section.length ; i++ ) {
        int step = buffer_size() / spectrum_size();
        int in = floor(section[i].in / step);
        int out = floor(section[i].out / step);
        for(int k = in ; k < out ; k++) {
          beat_band_is[i][k] = true ;
        }
      }
    } else {
      if(section == null) {
        printErr("method set_beat(): there is no section initialized, use method set_section(), before set_beat() advance mode");
      }
      if(spectrum == null) {
        printErr("method set_beat(): spectrum is not initialized, use method set_spectrum(), before set_beat()");
      }     
    }
  }

  // boolean beat is
  public boolean beat_is() {
    boolean beat_is = false ;
    for(int i = 0 ; i < section_num() ; i++) {
      for(int k = 0 ; k < spectrum_bands ; k++ ) {
        if(beat_band_is(i,k)) {
          beat_is = true ;
          break ;
        }
      }
    }
    return beat_is;
  }

  public boolean beat_is(int beat_target) {
    boolean beat_is = false ;
    if(beat_target < section.length) {
      int step = buffer_size() / spectrum_size();
      int in = floor(section[beat_target].in / step);
      int out = floor(section[beat_target].out / step);
      for(int band_target = in ; band_target < out ; band_target++) {
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
  public boolean beat_band_is(int beat_target, int band_target) {
    if(get_spectrum(band_target) > get_beat_threshold(beat_target,band_target)) {
      return true ;
    } else {
      return false ;
    }
  }

  Section get_beat(int beat_target) {
    return section[beat_target];
  }


  // get bet threshold
  public float get_beat_threshold(int section_target, int band_target) {
    float threshold = Float.MAX_VALUE ;
    // check if the target is on the beat range analyze
    if(beat_advance_is && beat_band_is[section_target][band_target]) {
      threshold = section[section_target].get_threshold_beat();
    }
    return threshold;
  }


  public float get_beat_threshold(int section_target) {
    return section[section_target].get_threshold_beat();
  }











  /**
  TEMPO
  v 0.4.1
  */
  /**
  master method
  */
  String [] tempo_name = {"silenzio","largo","larghetto","adagio","andante","moderato","allegro","presto","prestissimo"};
  Tempo [] tempo;

  public void set_tempo() {
    set_tempo(null);
  }

  public void set_tempo(float... threshold) {
    if(threshold != null) {
      // printErrTempo(60,"method set_tempo() is not availble at this time try in an other life");
      if(section_num() > 0 && threshold.length <= section_num()) {
        tempo = new Tempo[section_num()];
        for(int i = 0 ; i < section_num() ; i++) {
          tempo[i] = new Tempo(get_beat(i));
          // tempo[i] = new Tempo(get_transient(i));
          tempo[i].set_threshold(threshold[i]);
        }
      } else {
        printErrTempo(60,"method set_tempo(boolean true) must be used after set_section() method");
      }
    } else {
      tempo = new Tempo[1];
      tempo[0] = new Tempo(analyze_length);
    }
  }


  public int get_tempo() {
    if(tempo.length > 1) {
      int sum = 0 ;
      for(int i = 0 ; i < tempo.length ; i++) {
        sum += tempo[i].get_tempo();
      }
      return sum / tempo.length;
    } else {
      return tempo[0].get_tempo();
    }
  }

  public float get_tempo_threshold(int target_tempo) {
    return tempo[target_tempo].get_threshold();
  }

  public int get_tempo(int target_tempo) {
    if(tempo.length > 1 && target_tempo < tempo.length) {
      return tempo[target_tempo].get_tempo();
    } else {
      printErrTempo(60,"method get_tempo(int target_tempo): target_tempo",target_tempo," is out of tempo num, instead the method use the global tempo");
      return tempo[0].get_tempo();
    }
  }

  public String get_tempo_name() {
    return get_tempo_name(0);
  }

  public String get_tempo_name(int target_tempo) {
    if(tempo[target_tempo].get_tempo() <= 0) return tempo_name[target_tempo];
    else if(tempo[target_tempo].get_tempo() > 0 && tempo[target_tempo].get_tempo() <= 60) return tempo_name[1];
    else if(tempo[target_tempo].get_tempo() > 60 && tempo[target_tempo].get_tempo() <= 66) return tempo_name[2];
    else if(tempo[target_tempo].get_tempo() > 66 && tempo[target_tempo].get_tempo() <= 76) return tempo_name[3];
    else if(tempo[target_tempo].get_tempo() > 76 && tempo[target_tempo].get_tempo() <= 108) return tempo_name[4];
    else if(tempo[target_tempo].get_tempo() > 108 && tempo[target_tempo].get_tempo() <= 120) return tempo_name[5];
    else if(tempo[target_tempo].get_tempo() > 120 && tempo[target_tempo].get_tempo() <= 160) return tempo_name[6];
    else if(tempo[target_tempo].get_tempo() > 160 && tempo[target_tempo].get_tempo() <= 200) return tempo_name[7];
    else return tempo_name[7];
  }

  public void update_tempo(boolean update_tempo_is) {
    if(update_tempo_is) {
      for(int i = 0 ; i < tempo.length ; i++) {
        tempo[i].update();
      }
    }   
  }






  /**
  Private class
  */
  /**
  class Section
  v 0.3.0
  */
  protected class Section {
    Vec2 threshold_transient = Vec2(0,1);
    float threshold_beat = 1;
    int in ;
    int out ;
    int [] leg;
    int length;

    public Section(int length) {
      this.length = length;
      leg = new int[length];
      this.in = 0;
      this.out = leg.length;
    }

    public Section(int length, int in, int out) {
      this.length = length;
      leg = new int[out -in +1];
      this.in = in;
      this.out = out;
    }


    public Section(int length, int in, int out, Vec2 threshold_transient) {
      this.length = length;
      leg = new int[out -in +1];
      this.in = in;
      this.out = out;
      this.threshold_transient = threshold_transient.copy();
    }

    public Section(int length, int in, int out, float threshold_beat) {
      this.length = length;
      leg = new int[out -in +1];
      this.in = in;
      this.out = out;
      this.threshold_beat = threshold_beat;
    }
     

    /*
    public boolean beat_is() {
      boolean beat_is = false ;
      int max = out ;
      if(out >= length) {
        max = length -1;
      }

      for(int i = in ; i <= max ; i++) {
        if(get_spectrum(i) > threshold_beat) {
          beat_is = true ;
          break ;
        }
      }
      return beat_is ;
    }
    */

    // set 
    public void set_threshold_transient(Vec2 threshold_transient) {
      this.threshold_transient = threshold_transient;
    }

    public void set_threshold_beat(float threshold_beat) {
      this.threshold_beat = threshold_beat;
    }

    public void set_in(int in) {
      leg = new int[out -in +1];
      this.in = in;
    }

    public void set_out(int out) {
      leg = new int[out -in +1];
      this.out = out;
    }

    // get
    public Vec2 get_threshold_transient() {
      return threshold_transient;
    }

    public float get_threshold_beat() {
      return threshold_beat;
    }

    public int get_in() {
      return in ;
    }

    public int get_out() {
      return out ;
    }
  }
  




  /**
  class Tempo
  v 0.0.1
  */
  class Tempo {
    private int tempo;
    private int progress;
    private int time_tempo_count;
    private int sec_tempo_count;
    private float threshold;
    private int in, out;

    public Tempo (int len) {
      this.in = 0 ;
      this.out = len;
      set_threshold(4.5);
    }

    public Tempo (Section s) {
      this.in = s.get_in();
      this.out =  s.get_out();
      set_threshold(4.5);
    }


    private void update() {
      if(second() != sec_tempo_count) {
        time_tempo_count++;
        sec_tempo_count = second();
      }
      compute_tempo();
    }

    private int time_elapse = 0;
    private boolean new_tempo_count = true;
    private void compute_tempo() {
      if(sound_is()) {
        int time = 4;
        if(time_tempo_count%time == 0 && new_tempo_count) {
          new_tempo_count = false;
          time_elapse = 0;
          tempo = progress;
          if(tempo < 40) tempo = 40;
          progress = 0;
        }

        if(time_tempo_count%time != 0) new_tempo_count = true;

        time_elapse++;
        count_tempo();
      } else {
        progress = 0 ;
        tempo = 0 ;
      }
    }

    private void count_tempo() {
      for(int target_band = in ; target_band < out ; target_band++) {
        if(get_spectrum(target_band) > threshold) {
          progress++;
          break;
        }
      }
    }

    public void set_threshold(float threshold) {
      this.threshold = threshold;
    }

    public float get_threshold() {
      return threshold;
    }


    public int get_tempo() {
      return tempo;
    }
  }






  /**
  color spectrum
  v 0.1.0
  */
  /*
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

    int [] line = new int[floor(spectrum_size()/component)];
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
  */
}














/**
TRANSIENT DETECTION
2018-2018
v 0.0.2
--
main transient method
on idea of Jean-Baptiste Vallon Hoarau

equation :
x = is your value entry value from buffer > buffer[n]
y = is your value array aftre the thread > value[n]

step 1 
--
low_pass filter :
value [] lp ; 
loop on buffer where n is a current value
entry is the first buffer val
value ref = first buffer value > buffer[entry];
value s = abs(a)+1 > make a value always positive upper to 1
ref = ref + (buffer[n] - ref) / s
lp[n] = ref
y = lp[n]

step 2
--
pow
loop on buffer where n is a current value
pow[n] = y^2
y = pow[n]

step 3 
--
low pass fast
value [] lp_fast ; 
loop on buffer where n is a current value
ref = pow[0];
s_fast = abs(smooth_fast) +1; > keep value positive upper to 1
ref = ref + (y - ref) / s_fast;
lp_fast[n] = ref;

step 4 and 5
--
low pass slow

value [] lp_slow ; 
loop on buffer where n is a current value
ref = pow[0];
s_slow = abs(smooth_slow)+1; > keep value positive upper to 1
float current_value = pow[n];
ref = ref + (current_value - ref) / s_slow;
lp_fast[n] = ref;

diff between value fast and slow or reverse
diff[n] = lp_fast[n] - lp_slow[n]
y = diff[n]

step 6
--
log value
loop on buffer where n is a current value
scale > need to have value signifiant
log_value[n] = log(1+(scale*y));
y = log_value[n]

step 7
--
Hysteresie with threshold low and high
loop on buffer where n is a current value
boolean state
if (y > threshold_high and  state false) 
    y = 1 ;
    test = true ;
else if (y < threshold_low and state true)
    y = 0;
    state = false;

if the answer is true in the couple : BINGO it's a transient
*/
class Transient extends Sounda {
  float [] buffer;

  float [] smooth_low_pass;
  float [] smooth_slow;
  float [] smooth_fast;
  float [] ratio_log;
  float [] threshold_low;
  float [] threshold_high;


  Transient() {
    super();
  }


  public void buffer(float [] buffer) {
    this.buffer = buffer; 
  }


  // setting
  public void set_transient(Vec2... threshold) {
    iVec2 [] in_out = new iVec2[threshold.length];
    int part = buffer.length / in_out.length;
    for(int i = 0 ; i < in_out.length ; i++) {
      in_out[i] = iVec2(i*part,(i+1)*part);
    }
    set_section(buffer.length,in_out);
    int [] id_transient_section = new int [threshold.length];
    for(int i = 0 ; i < id_transient_section.length ; i++) {
      id_transient_section[i]=i;
    }
    set_transient(id_transient_section,threshold);
  }

  private boolean transient_advance_is ;
  private boolean [][] transient_leg_is ;
  public void set_transient(int[] target_transient_section, Vec2... threshold) {
    if(section != null) {
      transient_advance_is = true ;
      transient_leg_is = new boolean [target_transient_section.length][buffer.length];
      // init var
      for(int i = 0 ; i < transient_leg_is.length ; i++) {
        if(target_transient_section[i] < section_num()) {
          int target_section = target_transient_section[i];
          section[target_section].set_threshold_transient(threshold[i]);
        } else {
          printErr("method set_beat(): int target_beat_section",target_transient_section[i],"is out of the num os section available");
        }
        for(int k = 0 ; k < transient_leg_is[0].length ; k++) {
          transient_leg_is[i][k] = false;
        }
      }
      // declare which band must be analyze when there is a beat detection
      for(int i = 0 ; i < section.length ; i++ ) {
        for(int k = section[i].in ; k < section[i].out ; k++) {
          transient_leg_is[i][k] = true ;
        }
      }
    } else {
      printErr("method set_transient(): there is no section initialized, use method set_section(), before set_transient() advance mode");
    }
  }

  // boolean transient is
  public boolean transient_is() {
    boolean transient_is = false ;
    for(int i = 0 ; i < section_num() ; i++) {
      if(transient_is(i)) {
        transient_is = true;
        break;
      }
    }
    return transient_is;
  }
  

  // set param transient
  public void set_transient_low_pass(float... smooth_low_pass) {
    this.smooth_low_pass = smooth_low_pass;
  }

  public void set_transient_smooth_slow(float... smooth_slow) {
    this.smooth_slow = smooth_slow;
  }

  public void set_transient_smooth_fast(float... smooth_fast) {
    this.smooth_fast = smooth_fast;
  }

  public void set_transient_ratio_transient(float... ratio_log) {
    this.ratio_log = ratio_log;
  }

  public void set_transient_threshold_low(float... threshold_low) {
    this.threshold_low = threshold_low;
  }

  public void set_transient_threshold_high(float... threshold_high) {
    this.threshold_high = threshold_high;
  }


  

  

  

  private int define_target(int target, float [] list) {
    // println("define");
    // println(target,list.length);
    int final_target = 0;
    if(target < list.length && target >= 0) {
      final_target = target ;
    } else if(target >= list.length) {
      final_target = target - list.length;
    }
    // security to against infinity loop
    int max_loop = 4 ;
    if(final_target > list.length *max_loop) {
      final_target = 0 ;
    } else if(final_target > list.length && final_target < list.length *max_loop) {
      final_target = define_target(final_target, list) ;
    } else if(final_target < list.length && final_target >= 0) {
      // final_target = 0;
    } else {
      final_target = 0;
    }
    // println(final_target);
    return final_target;
  }

  void default_setting() {
    if(smooth_low_pass == null) set_transient_low_pass(100);     
    if(smooth_slow == null) set_transient_smooth_slow(50);
    if(smooth_fast == null) set_transient_smooth_fast(500);
    if(ratio_log == null) set_transient_ratio_transient(200);
    if(threshold_low == null) set_transient_threshold_low(.1);
    if(threshold_high == null) set_transient_threshold_high(.5);
  }

  public boolean transient_is(int section_target) {
    boolean transient_event_is = false;
    // starting default value if no setting is call outside of the class Transient
    default_setting();
    
    // here we set the sensibility of each section
    int section_target_low_pass = define_target(section_target, smooth_low_pass);
    int section_target_smooth_slow = define_target(section_target, smooth_slow);
    int section_target_smooth_fast = define_target(section_target, smooth_fast);
    int section_target_ratio_log = define_target(section_target, ratio_log);
    int section_target_threshold_low = define_target(section_target, threshold_low);
    int section_target_threshold_high = define_target(section_target, threshold_high);

    // print_transient_param();

    if(section_target < section.length) {
      // set the value must be analyze
      int in = floor(section[section_target].in);
      int out = floor(section[section_target].out);

      int num_leg = out - in ;
      float [] pow_value = new float[num_leg];
      float [] low_pass_value_fast = new float[num_leg];
      float [] low_pass_value_slow = new float[num_leg];
      float [] diff_value = new float[num_leg];
      float [] log_value = new float[num_leg];
      boolean [] transient_is = new boolean[num_leg];
      float [] raw_value = new float[num_leg];

      for(int index = in ; index < out ; index++) {
        int index_value = index - in ;
        if(index < buffer.length) {
          raw_value[index_value] = buffer[index];
        } else {
          raw_value[index_value] = 0;
        }
      }

      low_pass(smooth_low_pass[section_target_low_pass],in,out);
      // here pass the first filtering value from first low pass
      for(int i = 0 ; i  < pow_value.length ; i++) {
        pow_value[i] = low_pass_value[i];
        pow_value[i] = pow(pow_value[i],2);
      }
      // new low pass fast
      float ref_fast = pow_value[0];
      smoothing_fast = abs(smooth_fast[section_target_smooth_fast])+1;
      // println(smoothing_fast);
      for(int i = 0 ; i  < low_pass_value_fast.length ; i++) {
        float current_value = pow_value[i];
        ref_fast += (current_value - ref_fast) / smoothing_fast;
        low_pass_value_fast[i] = ref_fast;
      }

      // new low pass slow
      float ref_slow = pow_value[0];
      smoothing_slow = abs(smooth_slow[section_target_smooth_slow])+1;
      // pass second thread value: first low pass and pow treatment
      for(int i = 0 ; i  < low_pass_value_slow.length ; i++) {
        float current_value = pow_value[i];
        ref_slow += (current_value - ref_slow) / smoothing_slow;
        low_pass_value_slow[i] = ref_slow;
      }

      // difference between quick and fast low pass
      for(int i = 0 ; i  < diff_value.length ; i++) {
        //diff_value[i] = low_pass_value_slow[i] - low_pass_value_fast[i];
        diff_value[i] = low_pass_value_fast[i] - low_pass_value_slow[i];
      }

      // log 
      for(int i = 0 ; i  < log_value.length ; i++) {
        log_value[i] = log(1+(ratio_log[section_target_ratio_log]*diff_value[i]));
      }
      
      // transiente detection and hysteresie
      for(int i = 0 ; i  < log_value.length ; i++) {
        transient_is[i] = false;
        float value = log_value[i];
        if(value > threshold_high[section_target_threshold_high] && !transient_is[i]) {
          value = 1;
          transient_is[i] = true;
        } else if(value < threshold_low[section_target_threshold_low] && transient_is[i]) {
          value = 0;
          transient_is[i] = false;
        }
      }
      
      for(int i = 0 ; i < transient_is.length ; i++) {
        if(transient_is[i]) {
          transient_event_is = true;
          break ;
        }
      }

      // display just for devellopement
      boolean dev = true ;
      if(dev) {
        float factor =height/6;
        int num = 8;
        int step = height / num;
        int [] pos_y = new int[num] ;
        for(int i = 0 ; i < num ; i++) {
          pos_y[i] = step *(i +1); 
        }
        for(int i = 0 ; i < transient_is.length ;i++) {
        // no filter
          int x = i +in;
          // println(x,i,in,transient_is.length);
          int y = int(raw_value[i] *factor) + pos_y[0];
          set(x, y,r.YELLOW);
          // low pass filter
          y = int(low_pass_value[i] *factor) + pos_y[1];
          set(x, y,r.YELLOW);
          // transient work
          // show pow value
          y = int(pow_value[i] *factor) + pos_y[2];
          set(x, y,r.YELLOW);

          // show low pass quick
          y = int(low_pass_value_fast[i] *factor) + pos_y[3];
          set(x, y,r.YELLOW);

          // show low pass slow
          y = int(low_pass_value_slow[i] *factor) + pos_y[4];
          set(x, y,r.YELLOW);

          // diff between fast and slow
          y = int(diff_value[i] *factor) + pos_y[5];
          set(x, y,r.YELLOW);

           // log value + 1
          y = int(log_value[i] *factor) + pos_y[6];
          set(x, y,r.YELLOW);
        }
      }
      // end display dev   
    } else {
      printErrTempo(60,"method transient_is(section",section_target,") is out of the range, by default method return false",frameCount);
    }
    return transient_event_is;
  }

  float [] low_pass_value;
  private void low_pass(float smooth, int in, int out) {
    float smoothing;
    int length = out -in ;
    low_pass_value = new float[length];
  
    // float ref = buffer[0];
    float ref = buffer[in];
    smoothing = abs(smooth)+1;
    // println("smooth", smoothing);
    for(int index = in ; index < out ; index++) {
      float current_value = buffer[index];
      int index_low_pass = index - in ;
      ref += (current_value - ref) / smoothing; 
      low_pass_value[index_low_pass] = ref;
    }
  }


  void print_transient_param() {
    printTempo(60,"__");
    for(int i = 0 ; i < smooth_low_pass.length ; i ++) {
      printTempo(60,"smooth slow pass:",smooth_low_pass[i],frameCount);
    }
    for(int i = 0 ; i < smooth_slow.length ; i ++) {
      printTempo(60,"smooth slow:",smooth_slow[i],frameCount);
    }
    for(int i = 0 ; i < smooth_fast.length ; i ++) {
      printTempo(60,"smooth fast:",smooth_fast[i],frameCount);
    }
    for(int i = 0 ; i < threshold_low.length ; i ++) {
      printTempo(60,"threshold low:",threshold_low[i],frameCount);
    }
    for(int i = 0 ; i < threshold_high.length ; i ++) {
      printTempo(60,"threshold high:",threshold_high[i],frameCount);
    }
    for(int i = 0 ; i < ratio_log.length ; i ++) {
      printTempo(60,"ratio transient:",ratio_log[i],frameCount);
    }
  }
  


  // get param transient
  public float[] get_transient_low_pass() {
    return this.smooth_low_pass;
  }

  public float[] get_transient_smooth_slow() {
    return this.smooth_slow;
  }

  public float[] get_transient_smooth_fast() {
    return this.smooth_fast;
  }

  public float[] get_transient_ratio_transient() {
    return this.ratio_log;
  }

  public float[] get_transient_threshold_low() {
    return this.threshold_low;
  }

  public float[] get_transient_threshold_high() {
    return this.threshold_high;
  }


  // get bet threshold
  public Vec2 get_transient_threshold(int section_target, int band_target) {
    Vec2 threshold = Vec2(Float.MAX_VALUE) ;
    // check if the target is on the beat range analyze
    if(transient_advance_is && transient_leg_is[section_target][band_target]) {
      threshold = section[section_target].get_threshold_transient().copy();
    }
    return threshold;
  }


  public Vec2 get_transient_threshold(int section_target) {
    return section[section_target].get_threshold_transient();
  }

}
