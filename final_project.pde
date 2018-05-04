import de.bezier.data.sql.mapper.*;
import de.bezier.data.sql.*;

int position_normalizer = 5; // 5 feet
float sz_width = (17 / 12.0) / 2; // 17 inch strike zone

String[] hitCategory = {"In play, no out", "In play, out(s)", "In play, run(s)"};
String[] foulCategory = {"Foul", "Foul (Runner Going)", "Foul Tip"};
String[] swingingStrikeCategory = {"Swinging Strike", "Swinging Strike (Blocked)"};
String[] calledStrikeCategory = {"Called Strike"};
String[] ballCategory = {"Ball", "Ball In Dirt"};

color hitColor = #af1c1c; // H
color foulColor = #dae026; // F
color swingingStrikeColor = #8aad48; //S
color calledStrikeColor = #216604; // C
color ballColor = #3f87fc; // B
color otherColor = #bcbcbc; // X

SQLite db;
Batter batters[];
int selectedIndex = 0;
boolean big = false;
MagicButton strikeButton;

interface Drawable {
  void draw(float center_x, float center_y, char meta);
}

float getTextWidth(String s) {
  return textWidth(s);
}

public Batter[] load_batters() {
  ArrayList<Batter> batters_al = new ArrayList();
  db.query("select distinct batter, batter_name from atbat where batter_name <> ''");
  while (db.next()) {
    String name = db.getString("batter_name");
    int id = db.getInt("batter");
    Batter b = new Batter(name, id);
    batters_al.add(b);
  }
  return batters_al.toArray(new Batter[batters_al.size()]);
}

void setup() {
  size(800, 400, P3D);
  surface.setResizable(true);
  colorMode(RGB, 100);
  db = new SQLite(this, "pitchfx.sqlite3");
  if (db.connect()) {
    batters = load_batters();
  } else {
    println("couldn't connect to database!");
    exit();
  }
  strikeButton = new MagicButton(10, 100, 10, "Show Swinging Strikes", 20, new Runnable() {
    @Override
    public void run() {
      big = !big;
      if (big) {
        surface.setSize(width, height * 2);
      } else {
        surface.setSize(width, height / 2);
      }
    }
  });
}

void showStatus(String status) {
  pushStyle();
  textAlign(LEFT, TOP);
  fill(#000000);
  textSize(20);
  text(status, 10, 10);
  popStyle();
}

void draw() {
  background(#FFFFFF);
  float center_x = width / 2.0;
  float center_y = big ? height / 2.0 : height;
  Batter b = batters[selectedIndex];
  b.draw(center_x, center_y, '_');
  strikeButton.draw(0, 0, '_');
  if (big) {
    stroke(#000000);
    strokeWeight(2);
    line(0, height / 2.0, width, height / 2.0);
    b.draw(center_x, height, 'S');
  }
  //showStatus("FPS: " + frameRate);
}

void keyPressed() {
  showStatus("Loading...");
  if (key == CODED) {
    if (keyCode == UP) {
      selectedIndex -= 1;
    } else if (keyCode == DOWN) {
      selectedIndex += 1;
    }
    if (selectedIndex >= batters.length) selectedIndex = 0;
    if (selectedIndex < 0)               selectedIndex = batters.length - 1;
  }
}

void mouseClicked() {
  strikeButton.check(0, 0, mouseX, mouseY);
}
