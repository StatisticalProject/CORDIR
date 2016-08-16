 import java.util.*;
String datesSBar[];
String conceptSBar[];
String selectionSBar[];
String yearSelected="Toutes";
String conceptSelected="1";
String poloo="";
String poloo2="";
HashMap<String,HashMap<String,Float[]>> wordByYear=new HashMap();
HashMap<String,Color> colorByWord=new HashMap();
ArrayList<TermForce> termsForce=new ArrayList();
String nbSelect="100";
MaxSize max= new MaxSize();
void setup() {
  background(255);
  size(1024, 768);
  initTable();
  initScrollBar();
  //termsForce.add(new TermForce("test",10.0,(int)random(width),(int)random(height),max));
  //termsForce.add(new TermForce("teste",0.2,(int)random(width),(int)random(height),max));
  termsForce=generateTermForce(yearSelected,conceptSelected,nbSelect);
  arrange(termsForce); 
}

void draw() {
  background(255);
  
  drawSpirale();
  drawScroll();
}

ArrayList<TermForce> generateTermForce(String year,String concept,String nbSelect){
  max=new MaxSize();
  int nbSel=Integer.parseInt(nbSelect);
  ArrayList<TermForce> ters=new ArrayList();
  int conInt=Integer.parseInt(concept);
  HashMap<String,Float[]> wordsDouble=wordByYear.get(year);
  Set<String> words=wordsDouble.keySet();
  for(String word:words){
    float val=wordsDouble.get(word)[conInt-1];
    ters.add(new TermForce(word,val,(int)random(width),(int)random(height),max));
  }
  double nbSelCal=min(nbSel,ters.size());
  float nia=(float)(width*height/(textWidth("demonstration")*nbSelCal));
  //max.min=0.2*max.max;
  max.fontMax=min(70,nia*0.6);
  max.fontMin=max.fontMax*0.15;
  
  Collections.sort(ters,
        new Comparator<TermForce>(){
          public int compare(TermForce o1, TermForce o2){
            return o1.compareTo(o2);
        }
      });
  ArrayList<TermForce> tersRe=new ArrayList();
      
  for(int i=0;i<min(ters.size(),nbSel);i++)
  {
    tersRe.add(ters.get(i));
    float val=ters.get(i).value;
    max.max=max(max.max,val);
    max.min=min(max.min,val);
  
  }
  return tersRe;
}
void drawSpirale(){
  for(TermForce ter:termsForce)
  {
    ter.display();
  }
}

void drawScroll(){
  int sliderW=(int)(height*0.8);
  String prevYear=yearSelected;
  String prevConcept=conceptSelected;
  String prevSel=nbSelect;
  yearSelected=drawScrollBar("Année",65,50,sliderW,datesSBar,yearSelected);
  conceptSelected=drawScrollBar("Concept",10,50,sliderW,conceptSBar,conceptSelected);
  sliderW=(int)(height*0.4);
  nbSelect=drawScrollBar("Effectif",125,50,sliderW,selectionSBar,nbSelect);
  if(!prevYear.equals(yearSelected)||!prevConcept.equals(conceptSelected)||!prevSel.equals(nbSelect)){
    termsForce=generateTermForce(yearSelected,conceptSelected,nbSelect);
    arrange(termsForce); 
  }
}

void initTable(){
  Table tableConcept=loadTable("../projetTermConceptYear.csv");
  for (TableRow row : tableConcept.rows()) {
    String or[]=row.getString(0).split(":");
    String year = or[0];
    String word="";
    if(or.length>1){
      word = or[1];
    }else{
      continue;
    }
    String con[]=row.getString(1).substring(1,row.getString(1).length()-1).split(",");
    Float []doubleCon=new Float[con.length];
    for(int i=0;i<con.length;i++){
      doubleCon[i]=Float.parseFloat(con[i]);
    }
    if(!wordByYear.containsKey(year)){
      wordByYear.put(year,new LinkedHashMap());
    }
    wordByYear.get(year).put(word,doubleCon);
    
  }
  tableConcept=loadTable("../projetTermConcept.csv");
  for (TableRow row : tableConcept.rows()) {
    String word=row.getString(0);
    if(word.equals("_id")){
      continue;
    }
    String con[]=row.getString(1).substring(1,row.getString(1).length()-1).split(",");
    Float []doubleCon=new Float[con.length];
    for(int i=0;i<con.length;i++){
      doubleCon[i]=Float.parseFloat(con[i]);
    }
    if(!wordByYear.containsKey("Toutes")){
      wordByYear.put("Toutes",new LinkedHashMap());
    }
    wordByYear.get("Toutes").put(word,doubleCon);
    
  }
}
void initScrollBar(){
  int nb=2020-2006;
  datesSBar=new String[nb+1];
  datesSBar[0]="Toutes";
  for (int i=1;i<nb+1;i++){
     datesSBar[i]=Integer.toString(2006+i-1);
  }
  conceptSBar=new String[30];
  for (int i=0;i<30;i++){
     conceptSBar[i]=Integer.toString(i+1);
  }
  selectionSBar=new String[]{"20","50","100","200","500","1000"};
}

String drawScrollBar( String title, int x,int y,int h,String []list,String selection){
   textSize(12);
  int baseW=(int)Math.rint(h/list.length);
  line(x, y, x, y+h-baseW);
  String select=selection;
  for (int i=0;i<list.length;i++){
      String name=list[i];
      int xCoo=x;
      int yCoo=y+i*baseW;
      double txtSize=textWidth(name);
      boolean hover=mouseX>xCoo-5&&mouseX<xCoo+txtSize+15&&
      mouseY>yCoo-10&&mouseY<yCoo+10;
      
      drawTextIndex(xCoo,yCoo,name,name.equals(selection),hover);
      if(mousePressed &&hover){
        select=name;
      }
  }
  noFill();
  text(title, x-2, y-textAscent()+5);
  return select;
}
void drawTextIndex(int baseX,int baseY,String text,boolean selected,boolean hov){
 
  if(hov){
    fill(0, 182, 203, 254);
  }else{
    fill(0, 102, 153, 204);
  }
  Float sText= textAscent() * 0.9;
  if(!selected&&!hov){
    noFill();
  }
  text(text, baseX+13, baseY+sText); 
  triangle(baseX, baseY, baseX+6, baseY+6, baseX, baseY+12);
}

// calcule de la spirale des mots
void arrange(ArrayList<TermForce>  arranging) {
     //cntre de la spirale
    float cx=width/2+50,cy=height/2;
    //Eloignement et angle
    float R=0.0,dR=0.05,theta=0.0,dTheta=0.01;
    //bruit
    float Rnoise=0.01,dRnoise=0.5;
      R=0.0;
      theta=0.0;
      ArrayList<TermForce>  bases = arranging;
      ArrayList<TermForce> arrayCalcul=new ArrayList();
      for(TermForce arrange:bases){
              R=0.0;
        theta=noise(1);
        arrange.calculateValue();
        arrange.calculateDisplay();
        int loop=0;
        do{
          float radd=theta+(noise(Rnoise)*20)-10;
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
    if(!colorByWord.containsKey(name)){
      Color colore=new Color();
      colore.colore=color(50+random(155),50+random(155),50+random(155));
      colorByWord.put(name,colore);
    }
    this.colori=colorByWord.get(name).colore;
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

class Color{
  color colore;
}