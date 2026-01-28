<%@ page import="javax.sql.rowset.CachedRowSet" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page session="true" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

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
/* ===== SUMMARY CARDS ===== */
.summary-bar{
    display:flex;
    gap:12px;
    flex-wrap:wrap;
    width:100%;
}

.summary-card{
    flex:1;
    min-width:160px;
    padding:12px 16px;
    border-radius:14px;
    color:white;
    box-shadow:0 8px 20px rgba(0,0,0,0.2);
    display:flex;
    flex-direction:column;
    align-items:flex-start;
    justify-content:center;
    transition:.2s;
}

.summary-card:hover{
    transform: translateY(-3px) scale(1.02);
}

.summary-title{
    font-size:13px;
    opacity:0.9;
    font-weight:600;
}

.summary-value{
    font-size:26px;
    font-weight:800;
    margin-top:4px;
}

/* Colors */
.sum-total{ background: linear-gradient(135deg,#2563eb,#1d4ed8); }
.sum-visible{ background: linear-gradient(135deg,#0ea5e9,#0284c7); }
.sum-day{ background: linear-gradient(135deg,#22c55e,#16a34a); }
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
function calculateAges() {
    let cells = document.querySelectorAll(".age-cell");
    let asOnDate = new Date(2026, 4, 31);
    asOnDate.setHours(0,0,0,0);

    cells.forEach(cell => {
        let dob = cell.dataset.dob;
        if (!dob) return;

        let birth = new Date(dob);
        birth.setHours(0,0,0,0);

        let y = 0, m = 0;
        let temp = new Date(birth);

        while (true) {
            let next = new Date(temp);
            next.setFullYear(next.getFullYear() + 1);
            if (next <= asOnDate) {
                y++;
                temp = next;
            } else break;
        }

        while (true) {
            let next = new Date(temp);
            next.setMonth(next.getMonth() + 1);
            if (next <= asOnDate) {
                m++;
                temp = next;
            } else break;
        }

        let d = Math.floor((asOnDate - temp) / (1000 * 60 * 60 * 24));
        cell.innerText = y + "Y " + m + "M " + d + "D";
    });
}

function applyFilters(){
    let search = document.getElementById("filterSearch").value.toLowerCase();
    let cls = document.getElementById("filterClass").value.toLowerCase();
    let type = document.getElementById("filterType").value.toLowerCase();

    let rows = document.querySelectorAll(".data-row");

    let total = 0, visible = 0, day = 0, res = 0;

    rows.forEach(row=>{
        total++;

        let text = row.innerText.toLowerCase();
        let classCol = row.children[5].innerText.toLowerCase();
        let typeCol = row.children[6].innerText.toLowerCase();

        let show = true;

        if(search && !text.includes(search)) show = false;
        if(cls && classCol !== cls) show = false;
        if(type && !typeCol.includes(type)) show = false;

        if(show){
            row.style.display="";
            visible++;
            if(typeCol.includes("day")) day++;
            else res++;
        } else {
            row.style.display="none";
        }
    });

    document.getElementById("countTotal").innerText = total;
    document.getElementById("countVisible").innerText = visible;
    document.getElementById("countDay").innerText = day;
    document.getElementById("countRes").innerText = res;
}

function downloadExcel() {
    const table = document.getElementById('enquiryTable');
    let csv = [];

    const rows = table.querySelectorAll('tr');
    rows.forEach(row => {
        let cols = row.querySelectorAll('th, td');
        let rowData = [];
        cols.forEach(cell => {
            let text = cell.innerText.replace(/\n/g, ' ').replace(/"/g, '""').trim();
            rowData.push('"' + text + '"');
        });
        csv.push(rowData.join(','));
    });

    const blob = new Blob([csv.join('\n')], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = 'enquiryTable.csv';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

function openEditModal(id){
    document.getElementById("editModal"+id).style.display="flex";
}

function closeEditModal(id){
    document.getElementById("editModal"+id).style.display="none";
}

function saveEditForm(id){
    let form = document.getElementById("editForm"+id);
    let data = new FormData(form);

    fetch("admission", { method:"POST", body:data })
    .then(r=>r.text())
    .then(res=>{
        alert("Updated successfully!");
        closeEditModal(id);
        location.reload();
    })
    .catch(e=>{
        alert("Update failed!");
        console.log(e);
    });
    return false;
}

function deleteRecord(id){
    if(!confirm("Delete this record?")) return;

    fetch("admission?action=delete&id="+id)
    .then(r=>r.text())
    .then(res=>{
        let row = document.getElementById("row"+id);
        if(row) row.remove();
        applyFilters();
        alert("Deleted successfully!");
    })
    .catch(e=>{
        alert("Delete failed!");
        console.log(e);
    });
}

function approveRecord(id){
    fetch("admission?action=approve&id="+id)
    .then(r=>r.text())
    .then(res=>{
        let cell = document.getElementById("approveCell"+id);
        cell.innerHTML = '<span style="color:#15803d;font-weight:900;">Approved</span>';
        alert("Approved successfully!");
    })
    .catch(e=>{
        alert("Approve failed!");
        console.log(e);
    });
}

window.onload = function(){
    calculateAges();
    applyFilters();
}
</script>




</head>

<body>
<div class="app">

<jsp:include page="common_header.jsp" />

<div class="filters">
    <b>Total:</b> <span id="countTotal">0</span>
    <b>Visible:</b> <span id="countVisible">0</span>
    <b>Dayscholar:</b> <span id="countDay">0</span>
    <b>Residential:</b> <span id="countRes">0</span>
    <input type="text" id="filterSearch" placeholder="Search..." onkeyup="applyFilters()">
    <select id="filterClass" onchange="applyFilters()">
        <option value="">All Classes</option>
        <option>Nursery</option><option>LKG</option><option>UKG</option>
        <option>Class 1</option><option>Class 2</option><option>Class 3</option>
        <option>Class 4</option><option>Class 5</option><option>Class 6</option>
        <option>Class 7</option><option>Class 8</option><option>Class 9</option>
    </select>

    <select id="filterType" onchange="applyFilters()">
        <option value="">All Types</option>
        <option>Dayscholar</option><option>Residential</option>
    </select>

    <button class="btn blue" onclick="downloadExcel()"> Export Excel</button>
</div>

<div class="table-wrap">
<table id="enquiryTable">

<tr>
<th>ID</th><th>Student</th><th>Gender</th><th>DOB</th><th>Age</th>
<th>Class</th><th>Type</th><th>Father</th><th>F Occ</th><th>F Org</th>
<th>F Mobile</th><th>Mother</th><th>M Occ</th><th>M Org</th>
<th>M Mobile</th><th>Place</th><th>Segment</th><th>Exam Date</th><th>App No</th><th>Action</th><th>Approval</th>
</tr>

<%
CachedRowSet rs = (CachedRowSet)request.getAttribute("list");
while(rs!=null && rs.next()){
    int id = rs.getInt("enquiry_id");
%>

<tr class="data-row" id="row<%=id%>">
<td><%="E26-"+id%></td>
<td><%=rs.getString("student_name")%></td>
<td><%=rs.getString("gender")%></td>
<td><%=rs.getString("date_of_birth")%></td>
<td class="age-cell" data-dob="<%=rs.getString("date_of_birth")%>" id="ageV<%=id%>"></td>
<td><%=rs.getString("class_of_admission")%></td>
<td>
<% if(rs.getString("admission_type").toLowerCase().contains("day")){ %>
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
<td><%=rs.getString("exam_date")%></td>
<td><%=rs.getString("application_no")%></td>

<td>
<button class="btn blue" onclick="openEditModal(<%=id%>)">Edit</button>
<% if("Global".equalsIgnoreCase(role)){ %>
<button class="btn red" onclick="deleteRecord(<%=id%>)">Delete</button>
<% } %>
</td>

<td id="approveCell<%=id%>">
<%
if("Global".equalsIgnoreCase(role)){
String approved = rs.getString("approved");
if(approved==null || !"Approved".equalsIgnoreCase(approved)){
%>
<button onclick="approveRecord(<%=id%>)"
style="padding:6px 12px;background:#22c55e;border:none;color:white;border-radius:8px;font-weight:700;">
Approve
</button>
<% } else { %>
<span style="color:#15803d;font-weight:900;">Approved</span>
<% } } %>
</td>
</tr>
<% } %>
</table>
</div>


<%
rs.beforeFirst();
while(rs!=null && rs.next()){
int id = rs.getInt("enquiry_id");
%>

<div id="editModal<%=id%>" class="modal-overlay" style="display:none;">
<div class="modal-box">

<div class="modal-header">
    <h3>Edit Enquiry #<%=id%></h3>
    <button class="close-btn" onclick="closeEditModal(<%=id%>)">Close</button>
</div>

<form id="editForm<%=id%>" method="post" onsubmit="return saveEditForm(<%=id%>)">

<input type="hidden" name="action" value="update">
<input type="hidden" name="enquiry_id" value="<%=id%>">

<div class="form-grid">

    <div><label>Student Name</label>
    <input type="text" name="student_name" value="<%=rs.getString("student_name")%>"></div>

    <div><label>Gender</label>
    <input type="text" name="gender" value="<%=rs.getString("gender")%>"></div>

    <div><label>Date of Birth</label>
    <input type="date" name="date_of_birth" value="<%=rs.getString("date_of_birth")%>"></div>

    <div><label>Class</label>
    <input type="text" name="class_of_admission" value="<%=rs.getString("class_of_admission")%>"></div>

    <div><label>Admission Type</label>
    <input type="text" name="admission_type" value="<%=rs.getString("admission_type")%>"></div>

    <div><label>Father Name</label>
    <input type="text" name="father_name" value="<%=rs.getString("father_name")%>"></div>

    <div><label>Father Occupation</label>
    <input type="text" name="father_occupation" value="<%=rs.getString("father_occupation")%>"></div>

    <div><label>Father Organization</label>
    <input type="text" name="father_organization" value="<%=rs.getString("father_organization")%>"></div>

    <div><label>Father Mobile</label>
    <input type="text" name="father_mobile_no" value="<%=rs.getString("father_mobile_no")%>"></div>

    <div><label>Mother Name</label>
    <input type="text" name="mother_name" value="<%=rs.getString("mother_name")%>"></div>

    <div><label>Mother Occupation</label>
    <input type="text" name="mother_occupation" value="<%=rs.getString("mother_occupation")%>"></div>

    <div><label>Mother Organization</label>
    <input type="text" name="mother_organization" value="<%=rs.getString("mother_organization")%>"></div>

    <div><label>Mother Mobile</label>
    <input type="text" name="mother_mobile_no" value="<%=rs.getString("mother_mobile_no")%>"></div>

    <div><label>Place From</label>
    <input type="text" name="place_from" value="<%=rs.getString("place_from")%>"></div>

    <div><label>Segment</label>
    <input type="text" name="segment" value="<%=rs.getString("segment")%>"></div>

    <div><label>Exam Date</label>
<input type="date" name="exam_date"
       value="<%= rs.getString("exam_date") == null ? "" : rs.getString("exam_date") %>"></div>

<div><label>General Remarks</label>
<input type="text" name="general_remarks"
       value="<%= rs.getString("general_remarks") == null ? "" : rs.getString("general_remarks") %>"></div>

<div><label>Entrance Remarks</label>
<input type="text" name="entrance_remarks"
       value="<%= rs.getString("entrance_remarks") == null ? "" : rs.getString("entrance_remarks") %>"></div>

<div><label>Application No</label>
<input type="text" name="application_no"
       value="<%= rs.getString("application_no") == null ? "" : rs.getString("application_no") %>"></div>

</div>

<br>

<button class="btn" type="submit">Save Changes</button>
<button class="btn gray" type="button" onclick="closeEditModal(<%=id%>)">Cancel</button>

</form>
</div>
</div>

<% } %>
</div>
</body>
</html>