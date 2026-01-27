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

<script>
/* ================= FIX TABLE STRUCTURE (NO THEAD/TBODY SAFE) ================= */
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

    if (headerRow.cells[0].innerText.trim() !== "S.No") {
        var th = document.createElement("th");
        th.innerText = "S.No";
        headerRow.insertBefore(th, headerRow.cells[0]);
    }

    if (headerRow.cells[headerRow.cells.length - 1].innerText.trim() !== "Percentage") {
        var thp = document.createElement("th");
        thp.innerText = "Percentage";
        headerRow.appendChild(thp);
    }

    var rows = tbody.rows;
    for (var i = 0; i < rows.length; i++) {
        var row = rows[i];

        if (row.cells[0].className !== "sno") {
            var td = document.createElement("td");
            td.className = "sno";
            row.insertBefore(td, row.cells[0]);
        }

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

/* ================= SERIAL NUMBER ================= */
function addSerialNumbers() {
    var rows = document.querySelectorAll("#dataArea table tbody tr");
    for (var i = 0; i < rows.length; i++) {
        rows[i].querySelector(".sno").innerText = i + 1;
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
        addSerialNumbers();
        calculateAllRows();
    };
    xhr.send();
}

/* ================= TRACK CHANGES ================= */
function hookChangeTracking() {
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

    // 🔥 Find all subject header indexes (those containing "(number)")
    var subjectHeaderIndexes = [];
    for (var h = 0; h < headerRow.cells.length; h++) {
        if (headerRow.cells[h].innerText.includes("(")) {
            subjectHeaderIndexes.push(h);
        }
    }

    // 🛡️ Safety check
    if (subjectHeaderIndexes.length === 0) return;

    // 🔁 Loop subject inputs only
    for (var i = 0; i < inputs.length; i++) {
        var obtained = parseFloat(inputs[i].value);
        if (!isNaN(obtained)) {
            totalObtained += obtained;
        }

        // Get correct header for this subject
        var th = headerRow.cells[subjectHeaderIndexes[i]];
        var maxMatch = th.innerText.match(/\((\d+)\)/);

        if (maxMatch) {
            totalMax += parseFloat(maxMatch[1]);
        }
    }

    // ✅ Set total
    var totalBox = row.querySelector(".totalBox");
    if (totalBox) totalBox.value = totalObtained;

    // ✅ Set percentage
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

<style>
* { box-sizing: border-box; font-family: "Segoe UI", Arial, sans-serif; }
body { margin: 0; padding: 0; background: #eef2f7; }

.container {
    max-width: 1200px;
    margin: 20px auto;
    background: #ffffff;
    padding: 20px 25px;
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.08);
}

/* ======= TOP CONTROLS DESIGN ======= */
.topBar {
    display: flex;
    gap: 20px;
    align-items: center;
    margin-bottom: 20px;
    flex-wrap: wrap;
}

.topBar label {
    font-weight: 600;
    color: #2c3e50;
}

.topBar select,
.topBar input[type="date"] {
    padding: 8px 12px;
    border-radius: 8px;
    border: 1px solid #cfd6e0;
    font-size: 14px;
    outline: none;
}

.topBar select:focus,
.topBar input[type="date"]:focus {
    border-color: #3498db;
    box-shadow: 0 0 0 2px rgba(52,152,219,0.15);
}

/* ======= TABLE ======= */
.marksTable { border-collapse: collapse; width: 100%; }

.marksTable th {
    background: #2c3e50;
    color: #ffffff;
    padding: 10px;
}

.marksTable td {
    padding: 8px;
    border-bottom: 1px solid #e1e6ef;
    text-align: center;
}

.markInput { width: 60px; padding: 5px; text-align: center; }
.markInput.changed { background: #fff3cd; }

.totalBox, .percentBox {
    width: 80px;
    font-weight: bold;
    background: #ecf0f1;
    text-align: center;
}

/* ======= BUTTONS (FROM SERVLET IF ANY) ======= */
button, input[type="submit"] {
    padding: 10px 18px;
    border-radius: 8px;
    border: none;
    background: #3498db;
    color: #fff;
    font-weight: 600;
    cursor: pointer;
}

button:hover, input[type="submit"]:hover {
    background: #2c80b4;
}
</style>

</head>
<body>

<jsp:include page="common_header.jsp" />

<div class="container">

<form method="post" action="SaveMarksServlet" onsubmit="return beforeSubmit();">

    <div class="topBar">
        <div>
            <label>Date:</label><br>
            <input type="date" id="exam_date" onchange="loadStudentsAndExams()" value="<%= java.time.LocalDate.now() %>">
            <input type="hidden" name="exam_date_hidden" id="exam_date_hidden">
        </div>

        <div>
            <label>Class:</label><br>
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

    <div id="dataArea"></div>

</form>

</div>

</body>
</html>
