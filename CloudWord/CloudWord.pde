String datesSBar[];
String conceptSBar[];
String yearSelected="2009",yearHover="2006";
String conceptSelected="8",conceptHover="10";

void setup() {
  background(255);
  size(800, 600);
    
  
  initScrollBar();
}

void draw() {
  background(255);
  
  drawScroll();
}

void drawScroll(){
  int sliderW=(int)(width*0.8);
  yearSelected=drawScrollBar(width/10,50,sliderW,datesSBar,yearSelected);
  conceptSelected=drawScrollBar(width/10,80,sliderW,conceptSBar,conceptSelected);
}
void initScrollBar(){
  int nb=2021-2006;
  datesSBar=new String[nb];
  for (int i=0;i<nb;i++){
     datesSBar[i]=Integer.toString(2006+i);
  }
  conceptSBar=new String[20];
  for (int i=0;i<20;i++){
     conceptSBar[i]=Integer.toString(i+1);
  }
}

String drawScrollBar( int x,int y,int w,String []list,String selection){
   textSize(12);
  int baseW=(int)Math.rint(w/list.length);
  line(x, y, x+w-baseW, y);
  String select=selection;
  for (int i=0;i<list.length;i++){
      String name=list[i];
      int xCoo=x+i*baseW;
      double txtSize=textWidth(name)*0.5;
      boolean hover=mouseX>xCoo-txtSize&&mouseX<xCoo+txtSize+5&&
      mouseY>y-35&&mouseY<y+5;
      
      drawTextIndex(xCoo,y,name,name.equals(selection),hover);
      if(mousePressed &&hover){
        select=name;
      }
  }
  return select;
}
void drawTextIndex(int baseX,int baseY,String text,boolean selected,boolean hov){
 
  if(hov){
    fill(0, 182, 203, 254);
  }else{
    fill(0, 102, 153, 204);
  }
  Float sText=(textWidth(text))*0.5;
  if(!selected&&!hov){
    noFill();
  }
  text(text, baseX-sText+5, baseY-12); 
  triangle(baseX, baseY, baseX+6, baseY-7, baseX+12, baseY);
}