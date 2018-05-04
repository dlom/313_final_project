class AtBat {
  public String id;
  public float x;
  public float y;
  public char type;
  
  public AtBat(String id, float x, float y, char type) {
    this.id = id;
    this.x = x;
    this.y = y;
    this.type = type;
  }
}

class Batter implements Drawable {
  public String name;
  public int id;
  private AtBat at_bats[];
  public float sz_top;
  public float sz_bot;
  
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
  
  private boolean category_contains(String[] category, String des) {
    for (int i = 0; i < category.length; i++) {
      if (category[i].equals(des)) return true;
    }
    return false;
  }
  
  private char classify_swing(String des) {
    if (this.category_contains(hitCategory, des)) {
      return 'H';
    } else if (this.category_contains(foulCategory, des)) {
      return 'F';
    } else if (this.category_contains(swingingStrikeCategory, des)) {
      return 'S';
    } else if (this.category_contains(calledStrikeCategory, des)) {
      return 'C';
    } else if (this.category_contains(ballCategory, des)) {
      return 'B';
    } else {
      return 'X';
    }
  }
  
  private void load_at_bats() {
    ArrayList<AtBat> at_bat_al = new ArrayList();
    String query = "select px,pz,sz_top,sz_bot,des,stand,num||url as id from pitch join atbat using (num, url) where batter = '" + this.id + "'";
    db.query(query);
    print("Processing... ");
    int count = 0;
    float sz_top = 0;
    float sz_bot = 0; 
    while (db.next()) {
      float x = db.getFloat("px");
      float y = db.getFloat("pz");
      sz_top += db.getFloat("sz_top");
      sz_bot += db.getFloat("sz_bot");
      count++;
      if (x != 0 && y != 0) {
        char type = this.classify_swing(db.getString("des"));
        String id = db.getString("id");
        AtBat ab = new AtBat(id, -x, y, type);
        at_bat_al.add(ab);
      }
    }
    this.sz_top = sz_top / count;
    this.sz_bot = sz_bot / count;
    this.at_bats = at_bat_al.toArray(new AtBat[at_bat_al.size()]);
  }
  
  public void draw(float center_x, float center_y, char meta) {
    float top = 0;
    if (meta == 'S') {
      top = height / 2;
    }
    pushStyle();
    AtBat bats[] = this.get_at_bats();
    strokeWeight(5);
    beginShape(POINTS);
    for (int i = 0; i < bats.length; i++) {
      AtBat a = bats[i];
      float normalized_x = (a.x / position_normalizer) * center_x;
      float normalized_y = (a.y / position_normalizer) * (center_y - top);
      float fx = center_x + normalized_x;
      float fy = center_y - normalized_y;
      if (fy > center_y) continue;
      if (fy < top) continue;
      if (meta == 'S' && a.type != 'S') continue;
      
      if (a.type == 'H') {
        stroke(hitColor, 80);
      } else if (a.type == 'F') {
        stroke(foulColor, 80);
      } else if (a.type == 'S') {
        stroke(swingingStrikeColor, 80);
      } else if (a.type == 'C') {
        stroke(calledStrikeColor, 80);
      } else if (a.type == 'B') {
        stroke(ballColor, 80);
      } else {
        stroke(otherColor, 80);
      }
      
      vertex(fx, fy);
    }
    endShape();
    
    strokeWeight(2);
    stroke(#000000);
    noFill();
    float normalize_sz_top = (this.sz_top / position_normalizer) * (center_y - top);
    float normalize_sz_bot = (this.sz_bot / position_normalizer) * (center_y - top);
    float normalize_sz_width = (sz_width / position_normalizer) * center_x;
    rectMode(CORNERS);
    rect(center_x - normalize_sz_width, center_y - normalize_sz_top, center_x + normalize_sz_width, center_y - normalize_sz_bot);
    
    textAlign(LEFT, TOP);
    fill(#000000);
    textSize(20);
    text(name, 10, 50);
  
    popStyle();
  }
}
