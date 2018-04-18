import de.bezier.data.sql.mapper.*;
import de.bezier.data.sql.*;

int position_normalizer = 10;
int selectedIndex = 0;

class AtBat {
  public float x;
  public float y;
  public boolean hit;
  
  public AtBat(float x, float y, boolean hit) {
    this.x = x;
    this.y = y;
    this.hit = hit;
  }
}

class Batter {
  public String name;
  public int id;
  private AtBat at_bats[];
  
  public Batter(String name, int id) {
    this.name = name;
    this.id = id;
    this.at_bats = null;
  }
  
  public AtBat[] get_at_bats() {
    if (at_bats == null) {
      print("Loading at-bats for " + name + "... ");
      load_at_bats();
      println("Done!");
    }
    return at_bats;
  }
  
  private void load_at_bats() {
    ArrayList<AtBat> at_bat_al = new ArrayList();
    String query = "select px,pz,type from atbat join pitch using (num, url) where batter = '" + this.id + "'";
    db.query(query);
    while (db.next()) {
      float x = db.getFloat("px");
      float y = db.getFloat("pz");
      String result = db.getString("type");
      boolean hit = result.equals("X");
      AtBat ab = new AtBat(x, y, hit);
      at_bat_al.add(ab);
    }
    this.at_bats = at_bat_al.toArray(new AtBat[at_bat_al.size()]);
  }
  
  public void draw(float center_x, float center_y) {
    pushStyle();
    AtBat bats[] = this.get_at_bats();
    strokeWeight(20);
    beginShape(POINTS);
    for (int i = 0; i < bats.length; i++) {
      AtBat a = bats[i];
      float normalized_x = (a.x / position_normalizer) * center_x;
      float normalized_y = (a.y / position_normalizer) * center_y;
      float fx = normalized_x + center_x;
      float fy = normalized_y + center_y;
      
      if (a.hit) {
        stroke(#FF0000, 5);
      } else {
        stroke(#0000FF, 5);
      }
      
      vertex(fx, fy);
    }
    endShape();
    
    textAlign(LEFT, TOP);
    fill(#000000);
    textSize(20);
    text(name, 50, 50);
  
    popStyle();
  }
}

SQLite db;
Batter batters[];

Batter[] load_batters() {
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
  size(400, 400, P3D);
  colorMode(RGB, 100);
  db = new SQLite(this, "pitchfx.sqlite3");
  if (db.connect()) {
    batters = load_batters();
  } else {
    println("couldn't connect to database!");
    exit();
  }
}

void frameRate() {
  pushStyle();
  textAlign(LEFT, TOP);
  fill(#000000);
  textSize(20);
  text(frameRate, 10, 10);
  popStyle();
}

void draw() {
  background(#FFFFFF);
  float center_x = width / 2.0;
  float center_y = height / 2.0;
  Batter b = batters[selectedIndex];
  b.draw(center_x, center_y);
  line(0, center_y, width, center_y);
  line(center_x, 0, center_x, height);
  
  frameRate();
}

void keyPressed() {
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
