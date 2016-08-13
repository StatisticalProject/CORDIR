BufferedReader reader;
String line;
HashMap<String,Edge> map=new HashMap<String,Edge>(); 
HashMap<String,Node> mapNode=new HashMap<String,Node>(); 
ArrayList<String> mapWordConc=new ArrayList<String>();
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
      if(val==0) nodeValue="PROGRAMME";
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
  
  listPat=constructNodeFrom("3.0",map.get("50"));
        println("number="+listPat.size());
  
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
rect(0,0,200,200);
fill(c1);
noStroke();  
pushMatrix();

translate(translateX,translateY);
  scale(scaleFactor);
  drawSuperNode(listPat);

popMatrix();  
fill(255);
noStroke();
rect(201,0,width,height);
rect(0,201,width,height);
noStroke();

fill(c1);

drawSuperNode(listPat);

} 
void mouseMoved(MouseEvent e) {
  translateX = 100-mouseX*scaleFactor;
  translateY =  100-mouseY*scaleFactor;
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