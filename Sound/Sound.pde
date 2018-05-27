
void settings() {
  size(100, 100);
}


void setup() {
  /**
  sound_system_setup();
  surface.setSize(sounda.get_buffer_size(), sounda.get_buffer_size());
  */
  background(0);

  test_setup();
}



void draw() {
  background_rope(r.BLOOD);
  // sound_system_draw();
  test_draw();

}






Sounda test ;

void test_setup() {
  test = new Sounda(512);
  surface.setSize(test.buffer_size(), test.buffer_size());

}

void test_draw() {
  low_pass(mouseX/10);
  display_result();
}


float [] low_pass_value ;
float [] raw_value ;
void low_pass(float smooth) {
  if(low_pass_value == null) {
    low_pass_value = new float[test.buffer_size()];
  }

  if(raw_value == null) {
    raw_value = new float[test.buffer_size()];
  }

  float init_value = test.get_left(0);
  float smoothing = abs(smooth)+1;
  println("smooth", smoothing);
  for(int i = 0 ; i < test.buffer_size() ; i++) {
    raw_value[i] = test.get_left(i);
    float current_value = test.get_left(i);
    init_value += (current_value - init_value) / smoothing;
    low_pass_value[i] = init_value;
  }
}

void transient_detection() {

}


void display_result() {
  float factor = height/2;
  int pos_y_1 = height/3;
  int pos_y_2 = height -(height/3);
  for(int i = 0 ; i < test.buffer_size() ;i++) {
    // no filter
    int y = int(raw_value[i]  *factor) + pos_y_1;
    set(i, y,r.WHITE);
    // low pass filter
    y = int(low_pass_value[i] *factor) +pos_y_2;
    set(i, y,r.BLACK);
  }
}
