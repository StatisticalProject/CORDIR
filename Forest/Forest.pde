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
        mapNode.put(nodeValue,curEdge.next);
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
  drawNode(cuu.next, 500, 100);
} 

void drawNode(Node cuu,int x,int y){
  if(cuu==null) return;
  stroke(153);
  if(cuu.IF!=null){
    line(cuu.x, cuu.y, cuu.IF.next.x, cuu.IF.next.y);
    drawNode(cuu.IF.next,x+20,y+20);
  }
  if(cuu.ELSE!=null){
    line(cuu.x, cuu.y, cuu.ELSE.next.x, cuu.ELSE.next.y);
    drawNode(cuu.ELSE.next,x-20,y+20);
  }
  if(cuu.ELSE==null&&cuu.IF==null)
  {
    stroke(253);
    textSize(20);
    text(cuu.value, cuu.x, cuu.y);
  }
  textSize(1);
  text(cuu.name, cuu.x, cuu.y);
}

class Node{
  String name;
  String content;
  Edge IF=null;
  Edge ELSE;
  Edge parent;
  int x;
  int y;
  String value=null;
  Node(String name){
    this.name=name;
    this.x=int(random(width));
    this.y=int(random(height));
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