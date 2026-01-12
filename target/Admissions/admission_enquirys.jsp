<%@ page import="javax.sql.rowset.CachedRowSet" %>
<!DOCTYPE html>
<html>
<head>
<title>Admission Enquiry Register</title>

<link rel="stylesheet" href="css/enquiry-register.css">

<script>
function editRow(id){
    document.getElementById("rowView"+id).style.display="none";
    document.getElementById("rowEdit"+id).style.display="";
}
function cancelEdit(id){
    document.getElementById("rowEdit"+id).style.display="none";
    document.getElementById("rowView"+id).style.display="";
}

// ===== AGE CALC =====
function calculateAgeDetailed(dob, targetId) {
    if(!dob) return;
    var birth = new Date(dob);
    var today = new Date();

    var years = today.getFullYear() - birth.getFullYear();
    var months = today.getMonth() - birth.getMonth();
    var days = today.getDate() - birth.getDate();

    if (days < 0) {
        months--;
        var prevMonth = new Date(today.getFullYear(), today.getMonth(), 0);
        days += prevMonth.getDate();
    }
    if (months < 0) {
        years--;
        months += 12;
    }
    document.getElementById(targetId).innerText = years+"Year "+months+"Monts "+days+"Days";
}

// ===== FILTER =====
function applyFilters() {
    var classFilter = document.getElementById("filterClass").value.toLowerCase();
    var typeFilter = document.getElementById("filterType").value.toLowerCase();
    var search = document.getElementById("filterSearch").value.toLowerCase();

    document.querySelectorAll(".data-row").forEach(row=>{
        var cls = row.dataset.class.toLowerCase();
        var type = row.dataset.type.toLowerCase();
        var text = row.innerText.toLowerCase();

        var show = true;
        if(classFilter && cls!==classFilter) show=false;
        if(typeFilter && type!==typeFilter) show=false;
        if(search && !text.includes(search)) show=false;

        row.style.display = show ? "" : "none";
    });
}

// ===== EXCEL =====
function downloadExcel() {
    var rows = document.querySelectorAll(".data-row");
    var csv = "ID,Student,Gender,DOB,Age,Class,Type,Father,F Mobile,Mother,M Mobile,Place,Segment\n";

    rows.forEach(row=>{
        if(row.style.display==="none") return;
        var cols = row.querySelectorAll("td");
        var r=[];
        for(let i=0;i<cols.length-1;i++) r.push('"'+cols[i].innerText.replace(/"/g,'""')+'"');
        csv+=r.join(",")+"\n";
    });

    var blob=new Blob([csv],{type:"text/csv"});
    var a=document.createElement("a");
    a.href=URL.createObjectURL(blob);
    a.download="Admission_Enquiries.csv";
    a.click();
}
</script>

</head>
<body>

<div class="box">

<div class="toolbar">
    <h2>Admission Enquiry Register</h2>
    <button class="btn-primary" onclick="downloadExcel()">Export Excel</button>
</div>

<div class="filters">
    <input type="text" id="filterSearch" placeholder="Search..." onkeyup="applyFilters()">
    <select id="filterClass" onchange="applyFilters()">
        <option value="">All Classes</option>
        <option>LKG</option><option>UKG</option><option>1</option><option>2</option><option>3</option>
    </select>
    <select id="filterType" onchange="applyFilters()">
        <option value="">All Types</option>
        <option>Dayscholar</option><option>Hosteller</option>
    </select>
</div>

<div class="table-wrap">
<table>
<tr>
<th>ID</th><th>Student</th><th>Gender</th><th>DOB</th><th>Age</th><th>Class</th><th>Type</th>
<th>Father</th><th>F Mobile</th><th>Mother</th><th>M Mobile</th><th>Place</th><th>Segment</th><th>Action</th>
</tr>

<%
CachedRowSet rs=(CachedRowSet)request.getAttribute("list");
while(rs!=null && rs.next()){
int id=rs.getInt("enquiry_id");
String dob=rs.getString("date_of_birth");
String cls=rs.getString("class_of_admission");
String type=rs.getString("admission_type");
%>

<!-- VIEW ROW -->
<tr class="data-row" id="rowView<%=id%>" data-class="<%=cls%>" data-type="<%=type%>">
<td><%=id%></td>
<td><%=rs.getString("student_name")%></td>
<td><%=rs.getString("gender")%></td>
<td><%=dob%></td>
<td id="ageV<%=id%>"></td>
<script>calculateAgeDetailed("<%=dob%>","ageV<%=id%>");</script>
<td><span class="badge"><%=cls%></span></td>
<td><span class="badge"><%=type%></span></td>
<td><%=rs.getString("father_name")%></td>
<td><%=rs.getString("father_mobile_no")%></td>
<td><%=rs.getString("mother_name")%></td>
<td><%=rs.getString("mother_mobile_no")%></td>
<td><%=rs.getString("place_from")%></td>
<td><%=rs.getString("segment")%></td>
<td class="action-btns">
    <button class="btn-warning" onclick="editRow(<%=id%>)">Edit</button>
    <a href="admission?action=delete&id=<%=id%>" onclick="return confirm('Delete this record?')">
        <button class="btn-danger" type="button">Delete</button>
    </a>
</td>
</tr>

<!-- EDIT ROW -->
<tr id="rowEdit<%=id%>" class="edit-row" style="display:none;">
<form method="post" action="admission">
<input type="hidden" name="enquiry_id" value="<%=id%>">
<td><%=id%></td>
<td><input name="student_name" value="<%=rs.getString("student_name")%>"></td>
<td><input name="gender" value="<%=rs.getString("gender")%>"></td>
<td><input type="date" name="date_of_birth" value="<%=dob%>" onchange="calculateAgeDetailed(this.value,'ageE<%=id%>')"></td>
<td id="ageE<%=id%>"></td>
<script>calculateAgeDetailed("<%=dob%>","ageE<%=id%>");</script>
<td><input name="class_of_admission" value="<%=cls%>"></td>
<td><input name="admission_type" value="<%=type%>"></td>
<td><input name="father_name" value="<%=rs.getString("father_name")%>"></td>
<td><input name="father_mobile_no" value="<%=rs.getString("father_mobile_no")%>"></td>
<td><input name="mother_name" value="<%=rs.getString("mother_name")%>"></td>
<td><input name="mother_mobile_no" value="<%=rs.getString("mother_mobile_no")%>"></td>
<td><input name="place_from" value="<%=rs.getString("place_from")%>"></td>
<td><input name="segment" value="<%=rs.getString("segment")%>"></td>
<td class="action-btns">
    <button class="btn-success" type="submit">Save</button>
    <button class="btn-warning" type="button" onclick="cancelEdit(<%=id%>)">Cancel</button>
</td>
</form>
</tr>

<% } %>

</table>
</div>

</div>
</body>
</html>
