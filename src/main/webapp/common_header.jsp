<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page session="true" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String user = (String) sess.getAttribute("username");
%>

<style>

header.ams-header,
header.ams-header * {
    box-sizing: border-box !important;
    font-family: 'Inter', "Segoe UI", Roboto, sans-serif !important;
}


header.ams-header {
    background: #0f2a4d !important;
    border-bottom: 2px solid #38bdf8 !important;
    margin: 0 !important;
    padding: 0 !important;
    width: 100% !important;
    display: block !important;
}


.ams-header .nav-container {
    max-width: 1400px;
    margin: 0 auto !important;
    padding: 5px 20px !important;
    display: flex !important;
    align-items: center !important;
    justify-content: space-between !important;
    min-height: 45px !important;
}


.ams-header .brand-box {
    display: flex !important;
    flex-direction: column !important;
    border-left: 3px solid #fbbf24 !important;
    padding-left: 10px !important;
}

.ams-header .school-name {
    color: #fbbf24 !important;
    font-size: 0.95rem !important;
    font-weight: 800 !important;
    text-transform: uppercase !important;
    line-height: 1.1 !important;
}

.ams-header .system-name {
    color: #ffffff !important;
    font-size: 0.7rem !important;
    opacity: 0.9 !important;
}


.ams-header nav.ams-nav,
.ams-header nav.ams-nav ul,
.ams-header nav.ams-nav li {
    all: revert;
}

.ams-header nav.ams-nav {
    display: block !important;
}

.ams-header nav.ams-nav ul {
    list-style: none !important;
    display: flex !important;
    gap: 2px !important;
    margin: 0 !important;
    padding: 0 !important;
}

.ams-header nav.ams-nav ul li a {
    text-decoration: none !important;
    color: #e5e7eb !important;
    font-size: 11px !important;
    font-weight: 600 !important;
    padding: 4px 8px !important;
    border-radius: 4px !important;
    transition: all 0.2s ease !important;
    display: block !important;
}

.ams-header nav.ams-nav ul li a:hover {
    background: rgba(255,255,255,0.1) !important;
    color: #38bdf8 !important;
}


.ams-header .user-info {
    display: flex !important;
    align-items: center !important;
    gap: 10px !important;
    background: rgba(0,0,0,0.3) !important;
    padding: 3px 12px !important;
    border-radius: 4px !important;
}

.ams-header .user-name {
    color: #ffffff !important;
    font-size: 11px !important;
    font-weight: 600 !important;
}

.ams-header .logout-btn {
    color: #fca5a5 !important;
    font-size: 11px !important;
    font-weight: 700 !important;
    text-decoration: none !important;
    padding-left: 10px !important;
    border-left: 1px solid rgba(255,255,255,0.2) !important;
}


@media (max-width: 1100px) {
    .ams-header .nav-container {
        flex-direction: column !important;
        padding: 10px !important;
    }

    .ams-header nav.ams-nav ul {
        flex-wrap: wrap !important;
        justify-content: center !important;
    }
}
</style>

<header class="ams-header">
    <div class="nav-container">

        <div class="brand-box">
            <span class="school-name">Sandur Residential School</span>
            <span class="system-name">Admissions Management System</span>
        </div>

        <nav class="ams-nav">
            <ul>
                <li><a href="dashboard">Home</a></li>
                <li><a href="admission">Enquiries</a></li>
                <li><a href="admission_report.jsp">Dashboard</a></li>
                <li><a href="enter_marks.jsp">Exam</a></li>
                <li><a href="marks_report.jsp">Tabulation</a></li>
                <li><a href="ApproveAdmission.jsp">Approval</a></li>
                <li><a href="Capcity.jsp">Vacancy</a></li>
                <li><a href="student_tc_update.jsp">TC Update</a></li>
            </ul>
        </nav>

        <div class="user-info">
            <span class="user-name">👤 <%= user %></span>
            <a href="Logout.jsp" class="logout-btn">Logout</a>
        </div>

    </div>
</header>
