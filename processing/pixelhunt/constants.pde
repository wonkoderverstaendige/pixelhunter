// Modes
final int MODE_INIT = 0;
final int MODE_THRESH = 1;
final int MODE_SEARCH_GLOBAL = 2;
final int MODE_SEARCH_LOCAL = 3;
final int MODE_DONE = 4;
final int MODE_EXIT = 5;
final int MODE_ERROR = -1;

// sampling durations 
final long START_DELAY = 0;  // if > 0, delays threshold by finding to let filter settle [ms]
final int NUM_SAMPLES_DECISION_CALIBRATION = 5;  // number of samples needed to decice on anything
final int NUM_SAMPLES_DECISION_SEARCH = 2;  // number of samples needed to decice on anything

// "colors"
final float COLOR_BRIGHT = 1.0;
final float COLOR_DARK = 0.0;
final float COLOR_DEBUG = 0.00;  // 0.0 to disable
final boolean USE_MEDIAN = false;

// geometry
final float MIN_WIDTH = 100;  // minimal width of the final target area
final float MIN_HEIGHT = 100; // minimal height of the final target area
final int NUM_DIVISION = 2;
final int NUM_SHIFTS = 9;  // 0, 3 above, 3 below (2*(w or h)/MUM_LOCAL_SHIFTS step size)