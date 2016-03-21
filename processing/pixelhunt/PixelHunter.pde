class PixelHunter {
  Target target;
  int _mode = MODE_INIT;  // 0: initialization, 1: get thresholds, 2: search, 3: done, <-1: error
  FloatList samples = new FloatList();
  FloatDict reference = new FloatDict();
  long next_div_ms = START_DELAY;

  FloatList local_x = new FloatList();
  FloatList local_y = new FloatList();

  PixelHunter() {
    target = new Target(MIN_WIDTH, MIN_HEIGHT);
  }

  void process(float pd_current) {
    samples.append(pd_current);
  }

  void setMode(int m) {
    _mode = m;
  }

  boolean search_global () {
    // no data, no dice
    if (samples.size() < NUM_SAMPLES_DECISION_SEARCH) return false;

    // are we in the right place?
    if (test()) {
      // next_split() will fail if we reach target minimum size
      if (!target.next_split()) return true;

      // Nope: search next div
    } else {
      // If further division fails, something went terribly wrong!
      if (!target.next_div()) {
        println("Failed to further divide!");
        setMode(MODE_ERROR);
      }
    }
    samples.clear();
    return false;
  }

  boolean search_local() {
    if (samples.size() < NUM_SAMPLES_DECISION_SEARCH) return false;
    boolean rv = test(); 
    //println(target.axis, target.cur_shift, rv);
    if (rv) {
      if (target.axis == 'x') {
        local_x.append(target.x+(target.cur_shift*target.w/target.num_shift/2));
      } else {
        local_y.append(target.y+(target.cur_shift*target.h/target.num_shift/2));
      }
    }
    if (!target.next_shift()) {
      if (target.axis == 'x') {
        target.axis = target.next_axis();
        target.cur_shift = -target.num_shift/2;
      } else {
        return true;
      }
    }

    samples.clear();
    return false;
  }

  void tick(int current_ms) {
    pxh.target.display();
    switch(_mode) {
    case MODE_INIT:
      // let it run for a bit to have the sensor settle
      if (current_ms < next_div_ms) return;
      samples.clear();  // throw away all samples taken so far
      setMode(MODE_THRESH);
      break;

    case MODE_THRESH:
      target.brightness = COLOR_DARK;
      if (!calibration("low")) return;
      target.brightness = COLOR_BRIGHT;
      if (!calibration("high")) return;
      println("Reference low="+reference.get("low")+", high="+reference.get("high"));
      setMode(MODE_SEARCH_GLOBAL);
      samples.clear();  // throw away all samples taken so far
      break;

    case MODE_SEARCH_GLOBAL: 
      if (search_global()) {
        target.prep_for_local_search();
        setMode(MODE_SEARCH_LOCAL);
        samples.clear();  // throw away all samples taken so far
      }
      break;

    case MODE_SEARCH_LOCAL:
      if (search_local()) {
        if (local_y.size() > 0 && local_x.size() > 0) {
          target.x = aggregate(local_x);
          target.y = aggregate(local_y);
          target.cur_shift = 0;
          setMode(MODE_DONE);
        } else {
          target.cur_shift = -target.num_shift/2;
          samples.clear();
          if (local_x.size() > 0) {
            target.x = aggregate(local_x) + target.w/2;
            target.axis = 'y';
          } else {
            target.y = aggregate(local_y) + target.h/2;
            target.axis = 'x';
          }
          // re-run!
        }
      }
      break;

    case MODE_DONE:
      println("Stopped at x: "+int(target.x)+"+"+int(target.w)+", y: "+int(target.y)+"+"+int(target.h));
      String filename = "diode_feedback.json";
      println("Saving to file <"+filename+">");

      JSONObject json = new JSONObject();
      json.setInt("x", int(target.x));
      json.setInt("y", int(target.y));
      json.setInt("w", int(target.w));
      json.setInt("h", int(target.h));
      json.setFloat("low", reference.get("low"));
      json.setFloat("high", reference.get("high"));
      saveJSONObject(json, filename);
      next_div_ms = current_ms + 2000;
      setMode(MODE_EXIT);
      break;
    
    case MODE_EXIT:
      if (current_ms < next_div_ms) return;
      exit();
      break;

    case MODE_ERROR:
      print("OH NOES WE HAS GOT ERORRS!");
      println(MODE_ERROR);
      exit();
      break;
    }
  }

  boolean calibration(String ref) {
    if (reference.hasKey(ref)) return true;  // exists already, skip
    if (samples.size() >= NUM_SAMPLES_DECISION_CALIBRATION) {
      // we have enough data.
      reference.set(ref, median(samples));
      samples.clear();
      return true;
    }
    return false;
  } 

  float aggregate(FloatList list) {
    return (USE_MEDIAN) ? median(list) : mean(list);
  }

  float mean(FloatList list) {
    float sum = 0;
    for (int n=0; n < list.size(); n++) sum += list.get(n);
    return sum/list.size();
  }

  float median(FloatList list) {
    list.sort();
    return list.get(list.size()/2);
  }

  boolean test() {
    // TODO: proper test if stats allow for decision
    float agg = aggregate(samples);
    float threshold = reference.get("low") + (reference.get("high")-reference.get("low"))/3;
    //println("Testing ", agg, threshold);
    return (agg > threshold);
  }
}