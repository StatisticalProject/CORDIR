BufferedReader reader;
String line;
HashMap<String,Node> map=new HashMap<String,Node>(); 
void setup() {
    background(255);
  size(1024, 768);

  // Open the file from the createWriter() example
  reader = createReader("../model.txt");
  boolean notInTree=true;
  String number="0";
  Node currentNode=new Node("root","");
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
      currentNode=new Node("root","");
      map.put(number.trim(),currentNode);
      println("number="+number);
    }
    if (line.contains("If ")){
      String nodeValue=line.substring(line.indexOf("feature ")+8);
      
      String reste=nodeValue.substring(nodeValue.indexOf(" ")+1,nodeValue.indexOf(")"));
      nodeValue=nodeValue.substring(0,nodeValue.indexOf(" "));
      currentNode.IF=new Node(nodeValue,reste);
      if(currentNode.IF.parent!=null)
      currentNode.IF.parent.name=nodeValue;
      currentNode.IF.parent=currentNode;
      currentNode=currentNode.IF;
      
    }
    if (line.contains("Else ")){
      String nodeValue=line.substring(line.indexOf("feature ")+8);
      
      String reste=nodeValue.substring(nodeValue.indexOf(" ")+1,nodeValue.indexOf(")"));
      nodeValue=nodeValue.substring(0,nodeValue.indexOf(" "));
      currentNode=currentNode.parent;
      currentNode.ELSE=new Node(nodeValue,reste);
        currentNode.ELSE.parent=currentNode;
        currentNode=currentNode.ELSE;
      
    }
    if (line.contains("Predict: ")){
      String nodeValue=line.substring(line.indexOf("Predict: ")+9);
      currentNode.value=nodeValue;
      
    }
    
  }
}
 
void draw() {
  Node cuu=map.get("0");
  color c1 = color(204, 153, 0);
color c2 = #FFCC00;
noStroke();
fill(c1);
  drawNode(cuu, 500, 100);
} 

void drawNode(Node cuu,int x,int y){
  stroke(153);
  if(cuu.IF!=null){
    line(x, y, x+20, y+20);
    drawNode(cuu.IF,x+20,y+20);
  }
  if(cuu.ELSE!=null){
    line(x, y, x-20, y+20);
    drawNode(cuu.ELSE,x-20,y+20);
  }
  if(cuu.ELSE==null&&cuu.IF==null)
  {
    text(cuu.value, x+20, y);
  }
  text(cuu.name, x, y);
}

class Node{
  String name;
  String content;
  Edge IF=null;
  Edge ELSE;
  Edge parent;
  String value=null;
  Node(String name){
    
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