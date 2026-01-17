<%@ page import="java.util.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page session="true" %>
<%
Integer total = (Integer) request.getAttribute("total");
Integer day = (Integer) request.getAttribute("day");
Integer res = (Integer) request.getAttribute("res");
Integer semi = (Integer) request.getAttribute("semi");

Map<String, int[]> classTypeWise = (Map<String, int[]>) request.getAttribute("classTypeWise");

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

    String role = (String) sess.getAttribute("role");
    String User = (String) sess.getAttribute("username");
%>
<!DOCTYPE html>
<html>
<head>
<title>Admission Dashboard</title>

<style>
body {
    font-family: "Segoe UI", Arial, sans-serif;
    background: linear-gradient(135deg, #eef2ff, #f8fafc);
    padding: 20px;
}

/* ===== PAGE WRAPPER ===== */
.container {
    max-width: 1150px;
    margin: auto;
}

/* ===== HEADER ===== */
h2 {
    margin-bottom: 24px;
    font-size: 30px;
    font-weight: 900;
    letter-spacing: 0.4px;
    color: #1e3a8a;
}

/* ===== CARDS ===== */
.cards {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 22px;
    margin-bottom: 35px;
}

.card {
    padding: 24px;
    border-radius: 18px;
    color: white;
    position: relative;
    overflow: hidden;
    box-shadow: 0 10px 25px rgba(0,0,0,0.15);
    transition: 0.3s;
}

.card:hover {
    transform: translateY(-5px);
}

/* Card colors */
.card.total { background: linear-gradient(135deg, #0f172a, #1e293b); }
.card.day { background: linear-gradient(135deg, #2563eb, #60a5fa); }
.card.res { background: linear-gradient(135deg, #16a34a, #4ade80); }
.card.semi { background: linear-gradient(135deg, #ea580c, #fb923c); }

.card h1 {
    margin: 0;
    font-size: 42px;
    font-weight: 900;
}

.card p {
    margin-top: 6px;
    font-weight: 700;
    letter-spacing: 0.4px;
}

/* icon circle */
.card .icon {
    position: absolute;
    right: 18px;
    top: 18px;
    width: 52px;
    height: 52px;
    border-radius: 50%;
    background: rgba(255,255,255,0.25);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 24px;
    font-weight: bold;
}

/* ===== TABLE CONTAINER (SOFT GLASS CARD) ===== */
.table-box {
    background: rgba(255,255,255,0.85);
    backdrop-filter: blur(10px);
    padding: 26px;
    border-radius: 20px;
    box-shadow:
        0 20px 45px rgba(0,0,0,0.10),
        inset 0 1px 0 rgba(255,255,255,0.7);
    border: 1px solid rgba(226,232,240,0.9);
}

/* ===== TITLE ===== */
.table-box h3 {
    margin: 0 0 20px;
    font-size: 20px;
    font-weight: 900;
    color: #0f172a;
    letter-spacing: 0.4px;
}

/* ===== TABLE ===== */
table {
    width: 100%;
    border-collapse: collapse;
    font-size: 14px;
    background: white;
}

/* ===== HEADER ===== */
thead th {
    padding: 12px 12px;
    background: linear-gradient(135deg, #fde047, #facc15); /* yellow */
    color: #422006;
    text-transform: uppercase;
    font-size: 12px;
    letter-spacing: 0.6px;
    font-weight: 900;
    border: 1px solid #f59e0b;
}

/* ===== CELLS ===== */
td {
    padding: 10px 12px;
    text-align: center;
    font-weight: 600;
    color: #1f2933;
    border: 1px solid #e5e7eb;
}

/* first column */
td:first-child {
    text-align: left;
    font-weight: 800;
}

/* ===== ZEBRA STRIPES ===== */
tbody tr:nth-child(odd) td {
    background: #fffef3;
}

tbody tr:nth-child(even) td {
    background: #fff7cc;
}

/* ===== ROW HOVER ===== */
tbody tr:hover td {
    background: #fde68a;
}

/* ===== FOOTER ===== */
tfoot td {
    background: #facc15;
    font-weight: 900;
    color: #422006;
    border: 1px solid #f59e0b;
}

/* ===== COLORED NUMBERS (BADGE STYLE) ===== */
.dayTxt {
    color: #1d4ed8;
    background: #e0e7ff;
    padding: 6px 12px;
    border-radius: 999px;
    font-weight: 900;
}

.resTxt {
    color: #15803d;
    background: #dcfce7;
    padding: 6px 12px;
    border-radius: 999px;
    font-weight: 900;
}

.semiTxt {
    color: #c2410c;
    background: #ffedd5;
    padding: 6px 12px;
    border-radius: 999px;
    font-weight: 900;
}

.totalTxt {
    color: #020617;
    background: #e5e7eb;
    padding: 6px 12px;
    border-radius: 999px;
    font-weight: 900;
}

/* ===== FOOTER TOTAL ROW ===== */
tfoot tr {
    background: linear-gradient(135deg, #eef2ff, #e0e7ff);
    box-shadow: 0 8px 22px rgba(0,0,0,0.1);
}

tfoot td {
    padding: 16px 14px;
    font-weight: 900;
    color: #1e3a8a;
    border-radius: 12px;
}


/* ===== COLORED NUMBERS ===== */
.dayTxt {
    color: #1d4ed8;
    font-weight: 900;
}
.resTxt {
    color: #15803d;
    font-weight: 900;
}
.semiTxt {
    color: #c2410c;
    font-weight: 900;
}
.totalTxt {
    color: #020617;
    font-weight: 900;
}

/* ===== TOTAL ROW ===== */
tfoot td {
    padding: 14px 12px;
    font-weight: 900;
    background: linear-gradient(135deg, #eef2ff, #e0e7ff);
    color: #1e3a8a;
    border-top: 2px solid #c7d2fe;
}

/* round bottom corners */
tfoot td:first-child { border-bottom-left-radius: 16px; }
tfoot td:last-child { border-bottom-right-radius: 16px; }

/* ===== LOAD ANIMATION ===== */
.cards, .table-box {
    animation: fadeUp 0.6s ease;
}
/* ===== TOP HEADER BAR ===== */
.topbar {
    height: 64px;
    background: linear-gradient(90deg, #312e81, #5b21b6, #6d28d9);
    color: white;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 24px;
    border-radius: 14px;
    margin-bottom: 25px;
    box-shadow: 0 8px 22px rgba(0,0,0,0.25);
}

.topbar .title {
    font-size: 20px;
    font-weight: 900;
    letter-spacing: 0.4px;
}

/* ===== RIGHT BUTTONS ===== */
.topbar .actions {
    display: flex;
    gap: 12px;
}

.topbar .btn {
    border: none;
    padding: 8px 16px;
    border-radius: 10px;
    font-weight: 800;
    cursor: pointer;
    color: white;
    box-shadow: 0 4px 10px rgba(0,0,0,0.2);
    transition: 0.2s;
}

.topbar .btn:hover {
    transform: translateY(-1px);
}

/* Button colors */
.btn-dashboard { background: #2563eb; }
.btn-export { background: #22c55e; }
.btn-logout { background: #ef4444; }

@keyframes fadeUp {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
}
</style>
</head>

<body>
<div class="topbar">
    <div class="title">Admission Enquiry Dashboard</div>

    <div class="actions">
        <button class="btn btn-dashboard" onclick="location.href='admission'">Enquiries</button>
        <button class="btn btn-export" onclick="location.href='exportExcel'">Export</button>
        <button class="btn btn-logout" onclick="location.href='Logout.jsp'">Logout</button>
    </div>
</div>
<div class="container">

<h2>Admission Dashboard</h2>

<!-- ===== TOP CARDS ===== -->
<div class="cards">

    <div class="card total">
        <div class="icon">T</div>
        <h1><%= total %></h1>
        <p>Total Enquiries</p>
    </div>

    <div class="card day">
        <div class="icon">D</div>
        <h1><%= day %></h1>
        <p>Day Scholars</p>
    </div>

    <div class="card res">
        <div class="icon">R</div>
        <h1><%= res %></h1>
        <p>Residential</p>
    </div>

    <div class="card semi">
        <div class="icon">S</div>
        <h1><%= semi %></h1>
        <p>Semi Residential</p>
    </div>

</div>

<!-- ===== TABLE ===== -->
<div class="table-box">
<h3>Class Wise Admission Summary</h3>

<table>
<thead>
<tr>
    <th>Class</th>
    <th>Day</th>
    <th>Residential</th>
    <th>Semi</th>
    <th>Total</th>
</tr>
</thead>

<tbody>
<%
int gDay = 0, gRes = 0, gSemi = 0, gTotal = 0;

if(classTypeWise != null && !classTypeWise.isEmpty()){
    for(Map.Entry<String, int[]> e : classTypeWise.entrySet()){
        int[] v = e.getValue();
        gDay += v[0];
        gRes += v[1];
        gSemi += v[2];
        gTotal += v[3];
%>
<tr>
    <td><%= e.getKey() %></td>
    <td class="dayTxt"><%= v[0] %></td>
    <td class="resTxt"><%= v[1] %></td>
    <td class="semiTxt"><%= v[2] %></td>
    <td class="totalTxt"><%= v[3] %></td>
</tr>
<%
    }
} else {
%>
<tr>
    <td colspan="5">No Data Available</td>
</tr>
<% } %>
</tbody>

<tfoot>
<tr>
    <td>Grand Total</td>
    <td><%= gDay %></td>
    <td><%= gRes %></td>
    <td><%= gSemi %></td>
    <td><%= gTotal %></td>
</tr>
</tfoot>

</table>
</div>

</div>
</body>
</html>
