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
  int range=2;
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
          next.angle=curEdge.parent.angle+ random(-range, range);
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
 
void draw() {
  Edge cuu=map.get("1");
  color c1 = color(204, 153, 0);
color c2 = #FFCC00;
noStroke();
fill(c1);
  drawNode(cuu.next, 100);
} 
int baselevel=35;
void drawNode(Node cuu,int level){
  if(cuu==null) return;
  float xbase=width*0.5;
  float ybase=height*0.5;
  stroke(153);
  if(cuu.IF!=null){
    line(cuu.x*level+xbase, cuu.y*level+ybase, cuu.IF.next.x*(level+baselevel)+xbase, cuu.IF.next.y*(level+baselevel)+ybase);
    drawNode(cuu.IF.next,level+baselevel);
  }
  if(cuu.ELSE!=null){
    line(cuu.x*level+xbase, cuu.y*level+ybase, cuu.ELSE.next.x*(level+baselevel)+xbase, cuu.ELSE.next.y*(level+baselevel)+ybase);
    drawNode(cuu.ELSE.next,level+baselevel);
  }
  if(cuu.ELSE==null&&cuu.IF==null)
  {
    stroke(253);
    textSize(20);
    
    text(cuu.value, cuu.x*level+xbase, cuu.y*level+ybase);
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