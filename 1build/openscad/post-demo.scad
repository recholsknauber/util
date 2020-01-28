union () {
  translate ([150, 0, 0]) {
    cube ([100, 100, 100], center=true);
  }
  translate ([250, 0, 0]) {
    cube ([100, 100, 75], center=true);
  }
  translate ([350, 0, 0]) {
    cube ([100, 100, 50], center=true);
  }
  translate ([450, 0, 0]) {
    cube ([100, 100, 25], center=true);
  }
  translate ([550, 0, 0]) {
    cube ([100, 100, 10], center=true);
  }
  translate ([-150, 0, 0]) {
    sphere (r=110);
  }
  cylinder (h=150, r=10, center=true);
}
