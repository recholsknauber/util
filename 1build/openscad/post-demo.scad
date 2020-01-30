union () {
  translate ([150, 0, 500]) {
    cube ([100, 100, -500], center=true);
  }
  translate ([250, 0, 0]) {
    cube ([100, 100, 75], center=true);
  }
  translate ([350, 0, 800]) {
    cube ([100, 100, 50], center=true);
  }
  translate ([450, 0, 0]) {
    cube ([100, 100, 506], center=true);
  }
  translate ([550, 0, 0]) {
    cube ([100, 100, 10], center=true);
  }
  translate ([-150, 0, 0]) {
    sphere (r=600);
  }
  cylinder (h=550, r=510, center=true);
}
