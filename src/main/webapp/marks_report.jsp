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

<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>

<style>
* { box-sizing: border-box; font-family: 'Poppins', sans-serif; }
body { margin: 0; background: linear-gradient(to right, #eef2f7, #f8fafc); }

.container {
    max-width: 2400px;
    margin: 25px auto;
    background: #fff;
    padding: 25px 30px;
    border-radius: 14px;
    box-shadow: 0 8px 30px rgba(0,0,0,0.08);
}

.page-title { font-size: 22px; font-weight: 600; color: #2c3e50; margin-bottom: 20px; }

.filter-bar { display: flex; gap: 20px; align-items: center; flex-wrap: wrap; margin-bottom: 20px; }

label { font-weight: 500; color: #34495e; }

select, input[type="date"] {
    padding: 8px 12px; border-radius: 6px; border: 1px solid #ccd6e0;
    background: #f8fafc; font-size: 14px;
}

.table-wrapper { overflow-x: auto; border-radius: 10px; margin-top: 10px; }

.marksTable { width: 100%; border-collapse: collapse; min-width: 900px; }
.marksTable th { background: #0f2a4d; color: white; padding: 12px; font-weight: 500; }
.marksTable td { padding: 8px; border-bottom: 1px solid #e5e9f2; text-align: center; }

.markInput { width: 60px; padding: 5px; border-radius: 5px; border: 1px solid #ccd6e0; text-align: center; }
.markInput.changed, .remarksBox.changed { background: #fff3cd !important; border-color: #f39c12; }

.totalBox, .percentBox {
    width: 85px;
    font-weight: 600;
    background: #ecf0f1;
    border: none;
    text-align: center;
}

.remarksBox { width: 200px; border-radius: 6px; border: 1px solid #ccd6e0; padding: 5px; }

.btn-group { margin-top: 20px; display: flex; gap: 10px; }

.save-btn {
    padding: 10px 25px;
    border-radius: 8px;
    border: none;
    color: white;
    font-size: 15px;
    font-weight: 500;
    cursor: pointer;
    transition: 0.2s;
}

.bg-green { background: linear-gradient(45deg, #27ae60, #1e8449); }

.save-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(0,0,0,0.1);
}

.marksTable td:first-child, .marksTable th:first-child {
    width: 50px;
    font-weight: 600;
}
</style>

<script>

function fixTable() {
    const table = document.querySelector("#dataArea table");
    if (!table) return;

    let thead = table.querySelector("thead");
    if (!thead) {
        thead = document.createElement("thead");
        thead.appendChild(table.rows[0]);
        table.insertBefore(thead, table.firstChild);
    }

    const headerRow = thead.rows[0];

    if (headerRow.cells[headerRow.cells.length - 1].innerText.trim() !== "Percentage") {
        const th = document.createElement("th");
        th.innerText = "Percentage";
        headerRow.appendChild(th);
    }

    if (headerRow.cells[0].innerText.trim() !== "S.No") {
        headerRow.cells[0].innerText = "S.No";
    }

    table.querySelectorAll("tbody tr").forEach(row => {
        if (!row.querySelector(".percentBox")) {
            const td = document.createElement("td");
            td.innerHTML = '<input type="text" class="percentBox" readonly>';
            row.appendChild(td);
        }
    });
}


function loadStudentsAndExams() {
    const classId = class_id.value;
    const examDate = exam_date.value;
    if (!classId || !examDate) return;

    const xhr = new XMLHttpRequest();
    xhr.open("GET", "MarksReport?class_id=" + classId + "&exam_date=" + examDate, true);
    xhr.onload = function () {
        dataArea.innerHTML = this.responseText;
        fixTable();
        hookChangeTracking();
        calculateAllRows();
        sortByPercentageDesc(); 
    };
    xhr.send();
}


function hookChangeTracking() {
    document.querySelectorAll(".markInput, .remarksBox").forEach(inp => {
        inp.dataset.old = inp.value;
        inp.addEventListener("input", function () {
            this.classList.toggle("changed", this.value !== this.dataset.old);
            if (this.classList.contains("markInput")) calculateRow(this);
        });
    });
}


function calculateRow(input) {
    const row = input.closest("tr");
    let total = 0, maxTotal = 0;

    const headers = document.querySelector("#dataArea table thead tr").cells;

    row.querySelectorAll(".markInput").forEach(inp => {
        total += parseFloat(inp.value) || 0;

        const headerCell = headers[inp.parentElement.cellIndex];
        if (headerCell) {
            const match = headerCell.innerText.match(/\((\d+)\)/);
            if (match) maxTotal += parseFloat(match[1]);
        }
    });

    row.querySelector(".totalBox").value = total;
    row.querySelector(".percentBox").value =
        maxTotal > 0 ? ((total / maxTotal) * 100).toFixed(2) : 0;

    sortByPercentageDesc(); 
}

function calculateAllRows() {
    document.querySelectorAll(".markInput").forEach(calculateRow);
}


function sortByPercentageDesc() {
    const tbody = document.querySelector("#dataArea table tbody");
    if (!tbody) return;

    const rows = Array.from(tbody.rows);

    rows.sort((a, b) => {
        const pA = parseFloat(a.querySelector(".percentBox").value) || 0;
        const pB = parseFloat(b.querySelector(".percentBox").value) || 0;
        return pB - pA; // DESC
    });

    rows.forEach((row, index) => {
        tbody.appendChild(row);
        row.cells[0].innerText = index + 1; // ✅ NEW SERIAL NUMBER
    });
}
</script>
</head>

<body>
<jsp:include page="common_header.jsp" />

<div class="container">
    <div class="page-title">📘 Exam Marks Entry</div>

    <div class="btn-group">
        <button type="button" class="save-btn bg-green" onclick="exportToExcel()">📊 Download Excel</button>
    </div>

    <form>
        <div class="filter-bar">
            <div>
                <label>Exam Date</label><br>
                <input type="date" id="exam_date" value="<%= java.time.LocalDate.now() %>" onchange="loadStudentsAndExams()">
            </div>

            <div>
                <label>Class</label><br>
                <select id="class_id" onchange="loadStudentsAndExams()">
                    <option value="">-- Select Class --</option>
                    <%
                        try (Connection con = DBUtil.getConnection();
                             Statement st = con.createStatement();
                             ResultSet rs = st.executeQuery("SELECT class_id, class_name FROM classes")) {
                            while (rs.next()) {
                    %>
                    <option value="<%=rs.getInt("class_id")%>"><%=rs.getString("class_name")%></option>
                    <% }} catch (Exception e) {} %>
                </select>
            </div>
        </div>

        <div class="table-wrapper">
            <div id="dataArea"></div>
        </div>
    </form>
</div>
</body>
</html>
