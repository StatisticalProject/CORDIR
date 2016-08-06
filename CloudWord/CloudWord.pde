 import java.util.Set;
String datesSBar[];
String conceptSBar[];
String yearSelected="2009",yearHover="2006";
String conceptSelected="8",conceptHover="10";
Table tableConcept;
String poloo="";
String poloo2="";
HashMap<String,HashMap<String,Float[]>> wordByYear=new HashMap();
ArrayList<TermForce> termsForce=new ArrayList();
MaxSize max= new MaxSize();
void setup() {
  background(255);
  size(800, 600);
  initTable(); //<>//
  initScrollBar();
  //termsForce.add(new TermForce("test",10.0,(int)random(width),(int)random(height),max));
  //termsForce.add(new TermForce("teste",0.2,(int)random(width),(int)random(height),max));
  termsForce=generateTermForce(yearSelected,conceptSelected);
  arrange(termsForce); 
}

void draw() {
  background(255);
  drawScroll();
  drawSpirale();
}

ArrayList<TermForce> generateTermForce(String year,String concept){
  ArrayList<TermForce> ters=new ArrayList();
  int conInt=Integer.parseInt(concept);
  HashMap<String,Float[]> wordsDouble=wordByYear.get(year);
  Set<String> words=wordsDouble.keySet();
  for(String word:words){
    float val=wordsDouble.get(word)[conInt-1];
    ters.add(new TermForce(word,val,(int)random(width),(int)random(height),max));
  }
  return ters;
}
void drawSpirale(){
  for(TermForce ter:termsForce)
  {
    ter.display();
  }
}

void drawScroll(){
  int sliderW=(int)(width*0.8);
  String prevYear=yearSelected;
  String prevConcept=conceptSelected;
  
  yearSelected=drawScrollBar(width/10,50,sliderW,datesSBar,yearSelected);
  conceptSelected=drawScrollBar(width/10,80,sliderW,conceptSBar,conceptSelected);
  if(!prevYear.equals(yearSelected)||!prevConcept.equals(conceptSelected)){
    termsForce=generateTermForce(yearSelected,conceptSelected);
    arrange(termsForce); 
  }
}

void initTable(){
  tableConcept=loadTable("../projetTermConceptYear.csv");
  for (TableRow row : tableConcept.rows()) {
    String or[]=row.getString(0).split(":");
    String year = or[0];
    String word="";
    if(or.length>1){
      word = or[1];
    }else{
      continue;
    }
    String con[]=row.getString(1).substring(1,row.getString(1).length()-2).split(",");
    Float []doubleCon=new Float[con.length];
    for(int i=0;i<con.length;i++){
      doubleCon[i]=Float.parseFloat(con[i]);
    }
    if(!wordByYear.containsKey(year)){
      wordByYear.put(year,new HashMap());
    }
    wordByYear.get(year).put(word,doubleCon);
    
  }
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

// calcule de la spirale des mots
void arrange(ArrayList<TermForce>  arranging) {
     //cntre de la spirale
    float cx=width/2,cy=height/2;
    //Eloignement et angle
    float R=0.0,dR=1.0,theta=0.0,dTheta=0.05;
    //bruit
    float Rnoise=0.0,dRnoise=1.5;
      R=0.0;
      theta=0.0;
      ArrayList<TermForce>  bases = arranging;
      ArrayList<TermForce> arrayCalcul=new ArrayList();
      for(TermForce arrange:bases){
              R=0.0;
        theta=random(100)/100;
        arrange.calculateValue();
        arrange.calculateDisplay();
        int loop=0;
        do{
          float radd=theta+(noise(Rnoise)*200)-100;
          arrange.x=(int)(cx+R*cos(radd));
          arrange.y=(int)(cy+R*sin(radd));
                    
          theta+=dTheta;
          R+=dR;
          Rnoise+=dRnoise;
          loop++;
        }while(check(arrayCalcul,arrange)&&loop<10000);
        arrayCalcul.add(arrange);
      }
      
    

}

//regarde si le terme actuel est en conflit avec les termes deja affiche
boolean check(ArrayList<TermForce> checks, TermForce toCheck){
  if(toCheck.checkLimit(0,0,width,height)){
    return true;
  }
  for(TermForce onCheck:checks){
    if(toCheck.intersect(onCheck)){
      return true;
    }
  }

  return false;
}

/*terme avec sa probabilité, sa taille de fonte,sa couleur, sa taille et son emplacement*/
class TermForce  {
  String name;
  float value;
  float fontsize;
  color colori;
  int x,y;
  float tileW,tileH;
  public MaxSize size;
  public TermForce(String name,float value,int x,int y,MaxSize max){
    this.name=name;
    this.value=value;
    this.fontsize=max(4,min(20,map(value,0.0,1,max.fontMin,max.fontMax)));
    this.colori=color(random(name.toCharArray()[0]),random(name.toCharArray()[0]),random(name.toCharArray()[0]));
    this.size=max;
    this.x=x;
    this.y=y;
    calculateDisplay();
  }
  
  public void calculateValue(){  
    fontsize=max(size.fontMin,min(size.fontMax,map( value,size.min,size.max,size.fontMin,size.fontMax)));
  }  
  
  public void calculateDisplay(){
    textSize(fontsize);
    tileW=textWidth(name)+1;
    tileH=textAscent()+1;
  }
  
  public void display(){

    calculateValue();
       textSize(fontsize);
             fill(colori);
        text(name,x-tileW*0.5,y+tileH*0.5);
         
  }
  
  public boolean intersect(TermForce force){
    float left1=x -tileW*0.5;
    float right1= x +tileW*0.5;
    float top1=y-tileH*0.5;
    float bot1=y+tileH*0.5;
    
    float left2=force.x-force.tileW*0.5;
    float right2= force.x +force.tileW*0.5;
    float top2=force.y-force.tileH*0.5;
    float bot2=force.y+force.tileH*0.5;
    
    return !(right1<left2||right2<left1||bot1<top2||bot2<top1);
    
  }
  public boolean checkLimit(int startX,int startY,int endX,int endY){
    return x -tileW*0.5<startX || x +tileW*0.5>endX || startY>y+tileH*0.5 || endY<y-tileH*0.5;
  }
  
  public int compareTo(TermForce anotherInstance) {
        int acc=(int)map(value,size.min,size.max,0,100);
        int ecc=(int)map(anotherInstance.value,anotherInstance.size.min,anotherInstance.size.max,0,100);
        return ecc-acc;
    }
  
  
}

/* taille maximum*/
class MaxSize{
  
  float max=0.3;
  float min=0.0;
  float fontMax=50;
  float fontMin=1;
}