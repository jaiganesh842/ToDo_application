<%@ page import="java.util.*" %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="./Css/index.css">
  <meta charset="ISO-8859-1">
  <title>Main</title>
</head>
<body>
<%
  List<String> items = (List<String>) session.getAttribute("Mytodoapp");
  if (items == null) {
    items = new ArrayList<String>();
    session.setAttribute("Mytodoapp", items);
  }

  String theItem = request.getParameter("theItem");
  if (theItem != null && !theItem.isEmpty() && request.getParameter("Add") != null) {
    items.add(theItem);
  }

  String removeItem = request.getParameter("remove");
  if (removeItem != null && !removeItem.isEmpty()) {
    items.remove(removeItem);
  }
%>
<h2 class="heading">To Do Application</h2>
<div class="container">
  <form class="form1" action="index.jsp" method="post">
    <div class="input-container">
      <input class="input1" type="text" name="theItem">
      <input class="Add" type="submit" value="Add" name="Add" />
    </div>
  </form>

  <p>The items are:</p>
  <ul>
    <% for (String temp : items) { %>
    <li>
      <div class="item-container">
        <%= temp %>
        <form class="form2" action="index.jsp" method="post">
          <input type="hidden" name="remove" value="<%=temp%>" />
          <input class="remove" type="submit" value="remove" />
        </form>
      </div>
    </li>
    <% } %>
  </ul>
</div>
</body>
</html>
