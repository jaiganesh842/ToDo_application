<%@ page  import="java.util.*" %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Main</title>
</head>
<body>
<%
List<String> items = (List<String>) session.getAttribute("Mytodoapp");
if(items==null){
	items = new ArrayList<String>();
	session.setAttribute("Mytodoapp",items);
}

String theItem = request.getParameter("theItem");
if( theItem!=null && !theItem.isEmpty() && request.getParameter("Add") != null ){
	items.add(theItem);
}

String removeItem = request.getParameter("remove");
if(removeItem!= null && !removeItem.isEmpty()){
	items.remove(removeItem);
}
%>
<form action="index.jsp" method="post" >
<input type="text" name="theItem" >
<input type="submit" value="Add" name="Add" />
</form>

The items are:
<ol>
<%
for(String temp : items){
	out.println("<li>"+temp+"</li>");
%>
<form action="index.jsp" method="post">
<input type="hidden" name="remove" value="<%=temp%>" />
<input type="submit" value="remove" />
</form>	
<%	
}
%>
</ol>
</body>
</html>