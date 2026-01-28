<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="bean.DBUtil" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String role = (String) sess.getAttribute("role");
    String User = (String) sess.getAttribute("username");
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
<title>Student Master Marks Report</title>

<style>
body { font-family: 'Segoe UI', Arial; background:#eef2f7; margin:0; padding:0; }

.container {
    width: 98%;
    margin: 15px auto;
    background: #fff;
    padding: 15px;
    border-radius: 10px;
    box-shadow: 0 0 10px rgba(0,0,0,0.08);
}

h2 {
    margin: 5px 0 15px 0;
    text-align:center;
    color:#2c3e50;
}

.filters {
    background: #f8fafc;
    padding: 12px;
    border-radius: 8px;
    display:flex;
    align-items:center;
    gap:12px;
    flex-wrap: wrap;
    margin-bottom: 12px;
}

.filters label { font-weight:600; }

.filters select, .filters input {
    padding:8px 10px;
    border-radius:6px;
    border:1px solid #ccc;
}

.btn {
    padding:9px 18px;
    border:none;
    border-radius:6px;
    cursor:pointer;
    font-weight:600;
}

.search { background:#3498db; color:white; }
.search:hover { background:#2c80b4; }

.excel { background:#27ae60; color:white; }
.excel:hover { background:#219150; }

.table-wrap {
    overflow-x: auto;
    border-radius:8px;
}

table {
    border-collapse: collapse;
    width: 100%;
    font-size: 13px;
}

th {
    background:#2c3e50;
    color:white;
    padding:8px;
    position: sticky;
    top: 0;
    z-index: 5;
    text-align:center;
    white-space: nowrap;
}

td {
    padding:7px 8px;
    border-bottom:1px solid #ddd;
    white-space: nowrap;
}

tr:nth-child(even){ background:#f7f9fc; }
tr:hover{ background:#eef5ff; }

.center { text-align:center; }
.bold { font-weight:bold; color:#1e8449; }

.no-data {
    text-align:center;
    color:red;
    font-weight:bold;
    padding:20px;
}
</style>
</head>

<body>
<div class="no-print">
    <jsp:include page="common_header.jsp" />
</div>
<div class="container">

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
<tr>
<th>ID</th>
<th>Student Name</th>
<th>Gender</th>
<th>DOB</th>
<th>Class</th>
<th>Admission Type</th>
<th>Father Name</th>
<th>Father Occ.</th>
<th>Father Org.</th>
<th>Father Mobile</th>
<th>Mother Name</th>
<th>Mother Occ.</th>
<th>Mother Org.</th>
<th>Mother Mobile</th>
<th>Place From</th>
<th>Segment</th>


<th>Total Marks</th>

</tr>

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

while(rs.next()){
    found = true;
%>

<tr>
<td class="center"><%=rs.getInt("enquiry_id")%></td>
<td><%=rs.getString("student_name")%></td>
<td class="center"><%=rs.getString("gender")%></td>
<td class="center"><%=rs.getString("date_of_birth")%></td>
<td class="center"><%=rs.getString("class_of_admission")%></td>
<td class="center"><%=rs.getString("admission_type")%></td>
<td><%=rs.getString("father_name")%></td>
<td><%=rs.getString("father_occupation")%></td>
<td><%=rs.getString("father_organization")%></td>
<td class="center"><%=rs.getString("father_mobile_no")%></td>
<td><%=rs.getString("mother_name")%></td>
<td><%=rs.getString("mother_occupation")%></td>
<td><%=rs.getString("mother_organization")%></td>
<td class="center"><%=rs.getString("mother_mobile_no")%></td>
<td><%=rs.getString("place_from")%></td>
<td class="center"><%=rs.getString("segment")%></td>


<td class="center bold"><%=rs.getInt("total_marks")%></td>

</tr>

<%
}

if(!found){
%>
<tr>
<td colspan="20" class="no-data">No data found</td>
</tr>
<%
}

con.close();
%>

</table>

</div>

</div>

</body>
</html>
