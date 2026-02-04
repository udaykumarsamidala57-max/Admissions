<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page session="true" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String role = (String) sess.getAttribute("role");
    String User = (String) sess.getAttribute("username");
%>

<style>
/* ================= HEADER ISOLATED SCOPE ================= */
.ams-header *{
    box-sizing: border-box;
    font-family: "Segoe UI", Arial, sans-serif;
}

/* ===== HEADER BAR ===== */
.ams-header .toolbar{
    position: sticky;
    top: 0;
    z-index: 99999;
    background: linear-gradient(135deg,#1e3a8a,#4338ca);
    padding: 14px 22px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    box-shadow: 0 10px 30px rgba(0,0,0,0.25);
    color: white;
}

/* ===== TITLE ===== */
.ams-header .toolbar h2{
    margin: 0;
    font-size: 22px;
    font-weight: 800;
    letter-spacing: 0.5px;
    white-space: nowrap;
}

/* ===== RIGHT MENU ===== */
.ams-header .menu-right{
    display: flex;
    gap: 12px;
    align-items: center;
    flex-wrap: wrap;
}

/* ===== BUTTONS ===== */
.ams-header .btn{
    border: none;
    padding: 10px 18px;
    border-radius: 12px;
    cursor: pointer;
    font-weight: 700;
    font-size: 14px;
    color: white;
    background: linear-gradient(135deg,#22c55e,#16a34a);
    box-shadow: 0 6px 14px rgba(0,0,0,0.25);
    transition: all .25s ease;
    display: flex;
    align-items: center;
    gap: 6px;
    white-space: nowrap;
}

.ams-header .btn:hover{
    transform: translateY(-2px) scale(1.04);
    box-shadow: 0 10px 20px rgba(0,0,0,0.35);
}

/* Button colors */
.ams-header .btn.blue{ background: linear-gradient(135deg,#2563eb,#1d4ed8); }
.ams-header .btn.red{  background: linear-gradient(135deg,#ef4444,#dc2626); }
.ams-header .btn.gray{ background: linear-gradient(135deg,#64748b,#475569); }

/* ===== MOBILE ===== */
@media(max-width:768px){
    .ams-header .toolbar{
        flex-direction: column;
        align-items: flex-start;
        gap: 10px;
    }
    .ams-header .menu-right{
        width: 100%;
        justify-content: flex-end;
    }
}
</style>

<!-- ================= HEADER ================= -->
<div class="ams-header">
    <div class="toolbar">
        <h2 style="color:white">🎓 Admissions Management System</h2>

        <div class="menu-right">

            <button class="btn gray" onclick="location.href='dashboard'">
                📊 <span>Dashboard</span>
            </button>

            <button class="btn" onclick="location.href='admission'">
                📝 <span>Enquiries</span>
            </button>

            <button class="btn" onclick="location.href='enter_marks.jsp'">
                🧪 <span>Entrance Test</span>
            </button>

            <button class="btn" onclick="location.href='marks_report.jsp'">
                📈 <span>Test Report</span>
            </button>
            <button class="btn blue" onclick="location.href='Capcity.jsp'">
                📈 <span>Create vacancy</span>
            </button>

            <button class="btn blue" onclick="location.href='student_tc_update.jsp'">
                📄 <span>TC Update</span>
            </button>

            <button class="btn red" onclick="location.href='Logout.jsp'">
                🚪 <span>Logout</span>
            </button>

        </div>
    </div>
</div>
