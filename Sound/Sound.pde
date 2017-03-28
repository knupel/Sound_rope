


void setup() {
  background(255);
  size(512, 360);
  background(255);

  // beat alert
  set_sound(512) ;
  
  set_spectrum(256) ;
  set_beat(1.3) ;
  spectrum_scale(.2) ;
  
}      


float radius ;
void draw() { 
  background(255) ;
  if(beat_is()) {
    radius = height/2 ;
  }
  fill(255,125,0) ;
  radius *= .95 ;
  ellipse(width/2,height/2,radius,radius) ;



  audio_buffer(RIGHT) ;

  fill(0) ;
  noStroke() ;
  show_beat(Vec2(0), height/2) ;

  fill(255,0,0) ;
  noStroke() ;
  show_spectrum(Vec2(0), height/2) ; 
  

  audio_buffer(LEFT) ;
  fill(0) ;
  noStroke() ;
  show_beat(Vec2(0), -height/2) ;

  fill(255,0,0) ;
  noStroke() ;
  show_spectrum(Vec2(0), -height/2) ; 

}













void show_spectrum(Vec2 pos, int size) {
  for(int i = 0; i < num_bands(); i++) {
    float pos_x = i * band_size +pos.x;
    float pos_y = pos.y + abs(size) ;
    float size_x = band_size ;
    float size_y = -(band(i) *size) ;
    rect(pos_x, pos_y, size_x, size_y) ;
  } 
}


void show_beat(Vec2 pos, int size) {
  for(int i = 0; i < num_bands() ; i++) {
    // if(band(i) > get_beat_alert(i)) {
      if(beat_is(i)) {
      // println("alert", i, band(input.mix, i, .5)) ;
      float pos_x = i * band_size +pos.x ;
      float pos_y = pos.y + abs(size) ;
      float size_x = band_size ;
      float size_y = -size ;
      rect (pos_x, pos_y, size_x, size_y) ;
    }
  } 
}









