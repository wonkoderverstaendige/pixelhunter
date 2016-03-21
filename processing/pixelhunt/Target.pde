class Target {
  float x = 0;
  float y = 0;
  float w = width;
  float h = height;
  float min_w;
  float min_h; 
  char axis = 'f';  // which axis to search over. 'f': none, full size, 'x', 'y' split along those
  
  int num_div = NUM_DIVISION;
  int cur_div = 0;
  
  int num_shift = NUM_SHIFTS;
  int cur_shift = 0;
  
  float brightness = COLOR_DARK;
  
  Target(float fmin_w, float fmin_h) {
    min_w = fmin_w;
    min_h = fmin_h;
  }

  char next_axis() {
    return (axis == 'x') ? 'y' : 'x';
  }
  
  boolean next_split() {
    // When we ran fullscreen for calibration,
    // set axis and start over
    if(axis == 'f') {
      axis = next_axis();
      return true;
    }

    // When hitting minimum size on both axis, stop immediately
    if (!(can_split(axis) || can_split(next_axis()))) {
      println("Minimum sizes reached");
      return false;
    }

    // check if next split size works. If not, check next axis
    if (!can_split(axis)) {
      println("Can't split "+axis);
      if (can_split(next_axis())) {
        axis = next_axis();
      }
    }

    if(axis == 'x') {
      x += cur_div * w/num_div;
      w /= num_div;
    } else {
      y += cur_div * h/num_div;
      h /= num_div;
    }
    axis = next_axis();
    cur_div = 0;
    return true;
  }
  
  boolean next_div() {
    // Move to the next sub-area in the search window
    //println("Div to", cur_div + 1);
    return (++cur_div < num_div);
  }
  
  boolean next_shift() {
    return (++cur_shift < num_shift/2+1);
  }
  
  void display() {
    // slightly draw the current search area
    fill((axis=='f') ? brightness : COLOR_DEBUG);
    rect(x, y, w, h);
  
    fill(brightness);
    // global search with divisions
    if (num_div > 1) {
      if (axis=='x') {
        rect(x+w/num_div*cur_div, y, w/num_div, h);
      } else {
        rect(x, y+h/num_div*cur_div, w, h/num_div);
      }
    // local search with shift
    } else {
      if (axis=='x') {
        rect(x+(cur_shift*w/num_shift), y, w, h);
      } else {
        rect(x, y+(cur_shift*h/num_shift), w, h);
      }
    }

  }

  boolean can_split(char a) {
    if (a == 'x') {
      return (w/num_div >= min_w);
    } else {
      return (h/num_div >= min_h);
    }
  }
  
 void set_rect(float _x, float _y, float _w, float _h) {
   x = _x;
   y = _y;
   w = _w;
   h = _h;
 }
 
 void prep_for_local_search() {
   float new_x;
   float new_y;
  if (axis=='x') {
    new_x = (x + w/num_div*cur_div) - MIN_WIDTH/2;
    new_y = (y + h/2) - MIN_HEIGHT/2;
  } else {
    new_x = (x + w/2) - MIN_WIDTH/2;
    new_y = (y + h/num_div*cur_div) - MIN_HEIGHT/2;
  }
  set_rect(new_x, new_y, MIN_WIDTH, MIN_HEIGHT);
  cur_div = 0;
  num_div = 1;
  axis = 'x';
  cur_shift = -num_shift/2;
 }
}