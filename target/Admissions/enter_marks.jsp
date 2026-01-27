<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="bean.DBUtil" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Enter Exam Marks</title>

<script>
function loadStudentsAndExams() {
    var classId = document.getElementById("class_id").value;
    var examDate = document.getElementById("exam_date").value;

    if(classId == "" || examDate == "") {
        document.getElementById("dataArea").innerHTML = "";
        return;
    }

    document.getElementById("exam_date_hidden").value = examDate;

    var xhr = new XMLHttpRequest();
    xhr.open("GET", "LoadStudentsAndExamsServlet?class_id=" + classId + "&exam_date=" + examDate, true);
    xhr.onload = function() {
        document.getElementById("dataArea").innerHTML = this.responseText;
    };
    xhr.send();
}

// Auto calculate row total
function calculateRowTotal(input) {
    var row = input.parentNode.parentNode;
    var inputs = row.getElementsByClassName("markInput");
    var total = 0;

    for(var i=0;i<inputs.length;i++) {
        var val = parseInt(inputs[i].value);
        if(!isNaN(val)) total += val;
    }

    row.querySelector(".totalBox").value = total;
}
</script>

<style>
body { font-family: Arial; background: #f4f6f8; }
h2 { background: #2c3e50; color: white; padding: 10px; }
select, input[type=date] { padding: 6px; font-size: 15px; }

.marksTable { border-collapse: collapse; width: 100%; background: white; }
.marksTable th { background: #34495e; color: white; padding: 8px; }
.marksTable td { padding: 6px; text-align: center; }
.marksTable tr:nth-child(even) { background: #f2f2f2; }

.markInput { width: 60px; padding: 4px; text-align: center; }
.totalBox { width: 70px; font-weight: bold; background: #ecf0f1; border: 1px solid #aaa; text-align: center; }

.saveBtn {
    padding: 10px 20px;
    font-size: 16px;
    background: #27ae60;
    color: white;
    border: none;
    cursor: pointer;
}
.saveBtn:hover { background: #219150; }
</style>

</head>
<body>

<h2>Enter / Edit Student Exam Marks</h2>

<form method="post" action="SaveMarksServlet">

Exam Date:
<input type="date" id="exam_date" onchange="loadStudentsAndExams()" value="<%= java.time.LocalDate.now() %>">

<input type="hidden" name="exam_date_hidden" id="exam_date_hidden">

&nbsp;&nbsp; Select Class:
<select name="class_id" id="class_id" onchange="loadStudentsAndExams()">
    <option value="">--Select Class--</option>

<%
Connection con = DBUtil.getConnection();
Statement st = con.createStatement();
ResultSet rs = st.executeQuery("SELECT class_id, class_name FROM classes");
while(rs.next()){
%>
<option value="<%=rs.getInt("class_id")%>"><%=rs.getString("class_name")%></option>
<% } con.close(); %>
</select>

<br><br>

<div id="dataArea"></div>

</form>

</body>
</html>
