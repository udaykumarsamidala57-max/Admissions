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

/* Table Styles */
.marksTable { width: 100%; border-collapse: collapse; min-width: 900px; }
.marksTable th { background: #0f2a4d; color: white; padding: 12px; font-weight: 500; }
.marksTable td { padding: 8px; border-bottom: 1px solid #e5e9f2; text-align: center; }

/* Input Styles */
.markInput { width: 60px; padding: 5px; border-radius: 5px; border: 1px solid #ccd6e0; text-align: center; }
.markInput.changed, .remarksBox.changed { background: #fff3cd !important; border-color: #f39c12; }
.totalBox, .percentBox { width: 85px; font-weight: 600; background: #ecf0f1; border: none; text-align: center; }
.remarksBox { width: 200px; border-radius: 6px; border: 1px solid #ccd6e0; padding: 5px; }

/* Buttons */
.btn-group { margin-top: 20px; display: flex; gap: 10px; }
.save-btn {
    padding: 10px 25px; border-radius: 8px; border: none;
    color: white; font-size: 15px; font-weight: 500; cursor: pointer; transition: 0.2s;
}
.bg-blue { background: linear-gradient(45deg, #3498db, #2c80b4); }
.bg-green { background: linear-gradient(45deg, #27ae60, #1e8449); }
.save-btn:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
</style>

<script>
/* ================= EXCEL EXPORT LOGIC ================= */
function exportToExcel() {
    const table = document.querySelector("#dataArea table");
    if (!table) {
        alert("Please load data first!");
        return;
    }

    // 1. Create a virtual copy of the table to clean data
    const ws_data = [];
    const rows = table.querySelectorAll("tr");

    rows.forEach((row) => {
        const rowData = [];
        const cells = row.querySelectorAll("th, td");
        cells.forEach((cell) => {
            // If cell has an input, get the value; otherwise get text
            const input = cell.querySelector("input");
            if (input) {
                rowData.push(input.value);
            } else {
                rowData.push(cell.innerText.trim());
            }
        });
        ws_data.push(rowData);
    });

    // 2. Build the Workbook
    const wb = XLSX.utils.book_new();
    const ws = XLSX.utils.aoa_to_sheet(ws_data);

    // 3. Simple Formatting: Set column widths
    const wscols = ws_data[0].map(() => ({ wch: 15 }));
    ws['!cols'] = wscols;

    XLSX.utils.book_append_sheet(wb, ws, "Marks_Report");

    // 4. Filename generation
    const className = document.getElementById("class_id").options[document.getElementById("class_id").selectedIndex].text;
    const date = document.getElementById("exam_date").value;
    XLSX.writeFile(wb, `Marks_${className}_${date}.xlsx`);
}

/* ================= EXISTING LOGIC ================= */
function fixTable() {
    var table = document.querySelector("#dataArea table");
    if (!table) return;
    var thead = table.querySelector("thead") || document.createElement("thead");
    if (!table.querySelector("thead")) {
        thead.appendChild(table.rows[0]);
        table.insertBefore(thead, table.firstChild);
    }
    var headerRow = thead.rows[0];
    if (headerRow.cells[headerRow.cells.length - 1].innerText.trim() !== "Percentage") {
        var thp = document.createElement("th"); thp.innerText = "Percentage";
        headerRow.appendChild(thp);
    }
    var rows = table.querySelectorAll("tbody tr");
    rows.forEach(row => {
        if (!row.querySelector(".percentBox")) {
            var td = document.createElement("td");
            td.innerHTML = '<input type="text" class="percentBox" readonly>';
            row.appendChild(td);
        }
    });
}

function loadStudentsAndExams() {
    var classId = document.getElementById("class_id").value;
    var examDate = document.getElementById("exam_date").value;
    if(!classId || !examDate) return;
    document.getElementById("exam_date_hidden").value = examDate;
    
    var xhr = new XMLHttpRequest();
    xhr.open("GET", "MarksReport?class_id=" + classId + "&exam_date=" + examDate, true);
    xhr.onload = function() {
        document.getElementById("dataArea").innerHTML = this.responseText;
        fixTable();
        hookChangeTracking();
        calculateAllRows();
    };
    xhr.send();
}

function hookChangeTracking() {
    var inputs = document.querySelectorAll(".markInput, .remarksBox");
    inputs.forEach(inp => {
        inp.setAttribute("data-old", inp.value);
        inp.addEventListener("input", function() {
            this.classList.toggle("changed", this.value !== this.getAttribute("data-old"));
            if(this.classList.contains("markInput")) calculateRow(this);
        });
    });
}

function calculateRow(input) {
    var row = input.closest("tr");
    var markInputs = row.querySelectorAll(".markInput");
    var total = 0, maxTotal = 0;
    
    var headers = document.querySelector("#dataArea table thead tr").cells;
    markInputs.forEach((inp, idx) => {
        total += parseFloat(inp.value) || 0;
        // Logic to find max marks from header: "Maths (100)"
        var headerText = Array.from(headers).find(h => h.cellIndex === inp.parentElement.cellIndex).innerText;
        var match = headerText.match(/\((\d+)\)/);
        if(match) maxTotal += parseFloat(match[1]);
    });

    row.querySelector(".totalBox").value = total;
    if(maxTotal > 0) row.querySelector(".percentBox").value = ((total/maxTotal)*100).toFixed(2);
}

function calculateAllRows() {
    document.querySelectorAll(".markInput").forEach(calculateRow);
}
</script>
</head>
<body>

<jsp:include page="common_header.jsp" />

<div class="container">
    <div class="page-title">📘 Exam Marks Entry</div>
<div class="btn-group" >
            
            <button  type="button" class="save-btn bg-green" onclick="exportToExcel()">📊 Download Excel</button>
        </div>
    <form method="post" action="" onsubmit="return beforeSubmit()">
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
                    try(Connection con = DBUtil.getConnection(); 
                        Statement st = con.createStatement(); 
                        ResultSet rs = st.executeQuery("SELECT class_id, class_name FROM classes")) {
                        while(rs.next()){
                    %>
                        <option value="<%=rs.getInt("class_id")%>"><%=rs.getString("class_name")%></option>
                    <% }} catch(Exception e) {} %>
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