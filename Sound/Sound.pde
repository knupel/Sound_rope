/*
import ddf.minim.*;
import ddf.minim.analysis.*;
*/





void settings() {
  size(100, 100);
}


void setup() {
  sound_system_setup();
  surface.setSize(sounda.get_buffer_size(), sounda.get_buffer_size());
  background(0);
}      



void draw() {
  background_rope(r.BLOOD);
  sound_system_draw();

}






























