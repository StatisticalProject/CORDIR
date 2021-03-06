BufferedReader reader;
String line;
HashMap<String,Edge> map=new HashMap<String,Edge>(); 
HashMap<String,Node> mapNode=new HashMap<String,Node>(); 

void setup() {
    background(255);
  size(1024, 768);

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
        continue; //<>//
    }
    if (line.trim().isEmpty()){
      notInTree=true;
    }
    if (line.contains("Tree ")){
      number=line.substring(line.indexOf("Tree ")+5,line.indexOf(":")); //<>//
      notInTree=false;
      curEdge=new Edge(null,null,null);
      map.put(number.trim(),curEdge);
      println("number="+number);
    }
    if (line.contains("If ")){
      String nodeValue=line.substring(line.indexOf("feature ")+8);
      
      String reste=nodeValue.substring(nodeValue.indexOf(" ")+1,nodeValue.indexOf(")"));
      nodeValue=nodeValue.substring(0,nodeValue.indexOf(" "));
      
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
      curEdge.next=mapNode.get(nodeValue);
      if(curEdge.next==null){
        curEdge.next=new Node(nodeValue);
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
}
 float scaleFactor=3;
float translateX;
float translateY;
void draw() {
  background(255);
  Edge cuu=map.get("50");
  color c1 = color(204, 153, 0);
color c2 = #FFCC00;
int depart=0;
fill(255);
rect(0,0,200,200);
fill(c1);
noStroke();  
pushMatrix();

translate(translateX,translateY);
  scale(scaleFactor);
  drawNode(cuu.next, depart,0,360);

popMatrix();  
fill(255);
noStroke();
rect(201,0,width,height);
rect(0,201,width,height);
noStroke();

fill(c1);

drawNode(cuu.next, depart,0,360);

} 
void mouseMoved(MouseEvent e) {
  translateX = 100-mouseX*scaleFactor;
  translateY =  100-mouseY*scaleFactor;
}

float baselevel=20;

float maxlevel=10;
float maxLevel=20;
float devAngle=0.005;
void drawNode(Node cuu,float levelBase,float beginangle,float endangle){
  if(cuu==null) return;
  strokeWeight(0.5);
  if(levelBase>maxLevel) return;
  float actLevel=baselevel+20*levelBase;
  float actLevelP=baselevel+20*((levelBase+1));
  
  float xbase=width*0.5;
  float ybase=height*0.5;
  cuu.angle=(endangle+beginangle)*0.5;
  cuu.calculate();
  stroke(153);
  if(cuu.IF!=null){
    cuu.IF.next.angle=(cuu.angle-devAngle+beginangle+devAngle)*0.5;
    cuu.IF.next.calculate();
    line(cuu.x*actLevel+xbase, cuu.y*actLevel+ybase, cuu.IF.next.x*actLevelP+xbase, cuu.IF.next.y*actLevelP+ybase);
    drawNode(cuu.IF.next,levelBase+1,beginangle-devAngle,cuu.angle+devAngle);
  }
  if(cuu.ELSE!=null){
    cuu.ELSE.next.angle=(cuu.angle-devAngle+endangle+devAngle)*0.5;
    cuu.ELSE.next.calculate();
    line(cuu.x*actLevel+xbase, cuu.y*actLevel+ybase, cuu.ELSE.next.x*actLevelP+xbase, cuu.ELSE.next.y*actLevelP+ybase);
    drawNode(cuu.ELSE.next,levelBase+1,cuu.angle-devAngle,endangle+devAngle);
  }
  if(cuu.ELSE==null&&cuu.IF==null)
  {
    stroke(53);
    textSize(2);
    //text(cuu.value, cuu.x*level+xbase, cuu.y*level+ybase);
  }
  textSize(3);
  strokeWeight(2);
  point(cuu.x*actLevel+xbase, cuu.y*actLevel+ybase);
  strokeWeight(0.5);
  text(cuu.name, cuu.x*actLevel+xbase, cuu.y*actLevel+ybase);
}

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
  Node(String name){
    this.name=name;
    angle=random(360);
    float px = cos(radians(angle));
    float py = sin(radians(angle));
  
    this.x=px;
    this.y=py;
  }
  public void calculate(){
    x = cos(radians(angle));
    y = sin(radians(angle));
  
  }
 
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