BufferedReader reader;
String line;
HashMap<String,Edge> map=new HashMap<String,Edge>(); 
HashMap<String,Node> mapNode=new HashMap<String,Node>(); 
ArrayList<String> mapWordConc=new ArrayList<String>();

ArrayList<Button> listTreeButtons=new ArrayList(); 
ArrayList<Button> listClassButtons=new ArrayList(); 

void setup() {
    background(255);
  size(1024, 768);
  HashMap<String,ArrayList<Float>> wordByYear=new HashMap<String,ArrayList<Float>>();
    
  Table tableConcept=loadTable("../projetTermConcept.csv");
  for (TableRow row : tableConcept.rows()) {
    String word=row.getString(0);
    if(word.equals("_id")){
      continue;
    }
    String con[]=row.getString(1).substring(1,row.getString(1).length()-1).split(",");
    ArrayList<Float>doubleCon=new ArrayList();
    for(int i=0;i<con.length;i++){
      doubleCon.add(Float.parseFloat(con[i]));
    }
    
    wordByYear.put(word,doubleCon);
    
  }
  for(int i=0;i<30;i++)
  {
    float max=Integer.MIN_VALUE;
    String word="";
    for (String wordRes:wordByYear.keySet()){
      if(max<wordByYear.get(wordRes).get(i)){
        max=wordByYear.get(wordRes).get(i);
        word=wordRes;
      }      
    }
    mapWordConc.add(word);
  }

  // Open the file from the createWriter() example
  reader = createReader("../model.txt");
  boolean notInTree=true;
  String number="0";
  Edge curEdge=new Edge(null,null,null);
  int range=150;
  try {
    line = reader.readLine();
  } catch (IOException e) {
      e.printStackTrace();
      line = null;
      
    }
  while(line!=null)
  {
    try {
      line = reader.readLine();
    } catch (IOException e) {
      e.printStackTrace();
      line = null;
      break;
    }
    if (line==null||(notInTree&&!line.contains("Tree ")))
    {
        continue;
    }
    if (line.trim().isEmpty()){
      notInTree=true;
    }
    if (line.contains("Tree ")){
      number=line.substring(line.indexOf("Tree ")+5,line.indexOf(":"));
      notInTree=false;
      curEdge=new Edge(null,null,null);
      map.put(number.trim(),curEdge);
      println("number="+number);
    }
    if (line.contains("If ")){
      String nodeValue=line.substring(line.indexOf("feature ")+8);
      
      String reste=nodeValue.substring(nodeValue.indexOf(" ")+1,nodeValue.indexOf(")"));
      nodeValue=nodeValue.substring(0,nodeValue.indexOf(" "));
      int val=Integer.parseInt(nodeValue);
      if(val==0) nodeValue="COUNTRY";
      if(val==1) nodeValue="PROGR";
      if(val>1)
        nodeValue=mapWordConc.get(Integer.parseInt(nodeValue)-2);
      Node next=mapNode.get(nodeValue);
      if(next==null){
        next=new Node(nodeValue);
        if(curEdge.parent!=null)
          next.angle=curEdge.parent.angle+ random(0, range);
        next.calculate();
        //mapNode.put(nodeValue,next);
      }
      curEdge.next=next;
      next.IF=new Edge(reste,next,null);
      next.parent=curEdge;
      curEdge=next.IF;
      
    }
    if (line.contains("Else ")){
      String nodeValue=line.substring(line.indexOf("feature ")+8);
      
      String reste=nodeValue.substring(nodeValue.indexOf(" ")+1,nodeValue.indexOf(")"));
      nodeValue=nodeValue.substring(0,nodeValue.indexOf(" "));
      Node par=curEdge.parent;
      par.ELSE=new Edge(reste,par,null);
      curEdge=par.ELSE;
      
    }
    if (line.contains("Predict: ")){
      String nodeValue=line.substring(line.indexOf("Predict: ")+9);
      if(nodeValue.equals("0.0")){
        nodeValue="<500k";
      }
      if(nodeValue.equals("1.0")){
        nodeValue="500k-2800k";
      }
      if(nodeValue.equals("2.0")){
        nodeValue="2800k-8M";
      }
      if(nodeValue.equals("3.0")){
        nodeValue=">8M";
      }
      curEdge.next=mapNode.get(nodeValue);
      if(curEdge.next==null){
        curEdge.next=new Node(nodeValue);
        curEdge.next.parent=curEdge;
        curEdge.next.angle=curEdge.parent.angle+ random(-range, range);;
        curEdge.next.calculate();
        
        //mapNode.put(nodeValue,curEdge.next);
      }
      curEdge.next.value=nodeValue;
      while(curEdge.parent!=null&&curEdge.parent.ELSE!=null)
      {
        curEdge=curEdge.parent.parent;
      }
      //currentNode=currentNode.parent.parent;
    }
    
  }
  calculateTree();
  int count=0;
  for (int i=0;i<20;i++)
    for(int j=0;j<5;j++){
      Button but=new Button(j*30+10,i*25+250,20,20,Integer.toString(count++));
      but.selected=but.text.equals(treeSel);
      listTreeButtons.add(but);
    }
    Button b1=new Button(10,150,69,20,"<500k",10);
    b1.selected=true;
  listClassButtons.add(b1);
  listClassButtons.add(new Button(81,150,69,20,"500k-2800k",10));
  listClassButtons.add(new Button(10,172,69,20,"2800k-8M",10));
  listClassButtons.add(new Button(81,172,69,20,">8M",10));
}

void calculateTree(){
  listPat=constructNodeFrom(classSel,map.get(treeSel));
        println("number="+listPat.size());
  counterWord=      new HashMap();
  for(int i=0;i<listPat.size();i++){
    countWord(listPat.get(i),0);
  }
}

class Button{
  int x;
  int y;
  int w;
  int h;
  boolean over;
  boolean selected;
  String text;
  float size;
  
  Button(int x,int y,int w,int h,String text){
    this(x,y,w,h,text,0.7*h);
  }
  
  Button(int x,int y,int w,int h,String text,float size){
    this.x=x;
    this.y=y;
    this.w=w;
    this.h=h;
    this.over=false;
    this.selected=false;
    this.text=text;
    this.size=size;
  }
  
  void draw(){
    drawButton(x,y,w,h,over,selected,text,size);
  }
  
  boolean select(int xin,int yin){
    return isIn(xin,yin);
    
  }
  
  boolean isIn(int xin,int yin){
    return xin>x&&xin<x+w&&yin>y&&yin<y+w;
  }
  
  void over(int xin,int yin){
    over=isIn(xin,yin);
  }
  
  void drawButton(int x,int y,int w,int h,boolean over,boolean selected,String text,float size){
    color rectColor = color(255);
    color rectHighlight = color(150);
    color rectHigh = color(100);
    if (selected) {
      fill(rectHigh);
    } else
    if (over) {
      fill(rectHighlight);
    } else {
      fill(rectColor);
    }
    stroke(0);
    textSize(size);
    rect(x, y, w, h);
    float si=textWidth(text);
    fill(0);
    text(text, x+w/2-si/2, y+h/4*3); 
  }
}
ArrayList<Node> listPat;
 float scaleFactor=4;
float translateX;
float translateY;
void draw() {
  background(255);
  Edge cuu=map.get("50");
  color c1 = color(204, 153, 0);
color c2 = #FFCC00;
int depart=0;
fill(255);
rect(width-actX-100,actY-100,width-actX+100,actY+100);
fill(c1);
noStroke();  
pushMatrix();

translate(translateX,translateY);
  scale(scaleFactor);
  //drawSuperNode(listPat);
drawAll(counterWord);
popMatrix();  
fill(255);
noStroke();
rect(0,0,width-actX-101,height);
rect(width-actX-101,actY+101,width-actX-101,height);

noStroke();

fill(c1);

//drawSuperNode(listPat);
drawAll(counterWord);
for(Button but:listTreeButtons){
  but.over(mouseX,mouseY);
  but.draw();
}
for(Button but:listClassButtons){
  but.over(mouseX,mouseY);
  but.draw();
}
stroke(0);
fill(255,255,255,0);
float minscal=100/scaleFactor;
scale(1);
if(mouseX>180)
rect(mouseX-minscal,mouseY-minscal,2*minscal,2*minscal);


}

String treeSel="0";
String classSel="<500k";


void mouseClicked() {
  for(Button but:listTreeButtons){
    boolean sel=but.select(mouseX,mouseY);
    if(sel){
      for(Button butUn:listTreeButtons){
        if(butUn!=but)
          butUn.selected=false;
      }
      but.selected=true;
      treeSel=but.text;
      calculateTree();
      break;
    }
  }
  for(Button but:listClassButtons){
    boolean sel=but.select(mouseX,mouseY);
    if(sel){
      for(Button butUn:listClassButtons){
        if(butUn!=but)
          butUn.selected=false;
      }
      but.selected=true;
      classSel=but.text;
      calculateTree();
      break;
    }
  }
}

  
int actX=100;
int actY=100;
void mouseMoved(MouseEvent e) {
  translateX = width-actX-mouseX*scaleFactor;
  translateY =  actY-mouseY*scaleFactor;
}

float baselevel=40;

float maxlevel=10;
float maxLevel=20;
float devAngle=0.005;
void drawSuperNode(ArrayList<Node> list){
  for(int i=0;i<list.size();i++){
    drawNode(list.get(i),0,i*360/list.size(),(i+1)*360/list.size());
  }
}


void drawAll(HashMap<Integer,HashMap<String,Integer>> wordCount){
  for(Integer level:wordCount.keySet()){
    drawLevel(wordCount.get(level),level);
  }
}

void drawLevel(HashMap<String,Integer> wordCount,int level){
  float angl=2*PI/wordCount.size();
  int max=0;
  for(String mess:wordCount.keySet()){
    if(wordCount.get(mess)>max) max=wordCount.get(mess);
  }
  int count=0;
  map(mouseX, 0, width, 0, 175);
  for(String mess:wordCount.keySet()){
    float si=map(wordCount.get(mess), 0, max,4, 15);
    fill(colorW.get(mess).colore);
    textSize(si);
    drawWord(mess,130+level*15.0,PI*0.5+angl*count++);
  }

}

void drawWord(String message,Float r,float baseAngle){
  // We must keep track of our position along the curve
  float arclength = 0;

  // For every box
  for (int i = 0; i < message.length(); i++)
  {
    // Instead of a constant width, we check the width of each character.
    char currentChar = message.charAt(i);
    float w = textWidth(currentChar);
    if(currentChar=='i') w=w*0.5;

    // Each box is centered so we move half the width
    arclength += w/2;
    // Angle in radians is the arclength divided by the radius
    // Starting on the left side of the circle by adding PI
    float theta = baseAngle+PI + arclength / r;    

    pushMatrix();
    // Polar to cartesian coordinate conversion
    translate(width*0.5+r*cos(theta),height*0.5+ r*sin(theta));
    // Rotate the box
    rotate(theta+PI/2); // rotation is offset by 90 degrees
    // Display the character
    text(currentChar,0,0);
    popMatrix();
    // Move halfway again
    arclength += w/2;
  }
}

void drawNode(Node cuu,float levelBase,float beginangle,float endangle){
  if(cuu==null) return;
  strokeWeight(0.5);
  //if(levelBase>maxLevel) return;
  float actLevel=baselevel+15*levelBase;
  float actLevelP=baselevel+15*((levelBase+1));
  
  float xbase=width*0.5;
  float ybase=height*0.5;
  cuu.angle=(endangle+beginangle)*0.5;
  cuu.calculate();
  stroke(153);
  if(cuu.parent!=null&&cuu.parent.parent!=null){
    Edge parente=cuu.parent;
    parente.parent.angle=(cuu.angle-devAngle+endangle+devAngle)*0.5; //<>//
    parente.parent.calculate();
    //line(cuu.x*actLevel+xbase, cuu.y*actLevel+ybase, parente.parent.x*actLevelP+xbase, parente.parent.y*actLevelP+ybase);
    drawNode(parente.parent,levelBase+1,cuu.angle-devAngle,endangle+devAngle);
  }
  
  textSize(3);
  strokeWeight(2);
  //point(cuu.x*actLevel+xbase, cuu.y*actLevel+ybase);
  strokeWeight(0.5);
  text(cuu.name, cuu.x*actLevel+xbase, cuu.y*actLevel+ybase);
}
HashMap<Integer,HashMap<String,Integer>> counterWord=new HashMap();
void countWord(Node cuu,int levelBase){
  if(cuu==null) return;
  if(counterWord.get(levelBase)==null){
    counterWord.put(levelBase,new HashMap());
  }
  if(counterWord.get(levelBase).get(cuu.name)==null){
    counterWord.get(levelBase).put(cuu.name,0);
  }
  counterWord.get(levelBase).put(cuu.name,counterWord.get(levelBase).get(cuu.name)+1);
  if(cuu.parent!=null&&cuu.parent.parent!=null){
    Edge parente=cuu.parent;
    //line(cuu.x*actLevel+xbase, cuu.y*actLevel+ybase, parente.parent.x*actLevelP+xbase, parente.parent.y*actLevelP+ybase);
    countWord(parente.parent,levelBase+1);
  }
}


ArrayList<Node> constructNodeFrom(String patt,Edge root){
  Edge start=root;
      ArrayList<Node> list= new ArrayList();
    if(start==null||start.next==null) return new ArrayList();
    if(start.next.value!=null&&start.next.value.equals(patt)){
      list.add(start.next);
      
      
    }else{
      list.addAll(constructNodeFrom(patt,root.next.IF));
      list.addAll(constructNodeFrom(patt,root.next.ELSE));
      
    }
  return list;
  
}

HashMap <String,Color> colorW=new HashMap();
class Node{
  String name;
  String content;
  Edge IF=null;
  Edge ELSE;
  Edge parent;
  float angle=random(360);
  float x;
  float y;
  String value=null;
  color colori;
  Node(String name){
    this.name=name;
    angle=random(360);
    float px = cos(radians(angle));
    float py = sin(radians(angle));
  
    this.x=px;
    this.y=py;
    if(!colorW.containsKey(name)){
      Color colore=new Color();
      colore.colore=color(50+random(155),50+random(155),50+random(155));
      colorW.put(name,colore);
    }
    this.colori=colorW.get(name).colore;
  }
  public void calculate(){
    x = cos(radians(angle));
    y = sin(radians(angle));
  
  }
 
}
class Color{
  color colore;
}
class Edge{
  String content;
  Node parent=null;
  Node next=null;
  Edge(String content,Node parent,Node next){
    this.content=content;
    this.parent=parent;
    this.next=next;
  }
 
}