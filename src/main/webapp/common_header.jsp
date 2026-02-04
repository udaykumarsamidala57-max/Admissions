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
    String user = (String) sess.getAttribute("username");
%>

<style>

.ams-header {
    box-sizing: border-box;
    font-family: 'Inter', "Segoe UI", Roboto, sans-serif;
    background: #0f2a4d;
    border-bottom: 3px solid #38bdf8; /* Accent border */
}

.ams-header .nav-container {
    max-width: 1400px;
    margin: 0 auto;
    padding: 12px 24px;
    display: flex;
    align-items: center;
    justify-content: space-between;
}


.ams-header .brand-box {
    display: flex;
    flex-direction: column;
    border-left: 4px solid #fbbf24; 
    padding-left: 15px;
}

.ams-header .school-name {
    color: #fbbf24; 
    font-size: 1.2rem;
    font-weight: 800;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    line-height: 1.1;
}

.ams-header .system-name {
    color: #ffffff;
    font-size: 0.85rem;
    font-weight: 400;
    letter-spacing: 1px;
    opacity: 0.9;
}


.ams-header nav ul {
    list-style: none;
    display: flex;
    gap: 8px;
    margin: 0;
    padding: 0;
}

.ams-header nav ul li a {
    text-decoration: none;
    color: #e5e7eb;
    font-size: 14px;
    font-weight: 500;
    padding: 8px 14px;
    border-radius: 4px;
    transition: all 0.2s ease;
}

.ams-header nav ul li a:hover {
    background: rgba(255, 255, 255, 0.1);
    color: #38bdf8;
}


.ams-header .user-info {
    display: flex;
    align-items: center;
    gap: 20px;
    background: rgba(0, 0, 0, 0.2);
    padding: 6px 16px;
    border-radius: 50px;
}

.ams-header .user-name {
    color: #ffffff;
    font-size: 13px;
    font-weight: 600;
}

.ams-header .logout-btn {
    color: #fca5a5;
    font-size: 13px;
    font-weight: 700;
    text-decoration: none;
    padding-left: 12px;
    border-left: 1px solid rgba(255,255,255,0.2);
}

.ams-header .logout-btn:hover {
    color: #ef4444;
}


@media(max-width: 1024px) {
    .ams-header .nav-container {
        flex-direction: column;
        gap: 15px;
        text-align: center;
    }
    .ams-header .brand-box { border-left: none; padding-left: 0; }
}
</style>

<header class="ams-header">
    <div class="nav-container">
        
        <div class="brand-box">
            <span class="school-name">Sandur Residential School</span>
            <span class="system-name">Admissions Management System</span>
        </div>

        <nav>
            <ul>
                <li><a href="dashboard">Home</a></li>
                <li><a href="admission">Enquiries</a></li>
                <li><a href="enter_marks.jsp">Exam</a></li>
                <li><a href="marks_report.jsp">Tabulation</a></li>
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