
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
  keep_raw_value();
  float smooth = mouseX/10;
  low_pass(smooth);
  
  float smooth_slow = mouseX/10;
  float smooth_quick = smooth_slow *10;
  transient_detection(smooth_quick, smooth_slow);
  display_result(height/6);
}



float [] raw_value ;

float [] low_pass_value;
float [] pow_value;
float [] low_pass_value_fast;
float [] low_pass_value_slow;
float [] diff_value;
float [] log_value;

float [] transient_value;



void keep_raw_value() {
  if(raw_value == null) {
    raw_value = new float[test.buffer_size()];
  }

  for(int i = 0 ; i < test.buffer_size() ; i++) {
    raw_value[i] = test.get_left(i);
  }
}



/**
low pass
*/
float smoothing;
void low_pass(float smooth) {
  if(low_pass_value == null) {
    low_pass_value = new float[test.buffer_size()];
  }

  float ref = test.get_left(0);
  smoothing = abs(smooth)+1;
  // println("smooth", smoothing);
  for(int i = 0 ; i < test.buffer_size() ; i++) {
    float current_value = test.get_left(i);
    ref += (current_value - ref) / smoothing;
    low_pass_value[i] = ref;
  }
}


/**
transient work
*/
float smoothing_fast,smoothing_slow;
void transient_detection(float smooth_fast, float smooth_slow) {
  // pow part
  if(pow_value == null || pow_value.length < raw_value.length ) {
    pow_value = new float [raw_value.length];
  }
  // here pass the first filtering value from first low pass
  for(int i = 0 ; i  < pow_value.length ; i++) {
    pow_value[i] = low_pass_value[i];
    pow_value[i] *= pow_value[i];
  }
  
  // new low pass quick
  if(low_pass_value_fast == null || low_pass_value_fast.length < raw_value.length ) {
    low_pass_value_fast = new float [raw_value.length];
  }
  
  float ref_fast = pow_value[0];
  smoothing_fast = abs(smooth_fast)+1;
  // println("smooth quick", smoothing_quick);
  // pass second thread value: first low pass and pow treatment
  for(int i = 0 ; i  < low_pass_value_fast.length ; i++) {
    float current_value = pow_value[i];
    ref_fast += (current_value - ref_fast) / smoothing_fast;
    low_pass_value_fast[i] = ref_fast;
  }
  

  // new low pass slow
  if(low_pass_value_slow == null || low_pass_value_slow.length < raw_value.length ) {
    low_pass_value_slow = new float [raw_value.length];
  }
  
  float ref_slow = pow_value[0];
  smoothing_slow = abs(smooth_slow)+1;
  // println("smooth slow", smoothing_slow);
  // pass second thread value: first low pass and pow treatment
  for(int i = 0 ; i  < low_pass_value_slow.length ; i++) {
    float current_value = pow_value[i];
    ref_slow += (current_value - ref_slow) / smoothing_slow;
    low_pass_value_slow[i] = ref_slow;
  }

  // difference between quick and fast low pass
  if(diff_value == null || diff_value.length < raw_value.length ) {
    diff_value = new float [raw_value.length];
  }
  for(int i = 0 ; i  < diff_value.length ; i++) {
    // diff_value[i] = low_pass_value_slow[i] - low_pass_value_fast[i];
    diff_value[i] = low_pass_value_fast[i] - low_pass_value_slow[i];
  }

  // difference between quick and fast low pass
  if(log_value == null || log_value.length < raw_value.length ) {
    log_value = new float [raw_value.length];
  }
  for(int i = 0 ; i  < log_value.length ; i++) {
    log_value[i] = log(1+diff_value[i]);
  }
}


void display_result(float factor) {
  int num = 8;
  int step = height / num;
  int [] pos_y = new int[num] ;
  for(int i = 0 ; i < num ; i++) {
    pos_y[i] = step *(i +1); 
  }
  fill(r.BLACK);
  textSize(16);
  text("raw",30, pos_y[0]);
  text("low pass: "+smoothing,30, pos_y[1]);
  text("pow 2",30, pos_y[2]);
  text("fast low pass: "+smoothing_fast,30, pos_y[3]);
  text("slow low pass: "+smoothing_slow,30, pos_y[4]);
  text("diff slow - fast",30, pos_y[5]);
  text("log diff + 1",30, pos_y[6]);

  for(int i = 0 ; i < test.buffer_size() ;i++) {
    // no filter
    int y = int(raw_value[i] *factor) + pos_y[0];
    set(i, y,r.YELLOW);
    // low pass filter
    y = int(low_pass_value[i] *factor) + pos_y[1];
    set(i, y,r.YELLOW);
    // transient work
    // show pow value
    y = int(pow_value[i] *factor) + pos_y[2];
    set(i, y,r.YELLOW);

    // show low pass quick
    y = int(low_pass_value_fast[i] *factor) + pos_y[3];
    set(i, y,r.YELLOW);

    // show low pass slow
    y = int(low_pass_value_slow[i] *factor) + pos_y[4];
    set(i, y,r.YELLOW);

    // diff between fast and slow
    y = int(diff_value[i] *factor) + pos_y[5];
    set(i, y,r.YELLOW);

     // log value + 1
    y = int(log_value[i] *factor) + pos_y[6];
    set(i, y,r.YELLOW);

    // end
  }
}


