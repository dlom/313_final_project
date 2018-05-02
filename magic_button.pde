class MagicButton implements Drawable {
  private float x;
  private float y;
  private float w;
  private float h;
  private float padding;
  private String text;
  private float textSize;
  private Runnable callback;
  
  public MagicButton(float x, float y, float padding, String text, float textSize, Runnable callback) {
    pushStyle();
    textSize(textSize);
    this.x = x;
    this.y = y;
    this.w = getTextWidth(text) + (2 * padding);
    this.h = textSize + (2 * padding);
    this.padding = padding;
    this.text = text;
    this.textSize = textSize;
    this.callback = callback;
    popStyle();
  }
  
  public void draw(float center_x, float center_y, char _) {
    pushStyle();
    
    stroke(#000000);
    strokeWeight(2);
    fill(#FFFFFF);
    rectMode(CORNER);
    rect(center_x + x, center_y + y, w, h);
    
    fill(#000000);
    textSize(this.textSize);
    text(this.text, center_x + x + padding, center_y + y + padding + this.textSize);
    
    popStyle();
  }
  
  public void check(float center_x, float center_y, float x, float y) {
    if (x >= this.x + center_x && x <= this.x + this.w + center_x && 
        y >= this.y + center_y && y <= this.y + this.h + center_y) {
      this.callback.run();
    }
  }
}
