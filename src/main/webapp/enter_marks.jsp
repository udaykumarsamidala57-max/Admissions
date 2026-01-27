<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
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
<!DOCTYPE html>
<html>
<head>

<title>Enter Exam Marks</title>

<script>
function loadStudentsAndExams() {
    var classId = document.getElementById("class_id").value;
    var examDate = document.getElementById("exam_date").value;

    if(classId === "" || examDate === "") {
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
    var row = input.closest("tr");
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
* {
    box-sizing: border-box;
    font-family: "Segoe UI", Arial, sans-serif;
}

body {
    margin: 0;
    padding: 0;
    background: #eef2f7;
}

.container {
    max-width: 1200px;
    margin: 20px auto;
    background: #ffffff;
    padding: 20px 25px;
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.08);
}

.page-title {
    font-size: 22px;
    font-weight: 600;
    color: #2c3e50;
    margin-bottom: 15px;
    border-left: 6px solid #3498db;
    padding-left: 12px;
}

.filters {
    display: flex;
    flex-wrap: wrap;
    gap: 15px;
    align-items: center;
    margin-bottom: 20px;
    padding: 15px;
    background: #f7f9fc;
    border-radius: 8px;
    border: 1px solid #e1e6ef;
}

.filters label {
    font-weight: 600;
    color: #333;
}

.filters input, .filters select {
    padding: 8px 10px;
    font-size: 15px;
    border-radius: 6px;
    border: 1px solid #ccc;
    outline: none;
}

.filters input:focus, .filters select:focus {
    border-color: #3498db;
}

/* Table */
.marksTable {
    border-collapse: collapse;
    width: 100%;
    margin-top: 10px;
}

.marksTable th {
    background: #2c3e50;
    color: #ffffff;
    padding: 10px;
    font-size: 14px;
    position: sticky;
    top: 0;
}

.marksTable td {
    padding: 8px;
    border-bottom: 1px solid #e1e6ef;
    text-align: center;
    font-size: 14px;
}

.marksTable tr:nth-child(even) {
    background: #f8fafc;
}

.marksTable tr:hover {
    background: #eef5ff;
}

.markInput {
    width: 70px;
    padding: 6px;
    text-align: center;
    border-radius: 5px;
    border: 1px solid #bbb;
    font-size: 14px;
}

.markInput:focus {
    border-color: #3498db;
    outline: none;
    background: #f0f7ff;
}

.totalBox {
    width: 80px;
    font-weight: bold;
    background: #ecf0f1;
    border: 1px solid #bbb;
    text-align: center;
    padding: 6px;
    border-radius: 5px;
}

.saveBtn {
    margin-top: 20px;
    padding: 12px 30px;
    font-size: 16px;
    border-radius: 8px;
    background: linear-gradient(135deg, #27ae60, #219150);
    color: white;
    border: none;
    cursor: pointer;
    box-shadow: 0 3px 10px rgba(0,0,0,0.15);
}

.saveBtn:hover {
    transform: translateY(-1px);
    box-shadow: 0 5px 14px rgba(0,0,0,0.2);
}

.successMsg {
    padding: 12px;
    background: #d4edda;
    border: 1px solid #c3e6cb;
    color: #155724;
    border-radius: 6px;
    margin-bottom: 15px;
}

.errorMsg {
    padding: 12px;
    background: #f8d7da;
    border: 1px solid #f5c6cb;
    color: #721c24;
    border-radius: 6px;
    margin-bottom: 15px;
}
</style>

</head>
<body>
<div class="no-print">
    <jsp:include page="common_header.jsp" />
</div>
<div class="container">

    <div class="page-title">📝 Enter / Edit Student Exam Marks</div>

    <% if("success".equals(request.getParameter("msg"))) { %>
        <div class="successMsg">✅ Marks saved successfully!</div>
    <% } else if("error".equals(request.getParameter("msg"))) { %>
        <div class="errorMsg">❌ Error while saving marks!</div>
    <% } %>

    <form method="post" action="SaveMarksServlet">

        <div class="filters">
            <label>📅 Exam Date:</label>
            <input type="date" id="exam_date" onchange="loadStudentsAndExams()" value="<%= java.time.LocalDate.now() %>">

            <input type="hidden" name="exam_date_hidden" id="exam_date_hidden">

            <label>🏫 Select Class:</label>
            <select name="class_id" id="class_id" onchange="loadStudentsAndExams()">
                <option value="">-- Select Class --</option>

                <%
                Connection con = DBUtil.getConnection();
                Statement st = con.createStatement();
                ResultSet rs = st.executeQuery("SELECT class_id, class_name FROM classes");
                while(rs.next()){
                %>
                <option value="<%=rs.getInt("class_id")%>"><%=rs.getString("class_name")%></option>
                <% } con.close(); %>
            </select>
        </div>

        <div id="dataArea"></div>

    </form>

</div>

</body>
</html>
