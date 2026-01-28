<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="bean.DBUtil" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
<title>Enter Exam Marks</title>

<!-- Google Font -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">

<style>
* { box-sizing: border-box; font-family: 'Poppins', sans-serif; }

body {
    margin: 0;
    background: linear-gradient(to right, #eef2f7, #f8fafc);
}

/* ================= CARD CONTAINER ================= */
.container {
    max-width: 1300px;
    margin: 25px auto;
    background: #fff;
    padding: 25px 30px;
    border-radius: 14px;
    box-shadow: 0 8px 30px rgba(0,0,0,0.08);
}

.page-title {
    font-size: 22px;
    font-weight: 600;
    color: #2c3e50;
    margin-bottom: 20px;
}

/* ================= FILTER BAR ================= */
.filter-bar {
    display: flex;
    gap: 20px;
    align-items: center;
    flex-wrap: wrap;
    margin-bottom: 20px;
}

label {
    font-weight: 500;
    color: #34495e;
}

select, input[type="date"] {
    padding: 8px 12px;
    border-radius: 6px;
    border: 1px solid #ccd6e0;
    background: #f8fafc;
    font-size: 14px;
}

select:focus, input:focus {
    outline: none;
    border-color: #3498db;
}

/* ================= TABLE AREA ================= */
.table-wrapper {
    overflow-x: auto;
    border-radius: 10px;
}

.marksTable {
    width: 100%;
    border-collapse: collapse;
    min-width: 900px;
}

.marksTable th {
    background: #2c3e50;
    color: white;
    padding: 10px;
    font-weight: 500;
    position: sticky;
    top: 0;
    z-index: 2;
}

.marksTable td {
    padding: 8px;
    border-bottom: 1px solid #e5e9f2;
    text-align: center;
    background: #fff;
}

.marksTable tr:hover td {
    background: #f9fbff;
}

/* ================= INPUT STYLES ================= */
.markInput {
    width: 60px;
    padding: 5px;
    border-radius: 5px;
    border: 1px solid #ccd6e0;
    text-align: center;
}

.markInput.changed,
.remarksBox.changed {
    background: #fff3cd !important;
    border-color: #f39c12;
}

.totalBox, .percentBox {
    width: 85px;
    font-weight: 600;
    background: #ecf0f1;
    border: none;
    text-align: center;
}

.remarksBox {
    width: 200px;
    border-radius: 6px;
    border: 1px solid #ccd6e0;
    padding: 5px;
}

/* ================= BUTTON ================= */
.save-btn {
    margin-top: 18px;
    padding: 10px 28px;
    border-radius: 8px;
    border: none;
    background: linear-gradient(45deg, #3498db, #2c80b4);
    color: white;
    font-size: 15px;
    font-weight: 500;
    cursor: pointer;
    transition: 0.2s;
}

.save-btn:hover {
    transform: scale(1.05);
    box-shadow: 0 5px 15px rgba(52,152,219,0.3);
}

/* Responsive */
@media(max-width: 768px){
    .filter-bar { flex-direction: column; align-items: flex-start; }
}
</style>

<script>
/* ================= FIX TABLE STRUCTURE ================= */
function fixTable() {
    var table = document.querySelector("#dataArea table");
    if (!table) return;

    var thead = table.querySelector("thead");
    if (!thead) {
        thead = document.createElement("thead");
        var firstRow = table.rows[0];
        thead.appendChild(firstRow.cloneNode(true));
        table.deleteRow(0);
        table.insertBefore(thead, table.firstChild);
    }

    var tbody = table.querySelector("tbody");
    if (!tbody) {
        tbody = document.createElement("tbody");
        while (table.rows.length > 1) {
            tbody.appendChild(table.rows[1]);
        }
        table.appendChild(tbody);
    }

    var headerRow = thead.rows[0];

    if (headerRow.cells[headerRow.cells.length - 1].innerText.trim() !== "Percentage") {
        var thp = document.createElement("th");
        thp.innerText = "Percentage";
        headerRow.appendChild(thp);
    }

    var rows = tbody.rows;
    for (var i = 0; i < rows.length; i++) {
        var row = rows[i];

        var lastCell = row.cells[row.cells.length - 1];
        if (!lastCell.querySelector || !lastCell.querySelector(".percentBox")) {
            var td2 = document.createElement("td");
            var inp = document.createElement("input");
            inp.type = "text";
            inp.className = "percentBox";
            inp.readOnly = true;
            td2.appendChild(inp);
            row.appendChild(td2);
        }
    }
}

/* ================= LOAD TABLE ================= */
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

        fixTable();
        hookChangeTracking();
        calculateAllRows();
    };
    xhr.send();
}

/* ================= TRACK CHANGES ================= */
function hookChangeTracking() {

    // Track MARKS
    var inputs = document.getElementsByClassName("markInput");
    for (var i = 0; i < inputs.length; i++) {
        inputs[i].setAttribute("data-old", inputs[i].value);
        inputs[i].addEventListener("input", function () {
            if (this.value !== this.getAttribute("data-old")) {
                this.classList.add("changed");
            } else {
                this.classList.remove("changed");
            }
            calculateRow(this);
        });
    }

    // Track REMARKS
    var remarks = document.getElementsByClassName("remarksBox");
    for (var i = 0; i < remarks.length; i++) {
        remarks[i].setAttribute("data-old", remarks[i].value);
        remarks[i].addEventListener("input", function () {
            if (this.value !== this.getAttribute("data-old")) {
                this.classList.add("changed");
            } else {
                this.classList.remove("changed");
            }
        });
    }
}

/* ================= PREVENT EMPTY SAVE ================= */
function beforeSubmit() {
    var changed = document.getElementsByClassName("changed");
    if (changed.length === 0) {
        alert("⚠️ No changes to save!");
        return false;
    }
    return true;
}

/* ================= AUTO TOTAL + PERCENT ================= */
function calculateRow(anyInputInRow) {
    var row = anyInputInRow.closest("tr");
    var table = document.querySelector("#dataArea table");
    var headerRow = table.tHead.rows[0];

    var inputs = row.getElementsByClassName("markInput");

    var totalObtained = 0;
    var totalMax = 0;

    var subjectHeaderIndexes = [];
    for (var h = 0; h < headerRow.cells.length; h++) {
        if (headerRow.cells[h].innerText.includes("(")) {
            subjectHeaderIndexes.push(h);
        }
    }

    if (subjectHeaderIndexes.length === 0) return;

    for (var i = 0; i < inputs.length; i++) {
        var obtained = parseFloat(inputs[i].value);
        if (!isNaN(obtained)) {
            totalObtained += obtained;
        }

        var th = headerRow.cells[subjectHeaderIndexes[i]];
        var maxMatch = th.innerText.match(/\((\d+)\)/);

        if (maxMatch) {
            totalMax += parseFloat(maxMatch[1]);
        }
    }

    var totalBox = row.querySelector(".totalBox");
    if (totalBox) totalBox.value = totalObtained;

    var percentBox = row.querySelector(".percentBox");
    if (percentBox && totalMax > 0) {
        var percent = (totalObtained / totalMax) * 100;
        percentBox.value = percent.toFixed(2);
    }
}

/* ================= RECALCULATE ALL ================= */
function calculateAllRows() {
    var rows = document.querySelectorAll("#dataArea table tbody tr");
    for (var i = 0; i < rows.length; i++) {
        var input = rows[i].querySelector(".markInput");
        if(input) calculateRow(input);
    }
}
</script>

</head>
<body>

<jsp:include page="common_header.jsp" />

<div class="container">

<div class="page-title">📘 Exam Marks Entry</div>

<form method="post" action="SaveMarksServlet">



<div class="filter-bar">
    <div>
        <label>Exam Date</label><br>
        <input type="date" id="exam_date" onchange="loadStudentsAndExams()" value="<%= java.time.LocalDate.now() %>">
        <input type="hidden" name="exam_date_hidden" id="exam_date_hidden">
    </div>

    <div>
        <label>Class</label><br>
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
</div>

<div class="table-wrapper">
    <div id="dataArea"></div>
</div>

<button type="submit" class="save-btn">💾 Save Marks</button>

</form>
</div>

</body>
</html>
