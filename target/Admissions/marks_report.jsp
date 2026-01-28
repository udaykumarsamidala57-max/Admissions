<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="bean.DBUtil" %>

<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<%
String selectedClass = request.getParameter("class_of_admission");
String selectedDate  = request.getParameter("exam_date");
String download      = request.getParameter("download");

// Excel mode
if("1".equals(download)){
    response.setContentType("application/vnd.ms-excel");
    response.setHeader("Content-Disposition","attachment; filename=Student_Total_Marks_Full_Report.xls");
}
%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<title>Entrance Test Report</title>

<style>
/* ===== Base ===== */
body {
    font-family: "Segoe UI", system-ui, Arial;
    background:#eef2f7;
    margin:0;
}

/* ===== Layout ===== */
.container {
    width: 100%;
    padding: 10px;
}

.card {
    background:#fff;
    border-radius:12px;
    box-shadow:0 4px 16px rgba(0,0,0,0.08);
    padding:12px;
}

/* ===== Heading ===== */
h2 {
    text-align:center;
    margin: 6px 0 14px 0;
    color:#1f2937;
    letter-spacing:0.3px;
}

/* ===== Filters ===== */
.filters {
    background:#f8fafc;
    padding:10px;
    border-radius:10px;
    display:flex;
    gap:10px;
    flex-wrap:wrap;
    align-items:center;
    margin-bottom:12px;
}

.filters label {
    font-weight:600;
    color:#334155;
}

.filters select, .filters input {
    padding:8px 10px;
    border-radius:8px;
    border:1px solid #cbd5e1;
}

.btn {
    padding:8px 18px;
    border:none;
    border-radius:8px;
    cursor:pointer;
    font-weight:600;
}

.search { background:#2563eb; color:white; }
.search:hover { background:#1d4ed8; }

.excel { background:#16a34a; color:white; }
.excel:hover { background:#15803d; }

/* ===== Table Wrapper ===== */
.table-wrap {
    width: 100%;
    overflow-x: auto;
    border-radius:10px;
    border:1px solid #e5e7eb;
}

/* ===== Table ===== */
table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;   /* 🔥 Important for wrapping */
    font-size: 14px;
}

/* Column widths */
th:nth-child(1), td:nth-child(1) { width: 60px; }
th:nth-child(2), td:nth-child(2) { width: 180px; }
th:nth-child(3), td:nth-child(3) { width: 70px; }
th:nth-child(4), td:nth-child(4) { width: 90px; }
th:nth-child(5), td:nth-child(5) { width: 80px; }
th:nth-child(6), td:nth-child(6) { width: 110px; }
th:nth-child(7), td:nth-child(7) { width: 160px; }
th:nth-child(8), td:nth-child(8) { width: 130px; }
th:nth-child(9), td:nth-child(9) { width: 170px; }
th:nth-child(10), td:nth-child(10) { width: 160px; }
th:nth-child(11), td:nth-child(11) { width: 130px; }
th:nth-child(12), td:nth-child(12) { width: 170px; }
th:nth-child(13), td:nth-child(13) { width: 140px; }
th:nth-child(14), td:nth-child(14) { width: 90px; }
th:nth-child(15), td:nth-child(15) { width: 90px; }

/* Header */
th {
    background:#0f172a;
    color:white;
    padding:10px 8px;
    position: sticky;
    top: 0;
    z-index: 5;
    text-align:center;
    font-weight:600;
}

/* Cells */
td {
    padding:10px 8px;
    border-bottom:1px solid #e5e7eb;
    vertical-align: top;
    word-wrap: break-word;
    word-break: break-word;
    white-space: normal;   /* 🔥 Enables wrapping */
    line-height: 1.4;
}

/* Zebra */
tr:nth-child(even){ background:#f8fafc; }
tr:hover{ background:#eef5ff; }

/* Alignment */
.center { text-align:center; }
.left   { text-align:left; }

/* TOTAL column */
.total-marks {
    font-size: 18px;
    font-weight: 800;
    color: #065f46;
    text-align: center;
    background: #ecfdf5;
}

th.total-header {
    background: #065f46;
}

/* No data */
.no-data {
    text-align:center;
    color:#dc2626;
    font-weight:bold;
    padding:20px;
}

/* Mobile */
@media (max-width: 900px) {
    table {
        min-width: 1200px;
    }
}
</style>
</head>

<body>

<div class="no-print">
    <jsp:include page="common_header.jsp" />
</div>

<div class="container">
<div class="card">

<h2>Entrance Test Report</h2>

<form method="get">
<div class="filters">

<label>Class:</label>
<select name="class_of_admission">
    <option value="">-- All Classes --</option>
<%
Connection con1 = DBUtil.getConnection();
Statement st1 = con1.createStatement();
ResultSet rsClass = st1.executeQuery("SELECT DISTINCT class_of_admission FROM admission_enquiry WHERE class_of_admission IS NOT NULL");
while(rsClass.next()){
    String c = rsClass.getString(1);
%>
<option value="<%=c%>" <%= c.equals(selectedClass)?"selected":"" %>><%=c%></option>
<% }
con1.close();
%>
</select>

<label>Exam Date:</label>
<input type="date" name="exam_date" value="<%= selectedDate!=null?selectedDate:"" %>">

<button type="submit" class="btn search">Search</button>
<button type="submit" name="download" value="1" class="btn excel">Excel</button>

</div>
</form>

<div class="table-wrap">

<table>
<thead>
<tr>
<th>S.No</th>
<th>E ID</th>
<th>Student Name</th>
<th>Gender</th>
<th>DOB</th>
<th>Class</th>
<th>Admission Type</th>
<th>Father Name</th>
<th>Father Occ.</th>
<th>Father Org.</th>
<th>Mother Name</th>
<th>Mother Occ.</th>
<th>Mother Org.</th>
<th>Place</th>
<th>Segment</th>
<th class="total-header">TOTAL</th>
</tr>
</thead>
<tbody>

<%
Connection con = DBUtil.getConnection();

String sql =
"SELECT ae.*, IFNULL(SUM(sem.marks_obtained),0) AS total_marks " +
"FROM admission_enquiry ae " +
"LEFT JOIN student_exam_marks sem ON ae.enquiry_id = sem.enquiry_id " +
"WHERE 1=1 ";

List<String> params = new ArrayList<>();

if(selectedClass != null && !selectedClass.trim().isEmpty()){
    sql += " AND ae.class_of_admission = ? ";
    params.add(selectedClass);
}

if(selectedDate != null && !selectedDate.trim().isEmpty()){
    sql += " AND ae.exam_date = ? AND (sem.exam_date = ? OR sem.exam_date IS NULL) ";
    params.add(selectedDate);
    params.add(selectedDate);
}

sql += " GROUP BY ae.enquiry_id ORDER BY ae.class_of_admission, ae.student_name ";

PreparedStatement ps = con.prepareStatement(sql);

for(int i=0;i<params.size();i++){
    ps.setString(i+1, params.get(i));
}

ResultSet rs = ps.executeQuery();

boolean found = false;
int sno = 1;
while(rs.next()){
	
    found = true;
%>

<tr>
 <td class="center"><%=sno++%></td>
<td class="center"><%=rs.getInt("enquiry_id")%></td>
<td class="left"><%=rs.getString("student_name")%></td>
<td class="center"><%=rs.getString("gender")%></td>
<td class="center"><%=rs.getString("date_of_birth")%></td>
<td class="center"><%=rs.getString("class_of_admission")%></td>
<td class="center"><%=rs.getString("admission_type")%></td>
<td class="left"><%=rs.getString("father_name")%></td>
<td class="left"><%=rs.getString("father_occupation")%></td>
<td class="left"><%=rs.getString("father_organization")%></td>
<td class="left"><%=rs.getString("mother_name")%></td>
<td class="left"><%=rs.getString("mother_occupation")%></td>
<td class="left"><%=rs.getString("mother_organization")%></td>
<td class="left"><%=rs.getString("place_from")%></td>
<td class="center"><%=rs.getString("segment")%></td>
<td class="total-marks"><%=rs.getInt("total_marks")%></td>
</tr>

<%
}

if(!found){
%>
<tr>
<td colspan="16" class="no-data">No data found</td>
</tr>
<%
}

con.close();
%>

</tbody>
</table>

</div>
</div>
</div>

</body>
</html>
