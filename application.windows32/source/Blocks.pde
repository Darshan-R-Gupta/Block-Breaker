float wth = 70;  //width of the block
float hth = 20;  //height of the block

class Drop{
  int type;  // >=0 means good ones <0 means bad ones;
  PVector loc;
  float r;
  Drop(PVector l){
    type = round(random(-1,1));
    loc= l;
    r = 30;
  }
  void display(){
    if(type >= 0){
      fill(0,255,0);
    }
    else{
      fill(255,0,0);
    }
    ellipse(loc.x, loc.y, r,r);
    
  }
  void update(){
    loc.y += 10;
  }
}
class Block{
  PVector loc;
  float w;
  float h;
  boolean contains_drop;
  Block(float x, float y){
    loc = new PVector(x,y);
    w = wth;  
    h = hth;  
    float val = random(10);
    if(val > 9){
      contains_drop = true;
    }
    else{
      contains_drop = false;
    }
  }
  void display(){
    rectMode(CENTER);
    fill(255,255,0);
    rect(loc.x, loc.y, w,h);
  }
}
class Blocks{
  ArrayList<Block> blocks;
  Blocks(){
    float x =0;
    blocks = new ArrayList<Block>();
    for(int j = 70; j < height/2; j+= (hth+2) ){
        for(int i =1; i<= 15; i++){
          x = (wth+2)*i + (width-((wth+2)*15))/2;
          Block b= new Block( x, j);
          blocks.add(b);  
        }
    }
  }
  void display(){
    Block b;
    for(int i =0 ; i < blocks.size(); ++i){
        b = blocks.get(i);
        b.display();
    }
  }
  
  
}
class Walls{
  PVector[] loc;    //0 for left, 1 for upper 2 for right
  float thick;   //the thickness for each wall
  Walls(){
    loc = new PVector[3];
    thick = 50;
    loc[0] = new PVector(thick/2, height/2);
    loc[1] = new PVector(width/2, 10);
    loc[2] = new PVector(width- thick/2, height/2);
  }
  void display(){
    rectMode(CENTER);
    noStroke();
    fill(120,120,120);
    rect(loc[0].x, loc[0].y, thick, height);
    rect(loc[1].x, loc[1].y, width, thick);
    rect(loc[2].x, loc[2].y, thick, height);
    stroke(1);
  }
}
class Ball{
  PVector loc;
  PVector v;
  float r;
  Ball(float x, float y){
    loc = new PVector(x,y);
    v = new PVector(random(-3,3),random(-3,0) );
    r = 20;  
    v.setMag(7);
  }
  void display(){
    fill(255);
    ellipse(loc.x, loc.y ,r,r);
  }
  void update(Walls w){
    checkEdges(w);
    v.limit(15);
    loc.add(v);
  }
  void checkEdges(Walls w){
    if(loc.x - r < w.loc[0].x +w.thick/2){
      v.x *= -1;
    }
    if(loc.x + r > w.loc[2].x - w.thick/2){
      v.x *= -1;
    }
    if(loc.y - r < w.loc[1].y + w.thick/2){
      v.y *= -1;
    }
  }
  
}
class Plate{
  PVector loc;
  float w;
  float h;
  Plate(float x){
    loc= new PVector(x, height-20);
    w = 100;  
    h = 15;
  }
  void display(){
     fill(255,255,255);
     rectMode(CENTER);
     rect(loc.x, loc.y, w, h,30);
  }
  void update(Walls wl){
    if(keyPressed){
      if(key == 'D' || key == 'd'){
        if(loc.x + w/2 < wl.loc[2].x-wl.thick/2 -10){ loc.x += 10;  }
      }
      if(key == 'A' || key == 'a'){
        if(loc.x - w/2 > wl.loc[0].x+wl.thick/2 +10){ loc.x -= 10;  }
      }
    }
  }
}
class Board{
  Blocks b;
  Plate p;
  Ball bl;
  Walls w;  
  ArrayList<Drop> drops;
  boolean gameover;
  Board(){
    b = new Blocks();
    p = new Plate(width/2);
    bl = new Ball(p.loc.x, p.loc.y - 20);
    w = new Walls();
    drops = new ArrayList<Drop>(); 
    gameover = false;
  }
  void display(){
    b.display();
    p.display();
    w.display();
    bl.display();
  }
  void update(){
    checkBoundary();
    checkEaten();
    p.update(w);
    bl.update(w);
    Drop d;
    for(int i =drops.size() -1; i >= 0; --i){
      d = drops.get(i);
      d.update();
      d.display();
      
      if(d.loc.y > height){
        drops.remove(i);
      }
    }
  }
  void checkBoundary(){  //dachecks whether the ball has collided with the plate/any block or the game is over 
      
    if(bl.loc.y - bl.r/2 > p.loc.y-p.h/2 || p.w < 0){
      gameover = true;
    }
    if(!gameover){    //for the purpose of performance optimization
      float ballx = bl.loc.x;
      float bally = bl.loc.y;
      float br = bl.r/2;
      //check for plate collision
      if( (ballx + br > p.loc.x - p.w/2) && (ballx - br< p.loc.x + p.w/2) ){  //If x value passes
          if(bally + br >= p.loc.y - p.h/2){                //then check y
            bl.v.y *= -1.1;
            float mag = ballx - p.loc.x;
            mag = map(mag , 0, p.w/2, 2, 10 );
            bl.v.x = mag;
         }     
      }
      Block block;
       //check for block collision
      for(int i =b.blocks.size() -1; i >=0; --i){
        block = b.blocks.get(i);
        if( (ballx + br > block.loc.x - block.w/2) && (ballx - br < block.loc.x + block.w/2)){
           if((bally + br > block.loc.y - block.h/2) && (bally - br <block.loc.y + block.h/2) ){
              if(block.contains_drop){
                drops.add(new Drop(block.loc));
              }
             b.blocks.remove(i);
             bl.v.y *= -1.1;
           }  
        }
      }
    }
  }
  void checkEaten(){   //check if the plate ate the drop
    Drop d;
    for(int i = 0; i < drops.size()  ; ++i){
      d = drops.get(i);
      if(d.loc.x + d.r/2 > p.loc.x -p.w/2 && d.loc.x - d.r/2 < p.loc.x +p.w/2){
        if(d.loc.y+d.r/2 >= p.loc.y-p.h/2 ){
          if(d.type == 1){
            if(p.w < 300){  p.w += 25;  }
            drops.remove(i);
          }
          else if(d.type == -1){
            p.w -= 30;
            drops.remove(i);
          }
        }
      }
    }  
  }   
}
