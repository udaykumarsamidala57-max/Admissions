<%@ page import="java.util.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page session="true" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
Integer total = (Integer) request.getAttribute("total");
Integer day = (Integer) request.getAttribute("day");
Integer res = (Integer) request.getAttribute("res");
Integer semi = (Integer) request.getAttribute("semi");

Map<String, int[]> classTypeWise = (Map<String, int[]>) request.getAttribute("classTypeWise");
Map<String, int[]> dashboardMatrixRaw = (Map<String, int[]>) request.getAttribute("dashboardMatrix");

if(total == null) total = 0;
if(day == null) day = 0;
if(res == null) res = 0;
if(semi == null) semi = 0;
%>

<%
HttpSession sess = request.getSession(false);
if (sess == null || sess.getAttribute("username") == null) {
    response.sendRedirect("login.jsp");
    return;
}
%>

<%
/* ================= NORMALIZE CLASS NAMES ================= */
Map<String, int[]> dashboardMatrix = new HashMap<>();

if(dashboardMatrixRaw != null){
    for(Map.Entry<String,int[]> e : dashboardMatrixRaw.entrySet()){
        String raw = e.getKey().toLowerCase().replaceAll("[^a-z0-9]", "");

        String normalized = raw;

        if(raw.contains("nur")) normalized = "Nursery";
        else if(raw.contains("lkg")) normalized = "LKG";
        else if(raw.contains("ukg")) normalized = "UKG";
        else if(raw.equals("X") || raw.contains("classX")) normalized = "Class-X";
        else if(raw.equals("9") || raw.contains("class9")) normalized = "Class 9";
        else if(raw.equals("8") || raw.contains("class8")) normalized = "Class 8";
        else if(raw.equals("7") || raw.contains("class7")) normalized = "Class 7";
        else if(raw.equals("6") || raw.contains("class6")) normalized = "Class 6";
        else if(raw.equals("5") || raw.contains("class5")) normalized = "Class 5";
        else if(raw.equals("4") || raw.contains("class4")) normalized = "Class 4";
        else if(raw.equals("3") || raw.contains("class3")) normalized = "Class 3";
        else if(raw.equals("2") || raw.contains("class2")) normalized = "Class 2";
        else if(raw.equals("1") || raw.contains("class1")) normalized = "Class 1";


        dashboardMatrix.put(normalized, e.getValue());
    }
}
%>

<!DOCTYPE html>
<html>
<head>
<title>Admission Dashboard</title>

<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700;800&display=swap" rel="stylesheet">

<style>
body {
    font-family: 'Poppins', sans-serif;
    background: linear-gradient(135deg, #eef2ff, #f8fafc);
    padding: 20px;
}

.container { max-width: 1300px; margin: auto; }

h2 {
    margin-bottom: 24px;
    font-size: 34px;
    font-weight: 800;
    color: #1e3a8a;
}

/* ===== CARDS ===== */
.cards {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
    gap: 22px;
    margin-bottom: 35px;
}

.card {
    padding: 26px;
    border-radius: 22px;
    color: white;
    box-shadow: 0 15px 35px rgba(0,0,0,0.18);
    transition: transform .3s ease, box-shadow .3s ease;
}

.card:hover {
    transform: translateY(-6px) scale(1.02);
    box-shadow: 0 25px 45px rgba(0,0,0,0.25);
}

.card h1 { margin: 0; font-size: 42px; font-weight: 800; }
.card p { margin-top: 8px; font-size: 15px; opacity: .9; }

.card.total { background: linear-gradient(135deg, #020617, #1e293b); }
.card.day   { background: linear-gradient(135deg, #1d4ed8, #60a5fa); }
.card.res   { background: linear-gradient(135deg, #15803d, #4ade80); }
.card.semi  { background: linear-gradient(135deg, #c2410c, #fb923c); }

/* ===== TABLE BOX ===== */
.table-box {
    background: rgba(255,255,255,0.9);
    padding: 26px;
    border-radius: 22px;
    box-shadow: 0 25px 60px rgba(0,0,0,0.12);
    border: 1px solid rgba(226,232,240,0.9);
}

table { width: 100%; border-collapse: collapse; font-size: 14px; background: white; }

thead th {
    padding: 12px;
    background: linear-gradient(135deg, #fde047, #facc15);
    border: 1px solid #f59e0b;
    text-align:center;
    position: sticky;
    top: 0;
}

tbody tr:nth-child(even) { background: #f8fafc; }
tbody tr:hover { background: #e0f2fe; }

td {
    padding: 10px;
    text-align: center;
    border: 1px solid #e5e7eb;
    font-weight: 600;
}

td:first-child { text-align: left; font-weight: 800; }

.totalCol {
    background: #f1f5f9;
    font-weight: 900;
    color: #020617;
}

.grandRow td {
    background: #020617;
    color: white;
    font-weight: 900;
    font-size: 15px;
}
</style>

</head>

<body>
<jsp:include page="common_header.jsp" />

<div class="container">

<h2>📊 Admission Dashboard</h2>

<div class="cards">
    <div class="card total"><h1><%= total %></h1><p>Total Enquiries</p></div>
    <div class="card day"><h1><%= day %></h1><p>Day Scholars</p></div>
    <div class="card res"><h1><%= res %></h1><p>Residential</p></div>
    <div class="card semi"><h1><%= semi %></h1><p>Semi Residential</p></div>
</div>

<div class="table-box">

<table>
<thead>
<tr>
    <th rowspan="2">Class</th>
    <th colspan="4">Present Strength</th>
    <th colspan="4">Enquiries</th>
</tr>
<tr>
    <th>Day</th><th>Res</th><th>Semi</th><th>Total</th>
    <th>Day</th><th>Res</th><th>Semi</th><th>Total</th>
</tr>
</thead>

<tbody>
<%
String[] classOrder = {
    "Nursery","LKG","UKG",
    "Class 1","Class 2","Class 3","Class 4","Class 5",
    "Class 6","Class 7","Class 8","Class 9","Class-X,"
};

int gPSD=0, gPSR=0, gPSS=0, gPS=0;
int gED=0, gER=0, gES=0, gE=0;

for(String cls : classOrder){
    int[] v = (dashboardMatrix!=null && dashboardMatrix.get(cls)!=null)
                ? dashboardMatrix.get(cls)
                : new int[]{0,0,0,0,0,0};

    int psTotal = v[0]+v[1]+v[2];
    int enqTotal = v[3]+v[4]+v[5];

    gPSD+=v[0]; gPSR+=v[1]; gPSS+=v[2]; gPS+=psTotal;
    gED+=v[3]; gER+=v[4]; gES+=v[5]; gE+=enqTotal;
%>
<tr>
<td><%= cls %></td>
<td><%= v[0] %></td>
<td><%= v[1] %></td>
<td><%= v[2] %></td>
<td class="totalCol"><%= psTotal %></td>
<td><%= v[3] %></td>
<td><%= v[4] %></td>
<td><%= v[5] %></td>
<td class="totalCol"><%= enqTotal %></td>
</tr>
<% } %>

<tr class="grandRow">
<td>GRAND TOTAL</td>
<td><%= gPSD %></td>
<td><%= gPSR %></td>
<td><%= gPSS %></td>
<td><%= gPS %></td>
<td><%= gED %></td>
<td><%= gER %></td>
<td><%= gES %></td>
<td><%= gE %></td>
</tr>

</tbody>
</table>

</div>
</div>
</body>
</html>
