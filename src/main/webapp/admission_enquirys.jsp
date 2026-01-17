<%@ page import="javax.sql.rowset.CachedRowSet" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page session="true" %>
<!DOCTYPE html>

<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String role = (String) sess.getAttribute("role");
    String User = (String) sess.getAttribute("username");
%>

<html>
<head>
<title>Admission Enquiry Register</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">

<style>
*{ box-sizing:border-box; font-family:Inter,Segoe UI,Arial; }

body{
    margin:0;
    min-height:100vh;
    background:
        radial-gradient(circle at 10% 10%, #dbeafe 0%, transparent 40%),
        radial-gradient(circle at 90% 20%, #fef3c7 0%, transparent 40%),
        linear-gradient(135deg,#eef2ff,#f8fafc);
}

.app{ display:flex; flex-direction:column; height:100vh; }

/* ===== HEADER ===== */
.toolbar{
    position:sticky; top:0; z-index:100;
    background: linear-gradient(135deg,#1e3a8a,#4338ca);
    padding:14px 22px;
    display:flex; justify-content:space-between; align-items:center;
    box-shadow:0 10px 30px rgba(0,0,0,0.25);
    color:white;
}
.toolbar h2{ margin:0; font-size:22px; font-weight:700; }

.btn{
    border:none; padding:9px 16px; border-radius:12px;
    cursor:pointer; font-weight:600; font-size:14px;
    color:white;
    background: linear-gradient(135deg,#22c55e,#16a34a);
    box-shadow:0 6px 14px rgba(0,0,0,0.25);
    transition:.2s;
}
.btn:hover{ transform:translateY(-2px); }
.btn.red{ background:linear-gradient(135deg,#ef4444,#dc2626); }
.btn.gray{ background:linear-gradient(135deg,#64748b,#475569); }
.btn.blue{ background:linear-gradient(135deg,#2563eb,#1d4ed8); }

/* ===== FILTER BAR ===== */
.filters{
    margin:14px;
    padding:12px 14px;
    display:flex; gap:12px; flex-wrap:wrap;
    background: rgba(255,255,255,0.85);
    backdrop-filter: blur(10px);
    border-radius:16px;
    box-shadow:0 8px 20px rgba(0,0,0,0.1);
}
.filters input, .filters select{
    padding:9px 12px;
    border-radius:10px;
    border:1px solid #c7d2fe;
    font-size:14px;
}

/* ===== TABLE ===== */
.table-wrap{ flex:1; overflow:auto; padding:0 14px 14px 14px; }

table{
    width:100%;
    border-collapse:separate;
    border-spacing:0;
    background:white;
    border-radius:16px;
    overflow:hidden;
    box-shadow:0 10px 25px rgba(0,0,0,0.12);
}
th{
    position:sticky; top:0;
    background:#eef2ff;
    z-index:10; font-weight:700;
}
th,td{
    padding:10px;
    border-bottom:1px solid #e5e7eb;
    text-align:center;
    font-size:13.5px;
}
tr:nth-child(even){ background:#f8fafc; }
tr:hover{ background:#eef2ff; }

/* Badges */
.badge-day{ background:#dcfce7; color:#166534; padding:4px 10px; border-radius:20px; font-weight:700; }
.badge-res{ background:#fee2e2; color:#7f1d1d; padding:4px 10px; border-radius:20px; font-weight:700; }

/* ===== MODALS ===== */
.modal-overlay{
    position:fixed; inset:0;
    background: rgba(0,0,0,0.6);
    display:flex; align-items:center; justify-content:center;
    z-index:9999;
}
.modal-box{
    background:white;
    padding:22px;
    border-radius:18px;
    width:700px; max-width:95%;
    box-shadow:0 20px 60px rgba(0,0,0,0.45);
    animation: pop .25s ease;
}
@keyframes pop{
    from{ transform:scale(.85); opacity:0; }
    to{ transform:scale(1); opacity:1; }
}
.modal-header{
    display:flex; justify-content:space-between; align-items:center;
    margin-bottom:10px;
}
.close-btn{
    background:#ef4444; color:white;
    border:none; padding:6px 12px;
    border-radius:8px; cursor:pointer;
}

/* Form grid */
.form-grid{
    display:grid;
    grid-template-columns: repeat(3, 1fr);
    gap:10px;
}
.form-grid input{ width:100%; }

/* Dashboard table */
.dash-table{
    width:100%;
    border-collapse:collapse;
    margin-top:15px;
}
.dash-table th, .dash-table td{
    border:1px solid #c7d2fe;
    padding:10px;
    text-align:center;
    font-weight:600;
}
.dash-table th{ background:#e0e7ff; }

@media(max-width:900px){
    .form-grid{ grid-template-columns:1fr 1fr; }
}

/* ===== EDIT MODAL FORM FIELDS ===== */
.modal-box .form-grid div {
    display: flex;
    flex-direction: column;
}

.modal-box .form-grid label {
    font-weight: 600;
    font-size: 13px;
    margin-bottom: 4px;
    color: #1e293b; /* dark text for labels */
}

.modal-box .form-grid input {
    padding: 8px 10px;
    border-radius: 10px;
    border: 1px solid #c7d2fe; /* same as filter input borders */
    font-size: 14px;
    outline: none;
    transition: 0.2s;
}

.modal-box .form-grid input:focus {
    border-color: #4338ca; /* dark blue focus border like toolbar */
    box-shadow: 0 0 6px rgba(67, 56, 202, 0.4);
}

/* Adjust grid for smaller screens */
@media(max-width:900px){
    .modal-box .form-grid{
        grid-template-columns: 1fr 1fr; /* 2 columns instead of 3 */
        gap: 10px;
    }
}

@media(max-width:600px){
    .modal-box .form-grid{
        grid-template-columns: 1fr; /* single column on very small screens */
    }
}
</style>

<script>
const CUTOFF_DATE = new Date(2026,4,31);

function calculateAgeDetailed(dob, targetId){
    if(!dob) return;
    let birth = new Date(dob);
    let years = CUTOFF_DATE.getFullYear() - birth.getFullYear();
    let months = CUTOFF_DATE.getMonth() - birth.getMonth();
    let days = CUTOFF_DATE.getDate() - birth.getDate();

    if(days < 0){
        months--;
        let pm = new Date(CUTOFF_DATE.getFullYear(), CUTOFF_DATE.getMonth(), 0);
        days += pm.getDate();
    }
    if(months < 0){
        years--;
        months += 12;
    }
    document.getElementById(targetId).innerText =
        years + "Y " + months + "M " + days + "D";
}

/* ================= FILTERS ================= */
function applyFilters(){
    let c = document.getElementById("filterClass").value.toLowerCase();
    let t = document.getElementById("filterType").value.toLowerCase();
    let s = document.getElementById("filterSearch").value.toLowerCase();

    document.querySelectorAll(".data-row").forEach(r=>{
        let td = r.querySelectorAll("td");
        let cls = normalize(td[5].innerText);
        let typ = normalize(td[6].innerText);
        let txt = normalize(r.innerText);

        let show = true;
        if(c && cls !== c) show=false;
        if(t && !typ.includes(t)) show=false;
        if(s && !txt.includes(s)) show=false;

        r.style.display = show ? "" : "none";
    });
}

/* ================= EXPORT ================= */
function downloadExcel(){
    let rows = document.querySelectorAll(".data-row");
    let csv = "ID,Student,Gender,DOB,Age,Class,Type,Father,F Occ,F Org,F Mobile,Mother,M Occ,M Org,M Mobile,Place,Segment\n";

    rows.forEach(r=>{
        if(r.style.display==="none") return;
        let c = r.querySelectorAll("td");
        let a=[];
        for(let i=0;i<c.length-1;i++)
            a.push('"' + c[i].innerText.replace(/"/g,'""') + '"');
        csv += a.join(",") + "\n";
    });

    let blob = new Blob([csv],{type:"text/csv"});
    let a = document.createElement("a");
    a.href = URL.createObjectURL(blob);
    a.download = "Admission_Enquiries.csv";
    a.click();
}

/* ================= DASHBOARD ================= */

function normalize(txt){
    return txt
        .replace(/\u00A0/g," ")
        .replace(/\s+/g," ")
        .trim()
        .toLowerCase();
}

function openDashboard(){
    buildDashboard();
    document.getElementById("dashboardModal").style.display="flex";
}

function closeDashboard(){
    document.getElementById("dashboardModal").style.display="none";
}

function buildDashboard(){

    let mainTable = document.querySelector(".table-wrap table");
    if(!mainTable){
        alert("Main table not found!");
        return;
    }

    let rows = mainTable.querySelectorAll("tr.data-row");

    console.log("Rows found for dashboard:", rows.length);

    let data = {};

    rows.forEach(r => {

        if (r.style.display === "none") return;

        let tds = r.querySelectorAll("td");
        if (tds.length < 7) return;

        // ✅ CLASS
        let cls = tds[5].textContent
            .replace(/\u00A0/g," ")
            .replace(/\s+/g," ")
            .trim();

        // ✅ TYPE (from span badge)
        let typ = tds[6].textContent
            .replace(/\u00A0/g," ")
            .replace(/\s+/g," ")
            .trim()
            .toLowerCase();

        if (!cls || !typ) return;

        if (!data[cls]) {
            data[cls] = { d: 0, r: 0 };
        }

        if (typ.includes("day"))
            data[cls].d++;
        else if (typ.includes("res"))
            data[cls].r++;
    });

    let tb = document.getElementById("dashBody");
    tb.innerHTML = "";

    let grandDay = 0;
    let grandRes = 0;

    let classes = Object.keys(data).sort((a,b)=>{
        const order = ["Nursery","LKG","UKG"];

        let ia = order.indexOf(a);
        let ib = order.indexOf(b);

        if(ia !== -1 || ib !== -1){
            if(ia === -1) return 1;
            if(ib === -1) return -1;
            return ia - ib;
        }

        let na = parseInt(a.replace(/\D/g,"")) || 0;
        let nb = parseInt(b.replace(/\D/g,"")) || 0;
        return na - nb;
    });

    classes.forEach(cls => {

        let d = data[cls].d;
        let r = data[cls].r;
        let t = d + r;

        grandDay += d;
        grandRes += r;

        tb.innerHTML += `
        <tr>
            <td>${cls}</td>
            <td>${d}</td>
            <td>${r}</td>
            <td><b>${t}</b></td>
        </tr>`;
    });

    tb.innerHTML += `
    <tr>
        <th>Total</th>
        <th>${grandDay}</th>
        <th>${grandRes}</th>
        <th>${grandDay + grandRes}</th>
    </tr>`;
}

/* ================= EDIT MODAL ================= */
function openEditModal(id){ 
    document.getElementById("editModal"+id).style.display="flex"; 
}
function closeEditModal(id){ 
    document.getElementById("editModal"+id).style.display="none"; 
}

/* ================= AUTO AGE CALC ================= */
window.onload = function(){
    document.querySelectorAll(".age-cell").forEach(td=>{
        let dob = td.getAttribute("data-dob");
        let id = td.id;
        calculateAgeDetailed(dob, id);
    });
}
</script>

</head>

<body>
<div class="app">

<div class="toolbar">
    <h2>Admission Enquiry Register</h2>
    <div>
       <button class="btn blue" onclick="location.href='dashboard'">Dashboard</button>

        <button class="btn" onclick="downloadExcel()">Export</button>
        <button class="btn red" onclick="location.href='Logout.jsp'">Logout</button>
    </div>
</div>

<div class="filters">
    <input type="text" id="filterSearch" placeholder="Search..." onkeyup="applyFilters()">
    <select id="filterClass" onchange="applyFilters()">
        <option value="">All Classes</option>
        <option>LKG</option><option>UKG</option><option>Class 1</option>
        <option>Class 2</option><option>Class 3</option><option>Class 4</option>
        <option>Class 5</option><option>Class 6</option><option>Class 7</option>
        <option>Class 8</option><option>Class 9</option>
    </select>
    <select id="filterType" onchange="applyFilters()">
        <option value="">All Types</option>
        <option>Dayscholar</option><option>Residential</option>
    </select>
</div>

<div class="table-wrap">
<table>
<tr>
<th>ID</th><th>Student</th><th>Gender</th><th>DOB</th><th>Age</th>
<th>Class</th><th>Type</th><th>Father</th><th>F Occ</th><th>F Org</th>
<th>F Mobile</th><th>Mother</th><th>M Occ</th><th>M Org</th>
<th>M Mobile</th><th>Place</th><th>Segment</th><th>Action</th><th>Apporval</th>
</tr>

<%
CachedRowSet rs = (CachedRowSet)request.getAttribute("list");
java.util.List<Integer> ids = new java.util.ArrayList<>();

while(rs!=null && rs.next()){
    int id = rs.getInt("enquiry_id");
    ids.add(id);

    String dob = rs.getString("date_of_birth");
    String cls = rs.getString("class_of_admission");
    String type = rs.getString("admission_type");
%>

<tr class="data-row">
<td><%="E26"+id%></td>
<td><%=rs.getString("student_name")%></td>
<td><%=rs.getString("gender")%></td>
<td><%=dob%></td>
<td class="age-cell" data-dob="<%=dob%>" id="ageV<%=id%>"></td>

<td><%=cls%></td>
<td>
<% if(type.toLowerCase().contains("day")){ %>
<span class="badge-day">Dayscholar</span>
<% } else { %>
<span class="badge-res">Residential</span>
<% } %>
</td>

<td><%=rs.getString("father_name")%></td>
<td><%=rs.getString("father_occupation")%></td>
<td><%=rs.getString("father_organization")%></td>
<td><%=rs.getString("father_mobile_no")%></td>

<td><%=rs.getString("mother_name")%></td>
<td><%=rs.getString("mother_occupation")%></td>
<td><%=rs.getString("mother_organization")%></td>
<td><%=rs.getString("mother_mobile_no")%></td>

<td><%=rs.getString("place_from")%></td>
<td><%=rs.getString("segment")%></td>

<td>
<button class="btn blue" onclick="openEditModal(<%=id%>)">Edit</button>
<% if("Global".equalsIgnoreCase(role)){ %>
<a href="admission?action=delete&id=<%=id%>" onclick="return confirm('Delete this record?')">
<button type="button" class="btn red">Delete</button>
</a>
<% } %>
</td>
<td>
<% 
if("Global".equalsIgnoreCase(role)){ 
String approved = rs.getString("approved");

if(approved == null || !"Approved".equalsIgnoreCase(approved)) { %>
    <form action="admission" method="get" style="display:inline;">
        <input type="hidden" name="action" value="approve">
        <input type="hidden" name="id" value="<%= id %>">
        <button type="submit"
                style="padding:6px 12px;
                       background:#22c55e;
                       border:none;
                       color:white;
                       border-radius:8px;
                       font-weight:700;
                       cursor:pointer;">
            Approve
        </button>
    </form>
<% } else { %>
    <span style="color:#15803d;font-weight:900;">Approved</span>
<% } %>
<% } %>
</td>
</tr>

<% } %>

</table>
</div>

<!-- ===== EDIT MODALS (OUTSIDE TABLE) ===== -->
<%
rs.beforeFirst();
while(rs!=null && rs.next()){
    int id = rs.getInt("enquiry_id");
    String dob = rs.getString("date_of_birth");
    String cls = rs.getString("class_of_admission");
    String type = rs.getString("admission_type");
%>

<div id="editModal<%=id%>" class="modal-overlay" style="display:none;">
<div class="modal-box">

<div class="modal-header">
<h3>Edit Enquiry #<%=id%></h3>
<button class="close-btn" onclick="closeEditModal(<%=id%>)">Close</button>
</div>

<form method="post" action="admission">
<input type="hidden" name="enquiry_id" value="<%=id%>">

<div class="form-grid">

<div><label>Student Name</label><input name="student_name" value="<%=rs.getString("student_name")%>"></div>
<div><label>Gender</label><input name="gender" value="<%=rs.getString("gender")%>"></div>
<div><label>Date of Birth</label><input type="date" name="date_of_birth" value="<%=dob%>"></div>
<div><label>Class of Admission</label><input name="class_of_admission" value="<%=cls%>"></div>
<div><label>Admission Type</label><input name="admission_type" value="<%=type%>"></div>
<div><label>Segment</label><input name="segment" value="<%=rs.getString("segment")%>"></div>
<div><label>Father Name</label><input name="father_name" value="<%=rs.getString("father_name")%>"></div>
<div><label>Father Occupation</label><input name="father_occupation" value="<%=rs.getString("father_occupation")%>"></div>
<div><label>Father Organization</label><input name="father_organization" value="<%=rs.getString("father_organization")%>"></div>
<div><label>Father Mobile</label><input name="father_mobile_no" value="<%=rs.getString("father_mobile_no")%>"></div>
<div><label>Mother Name</label><input name="mother_name" value="<%=rs.getString("mother_name")%>"></div>
<div><label>Mother Occupation</label><input name="mother_occupation" value="<%=rs.getString("mother_occupation")%>"></div>
<div><label>Mother Organization</label><input name="mother_organization" value="<%=rs.getString("mother_organization")%>"></div>
<div><label>Mother Mobile</label><input name="mother_mobile_no" value="<%=rs.getString("mother_mobile_no")%>"></div>
<div><label>Place From</label><input name="place_from" value="<%=rs.getString("place_from")%>"></div>

</div>

<br>
<button class="btn" type="submit">Save Changes</button>
<button class="btn gray" type="button" onclick="closeEditModal(<%=id%>)">Cancel</button>

</form>
</div>
</div>

<% } %>

</div>

<!-- ===== DASHBOARD ===== -->
<div id="dashboardModal" class="modal-overlay" style="display:none;">
<div class="modal-box">
<div class="modal-header">
<h3> Admission Summary</h3>
<button onclick="closeDashboard()" class="close-btn"></button>
</div>
<table class="dash-table">
<thead>
<tr><th>Class</th><th>Dayscholar</th><th>Residential</th><th>Total</th></tr>
</thead>
<tbody id="dashBody"></tbody>
</table>
</div>
</div>

</body>

</html>
