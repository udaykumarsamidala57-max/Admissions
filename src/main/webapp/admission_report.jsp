<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, bean.DBUtil" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String user = (String) sess.getAttribute("username");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admission Insights | Executive Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
   <style>
:root {
    --primary: #6366f1;
    --primary-light: #eef2ff;
    --bg-body: #f1f5f9;
    --surface: #ffffff;
    --text-main: #334155;
    --text-muted: #64748b;
    --border: #e5e7eb;
    --success: #10b981;
    --accent: #f59e0b;
}

/* Base */
body { 
    font-family: 'Plus Jakarta Sans', sans-serif; 
    background-color: var(--bg-body); 
    color: var(--text-main); 
    margin: 0; 
    line-height: 1.4;
}

/* Header */
.ams-header { 
    background: #ffffff; 
    border-bottom: 1px solid var(--border);
    padding: 0 16px;
}
.nav-container { 
    max-width: 1400px; 
    margin: 0 auto; 
    height: 60px;
    display: flex; 
    align-items: center; 
    justify-content: space-between; 
}
.brand-box { 
    border-left: 3px solid var(--primary); 
    padding-left: 12px; 
}
.school-name { 
    color: #0f172a; 
    font-size: 1rem; 
    font-weight: 800; 
}
.system-name { 
    color: var(--text-muted); 
    font-size: 0.7rem; 
    font-weight: 500; 
}

nav ul { 
    list-style: none; 
    display: flex; 
    gap: 6px; 
    margin: 0; 
    padding: 0; 
}
nav ul li a { 
    text-decoration: none; 
    color: var(--text-muted); 
    font-size: 12px; 
    font-weight: 600; 
    padding: 6px 10px; 
    border-radius: 6px; 
}
nav ul li a:hover { 
    background: var(--primary-light); 
    color: var(--primary); 
}

/* Content */
.main-content { 
    padding: 24px 16px; 
    max-width: 1400px; 
    margin: auto; 
}
.page-title h1 { 
    font-size: 22px; 
    font-weight: 800; 
    color: #0f172a; 
    margin-bottom: 20px; 
}

/* Dashboard Cards (slightly tight) */
.stats-grid { 
    display: grid; 
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); 
    gap: 16px; 
    margin-bottom: 24px; 
}
.stat-card { 
    background: var(--surface); 
    padding: 16px; 
    border-radius: 10px; 
    border: 1px solid var(--border);
}
.stat-label { 
    font-size: 12px; 
    font-weight: 600; 
    color: var(--text-muted); 
    margin-bottom: 8px; 
}
.stat-value { 
    font-size: 26px; 
    font-weight: 800; 
    color: #0f172a; 
}
.icon-box { 
    width: 36px; 
    height: 36px; 
    border-radius: 8px; 
    font-size: 16px; 
}

/* ===== TABLES – COMPACT ADMIN STYLE ===== */

.table-container { 
    background: var(--surface);
    border-radius: 6px;
    border: 1px solid var(--border);
    overflow: hidden;
    margin-bottom: 12px;
}

.table-header { 
    padding: 10px 14px;
    border-bottom: 1px solid var(--border);
}
.table-header h3 { 
    margin: 0; 
    font-size: 14px; 
    font-weight: 700; 
    color: #0f172a; 
}

/* Table Core */
table { 
    width: 100%; 
    border-collapse: collapse;
}

/* Header cells */
th { 
    background: #f8fafc;
    padding: 8px 12px;
    font-weight: 700;
    text-transform: uppercase;
    color: var(--text-muted);
    font-size: 10px;
    letter-spacing: 0.4px;
    text-align: left;
    border-bottom: 1px solid var(--border);
}

/* Data cells */
td { 
    padding: 6px 12px;
    border-bottom: 1px solid var(--border);
    font-size: 13px;
    vertical-align: middle;
}

/* First column emphasis */
.col-main { 
    font-weight: 700;
    color: #0f172a;
    background: #fafafa;
    width: 180px;
}

/* Values */
.val-total { 
    font-size: 14px;
    font-weight: 700;
    color: #1e293b;
    display: block;
}

/* Gender pills – tight */
.gender-pill { 
    display: inline-flex;
    gap: 4px;
    margin-top: 2px;
    padding: 1px 6px;
    background: #f1f5f9;
    border-radius: 4px;
    font-size: 9px;
    font-weight: 700;
    color: var(--text-muted);
}
.text-m { color: var(--primary); }
.text-f { color: #ec4899; }

/* Total column */
.total-cell { 
    background: #f5f3ff !important;
    border-left: 2px solid #c7d2fe;
}
.total-cell .val-total { 
    color: var(--primary);
}

/* Footer summary */
.footer-summary { 
    background: #1e293b;
}
.footer-summary td { 
    color: #ffffff;
    font-weight: 700;
    font-size: 13px;
    padding: 8px 12px;
}
</style>
</head>
<body>

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
                <li><a href="admission_report.jsp">Dashboard</a></li>
                <li><a href="enter_marks.jsp">Exam</a></li>
                <li><a href="marks_report.jsp">Tabulation</a></li>
                <li><a href="ApproveAdmission.jsp">Approval</a></li>
            </ul>
        </nav>
        <div style="font-weight: 700; font-size: 13px;">
            <span style="color: var(--text-muted)">Welcome, </span> <%= user %>
        </div>
    </div>
</header>

<main class="main-content">
    <%
        // Java Logic remains identical to your processing
        Connection conn = null;
        int g_d_app_m=0, g_d_app_f=0, g_d_att_m=0, g_d_att_f=0, g_d_adm_m=0, g_d_adm_f=0;
        int g_r_app_m=0, g_r_app_f=0, g_r_att_m=0, g_r_att_f=0, g_r_adm_m=0, g_r_adm_f=0;
        int g_s_app_m=0, g_s_app_f=0, g_s_att_m=0, g_s_att_f=0, g_s_adm_m=0, g_s_adm_f=0;
        int g_t_app=0, g_t_att=0, g_t_adm=0;
        try {
            conn = DBUtil.getConnection();
            String sql = "SELECT class_of_admission, " +
                "SUM(CASE WHEN admission_type='Dayscholar' AND gender='Male' THEN 1 ELSE 0 END) as d_app_m, " +
                "SUM(CASE WHEN admission_type='Dayscholar' AND gender='Female' THEN 1 ELSE 0 END) as d_app_f, " +
                "SUM(CASE WHEN admission_type='Dayscholar' AND (exam_date IS NOT NULL AND exam_date != '') AND gender='Male' THEN 1 ELSE 0 END) as d_att_m, " +
                "SUM(CASE WHEN admission_type='Dayscholar' AND (exam_date IS NOT NULL AND exam_date != '') AND gender='Female' THEN 1 ELSE 0 END) as d_att_f, " +
                "SUM(CASE WHEN admission_type='Dayscholar' AND Admission_status='Selected' AND gender='Male' THEN 1 ELSE 0 END) as d_adm_m, " +
                "SUM(CASE WHEN admission_type='Dayscholar' AND Admission_status='Selected' AND gender='Female' THEN 1 ELSE 0 END) as d_adm_f, " +
                "SUM(CASE WHEN admission_type='Residential' AND gender='Male' THEN 1 ELSE 0 END) as r_app_m, " +
                "SUM(CASE WHEN admission_type='Residential' AND gender='Female' THEN 1 ELSE 0 END) as r_app_f, " +
                "SUM(CASE WHEN admission_type='Residential' AND (exam_date IS NOT NULL AND exam_date != '') AND gender='Male' THEN 1 ELSE 0 END) as r_att_m, " +
                "SUM(CASE WHEN admission_type='Residential' AND (exam_date IS NOT NULL AND exam_date != '') AND gender='Female' THEN 1 ELSE 0 END) as r_att_f, " +
                "SUM(CASE WHEN admission_type='Residential' AND Admission_status='Selected' AND gender='Male' THEN 1 ELSE 0 END) as r_adm_m, " +
                "SUM(CASE WHEN admission_type='Residential' AND Admission_status='Selected' AND gender='Female' THEN 1 ELSE 0 END) as r_adm_f, " +
                "SUM(CASE WHEN admission_type='Semi Residential' AND gender='Male' THEN 1 ELSE 0 END) as s_app_m, " +
                "SUM(CASE WHEN admission_type='Semi Residential' AND gender='Female' THEN 1 ELSE 0 END) as s_app_f, " +
                "SUM(CASE WHEN admission_type='Semi Residential' AND (exam_date IS NOT NULL AND exam_date != '') AND gender='Male' THEN 1 ELSE 0 END) as s_att_m, " +
                "SUM(CASE WHEN admission_type='Semi Residential' AND (exam_date IS NOT NULL AND exam_date != '') AND gender='Female' THEN 1 ELSE 0 END) as s_att_f, " +
                "SUM(CASE WHEN admission_type='Semi Residential' AND Admission_status='Selected' AND gender='Male' THEN 1 ELSE 0 END) as s_adm_m, " +
                "SUM(CASE WHEN admission_type='Semi Residential' AND Admission_status='Selected' AND gender='Female' THEN 1 ELSE 0 END) as s_adm_f " +
                "FROM admission_enquiry GROUP BY class_of_admission ORDER BY FIELD(class_of_admission, 'Nursery', 'LKG', 'UKG', 'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10')";
            List<Map<String, Object>> list = new ArrayList<>();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("cls", rs.getString("class_of_admission"));
                int dam=rs.getInt("d_app_m"), daf=rs.getInt("d_app_f"), dtm=rs.getInt("d_att_m"), dtf=rs.getInt("d_att_f"), dadm=rs.getInt("d_adm_m"), dadf=rs.getInt("d_adm_f");
                int ram=rs.getInt("r_app_m"), raf=rs.getInt("r_app_f"), rtm=rs.getInt("r_att_m"), rtf=rs.getInt("r_att_f"), radm=rs.getInt("r_adm_m"), radf=rs.getInt("r_adm_f");
                int sam=rs.getInt("s_app_m"), saf=rs.getInt("s_app_f"), stm=rs.getInt("s_att_m"), stf=rs.getInt("s_att_f"), sadm=rs.getInt("s_adm_m"), sadf=rs.getInt("s_adm_f");
                row.put("dam", dam); row.put("daf", daf); row.put("dtm", dtm); row.put("dtf", dtf); row.put("dadm", dadm); row.put("dadf", dadf);
                row.put("ram", ram); row.put("raf", raf); row.put("rtm", rtm); row.put("rtf", rtf); row.put("radm", radm); row.put("radf", radf);
                row.put("sam", sam); row.put("saf", saf); row.put("stm", stm); row.put("stf", stf); row.put("sadm", sadm); row.put("sadf", sadf);
                g_d_app_m += dam; g_d_app_f += daf; g_d_att_m += dtm; g_d_att_f += dtf; g_d_adm_m += dadm; g_d_adm_f += dadf;
                g_r_app_m += ram; g_r_app_f += raf; g_r_att_m += rtm; g_r_att_f += rtf; g_r_adm_m += radm; g_r_adm_f += radf;
                g_s_app_m += sam; g_s_app_f += saf; g_s_att_m += stm; g_s_att_f += stf; g_s_adm_m += sadm; g_s_adm_f += sadf;
                list.add(row);
            }
            g_t_app = g_d_app_m + g_d_app_f + g_r_app_m + g_r_app_f + g_s_app_m + g_s_app_f;
            g_t_att = g_d_att_m + g_d_att_f + g_r_att_m + g_r_att_f + g_s_att_m + g_s_att_f;
            g_t_adm = g_d_adm_m + g_d_adm_f + g_r_adm_m + g_r_adm_f + g_s_adm_m + g_s_adm_f;
            request.setAttribute("reportData", list);
        } catch (Exception e) { out.println("Error: " + e.getMessage()); }
        finally { if(conn != null) conn.close(); }
    %>

    <div class="page-title">
        <h1>Admission  <span style="font-weight: 400; color: var(--text-muted)">Overview</span></h1>
    </div>

    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-label"><div class="icon-box" style="background: #eef2ff; color: #6366f1;"><i class="fas fa-id-card-alt"></i></div> Overall Selections</div>
            <div class="stat-value"><%=g_t_adm%></div>
        </div>
        <div class="stat-card">
            <div class="stat-label"><div class="icon-box" style="background: #ecfdf5; color: #10b981;"><i class="fas fa-sun"></i></div> Dayscholars</div>
            <div class="stat-value"><%=g_d_adm_m + g_d_adm_f%></div>
        </div>
        <div class="stat-card">
            <div class="stat-label"><div class="icon-box" style="background: #fff7ed; color: #f59e0b;"><i class="fas fa-home"></i></div> Residential</div>
            <div class="stat-value"><%=g_r_adm_m + g_r_adm_f%></div>
        </div>
        <div class="stat-card">
            <div class="stat-label"><div class="icon-box" style="background: #fdf2f8; color: #db2777;"><i class="fas fa-building"></i></div> Semi-Residential</div>
            <div class="stat-value"><%=g_s_adm_m + g_s_adm_f%></div>
        </div>
    </div>

    <div class="table-container">
        <div class="table-header"><h3><i class="fas fa-chart-bar" style="color: var(--primary);"></i> Performance Matrix</h3></div>
        <table>
            <thead>
                <tr>
                    <th>Category</th>
                    <th>Applications</th>
                    <th>Exam Attendance</th>
                    <th>Absentees</th>
                    <th class="total-cell">Total Selected</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td class="col-main">Dayscholars</td>
                    <td><span class="val-total"><%=g_d_app_m+g_d_app_f%></span><div class="gender-pill"><span class="text-m"><%=g_d_app_m%>M</span> / <span class="text-f"><%=g_d_app_f%>F</span></div></td>
                    <td><span class="val-total"><%=g_d_att_m+g_d_att_f%></span><div class="gender-pill"><span class="text-m"><%=g_d_att_m%>M</span> / <span class="text-f"><%=g_d_att_f%>F</span></div></td>
                    <td><span class="val-total"><%=(g_d_app_m+g_d_app_f)-(g_d_att_m+g_d_att_f)%></span><div class="gender-pill"><span class="text-m"><%=g_d_app_m-g_d_att_m%>M</span> / <span class="text-f"><%=g_d_app_f-g_d_att_f%>F</span></div></td>
                    <td class="total-cell"><span class="val-total"><%=g_d_adm_m+g_d_adm_f%></span><div class="gender-pill"><span class="text-m"><%=g_d_adm_m%>M</span> / <span class="text-f"><%=g_d_adm_f%>F</span></div></td>
                </tr>
                <tr>
                    <td class="col-main">Residential</td>
                    <td><span class="val-total"><%=g_r_app_m+g_r_app_f%></span><div class="gender-pill"><span class="text-m"><%=g_r_app_m%>M</span> / <span class="text-f"><%=g_r_app_f%>F</span></div></td>
                    <td><span class="val-total"><%=g_r_att_m+g_r_att_f%></span><div class="gender-pill"><span class="text-m"><%=g_r_att_m%>M</span> / <span class="text-f"><%=g_r_att_f%>F</span></div></td>
                    <td><span class="val-total"><%=(g_r_app_m+g_r_app_f)-(g_r_att_m+g_r_att_f)%></span><div class="gender-pill"><span class="text-m"><%=g_r_app_m-g_r_att_m%>M</span> / <span class="text-f"><%=g_r_app_f-g_r_att_f%>F</span></div></td>
                    <td class="total-cell"><span class="val-total"><%=g_r_adm_m+g_r_adm_f%></span><div class="gender-pill"><span class="text-m"><%=g_r_adm_m%>M</span> / <span class="text-f"><%=g_r_adm_f%>F</span></div></td>
                </tr>
                <tr>
                    <td class="col-main">Semi-Residential</td>
                    <td><span class="val-total"><%=g_s_app_m+g_s_app_f%></span><div class="gender-pill"><span class="text-m"><%=g_s_app_m%>M</span> / <span class="text-f"><%=g_s_app_f%>F</span></div></td>
                    <td><span class="val-total"><%=g_s_att_m+g_s_att_f%></span><div class="gender-pill"><span class="text-m"><%=g_s_att_m%>M</span> / <span class="text-f"><%=g_s_att_f%>F</span></div></td>
                    <td><span class="val-total"><%=(g_s_app_m+g_s_app_f)-(g_s_att_m+g_s_att_f)%></span><div class="gender-pill"><span class="text-m"><%=g_s_app_m-g_s_att_m%>M</span> / <span class="text-f"><%=g_s_app_f-g_s_att_f%>F</span></div></td>
                    <td class="total-cell"><span class="val-total"><%=g_s_adm_m+g_s_adm_f%></span><div class="gender-pill"><span class="text-m"><%=g_s_adm_m%>M</span> / <span class="text-f"><%=g_s_adm_f%>F</span></div></td>
                </tr>
            </tbody>
            <tfoot>
                <tr class="footer-summary">
                    <td style="border-bottom-left-radius: 20px;">GRAND TOTAL</td>
                    <td><%=g_t_app%></td>
                    <td><%=g_t_att%></td>
                    <td><%=g_t_app-g_t_att%></td>
                    <td style="border-bottom-right-radius: 20px; background: #4f46e5;"><%=g_t_adm%></td>
                </tr>
            </tfoot>
        </table>
    </div>

    <div class="table-container">
        <div class="table-header"><h3><i class="fas fa-sun" style="color: var(--accent);"></i> Dayscholars - Class wise</h3></div>
        <table>
            <thead>
                <tr>
                    <th>Grade</th>
                    <th>Applied</th>
                    <th>Attended</th>
                    <th>Absentees</th>
                    <th class="total-cell">Selected</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="row" items="${reportData}">
                    <tr>
                        <td class="col-main">${row.cls}</td>
                        <td><span class="val-total">${row.dam + row.daf}</span><div class="gender-pill"><span class="text-m">${row.dam}M</span> / <span class="text-f">${row.daf}F</span></div></td>
                        <td><span class="val-total">${row.dtm + row.dtf}</span><div class="gender-pill"><span class="text-m">${row.dtm}M</span> / <span class="text-f">${row.dtf}F</span></div></td>
                        <td><span class="val-total">${(row.dam + row.daf) - (row.dtm + row.dtf)}</span><div class="gender-pill"><span class="text-m">${row.dam - row.dtm}M</span> / <span class="text-f">${row.daf - row.dtf}F</span></div></td>
                        <td class="total-cell"><span class="val-total">${row.dadm + row.dadf}</span><div class="gender-pill"><span class="text-m">${row.dadm}M</span> / <span class="text-f">${row.dadf}F</span></div></td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <div class="table-container">
        <div class="table-header"><h3><i class="fas fa-bed" style="color: #6366f1;"></i> Residential - Class wise</h3></div>
        <table>
            <thead>
                <tr>
                    <th>Grade</th>
                    <th>Applied</th>
                    <th>Attended</th>
                    <th>Absentees</th>
                    <th class="total-cell">Selected</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="row" items="${reportData}">
                    <tr>
                        <td class="col-main">${row.cls}</td>
                        <td><span class="val-total">${row.ram + row.raf}</span><div class="gender-pill"><span class="text-m">${row.ram}M</span> / <span class="text-f">${row.raf}F</span></div></td>
                        <td><span class="val-total">${row.rtm + row.rtf}</span><div class="gender-pill"><span class="text-m">${row.rtm}M</span> / <span class="text-f">${row.rtf}F</span></div></td>
                        <td><span class="val-total">${(row.ram + row.raf) - (row.rtm + row.rtf)}</span><div class="gender-pill"><span class="text-m">${row.ram - row.rtm}M</span> / <span class="text-f">${row.raf - row.rtf}F</span></div></td>
                        <td class="total-cell"><span class="val-total">${row.radm + row.radf}</span><div class="gender-pill"><span class="text-m">${row.radm}M</span> / <span class="text-f">${row.radf}F</span></div></td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</main>

</body>
</html>