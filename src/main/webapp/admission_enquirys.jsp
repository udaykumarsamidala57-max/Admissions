<%@ page import="javax.sql.rowset.CachedRowSet" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.regex.*" %>
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

   // --- DATA EXTRACTION & NATURAL SORTING LOGIC ---
   CachedRowSet rs = (CachedRowSet)request.getAttribute("list");
   List<Map<String, Object>> dataList = new ArrayList<>();
   
   if (rs != null) {
       rs.beforeFirst();
       java.sql.ResultSetMetaData metaData = rs.getMetaData();
       int columnCount = metaData.getColumnCount();
       while (rs.next()) {
           Map<String, Object> row = new HashMap<>();
           for (int i = 1; i <= columnCount; i++) {
               row.put(metaData.getColumnName(i), rs.getObject(i));
           }
           dataList.add(row);
       }

       Collections.sort(dataList, new Comparator<Map<String, Object>>() {
           // Helper to split string into Alpha and Numeric chunks
           private List<String> split(String s) {
               List<String> chunks = new ArrayList<>();
               Matcher m = Pattern.compile("(\\d+)|(\\D+)").matcher(s);
               while (m.find()) chunks.add(m.group());
               return chunks;
           }

           @Override
           public int compare(Map<String, Object> m1, Map<String, Object> m2) {
               String s1 = (String) m1.get("application_no");
               String s2 = (String) m2.get("application_no");
               
               boolean empty1 = (s1 == null || s1.trim().isEmpty());
               boolean empty2 = (s2 == null || s2.trim().isEmpty());

               // 1. Keep empty application numbers at the top (like unread mail)
               if (empty1 && !empty2) return -1;
               if (!empty1 && empty2) return 1;
               if (empty1 && empty2) return 0;

               // 2. Natural Sort for non-empty strings (Handle Alpha then Number)
               List<String> chunks1 = split(s1);
               List<String> chunks2 = split(s2);
               int size = Math.min(chunks1.size(), chunks2.size());

               for (int i = 0; i < size; i++) {
                   String c1 = chunks1.get(i);
                   String c2 = chunks2.get(i);
                   int res;
                   if (Character.isDigit(c1.charAt(0)) && Character.isDigit(c2.charAt(0))) {
                       res = Long.compare(Long.parseLong(c1), Long.parseLong(c2));
                   } else {
                       res = c1.compareToIgnoreCase(c2);
                   }
                   if (res != 0) return res;
               }
               return Integer.compare(chunks1.size(), chunks2.size());
           }
       });
   }
%>

<html>
<head>
<title>Admission Enquiry Register</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">

<style>
*{ box-sizing: border-box; font-family: Inter, Segoe UI, Arial, sans-serif; }
body{ margin: 0; min-height: 100vh; background: radial-gradient(circle at 10% 10%, #dbeafe 0%, transparent 40%), radial-gradient(circle at 90% 20%, #fef3c7 0%, transparent 40%), linear-gradient(135deg,#eef2ff,#f8fafc); }

.filters{ margin: 14px; padding: 14px 16px; display: flex; gap: 12px; flex-wrap: wrap; background: rgba(255,255,255,0.9); backdrop-filter: blur(10px); border-radius: 18px; box-shadow: 0 10px 24px rgba(0,0,0,0.12); }
.filters input, .filters select{ padding: 9px 12px; border-radius: 12px; border: 1px solid #c7d2fe; font-size: 14px; outline: none; }

.btn{ border: none; padding: 10px 18px; border-radius: 14px; cursor: pointer; font-size: 14px; font-weight: 600; color: #ffffff; transition: 0.25s ease; box-shadow: 0 6px 16px rgba(0,0,0,0.25); }
.btn.blue{ background: linear-gradient(135deg,#2563eb,#1e40af); }
.btn.red{ background: linear-gradient(135deg,#ef4444,#b91c1c); }
.btn.gray{ background: linear-gradient(135deg,#64748b,#475569); }

.table-wrap{ padding: 14px; overflow-x: auto; }
table{ width: 100%; border-collapse: collapse; background: #ffffff; font-size: 14px; }
table thead th{ background: #0f2a4d; color: #ffffff; padding: 9px 10px; font-weight: 700; border: 1px solid #0b1f3a; text-align: left; white-space: nowrap; }
table tbody td{ padding: 8px 10px; border: 1px solid #000000; color: #000000; vertical-align: middle; }
table tbody tr:hover{ background: #f1f5f9; }

/* Highlight for records without App No - Like "Unread" mail */
.empty-app-row { background-color: #fffbeb !important; border-left: 5px solid #f59e0b !important; }
.not-attended-badge { color: #b91c1c; font-weight: 800; background: #fee2e2; padding: 2px 6px; border-radius: 6px; }

.badge-day{ background: #dcfce7; color: #166534; padding: 4px 12px; border-radius: 20px; font-weight: 700; }
.badge-res{ background: #fee2e2; color: #7f1d1d; padding: 4px 12px; border-radius: 20px; font-weight: 700; }

.modal-overlay{ position: fixed; inset: 0; background: rgba(0,0,0,0.6); display: flex; align-items: center; justify-content: center; z-index: 9999; }
.modal-box{ background: #ffffff; padding: 24px; border-radius: 20px; width: 800px; max-width: 95%; box-shadow: 0 24px 60px rgba(0,0,0,0.45); }
.form-grid{ display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; }
.form-grid div{ display: flex; flex-direction: column; }
.form-grid label{ font-size: 12px; font-weight: 700; color: #475569; }
</style>

<script>
function calculateAges() {
    let cells = document.querySelectorAll(".age-cell");
    let asOnDate = new Date(2026, 4, 31);
    cells.forEach(cell => {
        let dob = cell.dataset.dob;
        if (!dob || dob === "null") return;
        let birth = new Date(dob);
        let y = 0, m = 0;
        let temp = new Date(birth);
        while (true) { let next = new Date(temp); next.setFullYear(next.getFullYear() + 1); if (next <= asOnDate) { y++; temp = next; } else break; }
        while (true) { let next = new Date(temp); next.setMonth(next.getMonth() + 1); if (next <= asOnDate) { m++; temp = next; } else break; }
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
        let show = (text.includes(search)) && (cls === "" || classCol === cls) && (type === "" || typeCol.includes(type));
        if(show){ row.style.display=""; visible++; if(typeCol.includes("day")) day++; else res++; } else { row.style.display="none"; }
    });
    document.getElementById("countTotal").innerText = total;
    document.getElementById("countVisible").innerText = visible;
    document.getElementById("countDay").innerText = day;
    document.getElementById("countRes").innerText = res;
}

function openEditModal(id){ document.getElementById("editModal"+id).style.display="flex"; }
function closeEditModal(id){ document.getElementById("editModal"+id).style.display="none"; }

function saveEditForm(id){
    let params = new URLSearchParams(new FormData(document.getElementById("editForm"+id)));
    fetch("admission", { method: "POST", body: params, headers: { 'Content-Type': 'application/x-www-form-urlencoded' } })
    .then(r => r.text()).then(res => { if(res.trim() === "OK") { alert("Updated!"); location.reload(); } else alert("Error: " + res); });
    return false;
}

function deleteRecord(id){
    if(confirm("Delete this record?")) fetch("admission?action=delete&id="+id).then(()=> { document.getElementById("row"+id).remove(); applyFilters(); });
}

function approveRecord(id){
    fetch("admission?action=approve&id="+id).then(()=> { document.getElementById("approveCell"+id).innerHTML = '<span style="color:#15803d;font-weight:900;">Approved</span>'; });
}

window.onload = function(){ calculateAges(); applyFilters(); }
</script>
</head>

<body>
<div class="app">
<jsp:include page="common_header.jsp" />

<div class="filters">
    <b>Total:</b> <span id="countTotal">0</span> | <b>Visible:</b> <span id="countVisible">0</span>
    <input type="text" id="filterSearch" placeholder="Search name, mobile, etc..." onkeyup="applyFilters()">
    <select id="filterClass" onchange="applyFilters()">
        <option value="">All Classes</option>
        <% for(int i=1; i<=9; i++){ %><option>Class <%=i%></option><% } %>
    </select>
    <select id="filterType" onchange="applyFilters()">
        <option value="">All Types</option>
        <option>Dayscholar</option><option>Residential</option>
    </select>
    <button class="btn gray" onclick="location.reload()">Refresh Sort</button>
</div>

<div class="table-wrap">
<table id="enquiryTable">
<thead>
    <tr>
    <th>ID</th><th>Student</th><th>Gender</th><th>DOB</th><th>Age</th>
    <th>Class</th><th>Type</th><th>Father</th><th>F Occ</th><th>F Mobile</th>
    <th>Place</th><th>Exam Date</th><th>App No</th><th>Actions</th><th>Print</th><th>Status</th>
    </tr>
</thead>
<tbody>
<%
if(dataList != null){
for(Map<String, Object> rowMap : dataList){
    int id = (Integer)rowMap.get("enquiry_id");
    String appNo = (String)rowMap.get("application_no");
    String dob = String.valueOf(rowMap.get("date_of_birth"));
    String type = String.valueOf(rowMap.get("admission_type"));
    boolean isNoApp = (appNo == null || appNo.trim().isEmpty());
%>
<tr class="data-row <%= isNoApp ? "empty-app-row" : "" %>" id="row<%=id%>">
    <td><%=id%></td>
    <td><%=rowMap.get("student_name")%></td>
    <td><%=rowMap.get("gender")%></td>
    <td><%=dob%></td>
    <td class="age-cell" data-dob="<%=dob%>"></td>
    <td><%=rowMap.get("class_of_admission")%></td>
    <td><span class="<%= type.toLowerCase().contains("day") ? "badge-day" : "badge-res" %>"><%=type%></span></td>
    <td><%=rowMap.get("father_name")%></td>
    <td><%=rowMap.get("father_occupation")%></td>
    <td><%=rowMap.get("father_mobile_no")%></td>
    <td><%=rowMap.get("place_from")%></td>
    <td><%=rowMap.get("exam_date")%></td>
    <td><%= isNoApp ? "<span class='not-attended-badge'>NOT ATTENDED</span>" : appNo %></td>

    <td>
        <button class="btn blue" onclick="openEditModal(<%=id%>)">Edit</button>
        <% if("Global".equalsIgnoreCase(role)){ %><button class="btn red" onclick="deleteRecord(<%=id%>)">Del</button><% } %>
    </td>
    <td><button class="btn gray" onclick="window.open('HallTicket.jsp?enquiry_id=<%=id%>&application_no=<%=appNo%>', '_blank')">Print</button></td>
    <td id="approveCell<%=id%>">
        <% if("Global".equalsIgnoreCase(role)){
            if(!"Approved".equalsIgnoreCase((String)rowMap.get("approved"))){ %>
            <button onclick="approveRecord(<%=id%>)" class="btn gray">Approve</button>
        <% } else { %><span style="color:#15803d;font-weight:900;">Approved</span><% } } %>
    </td>
</tr>
<% } } %>
</tbody>
</table>
</div>

<% if(dataList != null) { for(Map<String, Object> rowMap : dataList){ int id = (Integer)rowMap.get("enquiry_id"); %>
<div id="editModal<%=id%>" class="modal-overlay" style="display:none;">
<div class="modal-box">
    <h3>Edit Enquiry #<%=id%></h3>
    <form id="editForm<%=id%>" onsubmit="return saveEditForm(<%=id%>)">
        <input type="hidden" name="action" value="update"><input type="hidden" name="enquiry_id" value="<%=id%>">
        <div class="form-grid">
            <div><label>Name</label><input type="text" name="student_name" value="<%=rowMap.get("student_name")%>"></div>
            <div><label>DOB</label><input type="date" name="date_of_birth" value="<%=rowMap.get("date_of_birth")%>"></div>
            <div><label>Class</label><input type="text" name="class_of_admission" value="<%=rowMap.get("class_of_admission")%>"></div>
            <div><label>App No</label><input type="text" name="application_no" value="<%= rowMap.get("application_no")==null?"":rowMap.get("application_no") %>"></div>
            <div><label>Exam Date</label><input type="date" name="exam_date" value="<%=rowMap.get("exam_date")%>"></div>
            <div><label>Father Name</label><input type="text" name="father_name" value="<%=rowMap.get("father_name")%>"></div>
            <div><label>Mobile</label><input type="text" name="father_mobile_no" value="<%=rowMap.get("father_mobile_no")%>"></div>
            <div><label>Type</label><input type="text" name="admission_type" value="<%=rowMap.get("admission_type")%>"></div>
        </div>
        <div style="margin-top:20px;">
            <button class="btn blue" type="submit">Save</button>
            <button class="btn gray" type="button" onclick="closeEditModal(<%=id%>)">Cancel</button>
        </div>
    </form>
</div>
</div>
<% } } %>
</div>
</body>
</html>