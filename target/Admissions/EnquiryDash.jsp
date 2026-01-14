<%@ page import="java.util.*" %>
<%
Integer total = (Integer) request.getAttribute("total");
Map<String,Integer> classWise = (Map<String,Integer>) request.getAttribute("classWise");
Map<String,Integer> typeWise = (Map<String,Integer>) request.getAttribute("typeWise");

/* Calculate Day / Residential */
int day = 0;
int res = 0;

if(typeWise != null){
    for(Map.Entry<String,Integer> e : typeWise.entrySet()){
        if(e.getKey() != null && e.getKey().toLowerCase().contains("day"))
            day = e.getValue();
        else if(e.getKey() != null && e.getKey().toLowerCase().contains("res"))
            res = e.getValue();
    }
}
%>

<!DOCTYPE html>
<html>
<head>
<title>Admission Dashboard</title>

<style>
body { font-family: Segoe UI, Arial; background:#f4f7fb; padding:20px; }

.cards {
display:grid;
grid-template-columns: repeat(3, 1fr);
gap:20px;
margin-bottom:30px;
}

.card {
background:white;
padding:25px;
border-radius:12px;
box-shadow:0 4px 10px rgba(0,0,0,0.08);
text-align:center;
}

.card h1 { margin:0; font-size:36px; color:#2563eb; }
.card p { margin:5px 0 0; font-weight:600; color:#555; }

.grid {
display:grid;
grid-template-columns: 1fr 1fr;
gap:25px;
}

.table-box {
background:white;
padding:20px;
border-radius:12px;
box-shadow:0 4px 10px rgba(0,0,0,0.08);
}

table {
width:100%;
border-collapse: collapse;
}

th, td {
padding:10px;
border-bottom:1px solid #eee;
text-align:left;
}

th {
background:#f1f5f9;
}
</style>
</head>

<body>

<h2>📊 Admission Dashboard</h2>

<!-- ===== TOP CARDS ===== -->
<div class="cards">

<div class="card">
<h1><%= total != null ? total : 0 %></h1>
<p>Total Enquiries</p>
</div>

<div class="card">
<h1><%= day %> / <%= res %></h1>
<p>Day / Residential</p>
</div>

<div class="card">
<h1><%= (day + res) %></h1>
<p>Total Admissions</p>
</div>

</div>

<!-- ===== TABLES ===== -->
<div class="grid">

<!-- CLASS WISE -->
<div class="table-box">
<h3>Class Wise Enquiries</h3>
<table>
<tr><th>Class</th><th>Total</th></tr>

<%
if(classWise != null && !classWise.isEmpty()){
    for(Map.Entry<String,Integer> e : classWise.entrySet()){
%>
<tr>
<td><%= e.getKey() %></td>
<td><%= e.getValue() %></td>
</tr>
<%
    }
} else {
%>
<tr><td colspan="2">No Data</td></tr>
<% } %>

</table>
</div>

<!-- TYPE WISE -->
<div class="table-box">
<h3>Admission Type Wise</h3>
<table>
<tr><th>Type</th><th>Total</th></tr>

<%
if(typeWise != null && !typeWise.isEmpty()){
    for(Map.Entry<String,Integer> e : typeWise.entrySet()){
%>
<tr>
<td><%= e.getKey() %></td>
<td><%= e.getValue() %></td>
</tr>
<%
    }
} else {
%>
<tr><td colspan="2">No Data</td></tr>
<% } %>

</table>
</div>

</div>

</body>
</html>
