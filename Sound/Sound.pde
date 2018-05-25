
void settings() {
  size(100, 100);
}


void setup() {
  sound_system_setup();
  surface.setSize(sounda.get_analyze(), sounda.get_analyze()) ;
  background(0);
}      



void draw() {
  background_rope(r.BLOOD);
  sound_system_draw();

}


























