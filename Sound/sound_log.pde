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

/*
void log_sound(int log_sound_frame, boolean log_beat_only) {
  if(frameCount%log_sound_frame == 0) {
    String time = hour() +" "+ minute() +" "+ second() +" "+ frameCount ;
    for(int target_beat = 0 ; target_beat < sounda.section_size() ;target_beat++) {
      for(int target_band = 0 ; target_band < sounda.get_spectrum().length ; target_band++) {
        if(log_beat_only) {
          if(sounda.beat_band_is(target_beat,target_band)) {
            if(sounda.beat_band_is(target_beat,target_band)) {
            write_log_sound(time,target_beat,target_band, sounda.beat_band_is(target_beat,target_band), sounda.get_section(target_band), sounda.get_beat_threshold(target_beat,target_band), sounda.get_spectrum(target_band)) ;
          }
        } else {
          write_log_sound(time,target_beat,target_band, sounda.beat_band_is(target_beat,target_band), sounda.get_section(target_band), sounda.get_beat_threshold(target_beat,target_band), sounda.get_spectrum(target_band)) ;
        }
      }
    }
  }
}
*/


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