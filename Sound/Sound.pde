
void settings() {
  size(100, 100);
}


void setup() {
  sound_system_setup();
  surface.setSize(sounda.buffer_size(), sounda.buffer_size());
  background(0);

  // transient_setup();
}



void draw() {
  background_rope(r.BLOOD);
  sound_system_draw();
  // transient_draw();
}











