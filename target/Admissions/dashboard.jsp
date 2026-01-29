<%@ page import="java.util.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page session="true" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
Integer total = (Integer) request.getAttribute("total");
Integer day = (Integer) request.getAttribute("day");
Integer res = (Integer) request.getAttribute("res");
Integer semi = (Integer) request.getAttribute("semi");

Map<String, int[]> dashboardMatrixRaw = (Map<String, int[]>) request.getAttribute("dashboardMatrix");
Map<String, int[]> capacityMap = (Map<String, int[]>) request.getAttribute("capacityMap");

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
/* ================= NORMALIZE CLASS NAMES IN JSP ================= */
Map<String, int[]> dashboardMatrix = new HashMap<>();

if(dashboardMatrixRaw != null){
    for(Map.Entry<String,int[]> e : dashboardMatrixRaw.entrySet()){
        String clean = e.getKey().toLowerCase().replaceAll("[^a-z0-9]", "");

        String normalized;
        if(clean.contains("nur")) normalized = "Nursery";
        else if(clean.equals("lkg")) normalized = "LKG";
        else if(clean.equals("ukg")) normalized = "UKG";
        // FIX: Added "x" check here
        else if(clean.equals("classx") || clean.equals("x") || clean.equals("10")) normalized = "Class 10";
        else if(clean.equals("class9") || clean.equals("9")) normalized = "Class 9";
        // ... (keep the rest as is)
        else continue;

        dashboardMatrix.put(normalized, e.getValue());
    }
}
%>

<!DOCTYPE html>
<html>
<head>
<title>Admission Dashboard</title>

<!-- Google Font -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700;800&display=swap" rel="stylesheet">

<!-- Font Awesome Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

<style>
body {
    font-family: 'Poppins', sans-serif;
    background: linear-gradient(135deg, #eef2ff, #f8fafc);
    padding: 20px;
}

.container { max-width: 1300px; margin: auto; }

h2 {
    margin-bottom: 20px;
    font-size: 34px;
    font-weight: 800;
    color: #1e3a8a;
}

/* ===== PRINT BUTTON ===== */
.print-btn {
    float: right;
    padding: 10px 18px;
    background: #020617;
    color: #fff;
    border: none;
    border-radius: 10px;
    cursor: pointer;
    font-weight: 700;
}
.print-btn i { margin-right: 6px; }

/* ===== CARDS ===== */
.cards {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
    gap: 22px;
    margin-bottom: 35px;
}

.card {
    position: relative;
    padding: 26px;
    border-radius: 22px;
    color: white;
    box-shadow: 0 15px 35px rgba(0,0,0,0.18);
    transition: 0.3s;
    overflow: hidden;
}

.card i {
    position: absolute;
    right: 20px;
    top: 20px;
    font-size: 60px;
    opacity: 0.25;
}

.card h1 { margin: 0; font-size: 42px; font-weight: 800; }
.card p { margin-top: 8px; font-size: 16px; font-weight: 600; }

.card.total { background: linear-gradient(135deg, #020617, #1e293b); }
.card.day   { background: linear-gradient(135deg, #1d4ed8, #60a5fa); }
.card.res   { background: linear-gradient(135deg, #15803d, #4ade80); }
.card.semi  { background: linear-gradient(135deg, #c2410c, #fb923c); }

/* ===== TABLE ===== */
.table-box {
    background: white;
    padding: 26px;
    border-radius: 22px;
    box-shadow: 0 25px 60px rgba(0,0,0,0.12);
}

table { width: 100%; border-collapse: collapse; font-size: 14px; }

thead th {
    padding: 12px;
    background: linear-gradient(135deg, #fde047, #facc15);
    border: 1px solid #f59e0b;
    text-align:center;
}

td {
    padding: 10px;
    text-align: center;
    border: 1px solid #e5e7eb;
    font-weight: 600;
}

td:first-child { text-align: left; font-weight: 800; }

.totalCol { background: #f1f5f9; font-weight: 900; }

.grandRow td {
    background: #020617;
    color: white;
    font-weight: 900;
}

/* ===== PRINT MODE ===== */
@media print {
    .print-btn, .no-print { display: none !important; }
    body { background: white; }
}
</style>

<script>
function printDashboard() {
    window.print();
}
</script>

</head>

<body>

<div class="no-print">
    <jsp:include page="common_header.jsp" />
</div>

<div class="container">

<button class="print-btn" onclick="printDashboard()">
    <i class="fa-solid fa-print"></i> Print Dashboard
</button>
<h2 align="center">Sandur Residential School</h2>
<h2 align="center"><i class="fa-solid fa-chart-column"></i> Admission Dashboard(2026-27)</h2>

<div class="cards">
    <div class="card total">
        <i class="fa-solid fa-users"></i>
        <h1><%= total %></h1>
        <p>Total Enquiries</p>
    </div>

    <div class="card day">
        <i class="fa-solid fa-school"></i>
        <h1><%= day %></h1>
        <p>Day Scholars</p>
    </div>

    <div class="card res">
        <i class="fa-solid fa-house-chimney-user"></i>
        <h1><%= res %></h1>
        <p>Residential</p>
    </div>

    <div class="card semi">
        <i class="fa-solid fa-bus"></i>
        <h1><%= semi %></h1>
        <p>Semi Residential</p>
    </div>
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
String[] classOrder = {"Nursery","LKG","UKG","Class 1","Class 2","Class 3","Class 4","Class 5","Class 6","Class 7","Class 8","Class 9","Class 10"};

int gPSD=0, gPSR=0, gPSS=0, gPS=0;
int gED=0, gER=0, gES=0, gE=0;

for(String cls : classOrder){
    int[] v = (dashboardMatrix!=null && dashboardMatrix.get(cls)!=null) ? dashboardMatrix.get(cls) : new int[]{0,0,0,0,0,0};

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
<div class="table-box">

<h3 style="margin-bottom:15px; color:#1e3a8a;">Class Capacity Status</h3>

<table>
<thead>
<tr>
    <th rowspan="2">Class</th>

    <th colspan="3">Day Scholar</th>
    <th colspan="3">Residential</th>
    <th colspan="3">Total</th>
</tr>
<tr>
    <th>Cap</th>
    <th>Present</th>
    <th>Vacancy</th>

    <th>Cap</th>
    <th>Present</th>
    <th>Vacancy</th>

    <th>Cap</th>
    <th>Present</th>
    <th>Vacancy</th>
</tr>
</thead>

<tbody>
<%
String[] classOrder2 = {
		  "PreKG","LKG","UKG","Class 1","Class 2","Class 3","Class 4",
		  "Class 5","Class 6","Class 7","Class 8","Class 9","Class 10"
		};
// ===== GRAND TOTAL VARIABLES =====
int gDayCap=0, gDayPre=0, gDayVac=0;
int gResCap=0, gResPre=0, gResVac=0;
int gTotCap=0, gTotPre=0, gTotVac=0;

for(String cls : classOrder2){

    // capacityMap: [dayCap, resCap, totalCap]
    int[] cap = (capacityMap != null && capacityMap.get(cls) != null) 
                ? capacityMap.get(cls) 
                : new int[]{0,0,0};

    // dashboardMatrix: [dayPresent, resPresent, semi, ...]
    int[] ps = (dashboardMatrix != null && dashboardMatrix.get(cls) != null) 
               ? dashboardMatrix.get(cls) 
               : new int[]{0,0,0,0,0,0};

    int dayCap = cap[0];
    int resCap = cap[1];
    int totalCap = cap[2];

    // Day Scholar = Day + Semi
    int dayPresent = ps[0] + ps[2];

    // Residential only
    int resPresent = ps[1];

    // Total = Day + Semi + Residential
    int totalPresent = dayPresent + resPresent;

    int dayVac = dayCap - dayPresent;
    int resVac = resCap - resPresent;
    int totalVac = totalCap - totalPresent;

    if(dayVac < 0) dayVac = 0;
    if(resVac < 0) resVac = 0;
    if(totalVac < 0) totalVac = 0;

    // ===== ADD TO GRAND TOTALS =====
    gDayCap += dayCap; gDayPre += dayPresent; gDayVac += dayVac;
    gResCap += resCap; gResPre += resPresent; gResVac += resVac;
    gTotCap += totalCap; gTotPre += totalPresent; gTotVac += totalVac;
%>
<tr>
    <td><%= cls %></td>

    <!-- Day Scholar -->
    <td><%= dayCap %></td>
    <td><%= dayPresent %></td>
    <td><%= dayVac %></td>

    <!-- Residential -->
    <td><%= resCap %></td>
    <td><%= resPresent %></td>
    <td><%= resVac %></td>

    <!-- Total -->
    <td><%= totalCap %></td>
    <td><%= totalPresent %></td>
    <td><%= totalVac %></td>
</tr>
<% } %>

<!-- ===== GRAND TOTAL ROW ===== -->
<tr style="background:#020617; color:white; font-weight:900;">
    <td>GRAND TOTAL</td>

    <td><%= gDayCap %></td>
    <td><%= gDayPre %></td>
    <td><%= gDayVac %></td>

    <td><%= gResCap %></td>
    <td><%= gResPre %></td>
    <td><%= gResVac %></td>

    <td><%= gTotCap %></td>
    <td><%= gTotPre %></td>
    <td><%= gTotVac %></td>
</tr>

</tbody>
</table>



</div>

</div>

</body>
</html>
