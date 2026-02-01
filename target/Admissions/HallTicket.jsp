<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, bean.DBUtil" %>

<%
    String enquiryId = request.getParameter("enquiry_id");
    String applicationNo = request.getParameter("application_no");

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Hall Ticket</title>

<style>
    /* ===== A5 LANDSCAPE PRINT SETUP ===== */
    @page {
        size: A5 landscape;
        margin: 6mm;
    }

    body {
        font-family: 'Segoe UI', Arial, sans-serif;
        background: #f4f4f4;
        margin: 0;
        padding: 0;
    }

    .hall-ticket {
        width: 100%;
        min-height: 100%;
        background: #fff;
        border: 2px solid #000;
        padding: 12mm;
        box-sizing: border-box;
    }

    .header-section {
        text-align: center;
        border-bottom: 2px solid #000;
        padding-bottom: 6px;
        margin-bottom: 10px;
    }

    h2 {
        margin: 0;
        font-size: 20px;
        letter-spacing: 1px;
    }

    h4 {
        margin: 4px 0 0;
        font-size: 13px;
        font-weight: normal;
    }

    table {
        width: 100%;
        border-collapse: collapse;
        font-size: 13px;
        margin-top: 8px;
    }

    td {
        padding: 8px;
        border: 1px solid #000;
        vertical-align: middle;
    }

    .label {
        font-weight: bold;
        width: 35%;
        background: #f2f2f2;
    }

    .print-btn-container {
        text-align: center;
        margin-top: 12px;
    }

    .btn {
        padding: 7px 18px;
        font-size: 13px;
        background: #000;
        color: #fff;
        border: none;
        cursor: pointer;
    }

    @media print {
        body { background: #fff; }
        .print-btn-container { display: none; }
    }
</style>
</head>

<body>

<%
try {
    con = DBUtil.getConnection();

    // Logic: If Enquiry ID is provided, use it. If not, fallback to Application No.
    String sql = "SELECT * FROM admission_enquiry WHERE enquiry_id = ? OR (application_no = ? AND application_no IS NOT NULL AND application_no != '')";

    ps = con.prepareStatement(sql);

    // Sanitize and set Enquiry ID
    if (enquiryId != null && !enquiryId.trim().isEmpty()) {
        ps.setInt(1, Integer.parseInt(enquiryId.replaceAll("[^0-9]", "")));
    } else {
        ps.setNull(1, Types.INTEGER);
    }

    // Set Application No
    if (applicationNo != null && !applicationNo.trim().isEmpty()) {
        ps.setString(2, applicationNo);
    } else {
        ps.setNull(2, Types.VARCHAR);
    }

    rs = ps.executeQuery();

    if (rs.next()) {
        // Handle empty application number display logic
        String displayAppNo = rs.getString("application_no");
        if (displayAppNo == null) displayAppNo = ""; 
%>

<div class="hall-ticket">

    <div class="header-section">
        <h2>SANDUR RESIDENTIAL SCHOOL</h2>
        <h4>ADMISSION ENTRANCE EXAM – HALL TICKET</h4>
    </div>

    <table>
        <tr>
            <td class="label">Application No</td>
            <td><%= displayAppNo %></td>
        </tr>
        <tr>
            <td class="label">Enquiry ID</td>
            <td>E26-<%= rs.getInt("enquiry_id") %></td>
        </tr>
        <tr>
            <td class="label">Student Name</td>
            <td><strong><%= rs.getString("student_name") %></strong></td>
        </tr>
        <tr>
            <td class="label">Gender</td>
            <td><%= rs.getString("gender") %></td>
        </tr>
        <tr>
            <td class="label">Date of Birth</td>
            <td><%= rs.getDate("date_of_birth") %></td>
        </tr>
        <tr>
            <td class="label">Class of Admission</td>
            <td><%= rs.getString("class_of_admission") %></td>
        </tr>
        <tr>
            <td class="label">Admission Type</td>
            <td><%= rs.getString("admission_type") %></td>
        </tr>
        <tr>
            <td class="label">Father Name</td>
            <td><%= rs.getString("father_name") %></td>
        </tr>
    </table>

    <div class="print-btn-container">
        <button class="btn" onclick="window.print()">🖨 Print</button>
    </div>

</div>

<%
    } else {
%>
    <p style="text-align:center;color:red;font-weight:bold;margin-top:50px;">
        No record found. Please check your Enquiry ID.
    </p>
<%
    }
} catch (Exception e) {
    out.println("<pre>Error: " + e.getMessage() + "</pre>");
} finally {
    if (rs != null) rs.close();
    if (ps != null) ps.close();
    if (con != null) con.close();
}
%>

</body>
</html>