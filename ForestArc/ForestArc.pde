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
  int range=50;
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
int depart=10;
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

float baselevel=1.3;

float maxlevel=100;
void drawNode(Node cuu,float level,float beginangle,float endangle){
  if(cuu==null) return;
  float nextLevel=maxlevel*log(level*baselevel);
  float xbase=width*0.5;
  float ybase=height*0.5;
  cuu.angle=(endangle+beginangle)*0.5;
  cuu.calculate();
  stroke(153);
  if(cuu.IF!=null){
    cuu.IF.next.angle=(cuu.angle+beginangle)*0.5;
    cuu.IF.next.calculate();
    line(cuu.x*level+xbase, cuu.y*level+ybase, cuu.IF.next.x*nextLevel+xbase, cuu.IF.next.y*nextLevel+ybase);
    drawNode(cuu.IF.next,nextLevel,beginangle,cuu.angle);
  }
  if(cuu.ELSE!=null){
    cuu.ELSE.next.angle=(cuu.angle+endangle)*0.5;
    cuu.ELSE.next.calculate();
    line(cuu.x*level+xbase, cuu.y*level+ybase, cuu.ELSE.next.x*(level*baselevel)+xbase, cuu.ELSE.next.y*(level*baselevel)+ybase);
    drawNode(cuu.ELSE.next,nextLevel,cuu.angle,endangle);
  }
  if(cuu.ELSE==null&&cuu.IF==null)
  {
    stroke(53);
    textSize(9);
    //text(cuu.value, cuu.x*level+xbase, cuu.y*level+ybase);
  }
  textSize(8);
  text(cuu.name, cuu.x*level+xbase, cuu.y*level+ybase);
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