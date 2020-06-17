Board b;
void setup(){
  fullScreen();
  b = new Board();
}
void draw(){
  background(0);
  
  if(!b.gameover){
    b.update();
    b.display();
  }
  else{
    text("Game Over!", width/2 ,height/2);
    if(keyPressed && key == ' '){
      b.gameover = false;
      b = new Board();
    }
  }
}
